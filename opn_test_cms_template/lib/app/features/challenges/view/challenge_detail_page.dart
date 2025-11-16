import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:opn_test_guardia_civil_cms/app/config/widgets/buttons/modern_icon_button.dart';
import 'package:opn_test_guardia_civil_cms/bootstrap.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../questions/cubit/cubit.dart';
import '../../questions/repository/repository.dart';
import '../../questions/view/components/question_card.dart';
import '../../topics/cubit/cubit.dart';
import '../../topics/cubit/state.dart' as topic_state;
import '../../topics/model/topic_level.dart';
import '../../topics/model/topic_type_model.dart';
import '../cubit/cubit.dart';
import '../cubit/state.dart';
import '../model/challenge_model.dart';

/// Página de detalle de impugnación.
///
/// Muestra una vista dividida con:
/// - Panel izquierdo: Gestión de la impugnación
/// - Panel derecho: Detalles de la pregunta impugnada
class ChallengeDetailPage extends StatefulWidget {
  final int challengeId;

  const ChallengeDetailPage({
    super.key,
    required this.challengeId,
  });

  static const String route = '/challenges/detail';

  /// Crea la página con todos los providers necesarios
  static Widget create(int challengeId) {
    return BlocProvider<QuestionCubit>(
      create: (context) => QuestionCubit(
        GetIt.I.get<QuestionRepository>(),
        context.read<AuthCubit>(),
      ),
      child: ChallengeDetailPage(challengeId: challengeId),
    );
  }

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage>
    with SingleTickerProviderStateMixin {
  final controller = ResizableController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  final _reviewCommentsController = TextEditingController();
  late final ChallengeCubit _challengeCubit;
  Timer? _debounceTimer; // Timer para auto-guardado con debounce
  bool _hasLocalChanges = false; // Flag para cambios locales pendientes

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Cargar el challenge específico si no está seleccionado
    _challengeCubit = context.read<ChallengeCubit>();
    final challengeState = _challengeCubit.state;

    Challenge? challenge;

    if (challengeState.selectedChallenge?.id != widget.challengeId) {
      // Buscar en la lista de challenges
      challenge = challengeState.challenges.firstWhere(
        (c) => c.id == widget.challengeId,
        orElse: () => Challenge(
          questionId: 0,
          reason: '',
          state: ChallengeStatus.pending,
        ),
      );
      _challengeCubit.selectChallenge(challenge);
    } else {
      challenge = challengeState.selectedChallenge;
    }

    // Cargar el reply actual del challenge en el TextField
    if (challenge != null && challenge.reply.isNotEmpty) {
      _reviewCommentsController.text = challenge.reply;
    }

    // Cargar la pregunta y sus opciones usando el QuestionCubit
    if (challenge != null && challenge.questionId != 0) {
      final questionCubit = context.read<QuestionCubit>();

      // Establecer el topicId en el estado si está disponible
      // Esto es importante para que las imágenes se suban en la ubicación correcta
      if (challenge.topicId != null) {
        questionCubit.setSelectedTopicId(challenge.topicId!);
      }

      // Cargar la pregunta específica
      // Primero verificamos si ya está en el estado
      final existingQuestion = questionCubit.state.questions
          .where((q) => q.id == challenge!.questionId)
          .firstOrNull;

      if (existingQuestion == null) {
        // Si no está, la cargamos
        questionCubit.fetchQuestions().then((_) {
          // Después de cargar las preguntas, cargar las opciones de esta pregunta
          if (challenge!.questionId != null) {
            questionCubit.fetchQuestionOptions(challenge.questionId!);
          }
        });
      } else {
        // Si ya está, solo cargamos sus opciones
        if (challenge.questionId != null) {
          questionCubit.fetchQuestionOptions(challenge.questionId!);
        }
      }

      // Seleccionar la pregunta
      if (challenge.questionId != null) {
        questionCubit.selectQuestion(challenge.questionId!);
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _animationController.dispose();
    controller.dispose();
    _reviewCommentsController.dispose();
    super.dispose();
  }

  /// Debounced update - guarda después de 500ms de inactividad
  void _scheduleUpdate() {
    _hasLocalChanges = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_hasLocalChanges) {
        _updateReply();
      }
    });
  }

  /// Actualiza el reply en el cubit
  void _updateReply() {
    final currentText = _reviewCommentsController.text;
    final currentChallenge = _challengeCubit.state.selectedChallenge;

    // Solo actualizar si el texto realmente ha cambiado comparado con el challenge actual
    if (currentChallenge != null && currentText != currentChallenge.reply) {
      _challengeCubit
          .updateChallenge(currentChallenge.copyWith(reply: currentText));
      _hasLocalChanges = false; // Reset flag después de guardar
    }
  }

  void togglePanel() {
    final currentSizes = controller.ratios;
    if (currentSizes.length < 2) return;

    final currentRightRatio = currentSizes[1];

    // Si el panel derecho está cerrado, abrirlo; si está abierto, cerrarlo
    final isOpen = currentRightRatio > 0.1;
    if (isOpen) {
      _closeRightPanel();
    } else {
      _openRightPanel();
    }
  }

  void _openRightPanel() {
    final currentSizes = controller.ratios;
    if (currentSizes.length < 2) return;

    final currentLeftRatio = currentSizes[0];
    final currentRightRatio = currentSizes[1];

    if (currentRightRatio >= 0.1) return;

    const targetLeftRatio = 0.5;
    const targetRightRatio = 0.5;

    late VoidCallback animationListener;

    animationListener = () {
      final progress = _animation.value;
      final newLeftRatio =
          currentLeftRatio + (targetLeftRatio - currentLeftRatio) * progress;
      final newRightRatio =
          currentRightRatio + (targetRightRatio - currentRightRatio) * progress;

      controller.setSizes([
        ResizableSize.ratio(newLeftRatio),
        ResizableSize.ratio(newRightRatio),
      ]);
    };

    _animation.addListener(animationListener);

    _animationController.forward().then((_) {
      _animation.removeListener(animationListener);
      _animationController.reset();
    });
  }

  void _closeRightPanel() {
    final currentSizes = controller.ratios;
    if (currentSizes.length < 2) return;

    final currentLeftRatio = currentSizes[0];
    final currentRightRatio = currentSizes[1];

    if (currentRightRatio <= 0.01) return;

    const targetLeftRatio = 1.0;
    const targetRightRatio = 0.0;

    late VoidCallback animationListener;

    animationListener = () {
      final progress = _animation.value;
      final newLeftRatio =
          currentLeftRatio + (targetLeftRatio - currentLeftRatio) * progress;
      final newRightRatio =
          currentRightRatio + (targetRightRatio - currentRightRatio) * progress;

      controller.setSizes([
        ResizableSize.ratio(newLeftRatio),
        ResizableSize.ratio(newRightRatio),
      ]);
    };

    _animation.addListener(animationListener);

    _animationController.forward().then((_) {
      _animation.removeListener(animationListener);
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ChallengeCubit, ChallengeState>(
          builder: (context, state) {
            final challenge = state.selectedChallenge;
            return Text(
              challenge != null
                  ? 'Impugnación #${challenge.id}'
                  : 'Impugnación',
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ModernIconButton(
              icon: Icons.info_outline,
              tooltip: 'Ver/Ocultar detalles de la pregunta',
              onPressed: togglePanel,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<ChallengeCubit, ChallengeState>(
        builder: (context, state) {
          final challenge = state.selectedChallenge;

          if (challenge == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Impugnación no encontrada',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // _buildHeader(context, challenge),
              Expanded(
                child: ResizableContainer(
                  controller: controller,
                  direction: Axis.horizontal,
                  children: [
                    ResizableChild(
                      child: _buildChallengeManagementPanel(
                          context, challenge, state),
                      divider: const ResizableDivider(
                        color: Colors.grey,
                        thickness: 0.5,
                        padding: 2,
                      ),
                    ),
                    ResizableChild(
                      size: const ResizableSize.ratio(0.5),
                      child: _buildQuestionCardPanel(context, challenge),
                      divider: const ResizableDivider(
                        color: Colors.grey,
                        thickness: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Challenge challenge) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.error.withOpacity(0.1),
                  colorScheme.error.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.error.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.flag,
              color: colorScheme.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Detalles de Impugnación',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusChip(context, challenge.state),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pregunta #${challenge.questionId}${challenge.questionText != null ? ' - ${challenge.questionText}' : ''}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ChallengeStatus state) {
    return Chip(
      label: Text(state.label),
      backgroundColor: state.color.withOpacity(0.2),
      labelStyle: TextStyle(
        color: state.color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  /// Indicador de estado de guardado
  Widget _buildSavingIndicator() {
    return BlocBuilder<ChallengeCubit, ChallengeState>(
      builder: (context, state) {
        final isLoading = state.updateStatus.isLoading;

        if (isLoading) {
          return const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 4),
              Text(
                'Guardando...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }

        if (_hasLocalChanges) {
          return const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.circle,
                size: 8,
                color: Colors.orange,
              ),
              SizedBox(width: 4),
              Text(
                'Guardando...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }

        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 12,
              color: Colors.green,
            ),
            SizedBox(width: 4),
            Text(
              'Guardado',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChallengeManagementPanel(
    BuildContext context,
    Challenge challenge,
    ChallengeState state,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cubit = context.read<ChallengeCubit>();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del panel
            Text(
              'Gestión de Impugnación',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Información básica
            _buildInfoSection(
              context,
              title: 'Información',
              children: [
                _buildInfoRow('ID', challenge.id?.toString() ?? '-'),
                _buildInfoRow('Pregunta ID', challenge.questionId.toString()),
                if (challenge.topicName != null)
                  _buildInfoRow('Topic', challenge.topicName!),
                _buildInfoRow('Estado', challenge.state.label),
                _buildInfoRow(
                  'Creado',
                  challenge.createdAt != null
                      ? dateFormat.format(challenge.createdAt!)
                      : '-',
                ),
                _buildInfoRow('Días antiguedad', '${challenge.daysOld} días'),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Razón de la impugnación
            _buildInfoSection(
              context,
              title: 'Razón de la Impugnación',
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    challenge.reason ?? '',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Información del usuario
            _buildInfoSection(
              context,
              title: 'Creado por',
              children: [
                _buildInfoRow(
                  'Nombre',
                  challenge.userName ?? challenge.userEmail ?? '-',
                ),
                if (challenge.userEmail != null)
                  _buildInfoRow('Email', challenge.userEmail!),
              ],
            ),

            // Si ya fue revisado
            if (challenge.editorName != null || challenge.reply.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              _buildInfoSection(
                context,
                title: 'Revisado por',
                children: [
                  if (challenge.editorName != null)
                    _buildInfoRow('Revisor', challenge.editorName!),
                  if (challenge.reply.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Comentarios de revisión:',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        challenge.reply,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ],

            // Acciones
            if (challenge.isPending) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              _buildInfoSection(
                context,
                title: 'Acciones',
                children: [
                  // Label con indicador de guardado
                  Row(
                    children: [
                      Text(
                        'Comentarios de revisión',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildSavingIndicator(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Comentarios de revisión
                  TextField(
                    controller: _reviewCommentsController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tus comentarios aquí...',
                      border: OutlineInputBorder(),
                      helperText:
                          'Opcional para aprobar, recomendado para rechazar',
                    ),
                    maxLines: 5,
                    onChanged: (_) => _scheduleUpdate(),
                  ),
                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: state.statusChangeStatus.isLoading
                              ? null
                              : () =>
                                  _approveChallenge(context, challenge, cubit),
                          icon: state.statusChangeStatus.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle),
                          label: const Text('Aprobar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: state.statusChangeStatus.isLoading
                              ? null
                              : () =>
                                  _rejectChallenge(context, challenge, cubit),
                          icon: state.statusChangeStatus.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.cancel),
                          label: const Text('Rechazar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],

            // Opciones adicionales
            if (cubit.isAdmin) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _deleteChallenge(context, challenge, cubit),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCardPanel(BuildContext context, Challenge challenge) {
    return BlocBuilder<TopicCubit, topic_state.TopicState>(
      builder: (context, topicState) {
        // Buscar el topic de la pregunta usando el topicId del challenge
        final topic = challenge.topicId != null
            ? topicState.topics
                .where((t) => t.id == challenge.topicId)
                .firstOrNull
            : null;

        // Obtener el TopicType del topic
        TopicType topicType;
        if (topic != null) {
          topicType = topicState.topicTypes
                  .where((tt) => tt.id == topic.topicTypeId)
                  .firstOrNull ??
              TopicType.empty.copyWith(level: TopicLevel.Study);
        } else {
          // Si no se encuentra el topic, usar un TopicType por defecto
          topicType = TopicType.empty.copyWith(level: TopicLevel.Study);
        }

        return QuestionCard(
          topicType: topicType,
          onClose: _closeRightPanel,
        );
      },
    );
  }

  void _approveChallenge(
    BuildContext context,
    Challenge challenge,
    ChallengeCubit cubit,
  ) {
    final comments = _reviewCommentsController.text.trim();

    cubit.approveChallenge(
      challenge.id!,
      reviewComments: comments.isEmpty ? null : comments,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impugnación aprobada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectChallenge(
    BuildContext context,
    Challenge challenge,
    ChallengeCubit cubit,
  ) {
    final comments = _reviewCommentsController.text.trim();

    if (comments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se recomienda agregar comentarios al rechazar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    cubit.rejectChallenge(
      challenge.id!,
      reviewComments: comments,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Impugnación rechazada'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _deleteChallenge(
    BuildContext context,
    Challenge challenge,
    ChallengeCubit cubit,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Impugnación'),
        content: const Text(
          '¿Estás seguro de eliminar esta impugnación? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              cubit.deleteChallenge(challenge.id!);
              Navigator.pop(dialogContext);
              Navigator.pop(context); // Volver a la lista
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../config/widgets/buttons/modern_icon_button.dart';
import '../../questions/cubit/cubit.dart';
import '../../questions/repository/repository.dart';
import '../../questions/view/components/question_card.dart';
import '../../topics/cubit/cubit.dart';
import '../../topics/cubit/state.dart';
import '../../topics/model/topic_level.dart';
import '../../topics/model/topic_type_model.dart';
import '../cubit/cubit.dart';
import '../model/challenge_model.dart';
import '../cubit/state.dart' as challenge_state;

/// Página para gestionar múltiples impugnaciones de una pregunta de forma masiva.
///
/// Permite:
/// - Ver todas las impugnaciones de una pregunta específica
/// - Responder a todas las impugnaciones pendientes con un mensaje común
/// - Aprobar o rechazar todas las impugnaciones pendientes en masa
class ChallengesAggregatedPage extends StatefulWidget {
  const ChallengesAggregatedPage({
    super.key,
    required this.questionId,
  });

  static const String route = '/challenges/aggregated';

  final int questionId;

  /// Crea la página con todos los providers necesarios
  static Widget create(int questionId) {
    return BlocProvider<QuestionCubit>(
      create: (context) => QuestionCubit(
        GetIt.I.get<QuestionRepository>(),
        context.read<AuthCubit>(),
      ),
      child: ChallengesAggregatedPage(questionId: questionId),
    );
  }

  @override
  State<ChallengesAggregatedPage> createState() =>
      _ChallengesAggregatedPageState();
}

class _ChallengesAggregatedPageState extends State<ChallengesAggregatedPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Challenge> _challenges = [];
  final TextEditingController _globalResponseController =
      TextEditingController();
  bool _isProcessing = false;

  // Variables para el panel resizable
  final controller = ResizableController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Variables para autoguardado
  Timer? _debounceTimer;
  bool _hasLocalChanges = false;

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

    _fetchData();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _animationController.dispose();
    controller.dispose();
    _globalResponseController.dispose();
    super.dispose();
  }

  /// Debounced update - guarda después de 500ms de inactividad
  void _scheduleUpdate() {
    _hasLocalChanges = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_hasLocalChanges) {
        _updateGlobalReply();
      }
    });
  }

  /// Actualiza el reply en todas las impugnaciones de esta pregunta
  void _updateGlobalReply() async {
    final currentText = _globalResponseController.text;

    // Actualizar el reply de todos los challenges de esta pregunta
    final updatedChallenges = <Challenge>[];
    for (final challenge in _challenges) {
      if (challenge.id != null && currentText != challenge.reply) {
        final updated = challenge.copyWith(reply: currentText);
        await context.read<ChallengeCubit>().updateChallenge(updated);
        updatedChallenges.add(updated);
      } else {
        updatedChallenges.add(challenge);
      }
    }

    setState(() {
      _challenges = updatedChallenges;
      _hasLocalChanges = false;
    });
  }

  /// Actualiza el reply inmediatamente (cancela el debounce)
  void _updateGlobalReplyImmediately() {
    _debounceTimer?.cancel();
    _updateGlobalReply();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final challenges = await context
          .read<ChallengeCubit>()
          .fetchChallengesByQuestionId(widget.questionId);

      if (challenges.isEmpty && mounted) {
        // No hay impugnaciones, volver atrás
        context.pop();
        return;
      }

      setState(() {
        _challenges = challenges;
        _isLoading = false;
      });

      // Cargar el reply común si existe (del primer challenge que tenga reply)
      final firstChallengeWithReply =
          challenges.where((c) => c.reply.isNotEmpty).firstOrNull;
      if (firstChallengeWithReply != null) {
        _globalResponseController.text = firstChallengeWithReply.reply;
      }

      // Cargar la pregunta y sus opciones usando el QuestionCubit
      if (mounted) {
        final questionCubit = context.read<QuestionCubit>();

        // Obtener el topicId del primer challenge (todas las impugnaciones son de la misma pregunta)
        final topicId =
            _challenges.isNotEmpty ? _challenges.first.topicId : null;

        // Establecer el topicId en el estado si está disponible
        // Esto es importante para que las imágenes se suban en la ubicación correcta
        if (topicId != null) {
          questionCubit.setSelectedTopicId(topicId);
        }

        // Primero verificamos si ya está en el estado
        final existingQuestion = questionCubit.state.questions
            .where((q) => q.id == widget.questionId)
            .firstOrNull;

        if (existingQuestion == null) {
          // Si no está, la cargamos
          await questionCubit.fetchQuestions();
        }

        // Cargar las opciones de esta pregunta
        await questionCubit.fetchQuestionOptions(widget.questionId);

        // Seleccionar la pregunta
        questionCubit.selectQuestion(widget.questionId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar impugnaciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
        context.pop();
      }
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión Masiva de Impugnaciones'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ModernIconButton(
              icon: Icons.info_outline,
              tooltip: 'Ver/Ocultar detalles de la pregunta',
              onPressed: togglePanel,
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: ModernIconButton(
              icon: Icons.refresh,
              tooltip: 'Actualizar',
              onPressed: _fetchData,
            ),
          ),
        ],
      ),
      body: ResizableContainer(
        controller: controller,
        direction: Axis.horizontal,
        children: [
          ResizableChild(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header con información general
                  _buildHeaderInfo(),
                  const SizedBox(height: 16),

                  // Lista de impugnaciones
                  Expanded(
                    flex: 3,
                    child: _buildChallengesList(),
                  ),

                  const SizedBox(height: 16),

                  // Campo de respuesta global
                  Expanded(
                    flex: 2,
                    child: _buildGlobalResponseSection(),
                  ),

                  const SizedBox(height: 16),

                  // Botones de acción masiva
                  _buildMassActionButtons(),
                ],
              ),
            ),
            divider: const ResizableDivider(
              color: Colors.grey,
              thickness: 0.5,
              padding: 2,
            ),
          ),
          ResizableChild(
            size: const ResizableSize.ratio(0.5),
            child: _buildQuestionCardPanel(),
            divider: const ResizableDivider(
              color: Colors.grey,
              thickness: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final pendingCount = _challenges.where((c) => c.state.isPending).length;
    final acceptedCount = _challenges.where((c) => c.state.isApproved).length;
    final rejectedCount = _challenges.where((c) => c.state.isRejected).length;

    // Obtener información de la pregunta del primer challenge
    final questionText = _challenges.isNotEmpty
        ? _challenges.first.questionText ?? 'Pregunta no disponible'
        : 'Pregunta no disponible';
    final topicName = _challenges.isNotEmpty
        ? _challenges.first.topicName ?? 'Sin tema'
        : 'Sin tema';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topic badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              topicName,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Question text
          Text(
            questionText,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesList() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.list, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Lista de Impugnaciones (${_challenges.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: _challenges.length,
              separatorBuilder: (context, index) => const SizedBox(height: 1),
              itemBuilder: (context, index) {
                final challenge = _challenges[index];
                return _buildExpandableChallengeCard(challenge);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableChallengeCard(Challenge challenge) {
    final colorScheme = Theme.of(context).colorScheme;
    Color statusColor;
    IconData statusIcon;

    switch (challenge.state) {
      case ChallengeStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case ChallengeStatus.approved:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case ChallengeStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    final reason = challenge.reason ?? 'Sin razón especificada';
    final isLongReason = reason.length > 100;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: CircleAvatar(
          radius: 12,
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, size: 14, color: statusColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                challenge.userName ??
                    challenge.userEmail ??
                    'Usuario desconocido',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                challenge.state.label,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            reason,
            maxLines: isLongReason ? 2 : null,
            overflow: isLongReason ? TextOverflow.ellipsis : null,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
        trailing: isLongReason
            ? Icon(Icons.expand_more,
                color: colorScheme.onSurfaceVariant, size: 20)
            : null,
        children: [
          _buildExpandedChallengeContent(challenge),
        ],
      ),
    );
  }

  Widget _buildExpandedChallengeContent(Challenge challenge) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Razón completa
          if (challenge.reason != null && challenge.reason!.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.report_outlined,
                    size: 16, color: Colors.orange[600]),
                const SizedBox(width: 6),
                Text(
                  'Razón completa:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                challenge.reason!,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Información del usuario
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: Colors.blue[600]),
              const SizedBox(width: 6),
              Text(
                'Usuario:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (challenge.userName != null)
                  Text('Nombre: ${challenge.userName}',
                      style: const TextStyle(fontSize: 12)),
                if (challenge.userEmail != null)
                  Text('Email: ${challenge.userEmail}',
                      style: const TextStyle(fontSize: 12)),
                if (challenge.academyName != null)
                  Text('Academia: ${challenge.academyName}',
                      style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Respuesta anterior si existe
          if (challenge.reply.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.reply_outlined, size: 16, color: Colors.green[600]),
                const SizedBox(width: 6),
                Text(
                  'Respuesta anterior:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                challenge.reply,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Información adicional
          Row(
            children: [
              Icon(Icons.info_outline,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                'Información adicional:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${challenge.id}',
                    style: const TextStyle(fontSize: 11)),
                if (challenge.createdAt != null)
                  Text(
                    'Fecha: ${challenge.createdAt!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 11),
                  ),
                Text('Antigüedad: ${challenge.daysOld} días',
                    style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Indicador de estado de guardado
  Widget _buildSavingIndicator() {
    return BlocBuilder<ChallengeCubit, challenge_state.ChallengeState>(
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

  Widget _buildGlobalResponseSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.reply_all, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Respuesta General para Todas las Impugnaciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              _buildSavingIndicator(),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _globalResponseController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText:
                    'Escribe una respuesta que se aplicará a todas las impugnaciones pendientes...\n\nEsta respuesta se enviará a todas las impugnaciones pendientes de esta pregunta.',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(12),
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
              ),
              onChanged: (_) => _scheduleUpdate(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMassActionButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    final pendingChallenges =
        _challenges.where((c) => c.state.isPending).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Masivas (${pendingChallenges.length} pendientes)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing || pendingChallenges.isEmpty
                      ? null
                      : () => _handleMassAction(
                            ChallengeStatus.approved,
                            pendingChallenges,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text('Aceptar Todas (${pendingChallenges.length})'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isProcessing || pendingChallenges.isEmpty
                      ? null
                      : () => _handleMassAction(
                            ChallengeStatus.rejected,
                            pendingChallenges,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.cancel),
                  label: Text('Rechazar Todas (${pendingChallenges.length})'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCardPanel() {
    return BlocBuilder<TopicCubit, TopicState>(
      builder: (context, topicState) {
        // Buscar el topic de la pregunta usando el topicId del primer challenge
        final topic =
            _challenges.isNotEmpty && _challenges.first.topicId != null
                ? topicState.topics
                    .where((t) => t.id == _challenges.first.topicId)
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

  Future<void> _handleMassAction(
    ChallengeStatus action,
    List<Challenge> targetChallenges,
  ) async {
    if (_globalResponseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Por favor, proporciona una respuesta antes de continuar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirmar acción
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          action.isApproved
              ? 'Confirmar Aprobación Masiva'
              : 'Confirmar Rechazo Masivo',
        ),
        content: Text(
          '¿Estás seguro de que quieres ${action.isApproved ? "aprobar" : "rechazar"} ${targetChallenges.length} impugnaciones?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action.isApproved ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      final challengeIds = targetChallenges.map((c) => c.id!).toList();

      await context.read<ChallengeCubit>().handleMassAction(
            challengeIds: challengeIds,
            status: action,
            reviewComments: _globalResponseController.text.trim(),
          );

      // Refrescar la lista
      await _fetchData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${targetChallenges.length} impugnaciones ${action.isApproved ? "aprobadas" : "rechazadas"} correctamente',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Si ya no quedan impugnaciones pendientes, volver atrás
        if (_challenges.where((c) => c.state.isPending).isEmpty) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar las impugnaciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

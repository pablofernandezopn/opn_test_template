import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:get_it/get_it.dart';
import 'package:opn_test_guardia_civil_cms/app/features/questions/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/questions/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/questions/model/question_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/questions/model/question_option_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/questions/repository/repository.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_type_model.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../config/widgets/table/reorderable_table.dart';
import '../../topics/cubit/state.dart';
import '../../topics/model/topic_level.dart';
import '../../topics/model/topic_model.dart';
import 'components/question_card.dart';
import 'components/question_header.dart';

class QuestionsManagementScreen extends StatefulWidget {
  final int topicId;

  const QuestionsManagementScreen({
    super.key,
    required this.topicId,
  });

  static Widget create(int topicId) {
    return BlocProvider<QuestionCubit>(
      create: (context) => QuestionCubit(
        GetIt.I.get<QuestionRepository>(),
        context.read<AuthCubit>(),
      ),
      child: QuestionsManagementScreen(topicId: topicId),
    );
  }

  @override
  State<QuestionsManagementScreen> createState() =>
      _QuestionsManagementScreenState();
}

class _QuestionsManagementScreenState extends State<QuestionsManagementScreen>
    with SingleTickerProviderStateMixin {
  final controller = ResizableController();

  final Set<Question> _selectedQuestions = {};

  late AnimationController _animationController;
  late Animation<double> _animation;

  final ValueNotifier<bool> _isResizingNotifier = ValueNotifier(false);
  DateTime _lastRebuild = DateTime.now();
  static const _rebuildThreshold = Duration(milliseconds: 16);
  late Topic currentTopic;
  late TopicType currentTopicType;

  // ScrollController para scroll infinito
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTopicData();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    controller.addListener(_onResizeChange);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(QuestionsManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia el topicId, recargar los datos del nuevo topic
    if (oldWidget.topicId != widget.topicId) {
      _loadTopicData();
    }
  }

  /// Carga los datos del topic necesarios para esta página
  ///
  /// WEB-READY: Si los topics no están cargados (por ejemplo, después de un refresh),
  /// los carga automáticamente antes de buscar el topic específico.
  Future<void> _loadTopicData() async {
    final topicCubit = context.read<TopicCubit>();

    // Si no hay topics cargados, cargarlos primero (importante para web refresh)
    if (topicCubit.state.topics.isEmpty) {
      await topicCubit.fetchTopics();
    }

    // Buscar el topic actual
    currentTopic = topicCubit.state.topics.firstWhere(
      (topic) => topic.id == widget.topicId,
      orElse: () => Topic.empty,
    );

    // Buscar el topicType correspondiente
    currentTopicType = topicCubit.state.topicTypes.firstWhere(
      (type) => type.id == currentTopic.topicTypeId,
      orElse: () => TopicType(
        id: 0,
        topicTypeName: 'Desconocido',
        defaultNumberOptions: 4,
        description: '',
        penalty: 0.5,
        level: TopicLevel.Unknown,
        orderOfAppearance: 0,
        createdAt: null,
      ),
    );

    // Determinar si usar paginación basado en el tipo de topic
    // Solo usar paginación para topics de nivel Study
    final usePagination = currentTopicType.level == TopicLevel.Study;

    // Seleccionar el topic en QuestionCubit para cargar sus preguntas
    if (mounted) {
      context.read<QuestionCubit>().selectTopic(
            widget.topicId,
            usePagination: usePagination,
          );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    _isResizingNotifier.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Listener del scroll para detectar cuando llega al final
  void _onScroll() {
    // Solo aplicar scroll infinito si el topic type es Study
    if (currentTopicType.level != TopicLevel.Study) {
      return;
    }

    // Detectar si llegamos cerca del final (90% del scroll)
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      final threshold = maxScroll * 0.9;

      if (currentScroll >= threshold) {
        // Cargar más preguntas
        context.read<QuestionCubit>().loadMoreQuestions();
      }
    }
  }

  void restoreRatio() {
    final currentSizes = controller.ratios;
    if (currentSizes.length < 2) return;

    final currentLeftRatio = currentSizes[0];
    final currentRightRatio = currentSizes[1];

    // ✅ Verificar si ya está en la posición deseada
    if (currentRightRatio >= 0.1) return;

    const targetLeftRatio = 0.5;
    const targetRightRatio = 0.5;

    // ✅ Usar una variable para controlar el listener
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

  void closePanel() {
    final currentSizes = controller.ratios;
    if (currentSizes.length < 2) return;

    final currentLeftRatio = currentSizes[0];
    final currentRightRatio = currentSizes[1];

    // ✅ Verificar si ya está cerrado
    if (currentRightRatio <= 0.01) return;

    const targetLeftRatio = 1.0;
    const targetRightRatio = 0.0;

    // ✅ Usar una variable para controlar el listener
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

  void _onResizeChange() {
    final now = DateTime.now();
    if (now.difference(_lastRebuild) < _rebuildThreshold) return;

    _lastRebuild = now;
    _isResizingNotifier.value = true;

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _isResizingNotifier.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TopicCubit, TopicState>(
        builder: (context, topicState) {
          // Mostrar loading si los topics están cargando (importante para web refresh)
          if (topicState.fetchTopicsStatus.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando datos...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          // Una vez cargados, mostrar la interfaz normal
          return Column(
            children: [
              // Header del topic
              Builder(
                builder: (context) {
                  // Buscar el topic actualizado en el estado
                  final updatedTopic = topicState.topics.firstWhere(
                    (t) => t.id == widget.topicId,
                    orElse: () => currentTopic,
                  );

                  return QuestionHeader(
                    currentTopic: updatedTopic,
                    currentTopicType: currentTopicType,
                  );
                },
              ),
              Expanded(
                child: BlocListener<QuestionCubit, QuestionState>(
                  listenWhen: (previous, current) =>
                      previous.createQuestionStatus !=
                          current.createQuestionStatus ||
                      previous.updateQuestionStatus !=
                          current.updateQuestionStatus ||
                      previous.deleteQuestionStatus !=
                          current.deleteQuestionStatus ||
                      previous.createQuestionOptionStatus !=
                          current.createQuestionOptionStatus ||
                      previous.updateQuestionOptionStatus !=
                          current.updateQuestionOptionStatus ||
                      previous.deleteQuestionOptionStatus !=
                          current.deleteQuestionOptionStatus ||
                      previous.generateRetroAudioStatus !=
                          current.generateRetroAudioStatus,
                  listener: (context, state) {
                    // Manejar mensajes de snackbar para operaciones
                    if (state.createQuestionStatus.isError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(state.createQuestionStatus.message)),
                      );
                    }

                    // Manejar mensajes de generación de retroaudio en batch
                    if (state.generateRetroAudioStatus.isDone) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Row(
                      //       children: [
                      //         const Icon(Icons.check_circle,
                      //             color: Colors.white),
                      //         const SizedBox(width: 12),
                      //         Expanded(
                      //           child: Text(
                      //               state.generateRetroAudioStatus.message),
                      //         ),
                      //       ],
                      //     ),
                      //     backgroundColor: Colors.green,
                      //     duration: const Duration(seconds: 4),
                      //   ),
                      // );
                    } else if (state.generateRetroAudioStatus.isError) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Row(
                      //       children: [
                      //         const Icon(Icons.error, color: Colors.white),
                      //         const SizedBox(width: 12),
                      //         Expanded(
                      //           child: Text(
                      //               state.generateRetroAudioStatus.message),
                      //         ),
                      //       ],
                      //     ),
                      //     backgroundColor: Colors.red,
                      //     duration: const Duration(seconds: 4),
                      //   ),
                      // );
                    }
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: RepaintBoundary(
                          child: ResizableContainer(
                            controller: controller,
                            direction: Axis.horizontal,
                            children: [
                              ResizableChild(
                                child: RepaintBoundary(
                                  child: _buildQuestionsTable(),
                                ),
                                divider: const ResizableDivider(
                                  color: Colors.grey,
                                  thickness: 0.5,
                                  padding: 2,
                                ),
                              ),
                              ResizableChild(
                                size: const ResizableSize.ratio(0),
                                child: RepaintBoundary(
                                  child: QuestionCard(
                                    onClose: closePanel,
                                    topicType: currentTopicType,
                                  ),
                                ),
                                divider: const ResizableDivider(
                                  color: Colors.grey,
                                  thickness: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ); // Cierra el Column
        },
      ), // Cierra el BlocBuilder<TopicCubit>
      // Barra flotante de acciones múltiples
      // if (_selectedQuestions.isNotEmpty)
      //   Positioned(
      //     left: 0,
      //     right: 0,
      //     bottom: 0,
      //     child: _buildMultipleSelectionBar(),
      //   ),
    );
  }

  Widget _buildQuestionsTable() {
    return BlocBuilder<QuestionCubit, QuestionState>(
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Expanded(
                  child: ReorderableTable<Question>(
                    items: state.questions,
                    columns: _buildColumns(),
                    scrollController: currentTopicType.level == TopicLevel.Study
                        ? _scrollController
                        : null,
                    onReorder: (oldIndex, newIndex) {
                      // Ajustar el índice si se mueve hacia abajo
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      context
                          .read<QuestionCubit>()
                          .reorderQuestions(oldIndex, newIndex);
                    },
                    selectedItem: state.selectedQuestionId != null
                        ? state.questions
                            .where((q) => q.id == state.selectedQuestionId)
                            .firstOrNull
                        : null,
                    showCheckboxes: true,
                    selectedItems: _selectedQuestions,
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedQuestions.clear();
                        _selectedQuestions.addAll(newSelection);
                      });
                    },
                    onItemTap: (question) {
                      context
                          .read<QuestionCubit>()
                          .selectQuestion(question.id!);
                      restoreRatio(); // Abrir el panel derecho con animación
                    },
                    rowActions: (question) => [
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: Colors.red),
                        onPressed: () => _deleteQuestion(question.id!),
                        tooltip: 'Eliminar',
                      ),
                    ],
                    showDragHandle: true,
                    isLoading: state.fetchQuestionsStatus.isLoading,
                    emptyMessage: 'No hay preguntas disponibles',
                  ),
                ),
                // Indicador de carga para scroll infinito
                if (currentTopicType.level == TopicLevel.Study &&
                    state.isLoadingMore)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Cargando más preguntas...',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                // Mensaje cuando no hay más preguntas
                if (currentTopicType.level == TopicLevel.Study &&
                    !state.hasMore &&
                    state.questions.isNotEmpty &&
                    !state.isLoadingMore)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No hay más preguntas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ReorderableTableColumnConfig<Question>> _buildColumns() {
    return [
      ReorderableTableColumnConfig(
        id: 'order',
        label: '#',
        flex: 1,
        alignment: Alignment.center,
        sortable: false,
        valueGetter: (question) {
          final index =
              context.read<QuestionCubit>().state.questions.indexOf(question);
          return (index + 1).toString();
        },
        cellBuilder: (question) {
          final currentIndex =
              context.read<QuestionCubit>().state.questions.indexOf(question);
          return Text(
            '${currentIndex + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          );
        },
      ),
      if (currentTopicType.level == TopicLevel.Flashcard) ...[
        ...List.generate(
          currentTopic.options, // Máximo de opciones que mostraremos
          (index) => ReorderableTableColumnConfig(
            id: 'option_${index + 1}',
            label:
                'Cara ${String.fromCharCode('A'.codeUnitAt(0) + index)}', // Genera 'a', 'b', 'c', 'd'...
            flex: 1,
            alignment: Alignment.center,
            valueGetter: (question) =>
                '', // Requerido pero no usado cuando hay cellBuilder
            cellBuilder: (question) =>
                _buildAnswerStatusFlashcard(question, index),
          ),
        ),
      ],
      if (currentTopicType.level != TopicLevel.Flashcard) ...[
        ReorderableTableColumnConfig(
          id: 'question',
          label: 'Pregunta',
          flex: 2,
          valueGetter: (question) {
            final text =
                question.question.isEmpty ? 'Sin pregunta' : question.question;
            return text.length > 80 ? '${text.substring(0, 80)}...' : text;
          },
        ),
      ],
      if (currentTopicType.level != TopicLevel.Flashcard) ...[
        // Columnas dinámicas para las opciones de respuesta
        ...List.generate(
          currentTopic.options, // Máximo de opciones que mostraremos
          (index) => ReorderableTableColumnConfig(
            id: 'option_${index + 1}',
            label: String.fromCharCode(
                'A'.codeUnitAt(0) + index), // Genera 'a', 'b', 'c', 'd'...
            flex: 1,
            alignment: Alignment.center,
            valueGetter: (question) =>
                '', // Requerido pero no usado cuando hay cellBuilder
            cellBuilder: (question) =>
                _buildAnswerStatusButton(question, index),
          ),
        ),
      ],
      if (currentTopicType.level == TopicLevel.Study) ...[
        ReorderableTableColumnConfig(
          id: 'published',
          label: 'Publicado',
          flex: 1,
          valueGetter: (question) => question.published ? 'Sí' : 'No',
        ),
      ],
    ];
  }

  Widget _buildAnswerStatusFlashcard(Question question, int optionIndex) {
    return BlocBuilder<QuestionCubit, QuestionState>(
      buildWhen: (previous, current) =>
          previous.questionOptions != current.questionOptions,
      builder: (context, state) {
        // Buscar las opciones de esta pregunta
        final options = state.questionOptions
            .where((opt) => opt.questionId == question.id)
            .toList()
          ..sort((a, b) => a.optionOrder.compareTo(b.optionOrder));

        // Si no hay suficientes opciones, mostrar placeholder
        if (optionIndex >= options.length) {
          return Align(
            alignment: Alignment.center,
            child: Text(
              '-',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.5),
              ),
            ),
          );
        }

        final option = options[optionIndex];
        final isCorrect = option.isCorrect;

        return Align(
          alignment: Alignment.center,
          child: Text(
            option.answer.length > 50
                ? '${option.answer.substring(0, 50)}...'
                : option.answer,
          ),
        );
      },
    );
  }

  Widget _buildAnswerStatusButton(Question question, int optionIndex) {
    return BlocBuilder<QuestionCubit, QuestionState>(
      buildWhen: (previous, current) =>
          previous.questionOptions != current.questionOptions,
      builder: (context, state) {
        // Buscar las opciones de esta pregunta
        final options = state.questionOptions
            .where((opt) => opt.questionId == question.id)
            .toList()
          ..sort((a, b) => a.optionOrder.compareTo(b.optionOrder));

        // Si no hay suficientes opciones, mostrar placeholder
        if (optionIndex >= options.length) {
          return Align(
            alignment: Alignment.center,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove,
                size: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.5),
              ),
            ),
          );
        }

        final option = options[optionIndex];
        final isCorrect = option.isCorrect;

        return Align(
          alignment: Alignment.center,
          child: Tooltip(
            message: isCorrect
                ? 'Respuesta correcta'
                : 'Respuesta incorrecta - Click para marcar como correcta',
            child: InkWell(
              onTap: () => _toggleAnswerCorrectness(option),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color:
                      isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  size: 14,
                  color:
                      isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleAnswerCorrectness(QuestionOption option) async {
    final cubit = context.read<QuestionCubit>();

    // Si ya es correcta, no hacer nada (debe haber al menos una correcta)
    if (option.isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe haber al menos una respuesta correcta'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Marcar esta opción como correcta y las demás como incorrectas
    final allOptions = cubit.state.questionOptions
        .where((opt) => opt.questionId == option.questionId)
        .toList();

    for (final opt in allOptions) {
      if (opt.id == option.id) {
        // Marcar esta como correcta
        await cubit.updateQuestionOption(
          opt.id!,
          opt.copyWith(isCorrect: true),
        );
      } else if (opt.isCorrect) {
        // Desmarcar las que eran correctas
        await cubit.updateQuestionOption(
          opt.id!,
          opt.copyWith(isCorrect: false),
        );
      }
    }
  }

  void _deleteQuestion(int id) {
    context.read<QuestionCubit>().deleteQuestion(id);
  }

  Future<void> _generateRetroAudioForSelected() async {
    if (_selectedQuestions.isEmpty) return;

    // Filtrar preguntas que tienen retroAudioText
    final questionsWithText = _selectedQuestions
        .where((q) => q.retroAudioText.trim().isNotEmpty)
        .toList();

    if (questionsWithText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Ninguna de las preguntas seleccionadas tiene texto de retroalimentación configurado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar confirmación con información detallada
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar Retroaudio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Se generará audio para ${questionsWithText.length} de ${_selectedQuestions.length} preguntas seleccionadas.',
            ),
            const SizedBox(height: 8),
            if (questionsWithText.length != _selectedQuestions.length)
              Text(
                '${_selectedQuestions.length - questionsWithText.length} pregunta(s) no tienen texto de retroalimentación.',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Este proceso puede tardar varios minutos.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Generar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Generar retroaudio en batch
    await context
        .read<QuestionCubit>()
        .generateRetroAudioBatch(questionsWithText);

    // Limpiar la selección
    if (mounted) {
      setState(() {
        _selectedQuestions.clear();
      });
    }
  }

  Future<void> _deleteSelectedQuestions() async {
    if (_selectedQuestions.isEmpty) return;

    final selectedCount = _selectedQuestions.length;

    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar $selectedCount pregunta${selectedCount > 1 ? 's' : ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final cubit = context.read<QuestionCubit>();

    // Eliminar todas las preguntas seleccionadas
    for (final question in _selectedQuestions) {
      if (question.id != null) {
        await cubit.deleteQuestion(question.id!);
      }
    }

    // Limpiar la selección
    if (mounted) {
      setState(() {
        _selectedQuestions.clear();
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Preguntas eliminadas correctamente'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

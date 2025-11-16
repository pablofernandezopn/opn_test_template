import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/config/theme/color_scheme_extensions.dart';
import '../../cubit/cubit.dart';
import '../../cubit/state.dart';
import '../../model/question_model.dart';

class ValidationBarWidget extends StatelessWidget {
  const ValidationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestionCubit, QuestionState>(
      builder: (context, state) {
        final validationItems = _getValidationItems(state);
        final totalChecks = validationItems.length;
        final passedChecks =
            validationItems.where((item) => item.isValid).length;
        final percentage = totalChecks > 0 ? (passedChecks / totalChecks) : 0.0;

        return InkWell(
          onTap: () => _showValidationDialog(context, state),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: percentage == 1.0
                  ? Theme.of(context).colorScheme.completedBackground
                  : Theme.of(context).colorScheme.notCompletedBackground,
              borderRadius: BorderRadius.circular(8),
              // border: Border.all(
              //   color: percentage == 1.0 ? Colors.green : Colors.orange,
              //   width: 2,
              // ),
            ),
            child: Icon(
              Icons.error_outline,
              color: percentage == 1.0
                  ? Theme.of(context).colorScheme.completed
                  : Theme.of(context).colorScheme.notCompleted,
              size: 24,
            ),
          ),
        );
      },
    );
  }

  void _showValidationDialog(BuildContext context, QuestionState state) {
    final validationItems = _getValidationItems(state);
    final totalChecks = validationItems.length;
    final passedChecks = validationItems.where((item) => item.isValid).length;
    final percentage = totalChecks > 0 ? (passedChecks / totalChecks) : 0.0;

    final questionCubit = context.read<QuestionCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider<QuestionCubit>.value(
        value: questionCubit,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SizedBox(
              width: 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header minimalista
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Icono y título
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (percentage == 1.0
                                        ? Theme.of(context)
                                            .colorScheme
                                            .completed
                                        : Theme.of(context)
                                            .colorScheme
                                            .notCompleted)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.checklist_rounded,
                                color: percentage == 1.0
                                    ? Theme.of(context).colorScheme.completed
                                    : Theme.of(context)
                                        .colorScheme
                                        .notCompleted,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Validación',
                                    style: Theme.of(dialogContext)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$passedChecks de $totalChecks completados',
                                    style: Theme.of(dialogContext)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Progress bar minimalista
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .progressBarBackground,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percentage,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: percentage == 1.0
                                      ? Theme.of(context).colorScheme.completed
                                      : Theme.of(context)
                                          .colorScheme
                                          .notCompleted,
                                  // gradient: LinearGradient(
                                  //   colors: percentage == 1.0
                                  //       ? [
                                  //           Colors.green.shade400,
                                  //           Colors.green.shade600
                                  //         ]
                                  //       : [
                                  //           Colors.orange.shade400,
                                  //           Colors.orange.shade600
                                  //         ],
                                  // ),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (percentage == 1.0
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .completed
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .notCompleted)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Divider sutil
                  Container(
                    height: 1,
                    color: Colors.grey.shade100,
                  ),
                  // Lista de validaciones
                  Container(
                    constraints: const BoxConstraints(maxHeight: 420),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: validationItems.length,
                      itemBuilder: (context, index) {
                        final item = validationItems[index];
                        return _buildValidationItem(dialogContext, item, state);
                      },
                    ),
                  ),
                  // Footer con botón
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cerrar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidationItem(
    BuildContext context,
    ValidationItem item,
    QuestionState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item.isValid
                ? Theme.of(context).colorScheme.success.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.isValid ? Icons.check_rounded : Icons.close_rounded,
            color: item.isValid
                ? Theme.of(context).colorScheme.success
                : Theme.of(context).colorScheme.error,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
        ),
        trailing: !item.isValid && item.invalidQuestions.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${item.invalidQuestions.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (builderContext) {
                      return IconButton(
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          // color: Colors.grey.shade700,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.of(builderContext).pop();
                          _showInvalidQuestions(builderContext, item);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.grey.shade100.withValues(alpha: 0.5),
                          padding: const EdgeInsets.all(8),
                        ),
                      );
                    },
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _showInvalidQuestions(BuildContext context, ValidationItem item) {
    final questionCubit = context.read<QuestionCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider<QuestionCubit>.value(
        value: questionCubit,
        child: _InvalidQuestionsDialog(item: item),
      ),
    );
  }

  List<ValidationItem> _getValidationItems(QuestionState state) {
    return [
      ValidationItem(
        title: 'Todas las preguntas tienen solución válida',
        isValid: _allQuestionsHaveCorrectOption(state),
        invalidQuestions: _getQuestionsWithoutCorrectOption(state),
        getDetailText: (question) {
          final options = state.questionOptions
              .where((opt) => opt.questionId == question.id)
              .toList();
          final correctCount = options.where((opt) => opt.isCorrect).length;
          return 'Opciones correctas: $correctCount';
        },
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen texto',
        isValid: _allQuestionsHaveText(state),
        invalidQuestions:
            state.questions.where((q) => q.question.trim().isEmpty).toList(),
        getDetailText: (question) => 'Texto de pregunta vacío',
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen suficientes opciones',
        isValid: _allQuestionsHaveEnoughOptions(state),
        invalidQuestions: _getQuestionsWithInsufficientOptions(state),
        getDetailText: (question) {
          final options = state.questionOptions
              .where((opt) => opt.questionId == question.id)
              .length;
          return 'Opciones: $options (mínimo 3)';
        },
      ),
      ValidationItem(
        title: 'Todas las opciones tienen texto válido',
        isValid: _allOptionsHaveValidText(state),
        invalidQuestions: _getQuestionsWithInvalidOptions(state),
        getDetailText: (question) {
          final invalidOptions = state.questionOptions
              .where((opt) => opt.questionId == question.id && !opt.isValid)
              .length;
          return 'Opciones inválidas: $invalidOptions';
        },
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen tip',
        isValid: _allQuestionsHaveTip(state),
        invalidQuestions: state.questions
            .where((q) => q.tip == null || q.tip!.trim().isEmpty)
            .toList(),
        getDetailText: (question) => 'Tip vacío',
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen audio de retroalimentación',
        isValid: _allQuestionsHaveAudio(state),
        invalidQuestions: state.questions
            .where((q) => q.retroAudioUrl.trim().isEmpty)
            .toList(),
        getDetailText: (question) {
          if (!question.retroAudioEnable) {
            return 'Audio deshabilitado';
          }
          return 'Texto de audio vacío';
        },
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen texto para el retro audio',
        isValid: _allQuestionsHaveAudioText(state),
        invalidQuestions: _getQuestionsWithoutAudioText(state),
        getDetailText: (question) {
          final options = state.questionOptions
              .where((opt) => opt.questionId == question.id)
              .toList();
          final correctCount = options.where((opt) => opt.isCorrect).length;
          return 'Opciones correctas: $correctCount';
        },
      ),
      ValidationItem(
        title: 'Todas las preguntas tienen artículo de referencia',
        isValid: _allQuestionsHaveArticle(state),
        invalidQuestions: state.questions
            .where((q) => q.article == null || q.article!.trim().isEmpty)
            .toList(),
        getDetailText: (question) => 'Sin artículo de referencia',
      ),
    ];
  }

  bool _allQuestionsHaveAudioText(QuestionState state) {
    return state.questions.every(
        (q) => !q.retroAudioEnable && (q.retroAudioText.trim().isNotEmpty));
  }

  List<Question> _getQuestionsWithoutAudioText(QuestionState state) {
    return state.questions
        .where((q) => q.retroAudioText.trim().isEmpty)
        .toList();
  }

  bool _allQuestionsHaveCorrectOption(QuestionState state) {
    return state.questions.every((question) {
      final options = state.questionOptions
          .where((opt) => opt.questionId == question.id)
          .toList();
      return options.any((opt) => opt.isCorrect);
    });
  }

  List<Question> _getQuestionsWithoutCorrectOption(QuestionState state) {
    return state.questions.where((question) {
      final options = state.questionOptions
          .where((opt) => opt.questionId == question.id)
          .toList();
      return !options.any((opt) => opt.isCorrect);
    }).toList();
  }

  bool _allQuestionsHaveText(QuestionState state) {
    return state.questions.every((q) => q.question.trim().isNotEmpty);
  }

  bool _allQuestionsHaveEnoughOptions(QuestionState state) {
    return state.questions.every((question) {
      final options = state.questionOptions
          .where((opt) => opt.questionId == question.id)
          .length;
      return options >= 3;
    });
  }

  List<Question> _getQuestionsWithInsufficientOptions(QuestionState state) {
    return state.questions.where((question) {
      final options = state.questionOptions
          .where((opt) => opt.questionId == question.id)
          .length;
      return options < 3;
    }).toList();
  }

  bool _allOptionsHaveValidText(QuestionState state) {
    return state.questionOptions.every((opt) => opt.isValid);
  }

  List<Question> _getQuestionsWithInvalidOptions(QuestionState state) {
    final invalidQuestionIds = state.questionOptions
        .where((opt) => !opt.isValid)
        .map((opt) => opt.questionId)
        .toSet();

    return state.questions
        .where((q) => invalidQuestionIds.contains(q.id))
        .toList();
  }

  bool _allQuestionsHaveTip(QuestionState state) {
    return state.questions
        .every((q) => q.tip != null && q.tip!.trim().isNotEmpty);
  }

  bool _allQuestionsHaveAudio(QuestionState state) {
    return state.questions
        .every((q) => q.retroAudioEnable && q.retroAudioText.trim().isNotEmpty);
  }

  bool _allQuestionsHaveArticle(QuestionState state) {
    return state.questions
        .every((q) => q.article != null && q.article!.trim().isNotEmpty);
  }
}

class ValidationItem {
  final String title;
  final bool isValid;
  final List<Question> invalidQuestions;
  final String Function(Question) getDetailText;

  ValidationItem({
    required this.title,
    required this.isValid,
    required this.invalidQuestions,
    required this.getDetailText,
  });
}

class _InvalidQuestionsDialog extends StatefulWidget {
  final ValidationItem item;

  const _InvalidQuestionsDialog({required this.item});

  @override
  State<_InvalidQuestionsDialog> createState() =>
      _InvalidQuestionsDialogState();
}

class _InvalidQuestionsDialogState extends State<_InvalidQuestionsDialog> {
  bool _isGenerating = false;

  bool get _isAudioValidation =>
      widget.item.title.contains('audio de retroalimentación');

  Future<void> _generateAllRetroAudios() async {
    setState(() {
      _isGenerating = true;
    });

    final cubit = context.read<QuestionCubit>();

    try {
      await cubit.generateRetroAudioBatch(widget.item.invalidQuestions);

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Retroaudios generados para ${widget.item.invalidQuestions.length} preguntas',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar retroaudios: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SizedBox(
          width: 550,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .error
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            color: Theme.of(context).colorScheme.error,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preguntas con errores',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.item.invalidQuestions.length} preguntas necesitan atención',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_isGenerating) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const LinearProgressIndicator(
                              backgroundColor: Colors.white,
                              // valueColor:
                              //     AlwaysStoppedAnimation<Color>(Colors.blue),
                              minHeight: 6,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Generando ${widget.item.invalidQuestions.length} retroaudios...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Por favor espera, esto puede tomar algunos minutos',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Lista de preguntas
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.item.invalidQuestions.length,
                  itemBuilder: (context, index) {
                    final question = widget.item.invalidQuestions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerLowest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${question.order}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            question.question.isNotEmpty
                                ? (question.question.length > 60
                                    ? '${question.question.substring(0, 60)}...'
                                    : question.question)
                                : 'Pregunta vacía',
                            style: TextStyle(
                              color: question.question.isEmpty
                                  ? Colors.red.shade600
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.item.getDetailText(question),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          trailing: _isGenerating
                              ? null
                              : IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.grey.shade700,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    context
                                        .read<QuestionCubit>()
                                        .selectQuestion(question.id!);
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    if (_isAudioValidation && !_isGenerating)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _generateAllRetroAudios,
                          icon: const Icon(Icons.audiotrack, size: 18),
                          label: const Text('Generar Todos'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (_isAudioValidation && !_isGenerating)
                      const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: _isGenerating
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cerrar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

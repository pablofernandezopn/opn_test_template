import 'package:flutter/material.dart';

import '../../model/question_model.dart';
import '../../model/question_option_model.dart';

class QuestionIndexPage extends StatefulWidget {
  const QuestionIndexPage({
    super.key,
    required this.questions,
    required this.selectedOptions,
    required this.currentIndex,
    required this.questionOptions,
    required this.scrollController,
    this.isFlashcardMode = false,
    this.difficultyRatings = const {},
  });

  final List<Question> questions;
  final Map<int, int?> selectedOptions;
  final int currentIndex;
  final List<QuestionOption> questionOptions;
  final ScrollController scrollController;
  final bool isFlashcardMode;
  final Map<int, String> difficultyRatings;

  @override
  State<QuestionIndexPage> createState() => _QuestionIndexPageState();
}

class _QuestionIndexPageState extends State<QuestionIndexPage> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final optionsById = {
      for (final option in widget.questionOptions)
        if (option.id != null) option.id!: option,
    };

    String? optionLabelFor(int? optionId) {
      final option = optionId != null ? optionsById[optionId] : null;
      if (option == null) return null;
      final order = option.optionOrder;
      if (order <= 0) return null;
      final baseCode = 'A'.codeUnitAt(0);
      final code = baseCode + (order - 1);
      if (code > 'Z'.codeUnitAt(0)) {
        return order.toString();
      }
      return String.fromCharCode(code);
    }

    // Calcular estadísticas
    final totalQuestions = widget.questions.length;
    final answeredCount = widget.questions.where((q) {
      final key = q.id ?? widget.questions.indexOf(q);
      return widget.selectedOptions[key] != null;
    }).length;
    final progressPercentage = totalQuestions > 0 ? (answeredCount / totalQuestions) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Índice de preguntas'),
      ),
      body: Column(
        children: [
          // Resumen de progreso
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isFlashcardMode ? 'Progreso de estudio' : 'Progreso del test',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      '$answeredCount de $totalQuestions',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progressPercentage,
                    minHeight: 8,
                    backgroundColor: colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors.secondaryContainer,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.secondary, width: 1.5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isFlashcardMode ? 'Revisada' : 'Respondida',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.outline, width: 1.5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sin responder',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Grid de preguntas
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isCompact = width < 450;
                final crossAxisCount = isCompact ? 2 : 4;
                final childAspectRatio = isCompact ? 0.8 : 1.0;

                return GridView.builder(
                  key: const PageStorageKey('question_index_grid'),
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: childAspectRatio,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: widget.questions.length,
                  itemBuilder: (context, index) {
                final question = widget.questions[index];
                final key = question.id ?? index;
                final answered = widget.selectedOptions[key] != null;
                final isCurrent = index == widget.currentIndex;
                final selectedOptionId = widget.selectedOptions[key];
                final selectedLabel = optionLabelFor(selectedOptionId);

                Color background;
                Color borderColor = colors.outline;
                TextStyle? labelStyle = textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                );

                if (isCurrent) {
                  background = colors.primary.withValues(alpha: 0.15);
                  borderColor = colors.primary;
                  labelStyle = labelStyle?.copyWith(color: colors.primary);
                } else if (answered) {
                  background = colors.secondaryContainer.withValues(alpha: 0.7);
                  borderColor = colors.secondary;
                  labelStyle = labelStyle?.copyWith(color: colors.onSecondaryContainer);
                } else {
                  background = colors.surfaceContainerLowest;
                  labelStyle = labelStyle?.copyWith(color: colors.onSurface);
                }

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1.5),
                          color: background,
                        ),

                        child: Stack(
                          children: [
                            // Número de pregunta
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${index + 1}',
                                style: labelStyle,
                              ),
                            ),

                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                question.question,
                                style: labelStyle?.copyWith(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                            if (answered && !widget.isFlashcardMode && selectedLabel != null)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: colors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      selectedLabel,
                                      style: TextStyle(
                                        color: colors.onSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            if (answered && widget.isFlashcardMode)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: _DifficultyIndicator(
                                  rating: widget.difficultyRatings[key],
                                  colors: colors,
                                ),
                              ),
                            // Ícono de check si está respondida
                            if (answered)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: colors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: colors.onSecondary,
                                  ),
                                ),
                              ),
                            // Indicador de pregunta actual
                            if (isCurrent)
                              Positioned(
                                bottom: 4,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    width: 24,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyIndicator extends StatelessWidget {
  const _DifficultyIndicator({
    required this.rating,
    required this.colors,
  });

  final String? rating;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    if (rating == null) {
      return const SizedBox.shrink();
    }

    Color indicatorColor;
    IconData icon;

    switch (rating) {
      case 'again':
        indicatorColor = Colors.red;
        icon = Icons.close;
        break;
      case 'hard':
        indicatorColor = Colors.orange;
        icon = Icons.trending_down;
        break;
      case 'medium':
        indicatorColor = Colors.green;
        icon = Icons.check;
        break;
      case 'easy':
        indicatorColor = Colors.blue;
        icon = Icons.bolt;
        break;
      default:
        indicatorColor = colors.outline;
        icon = Icons.help_outline;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}

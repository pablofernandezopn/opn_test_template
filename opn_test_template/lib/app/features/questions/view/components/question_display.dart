import 'package:flutter/material.dart';
import '../../model/question_model.dart';
import '../../model/question_option_model.dart';
import 'after_finish_retro.dart';

/// Widget compartido para mostrar una pregunta con sus opciones
/// Usado tanto en TopicTestPage como en SurvivalTestPage
class QuestionDisplay extends StatelessWidget {
  const QuestionDisplay({
    super.key,
    required this.question,
    required this.options,
    required this.selectedOptionId,
    required this.onSelect,
    this.showTip = true,
    this.testFinished = false,
    this.showRetro = true,
  });

  final Question question;
  final List<QuestionOption> options;
  final int? selectedOptionId;
  final ValueChanged<int> onSelect;
  final bool showTip;
  final bool testFinished;
  final bool showRetro; // Para control de retroalimentación

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question.trim().isEmpty
                ? 'Pregunta sin enunciado'
                : question.question,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          if (question.questionImageUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                question.questionImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: colors.surfaceContainerLow,
                  alignment: Alignment.center,
                  child: Icon(Icons.image_not_supported_outlined,
                      color: colors.onSurfaceVariant),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          if (options.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No hay opciones disponibles para esta pregunta.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < options.length; i++) ...[
                  QuestionOptionTile(
                    index: i,
                    option: options[i],
                    selected: selectedOptionId == options[i].id,
                    testFinished: testFinished,
                    onTap: options[i].id == null || testFinished
                        ? null
                        : () => onSelect(options[i].id!),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          if (showRetro)
            AfterFinishRetro(
              question: question,
              visible: showTip && testFinished,
            ),
        ],
      ),
    );
  }
}

/// Widget para mostrar una opción de respuesta
class QuestionOptionTile extends StatelessWidget {
  const QuestionOptionTile({
    super.key,
    required this.index,
    required this.option,
    required this.selected,
    this.onTap,
    this.testFinished = false,
  });

  final int index;
  final QuestionOption option;
  final bool selected;
  final VoidCallback? onTap;
  final bool testFinished;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final letter = String.fromCharCode('A'.codeUnitAt(0) + index);

    // Determinar el estado de la opción cuando el test está finalizado
    Color borderColor;
    Color backgroundColor;
    Color letterBgColor;
    Color letterColor;
    IconData? resultIcon;
    Color? resultIconColor;

    final successColor = const Color(0xFF4CAF50);
    final errorColor = colors.error;

    if (testFinished) {
      // Modo corrección
      if (option.isCorrect) {
        // Opción correcta
        borderColor = successColor;
        backgroundColor = successColor.withValues(alpha: 0.1);
        letterBgColor = successColor;
        letterColor = colors.surface;
        resultIcon = Icons.check_circle;
        resultIconColor = successColor;
      } else if (selected) {
        // Opción incorrecta seleccionada
        borderColor = errorColor;
        backgroundColor = errorColor.withValues(alpha: 0.1);
        letterBgColor = errorColor;
        letterColor = colors.surface;
        resultIcon = Icons.cancel;
        resultIconColor = errorColor;
      } else {
        // Opción no seleccionada e incorrecta
        borderColor = colors.outlineVariant;
        backgroundColor = colors.surfaceContainerLowest;
        letterBgColor = Colors.transparent;
        letterColor = colors.onSurfaceVariant;
      }
    } else {
      // Modo normal (test en progreso)
      if (selected) {
        borderColor = colors.primary;
        backgroundColor = colors.primary.withValues(alpha: 0.08);
        letterBgColor = colors.primary;
        letterColor = colors.onPrimary;
      } else {
        borderColor = colors.outlineVariant;
        backgroundColor = colors.surfaceContainerLowest;
        letterBgColor = Colors.transparent;
        letterColor = colors.onSurface;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: selected || (testFinished && option.isCorrect) ? 2 : 1,
          ),
          color: backgroundColor,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: testFinished && !option.isCorrect && !selected
                      ? colors.onSurfaceVariant
                      : (testFinished && option.isCorrect)
                          ? successColor
                          : (selected && testFinished)
                              ? errorColor
                              : selected
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                ),
                color: letterBgColor,
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: textTheme.bodyMedium?.copyWith(
                  color: letterColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.answer,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ),
            if (testFinished && resultIcon != null) ...[
              const SizedBox(width: 12),
              Icon(
                resultIcon,
                color: resultIconColor,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
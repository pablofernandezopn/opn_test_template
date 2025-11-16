import 'package:flutter/material.dart';
import '../../../../config/widgets/numbers/count_up.dart';

class QuestionProgress extends StatelessWidget {
  const QuestionProgress({
    super.key,
    required this.duration,
    required this.curve,
    required this.goal,
    required this.goalWeek,
    this.color,
    this.onChangeGoal,
  });

  final Duration duration;
  final Curve curve;
  final int? goal;
  final int? goalWeek;
  final Color? color;
  final VoidCallback? onChangeGoal;

  double _percent(int value, int total) {
    if (total == 0) return 0;
    final p = value / total;
    return p > 1 ? 1 : p;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;
    final percent = _percent(goal ?? 0, goalWeek ?? 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Barra de progreso animada
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
          ),
        ),
        const SizedBox(height: 8),
        // Texto inferior
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Countup(
              end: percent * 100,
              duration: duration,
              curve: curve,
              suffix: '%',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w400),
            ),            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Countup(
                  end: (goal ?? 0).toDouble(),
                  duration: duration,
                  curve: curve,
                  suffix: '/${goalWeek ?? 0} preguntas',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                      color: effectiveColor,
                      fontWeight: FontWeight.w400),
                ),
                if (onChangeGoal != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onChangeGoal,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: effectiveColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}

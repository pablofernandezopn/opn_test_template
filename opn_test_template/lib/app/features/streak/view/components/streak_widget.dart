import 'package:flutter/material.dart';
import '../../model/streak_data_model.dart';
import '../../model/week_day_activity_model.dart';

class StreakWidget extends StatelessWidget {
  final StreakData streakData;
  final VoidCallback? onTap;

  const StreakWidget({
    super.key,
    required this.streakData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Textos pequeños con racha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '🔥',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${streakData.currentStreak} días',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ],
                ),
                if (streakData.longestStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          size: 12,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${streakData.longestStreak}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Días de la semana
            _buildWeekDays(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDays(BuildContext context) {
    if (streakData.weekActivity.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: streakData.weekActivity.map((day) {
        return _buildDayIndicator(context, day);
      }).toList(),
    );
  }

  Widget _buildDayIndicator(BuildContext context, WeekDayActivity day) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nombre del día encima
        Text(
          day.dayName,
          style: TextStyle(
            fontSize: 11,
            fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500,
            color: day.isToday
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        // Indicador visual
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getDayBackgroundColor(day, context),
            border: day.isToday
                ? Border.all(
                    color: colorScheme.primary,
                    width: 2.5,
                  )
                : day.hasActivity
                    ? Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      )
                    : null,
            boxShadow: day.hasActivity
                ? [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: day.hasActivity
                ? const Text(
                    '🔥',
                    style: TextStyle(fontSize: 18),
                  )
                : Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: day.isToday
                          ? colorScheme.primary.withValues(alpha: 0.4)
                          : colorScheme.onSurface.withValues(alpha: 0.15),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Color _getDayBackgroundColor(WeekDayActivity day, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (day.hasActivity) {
      return Colors.orange[50]!;
    }
    if (day.isToday) {
      return colorScheme.primaryContainer.withValues(alpha: 0.2);
    }
    return colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
  }
}

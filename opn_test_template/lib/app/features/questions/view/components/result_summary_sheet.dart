import 'package:flutter/material.dart';
import 'package:opn_test_template/app/features/topics/model/topic_level.dart';
import 'package:opn_test_template/app/features/topics/model/topic_type_model.dart';

enum ResultSummaryAction {
  continueReview,
  viewTips,
  exit,
}

Future<ResultSummaryAction?> showResultSummarySheet({
  required BuildContext context,
  required int correct,
  required int incorrect,
  required int blank,
  required double score,
  required double netScore,
  required double successRate,
  required double penalty,
  required bool hasTips,
  required double averageScore,
  TopicType? topicType,
  Map<String, int>? flashcardStats,
}) {
  return showModalBottomSheet<ResultSummaryAction>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).colorScheme;
      final textTheme = Theme.of(sheetContext).textTheme;
      final showAverage = topicType?.level == TopicLevel.Mock;
      final isFlashcard = topicType?.isFlashcards ?? false;
      final effectiveFlashcardStats = flashcardStats ?? const <String, int>{};

      return Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFlashcard
                        ? 'Resumen de flashcards'
                        : 'Resultado del test',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isFlashcard) ...[
                    _FlashcardSummarySection(
                      stats: effectiveFlashcardStats,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.surfaceContainerLowest,
                            border: Border.all(
                              color: colors.primary.withAlpha(32),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            score.toStringAsFixed(2),
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        if (showAverage) ...[
                          const SizedBox(width: 16),
                          Container(
                            height: 62,
                            width: 62,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.surfaceContainerLowest,
                              border: Border.all(
                                color: colors.primary.withAlpha(32),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Promedio',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: colors.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  averageScore.toStringAsFixed(2),
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colors.primary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _ResultStatTile(
                            label: 'Correctas',
                            value: correct.toString(),
                            color: const Color(0xFF4CAF50),
                            icon: Icons.check_circle_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ResultStatTile(
                            label: 'Incorrectas',
                            value: incorrect.toString(),
                            color: colors.error,
                            icon: Icons.cancel_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ResultStatTile(
                            label: 'En blanco',
                            value: blank.toString(),
                            color: colors.onSurfaceVariant,
                            icon: Icons.remove_circle_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(sheetContext)
                            .pop(ResultSummaryAction.continueReview);
                      },
                      child: const Text('Continuar revisando'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext)
                            .pop(ResultSummaryAction.exit);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: colors.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      label: const Text('Salir del test'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ResultStatTile extends StatelessWidget {
  const _ResultStatTile(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(52)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const Spacer(),
              Icon(
                icon,
                size: 12,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlashcardSummarySection extends StatelessWidget {
  const _FlashcardSummarySection({
    required this.stats,
    required this.colors,
    required this.textTheme,
  });

  final Map<String, int> stats;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final again = stats['again'] ?? 0;
    final hard = stats['hard'] ?? 0;
    final medium = stats['medium'] ?? 0;
    final easy = stats['easy'] ?? 0;
    final pending = stats['pending'] ?? 0;

    final totalReviewed = again + hard + medium + easy;
    final totalCards = totalReviewed + pending;
    final hasReviewedSomething = totalReviewed > 0;

    final tiles = _flashcardStatDefinitions.map((data) {
      final value = stats[data.key] ?? 0;
      final percent = totalCards > 0 ? value / totalCards : 0.0;
      return _FlashcardStatTile(
        data: data,
        value: value,
        percent: percent,
        textTheme: textTheme,
        colors: colors,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (totalCards > 0)
          Text(
            hasReviewedSomething
                ? 'Has repasado $totalReviewed de $totalCards tarjetas'
                : 'Aún no has valorado ninguna tarjeta',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        if (totalCards > 0) const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: tiles,
        ),
        if (pending > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$pending tarjetas pendientes de valorar',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FlashcardStatTile extends StatelessWidget {
  const _FlashcardStatTile({
    required this.data,
    required this.value,
    required this.percent,
    required this.textTheme,
    required this.colors,
  });

  final _FlashcardStatData data;
  final int value;
  final double percent;
  final TextTheme textTheme;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final percentageLabel =
        '${(percent * 100).clamp(0, 100).toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minWidth: 130),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.color.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  if (data.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      data.subtitle!,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(width: 32),
              Text(
                '$value',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: data.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlashcardStatData {
  const _FlashcardStatData({
    required this.key,
    required this.label,
    this.subtitle,
    required this.color,
    required this.icon,
  });

  final String key;
  final String label;
  final String? subtitle;
  final Color color;
  final IconData icon;
}

const List<_FlashcardStatData> _flashcardStatDefinitions = [
  _FlashcardStatData(
    key: 'again',
    label: 'Otra vez',
    subtitle: '< 1 día',
    color: Color(0xFFF44336),
    icon: Icons.refresh,
  ),
  _FlashcardStatData(
    key: 'hard',
    label: 'Difícil',
    subtitle: '1-2 días',
    color: Color(0xFFFF9800),
    icon: Icons.flag_outlined,
  ),
  _FlashcardStatData(
    key: 'medium',
    label: 'Bien',
    subtitle: '3-6 días',
    color: Color(0xFF4CAF50),
    icon: Icons.thumb_up_alt_outlined,
  ),
  _FlashcardStatData(
    key: 'easy',
    label: 'Fácil',
    subtitle: '7+ días',
    color: Color(0xFF2196F3),
    icon: Icons.emoji_emotions_outlined,
  ),
];

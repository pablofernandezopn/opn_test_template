import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../model/user_stats_model.dart';

/// Gráfica circular que muestra la distribución de posiciones en rankings
class RankingDistributionPieChart extends StatelessWidget {
  const RankingDistributionPieChart({
    super.key,
    required this.globalStats,
    required this.topicStats,
  });

  final UserStats globalStats;
  final List<TopicMockStats> topicStats;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Categorizar los topics por posición en ranking
    int top3Count = 0;
    int top10Count = 0;
    int top20Count = 0;
    int otherCount = 0;

    for (final stat in topicStats) {
      if (stat.rankPosition == null) continue;

      if (stat.rankPosition! <= 3) {
        top3Count++;
      } else if (stat.rankPosition! <= 10) {
        top10Count++;
      } else if (stat.rankPosition! <= 20) {
        top20Count++;
      } else {
        otherCount++;
      }
    }

    final total = top3Count + top10Count + top20Count + otherCount;

    if (total == 0) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.pie_chart,
                size: 48,
                color: colors.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No hay datos de ranking',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final sections = <PieChartSectionData>[];
    final legendItems = <_LegendItem>[];

    if (top3Count > 0) {
      sections.add(
        PieChartSectionData(
          value: top3Count.toDouble(),
          title: '${((top3Count / total) * 100).toStringAsFixed(0)}%',
          color: Colors.amber,
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      legendItems.add(_LegendItem(
        color: Colors.amber,
        label: 'Top 3',
        count: top3Count,
      ));
    }

    if (top10Count > 0) {
      sections.add(
        PieChartSectionData(
          value: top10Count.toDouble(),
          title: '${((top10Count / total) * 100).toStringAsFixed(0)}%',
          color: Colors.green,
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      legendItems.add(_LegendItem(
        color: Colors.green,
        label: 'Top 10',
        count: top10Count,
      ));
    }

    if (top20Count > 0) {
      sections.add(
        PieChartSectionData(
          value: top20Count.toDouble(),
          title: '${((top20Count / total) * 100).toStringAsFixed(0)}%',
          color: Colors.blue,
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      legendItems.add(_LegendItem(
        color: Colors.blue,
        label: 'Top 20',
        count: top20Count,
      ));
    }

    if (otherCount > 0) {
      sections.add(
        PieChartSectionData(
          value: otherCount.toDouble(),
          title: '${((otherCount / total) * 100).toStringAsFixed(0)}%',
          color: colors.surfaceContainerHighest,
          radius: 100,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
      );
      legendItems.add(_LegendItem(
        color: colors.surfaceContainerHighest,
        label: 'Otros',
        count: otherCount,
      ));
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Distribución de Rankings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.3,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        pieTouchData: PieTouchData(
                          enabled: true,
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: legendItems,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatColumn(
                    label: 'Total Tests',
                    value: '$total',
                    color: colors.primary,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: colors.outline.withOpacity(0.3),
                  ),
                  _StatColumn(
                    label: 'Mejor Pos.',
                    value: globalStats.bestRankPosition != null
                        ? '#${globalStats.bestRankPosition}'
                        : 'N/A',
                    color: colors.secondary,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: colors.outline.withOpacity(0.3),
                  ),
                  _StatColumn(
                    label: 'Veces Top 3',
                    value: '${globalStats.top3Count}',
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label ($count)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
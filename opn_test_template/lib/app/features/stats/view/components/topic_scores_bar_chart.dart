import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../model/user_stats_model.dart';

/// Gráfica de barras que muestra las puntuaciones por topic
class TopicScoresBarChart extends StatelessWidget {
  const TopicScoresBarChart({
    super.key,
    required this.topicStats,
    this.maxTopics = 10,
  });

  final List<TopicMockStats> topicStats;
  final int maxTopics;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Ordenar por mejor puntuación y tomar los primeros N
    final sortedStats = List<TopicMockStats>.from(topicStats)
      ..sort((a, b) => b.bestScore.compareTo(a.bestScore));

    final displayStats = sortedStats.take(maxTopics).toList();

    if (displayStats.isEmpty) {
      return Center(
        child: Text(
          'No hay datos suficientes',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
        ),
      );
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
                Icon(Icons.bar_chart, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Top ${displayStats.length} Mejores Puntuaciones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => colors.surfaceContainerHighest,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final stat = displayStats[groupIndex];
                        return BarTooltipItem(
                          '${stat.topicName}\n',
                          TextStyle(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: 'Primera: ${stat.firstScore.toStringAsFixed(1)}%\n',
                              style: TextStyle(
                                color: colors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: 'Mejor: ${stat.bestScore.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= displayStats.length) {
                            return const SizedBox.shrink();
                          }
                          final name = displayStats[value.toInt()].topicName;
                          // Truncar nombres largos
                          final displayName = name.length > 15
                              ? '${name.substring(0, 15)}...'
                              : name;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              displayName,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        reservedSize: 50,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          );
                        },
                        reservedSize: 40,
                        interval: 20,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colors.outlineVariant.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: colors.outline, width: 1),
                      bottom: BorderSide(color: colors.outline, width: 1),
                    ),
                  ),
                  barGroups: displayStats.asMap().entries.map((entry) {
                    final index = entry.key;
                    final stat = entry.value;

                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: stat.firstScore,
                          color: colors.secondary.withOpacity(0.7),
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: stat.bestScore,
                          color: colors.primary,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Leyenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(
                  color: colors.secondary.withOpacity(0.7),
                  label: 'Primera puntuación',
                ),
                const SizedBox(width: 20),
                _LegendItem(
                  color: colors.primary,
                  label: 'Mejor puntuación',
                ),
              ],
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
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
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
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
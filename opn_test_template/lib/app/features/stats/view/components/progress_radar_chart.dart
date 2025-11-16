import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../model/user_stats_model.dart';

/// Gráfica radial/radar que muestra el progreso en diferentes dimensiones
class ProgressRadarChart extends StatelessWidget {
  const ProgressRadarChart({
    super.key,
    required this.topicStats,
    this.maxCategories = 6,
  });

  final List<TopicMockStats> topicStats;
  final int maxCategories;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (topicStats.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.radar,
                size: 48,
                color: colors.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No hay datos de progreso',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Tomar los primeros N topics con más intentos
    final sortedStats = List<TopicMockStats>.from(topicStats)
      ..sort((a, b) => b.attempts.compareTo(a.attempts));

    final displayStats = sortedStats.take(maxCategories).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.radar, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Progreso por Tema',
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
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  tickCount: 5,
                  ticksTextStyle: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  radarBorderData: BorderSide(
                    color: colors.outline.withOpacity(0.3),
                    width: 1,
                  ),
                  gridBorderData: BorderSide(
                    color: colors.outlineVariant.withOpacity(0.3),
                    width: 1,
                  ),
                  titlePositionPercentageOffset: 0.15,
                  getTitle: (index, angle) {
                    if (index >= displayStats.length) return const RadarChartTitle(text: '');

                    final stat = displayStats[index];
                    final name = stat.topicName.length > 12
                        ? '${stat.topicName.substring(0, 12)}...'
                        : stat.topicName;

                    return RadarChartTitle(
                      text: name,
                      angle: angle,
                    );
                  },
                  titleTextStyle: TextStyle(
                    color: colors.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  dataSets: [
                    // Primera puntuación
                    RadarDataSet(
                      fillColor: colors.secondary.withOpacity(0.15),
                      borderColor: colors.secondary,
                      borderWidth: 2,
                      entryRadius: 3,
                      dataEntries: displayStats.map((stat) {
                        return RadarEntry(value: stat.firstScore);
                      }).toList(),
                    ),
                    // Mejor puntuación
                    RadarDataSet(
                      fillColor: colors.primary.withOpacity(0.2),
                      borderColor: colors.primary,
                      borderWidth: 2,
                      entryRadius: 3,
                      dataEntries: displayStats.map((stat) {
                        return RadarEntry(value: stat.bestScore);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Leyenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(
                  color: colors.secondary,
                  label: 'Primera puntuación',
                ),
                const SizedBox(width: 20),
                _LegendItem(
                  color: colors.primary,
                  label: 'Mejor puntuación',
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lista de mejoras
            ...displayStats.map((stat) {
              final improvement = stat.bestScore - stat.firstScore;
              final hasImproved = improvement > 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      hasImproved ? Icons.trending_up : Icons.trending_flat,
                      size: 16,
                      color: hasImproved ? Colors.green : colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stat.topicName,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      hasImproved
                          ? '+${improvement.toStringAsFixed(1)}%'
                          : '${improvement.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: hasImproved ? Colors.green : colors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              );
            }),
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
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 2),
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
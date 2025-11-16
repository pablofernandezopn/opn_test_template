import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../model/user_stats_model.dart';

/// Gráfica de línea que muestra la evolución de puntuaciones por topic dentro de un topic_type
class TopicTypeEvolutionChart extends StatelessWidget {
  const TopicTypeEvolutionChart({
    super.key,
    required this.data,
  });

  final TopicTypeEvolutionData data;

  // Paleta de colores para las líneas
  static const List<Color> lineColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEF4444), // Red
    Color(0xFF14B8A6), // Teal
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ordenar topics por fecha
    final sortedTopics = List<TopicEvolutionLine>.from(data.topics)
      ..sort((a, b) => a.firstAttemptDate.compareTo(b.firstAttemptDate));

    // Encontrar rango de valores
    final scores = sortedTopics.map((t) => t.firstScore).toList();
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final maxScore = scores.reduce((a, b) => a > b ? a : b);

    // Ajustar el rango del eje Y
    final double minY = (minScore - 10).clamp(0, 100);
    final double maxY = (maxScore + 10).clamp(0, 100);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.topicTypeName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${data.topics.length} test${data.topics.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => colors.surfaceContainerHighest,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final topic = sortedTopics[spot.x.toInt()];
                          final date = topic.firstAttemptDate;
                          final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

                          return LineTooltipItem(
                            '$dateStr\n',
                            TextStyle(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            children: [
                              TextSpan(
                                text: '${topic.topicName}\n',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: '${topic.firstScore.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: lineColors[spot.spotIndex % lineColors.length],
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (topic.rankPosition != null)
                                TextSpan(
                                  text: '\nRanking: #${topic.rankPosition}',
                                  style: TextStyle(
                                    color: colors.secondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (sortedTopics.length / 4).ceilToDouble().clamp(1, double.infinity),
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedTopics.length) {
                            return const SizedBox.shrink();
                          }
                          final date = sortedTopics[value.toInt()].firstAttemptDate;
                          final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              dateStr,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: sortedTopics.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.firstScore,
                        );
                      }).toList(),
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: colors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          // Alternar colores para mejor visualización
                          final color = lineColors[index % lineColors.length];
                          return FlDotCirclePainter(
                            radius: 5,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: colors.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colors.primary.withOpacity(0.15),
                            colors.primary.withOpacity(0.02),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Estadísticas rápidas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Promedio',
                    value: '${(scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(1)}%',
                    icon: Icons.trending_up,
                    color: colors.secondary,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: colors.outline.withOpacity(0.3),
                  ),
                  _StatItem(
                    label: 'Mejor',
                    value: '${maxScore.toStringAsFixed(1)}%',
                    icon: Icons.star,
                    color: colors.tertiary,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: colors.outline.withOpacity(0.3),
                  ),
                  _StatItem(
                    label: 'Tests',
                    value: '${data.topics.length}',
                    icon: Icons.quiz,
                    color: colors.primary,
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
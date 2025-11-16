import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../model/user_stats_model.dart';

/// Gráfica de línea que muestra la evolución temporal de las puntuaciones
class EvolutionLineChart extends StatelessWidget {
  const EvolutionLineChart({
    super.key,
    required this.evolutionData,
    this.days = 30,
  });

  final List<StatsDataPoint> evolutionData;
  final int days;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (evolutionData.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.show_chart,
                size: 48,
                color: colors.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No hay datos de evolución',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Ordenar por fecha
    final sortedData = List<StatsDataPoint>.from(evolutionData)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Encontrar rango de valores
    final scores = sortedData.map((d) => d.score).toList();
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final maxScore = scores.reduce((a, b) => a > b ? a : b);

    // Ajustar el rango del eje Y para mejor visualización
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
                Icon(Icons.trending_up, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Evolución de Puntuaciones',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  'Últimos $days días',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
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
                          final dataPoint = sortedData[spot.x.toInt()];
                          final date = dataPoint.date;
                          final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
                          return LineTooltipItem(
                            '$dateStr\n',
                            TextStyle(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: '${dataPoint.score.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (dataPoint.topicName != null)
                                TextSpan(
                                  text: '\n${dataPoint.topicName}',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
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
                        interval: (sortedData.length / 5).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= sortedData.length) {
                            return const SizedBox.shrink();
                          }
                          final date = sortedData[value.toInt()].date;
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
                      spots: sortedData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.score,
                        );
                      }).toList(),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: colors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: colors.primary,
                            strokeWidth: 2,
                            strokeColor: colors.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colors.primary.withOpacity(0.1),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colors.primary.withOpacity(0.2),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Promedio',
                  value: '${(scores.reduce((a, b) => a + b) / scores.length).toStringAsFixed(1)}%',
                  color: colors.secondary,
                ),
                _StatItem(
                  label: 'Mínimo',
                  value: '${minScore.toStringAsFixed(1)}%',
                  color: colors.error,
                ),
                _StatItem(
                  label: 'Máximo',
                  value: '${maxScore.toStringAsFixed(1)}%',
                  color: colors.tertiary,
                ),
              ],
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
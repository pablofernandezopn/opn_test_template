import 'package:flutter/material.dart';
import '../../../history/model/user_test_model.dart';

/// Estadísticas globales para FinalTestPage
///
/// Muestra la suma y el promedio de las puntuaciones de todas las partes
class FinalTestStats extends StatelessWidget {
  const FinalTestStats({
    super.key,
    required this.userTests,
  });

  final List<UserTest> userTests;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Calcular estadísticas
    final totalCorrect = userTests.fold<int>(0, (sum, test) => sum + test.rightQuestions);
    final totalIncorrect = userTests.fold<int>(0, (sum, test) => sum + test.wrongQuestions);
    final totalBlank = userTests.fold<int>(
      0,
      (sum, test) => sum + (test.questionCount - test.totalAnswered),
    );
    final totalQuestions = userTests.fold<int>(0, (sum, test) => sum + test.questionCount);

    // Suma de puntuaciones
    final totalScore = userTests.fold<double>(
      0,
      (sum, test) => sum + (test.score ?? 0),
    );

    // Promedio de puntuaciones
    final averageScore = userTests.isNotEmpty
        ? userTests.fold<double>(0, (sum, test) => sum + (test.score ?? 0)) / userTests.length
        : 0.0;

    return Card(
      elevation: 0,
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultado Global',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 20),

            // Métricas en grid
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Suma Total',
                    value: totalScore.toStringAsFixed(2),
                    subtitle: 'puntos',
                    icon: Icons.add_circle_outline,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    label: 'Promedio',
                    value: averageScore.toStringAsFixed(2),
                    subtitle: 'puntos',
                    icon: Icons.trending_up,
                    color: colors.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Desglose de respuestas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total de preguntas: $totalQuestions',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickStat(
                        label: 'Correctas',
                        value: '$totalCorrect',
                        color: const Color(0xFF4CAF50),
                      ),
                      _QuickStat(
                        label: 'Incorrectas',
                        value: '$totalIncorrect',
                        color: colors.error,
                      ),
                      _QuickStat(
                        label: 'En blanco',
                        value: '$totalBlank',
                        color: colors.onSurfaceVariant,
                      ),
                    ],
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: color.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
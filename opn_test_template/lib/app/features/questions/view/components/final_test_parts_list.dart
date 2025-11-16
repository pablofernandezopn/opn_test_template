import 'package:flutter/material.dart';
import '../../../history/model/user_test_model.dart';
import '../../../topics/model/topic_model.dart';

/// Lista de partes con resultados individuales para FinalTestPage
///
/// Muestra cada parte con su puntuación y métricas
class FinalTestPartsList extends StatelessWidget {
  const FinalTestPartsList({
    super.key,
    required this.userTests,
    required this.topics,
  });

  final List<UserTest> userTests;
  final List<Topic> topics;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partes del Examen',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Lista de partes
        ...List.generate(
          userTests.length,
          (index) {
            final test = userTests[index];
            final topic = topics.length > index ? topics[index] : null;
            return _PartCard(
              partNumber: index + 1,
              userTest: test,
              topic: topic,
            );
          },
        ),
      ],
    );
  }
}

class _PartCard extends StatelessWidget {
  const _PartCard({
    required this.partNumber,
    required this.userTest,
    this.topic,
  });

  final int partNumber;
  final UserTest userTest;
  final Topic? topic;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final score = userTest.score ?? 0.0;
    final correctRate = userTest.totalAnswered > 0
        ? (userTest.rightQuestions / userTest.totalAnswered) * 100
        : 0.0;

    return Card(
      elevation: 0,
      color: colors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Número de parte y nombre del topic
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$partNumber',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic?.topicName ?? 'Parte $partNumber',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        '${userTest.questionCount} preguntas',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Métricas
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PartMetric(
                    label: 'Puntuación',
                    value: score.toStringAsFixed(2),
                    color: colors.primary,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: colors.outlineVariant,
                  ),
                  _PartMetric(
                    label: 'Aciertos',
                    value: '${correctRate.toStringAsFixed(1)}%',
                    color: const Color(0xFF4CAF50),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: colors.outlineVariant,
                  ),
                  _PartMetric(
                    label: 'Correctas',
                    value: '${userTest.rightQuestions}/${userTest.totalAnswered}',
                    color: colors.tertiary,
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

class _PartMetric extends StatelessWidget {
  const _PartMetric({
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
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
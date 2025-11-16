import 'package:flutter/material.dart';

class RankingPosition extends StatelessWidget {
  final int? opnIndex;
  final int? globalRank;

  const RankingPosition({
    super.key,
    this.opnIndex,
    this.globalRank,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Si no hay datos disponibles
    if (opnIndex == null || globalRank == null) {
      return Container(
        width: 132,
        height: 112,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.onPrimaryContainer.withAlpha(55),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'Sin datos de ranking',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer.withAlpha(150),
          ),
        ),
      );
    }

    return Container(
      width: 132,
      height: 112,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer.withAlpha(100),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withAlpha(100),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono de trofeo
          Icon(
            Icons.emoji_events,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 4),
          // Posición en el ranking
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '#',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                '$globalRank',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  height: 1.0,
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}

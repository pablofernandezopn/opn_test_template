import 'package:flutter/material.dart';

/// Header para FinalTestPage
///
/// Muestra el nombre del grupo y el estado (completado/timeout)
class FinalTestHeader extends StatelessWidget {
  const FinalTestHeader({
    super.key,
    required this.groupName,
    required this.timedOut,
    required this.totalParts,
  });

  final String groupName;
  final bool timedOut;
  final int totalParts;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: timedOut
              ? [
                  colors.errorContainer,
                  colors.errorContainer.withValues(alpha: 0.8),
                ]
              : [
                  colors.primaryContainer,
                  colors.primaryContainer.withValues(alpha: 0.8),
                ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado (timeout o completado)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: timedOut
                  ? colors.error.withValues(alpha: 0.2)
                  : colors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  timedOut ? Icons.timer_off : Icons.check_circle,
                  size: 16,
                  color: timedOut ? colors.error : colors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  timedOut ? 'Tiempo agotado' : 'Completado',
                  style: textTheme.labelMedium?.copyWith(
                    color: timedOut ? colors.error : colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nombre del grupo
          Text(
            groupName,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: timedOut ? colors.onErrorContainer : colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),

          // Número de partes
          Text(
            '$totalParts ${totalParts == 1 ? 'parte completada' : 'partes completadas'}',
            style: textTheme.bodyMedium?.copyWith(
              color: timedOut
                  ? colors.onErrorContainer.withValues(alpha: 0.7)
                  : colors.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
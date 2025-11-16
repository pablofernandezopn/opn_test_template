import 'package:flutter/material.dart';

enum FinishTimeAttackAction {
  continueSession,
  exit,
  finalize,
}

/// Muestra opciones cuando el usuario presiona el botón de atrás
Future<FinishTimeAttackAction?> showFinishTimeAttackOptionsSheet({
  required BuildContext context,
  required bool hasStarted,
  required int questionsAnswered,
}) async {
  return showModalBottomSheet<FinishTimeAttackAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _FinishOptionsSheet(
      hasStarted: hasStarted,
      questionsAnswered: questionsAnswered,
    ),
  );
}

class _FinishOptionsSheet extends StatelessWidget {
  final bool hasStarted;
  final int questionsAnswered;

  const _FinishOptionsSheet({
    required this.hasStarted,
    required this.questionsAnswered,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle visual
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Título
            Text(
              '¿Qué quieres hacer?',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            if (hasStarted)
              Text(
                'Has respondido $questionsAnswered pregunta${questionsAnswered != 1 ? 's' : ''}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 24),

            // Continuar jugando
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(FinishTimeAttackAction.continueSession),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Continuar jugando'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 12),

            // Salir (perder progreso)
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(FinishTimeAttackAction.exit),
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Salir sin guardar'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: colorScheme.error,
              ),
            ),

            if (hasStarted) ...[
              const SizedBox(height: 12),

              // Finalizar definitivamente
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(FinishTimeAttackAction.finalize),
                icon: const Icon(Icons.stop),
                label: const Text('Finalizar y guardar resultados'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
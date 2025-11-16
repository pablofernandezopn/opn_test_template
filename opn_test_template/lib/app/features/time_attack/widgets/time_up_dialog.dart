import 'package:flutter/material.dart';
import '../model/time_attack_session.dart';

enum TimeUpAction {
  playAgain,
  viewHistory,
  exit,
}

/// Muestra un dialog cuando se acaba el tiempo en el modo contra reloj
Future<TimeUpAction?> showTimeUpDialog({
  required BuildContext context,
  required TimeAttackSession session,
}) async {
  return showModalBottomSheet<TimeUpAction>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TimeUpDialog(session: session),
  );
}

class _TimeUpDialog extends StatelessWidget {
  final TimeAttackSession session;

  const _TimeUpDialog({required this.session});

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
          children: [
            // Icono de reloj
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timer_off,
                size: 48,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 16),

            // Título
            Text(
              '¡Tiempo agotado!',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            // Puntuación final
            Text(
              '${session.finalScore ?? session.currentScore} puntos',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 24),

            // Grid de estadísticas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatColumn(
                    icon: Icons.check_circle,
                    value: '${session.questionsCorrect}',
                    label: 'Correctas',
                    color: Colors.green,
                  ),
                  _StatColumn(
                    icon: Icons.cancel,
                    value: '${session.questionsIncorrect}',
                    label: 'Incorrectas',
                    color: colorScheme.error,
                  ),
                  _StatColumn(
                    icon: Icons.local_fire_department,
                    value: '${session.bestStreak}',
                    label: 'Mejor racha',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botones de acción
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(TimeUpAction.playAgain),
              icon: const Icon(Icons.refresh),
              label: const Text('Jugar de nuevo'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(TimeUpAction.viewHistory),
              icon: const Icon(Icons.history),
              label: const Text('Ver historial'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () => Navigator.of(context).pop(TimeUpAction.exit),
              child: const Text('Salir'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
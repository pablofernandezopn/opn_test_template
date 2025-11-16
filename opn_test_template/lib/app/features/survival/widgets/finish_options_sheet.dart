import 'package:flutter/material.dart';
import '../model/survival_session.dart';

enum FinishSurvivalAction {
  continuePlay,
  continueLater,
  finalize,
}

/// Bottom sheet mostrado cuando el jugador presiona el botón de back/salir
Future<FinishSurvivalAction?> showFinishSurvivalSheet({
  required BuildContext context,
  required SurvivalSession session,
}) {
  return showModalBottomSheet<FinishSurvivalAction>(
    context: context,
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _FinishSurvivalSheet(session: session),
  );
}

class _FinishSurvivalSheet extends StatelessWidget {
  final SurvivalSession session;

  const _FinishSurvivalSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Título
                  Text(
                    '¿Qué deseas hacer?',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nivel ${session.currentLevel} • ${session.questionsAnswered} preguntas',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Opción 1: Continuar Jugando
                  _OptionCard(
                    icon: Icons.play_arrow,
                    iconColor: Colors.green,
                    title: 'Continuar Jugando',
                    subtitle: 'Cierra y sigue con la partida actual',
                    onTap: () => Navigator.of(context)
                        .pop(FinishSurvivalAction.continuePlay),
                  ),
                  const SizedBox(height: 12),

                  // Opción 2: Continuar Más Tarde
                  _OptionCard(
                    icon: Icons.pause_circle,
                    iconColor: Colors.orange,
                    title: 'Continuar Más Tarde',
                    subtitle: 'Guarda tu progreso y retoma desde el historial',
                    onTap: () => Navigator.of(context)
                        .pop(FinishSurvivalAction.continueLater),
                  ),
                  const SizedBox(height: 12),

                  // Opción 3: Finalizar
                  _OptionCard(
                    icon: Icons.stop_circle,
                    iconColor: Colors.red,
                    title: 'Finalizar Definitivamente',
                    subtitle: 'Termina la sesión y guarda resultados finales',
                    onTap: () =>
                        Navigator.of(context).pop(FinishSurvivalAction.finalize),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para cada opción
class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant),
          borderRadius: BorderRadius.circular(12),
          color: colors.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
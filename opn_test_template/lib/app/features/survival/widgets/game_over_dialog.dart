import 'package:flutter/material.dart';

import '../model/survival_session.dart';


enum GameOverAction {
  playAgain,
  viewHistory,
  exit,
}

/// Bottom sheet mostrado cuando el jugador se queda sin vidas
Future<GameOverAction?> showGameOverDialog({
  required BuildContext context,
  required SurvivalSession session,
  required int longestStreak,
}) {
  return showModalBottomSheet<GameOverAction>(
    context: context,
    isDismissible: true,
    enableDrag: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _GameOverBottomSheet(
      session: session,
      longestStreak: longestStreak,
    ),
  );
}

class _GameOverBottomSheet extends StatelessWidget {
  final SurvivalSession session;
  final int longestStreak;

  const _GameOverBottomSheet({
    required this.session,
    required this.longestStreak,
  });

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

                  // Header simplificado
                  Icon(
                    Icons.heart_broken,
                    size: 40,
                    color: colors.error.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Te has quedado sin vidas!',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Puntuación final compacta
                  if (session.finalScore != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.outlineVariant,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Puntuación Final',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${session.finalScore!.toStringAsFixed(0)}',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Estadísticas en grid
                  _StatsGrid(
                    session: session,
                    longestStreak: longestStreak,
                  ),
                  const SizedBox(height: 20),

                  // Botones de acción
                  _ActionButtons(
                    onPlayAgain: () =>
                        Navigator.of(context).pop(GameOverAction.playAgain),
                    onViewHistory: () =>
                        Navigator.of(context).pop(GameOverAction.viewHistory),
                    onExit: () =>
                        Navigator.of(context).pop(GameOverAction.exit),
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
/// Grid de estadísticas compacto
class _StatsGrid extends StatelessWidget {
  final SurvivalSession session;
  final int longestStreak;

  const _StatsGrid({
    required this.session,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Correctas
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle,
              label: 'Correctas',
              value: '${session.questionsCorrect}',
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(width: 8),
          // Incorrectas
          Expanded(
            child: _StatCard(
              icon: Icons.cancel,
              label: 'Incorrectas',
              value: '${session.questionsIncorrect}',
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          // Racha
          Expanded(
            child: _StatCard(
              icon: Icons.local_fire_department,
              label: 'Racha',
              value: '$longestStreak',
              color: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card individual de estadística
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: colors.outlineVariant,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color ?? colors.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Botones de acción compactos
class _ActionButtons extends StatelessWidget {
  final VoidCallback onPlayAgain;
  final VoidCallback onViewHistory;
  final VoidCallback onExit;

  const _ActionButtons({
    required this.onPlayAgain,
    required this.onViewHistory,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botón principal: Jugar de nuevo
        SizedBox(
          width: double.infinity,
          height: 44,
          child: FilledButton.icon(
            onPressed: onPlayAgain,
            icon: const Icon(Icons.replay, size: 18),
            label: const Text(
              'Jugar de Nuevo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Botón terciario: Salir
        TextButton.icon(
          onPressed: onExit,
          icon: const Icon(Icons.exit_to_app, size: 16),
          label: const Text(
            'Salir',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }
}

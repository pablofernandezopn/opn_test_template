import 'package:flutter/material.dart';
import '../model/survival_session.dart';
import 'survival_lives_indicator.dart';

/// Header especial para modo supervivencia
/// Se integra con TopicTestPage
class SurvivalTestHeader extends StatelessWidget implements PreferredSizeWidget {
  final SurvivalSession session;
  final int currentIndex;
  final int questionLength;
  final VoidCallback onViewIndex;

  const SurvivalTestHeader({
    super.key,
    required this.session,
    required this.currentIndex,
    required this.questionLength,
    required this.onViewIndex,
  });

  static const double _height = 72;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: _height,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              // Icono de fuego
              const Icon(
                Icons.local_fire_department,
                color: Colors.deepOrange,
                size: 24,
              ),
              const SizedBox(width: 12),

              // Título y stats
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Supervivencia',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nivel ${session.currentLevel}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.questionsAnswered} preguntas • ${session.accuracy.toStringAsFixed(0)}% precisión',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Vidas
              SurvivalLivesIndicator(
                livesRemaining: session.livesRemaining,
                animateChange: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
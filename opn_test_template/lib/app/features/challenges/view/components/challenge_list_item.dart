import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/go_route/app_routes.dart';
import '../../model/challenge_model.dart';

class ChallengeListItem extends StatelessWidget {
  const ChallengeListItem({
    super.key,
    required this.challenge,
  });

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Color según el estado
    Color stateColor;
    Color stateBackgroundColor;
    IconData stateIcon;

    switch (challenge.state) {
      case ChallengeStatus.pendiente:
        stateColor = colors.tertiary;
        stateBackgroundColor = colors.tertiary.withValues(alpha: 0.1);
        stateIcon = Icons.pending_outlined;
        break;
      case ChallengeStatus.aceptada:
        stateColor = const Color(0xFF4CAF50);
        stateBackgroundColor = const Color(0xFF4CAF50).withValues(alpha: 0.1);
        stateIcon = Icons.check_circle_outline;
        break;
      case ChallengeStatus.rechazada:
        stateColor = colors.error;
        stateBackgroundColor = colors.error.withValues(alpha: 0.1);
        stateIcon = Icons.cancel_outlined;
        break;
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final createdAtText = challenge.createdAt != null
        ? dateFormat.format(challenge.createdAt!)
        : 'Fecha desconocida';

    return InkWell(
      onTap: () {
        // Navegar a la página de detalle del challenge
        context.push('${AppRoutes.challengeDetail}/${challenge.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado: Estado y fecha
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: stateBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(stateIcon, size: 16, color: stateColor),
                    const SizedBox(width: 6),
                    Text(
                      challenge.state.displayName,
                      style: textTheme.labelSmall?.copyWith(
                        color: stateColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                createdAtText,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Razón de la impugnación
          if (challenge.reason != null && challenge.reason!.isNotEmpty) ...[
            Text(
              'Motivo:',
              style: textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              challenge.reason!,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],

          // Respuesta del tutor/editor
          if (challenge.reply.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Respuesta del tutor:',
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    challenge.reply,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Información adicional
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              if (challenge.questionId != null)
                _InfoChip(
                  icon: Icons.help_outline,
                  label: 'Pregunta #${challenge.questionId}',
                  colors: colors,
                ),
              if (challenge.topicId != null)
                _InfoChip(
                  icon: Icons.topic_outlined,
                  label: 'Tema #${challenge.topicId}',
                  colors: colors,
                ),
              if (!challenge.open)
                _InfoChip(
                  icon: Icons.lock_outline,
                  label: 'Cerrada',
                  colors: colors,
                ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
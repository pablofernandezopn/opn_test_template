import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuestionActionsBar extends StatelessWidget {
  const QuestionActionsBar({
    super.key,
    required this.isFavorite,
    required this.onReport,
    required this.onToggleFavorite,
    required this.onChatWithAi,
    required this.onShare,
    this.isChatWithAiDisabled = false,
  });

  final bool isFavorite;
  final VoidCallback onReport;
  final VoidCallback onToggleFavorite;
  final VoidCallback onChatWithAi;
  final VoidCallback onShare;
  final bool isChatWithAiDisabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _QuestionActionButton(
                  icon: Icons.gavel_rounded,
                  label: 'Impugnar',
                  onPressed: onReport,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuestionActionButton(
                  icon: isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  label: 'Favorita',
                  highlighted: isFavorite,
                  onPressed: onToggleFavorite,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuestionActionAiButton(
                  label: 'Chat IA',
                  onPressed: isChatWithAiDisabled ? null : onChatWithAi,
                  isDisabled: isChatWithAiDisabled,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuestionActionButton(
                  icon: Icons.share_outlined,
                  label: 'Compartir',
                  onPressed: onShare,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionActionButton extends StatelessWidget {
  const _QuestionActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = highlighted ? colors.primary : colors.onSurfaceVariant;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Botón especial para Chat con IA que usa SVG
class _QuestionActionAiButton extends StatelessWidget {
  const _QuestionActionAiButton({
    required this.label,
    required this.onPressed,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = isDisabled
        ? colors.onSurfaceVariant.withValues(alpha: 0.3)
        : colors.onSurfaceVariant;

    return InkWell(
      onTap: isDisabled ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: isDisabled ? 0.3 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/images/opn_logos/opn_intelligence_dark.svg'
                    : 'assets/images/opn_logos/opn_intelligence.svg',
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../model/question_model.dart';
import 'retro_audio_player.dart';

class AfterFinishRetro extends StatelessWidget {
  const AfterFinishRetro({
    super.key,
    required this.question,
    this.visible = true,
  });

  final Question question;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final tip = (question.tip ?? '').trim();
    final retroImageUrl = question.retroImageUrl.trim();
    final retroAudioText = question.retroAudioText.trim();
    final article = (question.article ?? '').trim();

    final hasTip = tip.isNotEmpty;
    final hasRetroImage = retroImageUrl.isNotEmpty;
    final hasRetroAudioText = question.retroAudioEnable && retroAudioText.isNotEmpty;
    final hasArticle = article.isNotEmpty;

    if (!hasTip && !hasRetroImage && !hasRetroAudioText && !hasArticle) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.lightbulb_outline,
                  color: colors.onSecondaryContainer,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Retroalimentación',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasTip) ...[
            Text(
              'Tip',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tip,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (hasRetroImage || hasRetroAudioText || hasArticle) const SizedBox(height: 16),
          ],
          if (hasArticle) ...[
            Text(
              'Referencia',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              article,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (hasRetroImage || hasRetroAudioText) const SizedBox(height: 16),
          ],
          if (hasRetroImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                retroImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: colors.surfaceContainerLow,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (hasRetroAudioText) const SizedBox(height: 16),
          ],
          if (hasRetroAudioText) ...[
            RetroAudioPlayer(text: retroAudioText),
          ],
        ],
      ),
    );
  }
}

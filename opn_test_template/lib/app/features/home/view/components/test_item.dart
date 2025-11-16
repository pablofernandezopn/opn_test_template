import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_template/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_template/app/config/widgets/premium/premium_content.dart';
import 'package:opn_test_template/app/features/topics/model/topic_model.dart';
import 'package:opn_test_template/app/features/topics/view/preview_topic_page.dart';

class SpecialTestItem extends StatelessWidget {
  const SpecialTestItem({
    super.key,
    required this.singleTitle,
    required this.topic,
    required this.rank,
    required this.showRanking,
    required this.percentile,
    required this.showTick,
    this.isCompleted = false,
  });

  final String singleTitle;
  final Topic topic;
  final int? rank;
  final bool showTick;
  final bool showRanking;
  final int? percentile;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = context.watch<AuthCubit>().state.user;
    final hasImage = topic.imageUrl != null && topic.imageUrl!.isNotEmpty;
    final titleColor = hasImage ? colors.onPrimary : colors.onPrimaryContainer;
    final subtitleColor = hasImage
        ? colors.onPrimary.withOpacity(0.92)
        : colors.onSurface;

    // Verificar si el topic está en desarrollo y el usuario es beta tester
    final now = DateTime.now();
    final isInDevelopment = topic.publishedAt != null && topic.publishedAt!.isAfter(now);
    final showDevelopmentBadge = isInDevelopment && user.isBetaTester;

    // 🆕 Verificar si el topic está deshabilitado
    final isDisabled = !topic.enabled && !user.isBetaTester;

    // 🆕 Verificar si debe bloquearse por premium (solo si es premium Y el usuario es freemium)
    final shouldLockPremium = topic.isPremium && user.isFreemium;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🆕 Envolver en DisabledTopicOverlay si está deshabilitado
        DisabledTopicOverlay(
          isDisabled: isDisabled,
          child: PremiumContent(
            requiresPremium: shouldLockPremium,
            onPressed: shouldLockPremium ? () => _showPremiumMessage(context) : null,
            child: InkWell(
              onTap: isDisabled ? null : () => _onTap(context),
              child: SpecialTestBox(
                title: Text(
                  topic.topicName.isNotEmpty ? topic.topicName : singleTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: _buildSubtitle(context, subtitleColor),
                imageUrl: topic.imageUrl,
                publishedAt: topic.publishedAt,
                showDevelopmentBadge: showDevelopmentBadge,
                isCompleted: isCompleted,
                rankPosition: rank,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: colors.onSurfaceVariant);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined, size: 14, color: colors.primary),
        const SizedBox(width: 4),
        Text('${(topic.durationSeconds ?? 0) ~/ 60} min', style: style),
        const SizedBox(width: 8),
        const Icon(Icons.circle, size: 4),
        const SizedBox(width: 8),
        Text('${topic.totalQuestions} preguntas', style: style),

      ],
    );
  }

  Widget _buildSubtitle(BuildContext context, Color textColor) {
    final textStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: textColor);

    final String statusText;
    if (showRanking && rank != null) {
      // Mostrar posición del ranking
      statusText = '#$rank';
    } else if (showRanking && percentile != null && showTick) {
      statusText = 'Percentil $percentile';
    } else if (!showTick || percentile == null) {
      statusText = 'Sin realizar';
    } else {
      statusText = 'Realizado';
    }

    final participants = topic.totalParticipants;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          statusText,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
        if (participants > 0) ...[
         // const SizedBox(width: 8),
         // Row(
         //   mainAxisSize: MainAxisSize.min,
         //   children: [
         //     Icon(Icons.groups_outlined, size: 16, color: textColor),
         //     const SizedBox(width: 4),
         //     Text(
         //       '$participants',
         //       style: textStyle,
         //     ),
         //   ],
         // ),
        ],
      ],
    );
  }

  void _onTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PreviewTopicPage(topic: topic),
      ),
    );
  }

  void _showPremiumMessage(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Contenido Premium. Desbloquea tu acceso para continuar.'),
        ),
      );
  }
}

class SpecialTestBox extends StatefulWidget {
  const SpecialTestBox({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.publishedAt,
    this.showDevelopmentBadge = false,
    this.isCompleted = false,
    this.rankPosition,
  });

  final Widget title;
  final Widget subtitle;
  final String? imageUrl;
  final DateTime? publishedAt;
  final bool showDevelopmentBadge;
  final bool isCompleted;
  final int? rankPosition;

  static const double height = 150.0;
  static const double width = 168.0;

  @override
  State<SpecialTestBox> createState() => _SpecialTestBoxState();
}

class _SpecialTestBoxState extends State<SpecialTestBox> {
  Timer? _timer;
  Duration? _timeUntilPublish;

  @override
  void initState() {
    super.initState();
    if (widget.showDevelopmentBadge && widget.publishedAt != null) {
      _updateTimeRemaining();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateTimeRemaining();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTimeRemaining() {
    if (widget.publishedAt != null) {
      final now = DateTime.now();
      final difference = widget.publishedAt!.difference(now);
      if (mounted) {
        setState(() {
          _timeUntilPublish = difference.isNegative ? null : difference;
        });
      }
    }
  }

  String _formatTimeRemaining() {
    if (_timeUntilPublish == null) return '';

    final hours = _timeUntilPublish!.inHours;
    final minutes = _timeUntilPublish!.inMinutes.remainder(60);
    final seconds = _timeUntilPublish!.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    final gradient = LinearGradient(
      colors: [
        colors.primaryContainer.withOpacity(0.9),
        colors.secondaryContainer.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      width: SpecialTestBox.width,
      height: SpecialTestBox.height,
      decoration: BoxDecoration(
        gradient: hasImage ? null : gradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (hasImage)
              Positioned.fill(
                child: Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withOpacity(0.8),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: colors.onSurfaceVariant.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ),
            if (hasImage)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colors.scrim.withOpacity(0.45),
                        colors.scrim.withOpacity(0.65),
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: widget.title,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: widget.subtitle,
                  ),
                ],
              ),
            ),
            // Badge de completado o ranking
            if (widget.isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: _buildBadge(colors),
              ),
            // Banda de desarrollo
            if (widget.showDevelopmentBadge)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFF9800).withOpacity(0.95),
                        const Color(0xFFFF5722).withOpacity(0.95),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9800).withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.science_outlined,
                        size: 14,
                        color: colors.surface,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'DESARROLLO',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.surface,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (_timeUntilPublish != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surface.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 11,
                                color: colors.surface,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _formatTimeRemaining(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colors.surface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  fontFeatures: [const FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(ColorScheme colors) {
    final isTopRanking = widget.rankPosition != null && widget.rankPosition! <= 3;

    Color badgeColor;
    IconData badgeIcon;

    if (isTopRanking) {
      // Top 3: Mostrar copa con color según posición
      switch (widget.rankPosition) {
        case 1:
          badgeColor = const Color(0xFFFFD700); // Oro
          break;
        case 2:
          badgeColor = const Color(0xFFC0C0C0); // Plata
          break;
        case 3:
          badgeColor = const Color(0xFFCD7F32); // Bronce
          break;
        default:
          badgeColor = Colors.green;
      }
      badgeIcon = Icons.emoji_events_rounded;
    } else {
      // Otros: Check verde
      badgeColor = Colors.green;
      badgeIcon = Icons.check_rounded;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.surface.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        badgeIcon,
        color: colors.surface,
        size: 20,
      ),
    );
  }
}

// ======================================================
// DISABLED TOPIC OVERLAY
// ======================================================

/// Widget que muestra un overlay de bloqueo sobre topics deshabilitados
/// Solo los beta testers pueden acceder a topics deshabilitados
class DisabledTopicOverlay extends StatelessWidget {
  const DisabledTopicOverlay({
    super.key,
    required this.isDisabled,
    required this.child,
  });

  final bool isDisabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDisabled) {
      return child;
    }

    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Contenido original con opacidad reducida
        Opacity(
          opacity: 0.4,
          child: child,
        ),
        // Overlay de bloqueo
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.outline.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 40,
                  color: colors.onSurface.withOpacity(0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  'No disponible',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Próximamente',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

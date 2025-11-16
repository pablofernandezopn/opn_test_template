import 'package:flutter/material.dart';

import '../model/survival_session.dart';


/// Barra minimalista que muestra solo progreso y vidas
class SurvivalStatsBar extends StatefulWidget {
  final SurvivalSession session;
  final VoidCallback? onBack;

  const SurvivalStatsBar({
    super.key,
    required this.session,
    this.onBack,
  });

  @override
  State<SurvivalStatsBar> createState() => _SurvivalStatsBarState();
}

class _SurvivalStatsBarState extends State<SurvivalStatsBar> {
  int? _previousLevel;

  @override
  void didUpdateWidget(SurvivalStatsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_previousLevel != null &&
        widget.session.currentLevel > _previousLevel!) {
      // El nivel cambió, actualizar
      setState(() {
        _previousLevel = widget.session.currentLevel;
      });
    } else if (_previousLevel == null) {
      _previousLevel = widget.session.currentLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = widget.session.progressToNextLevel;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Barra de nivel con progreso animado
                Expanded(
                  child: _AnimatedLevelBar(
                    currentLevel: widget.session.currentLevel,
                    progress: progress,
                    questionsUntilNext: widget.session.questionsUntilNextLevel,
                  ),
                ),

                const SizedBox(width: 16),

                // Indicador de vidas
                _LivesIndicator(livesRemaining: widget.session.livesRemaining),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra de nivel animada con progreso
class _AnimatedLevelBar extends StatefulWidget {
  final int currentLevel;
  final double progress;
  final int questionsUntilNext;

  const _AnimatedLevelBar({
    required this.currentLevel,
    required this.progress,
    required this.questionsUntilNext,
  });

  @override
  State<_AnimatedLevelBar> createState() => _AnimatedLevelBarState();
}

class _AnimatedLevelBarState extends State<_AnimatedLevelBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
    _previousProgress = widget.progress;
  }

  @override
  void didUpdateWidget(_AnimatedLevelBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0.0);
      _previousProgress = widget.progress;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nivel y preguntas restantes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.military_tech,
                  size: 14,
                  color: colors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Nivel ${widget.currentLevel}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Text(
              '${widget.questionsUntilNext} para nivel ${widget.currentLevel + 1}',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Barra de progreso animada
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Fondo de la barra
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.primary.withAlpha(50)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Progreso con gradiente
                FractionallySizedBox(
                  widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.primary,
                          colors.primary.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Widget minimalista que muestra las vidas restantes
class _LivesIndicator extends StatelessWidget {
  final int livesRemaining;
  final int maxLives;

  const _LivesIndicator({
    required this.livesRemaining,
    this.maxLives = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        final hasLife = index < livesRemaining;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(
            hasLife ? Icons.favorite : Icons.favorite_border,
            color: hasLife ? Colors.red : Colors.grey.shade400,
            size: 20,
          ),
        );
      }),
    );
  }
}

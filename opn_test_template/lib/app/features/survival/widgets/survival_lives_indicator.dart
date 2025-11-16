import 'package:flutter/material.dart';

/// Widget que muestra las vidas restantes del jugador
class SurvivalLivesIndicator extends StatefulWidget {
  final int livesRemaining;
  final int maxLives;
  final bool animateChange;

  const SurvivalLivesIndicator({
    super.key,
    required this.livesRemaining,
    this.maxLives = 3,
    this.animateChange = true,
  });

  @override
  State<SurvivalLivesIndicator> createState() => _SurvivalLivesIndicatorState();
}

class _SurvivalLivesIndicatorState extends State<SurvivalLivesIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousLives = 0;

  @override
  void initState() {
    super.initState();
    _previousLives = widget.livesRemaining;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void didUpdateWidget(SurvivalLivesIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateChange &&
        widget.livesRemaining != oldWidget.livesRemaining) {
      _controller.forward(from: 0.0);
      _previousLives = oldWidget.livesRemaining;
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxLives, (index) {
        final hasLife = index < widget.livesRemaining;
        final isLosingLife = widget.animateChange &&
            index >= widget.livesRemaining &&
            index < _previousLives;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              final scale = isLosingLife ? _scaleAnimation.value : 1.0;
              final opacity = isLosingLife
                  ? 1.0 - (_controller.value * 0.7)
                  : (hasLife ? 1.0 : 0.3);

              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Icon(
                    hasLife ? Icons.favorite : Icons.favorite_border,
                    color: hasLife ? Colors.red : colors.onSurfaceVariant,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
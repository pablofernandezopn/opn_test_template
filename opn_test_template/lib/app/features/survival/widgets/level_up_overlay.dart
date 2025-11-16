import 'package:flutter/material.dart';

/// Overlay que muestra una animación cuando el jugador sube de nivel
class LevelUpOverlay extends StatefulWidget {
  final int newLevel;
  final VoidCallback onComplete;

  const LevelUpOverlay({
    super.key,
    required this.newLevel,
    required this.onComplete,
  });

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: Colors.black.withOpacity(0.7 * _fadeAnimation.value),
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        colors.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.military_tech,
                        size: 80,
                        color: colors.onPrimary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '¡NIVEL ${widget.newLevel}!',
                        style: textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dificultad aumentada',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colors.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Muestra el overlay de level up
void showLevelUpOverlay(BuildContext context, int newLevel) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => LevelUpOverlay(
      newLevel: newLevel,
      onComplete: () {
        entry.remove();
      },
    ),
  );

  overlay.insert(entry);
}
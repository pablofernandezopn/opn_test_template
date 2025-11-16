import 'package:flutter/material.dart';
import '../model/time_attack_session.dart';

/// Barra de estadísticas para el modo contra reloj
/// Muestra: Timer, Nivel, Racha, Puntuación
class TimeAttackStatsBar extends StatefulWidget {
  final TimeAttackSession session;
  final int timeRemainingSeconds;
  final VoidCallback onBack;

  const TimeAttackStatsBar({
    super.key,
    required this.session,
    required this.timeRemainingSeconds,
    required this.onBack,
  });

  @override
  State<TimeAttackStatsBar> createState() => _TimeAttackStatsBarState();
}

class _TimeAttackStatsBarState extends State<TimeAttackStatsBar> {
  int? _previousTime;
  String? _timeChangeText;

  @override
  void didUpdateWidget(TimeAttackStatsBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detectar cambios en el tiempo
    if (oldWidget.timeRemainingSeconds != widget.timeRemainingSeconds) {
      final diff = widget.timeRemainingSeconds - oldWidget.timeRemainingSeconds;

      // Solo mostrar animación para cambios significativos (+5 o -2)
      // NO mostrar para el -1s automático del countdown
      if (diff != 0 && diff != -1) {
        setState(() {
          _timeChangeText = diff > 0 ? '+${diff}s' : '${diff}s';
        });

        // Ocultar el texto después de 1.5 segundos
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _timeChangeText = null;
            });
          }
        });
      }
    }

    _previousTime = oldWidget.timeRemainingSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLowTime = widget.timeRemainingSeconds <= 30;
    final progress = widget.timeRemainingSeconds / widget.session.timeLimitSeconds;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fila superior: Botón atrás + Timer + Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Botón atrás
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: widget.onBack,
                    tooltip: 'Salir',
                  ),

                  const SizedBox(width: 4),

                  // Timer (destacado) con overlay de cambio
                  Expanded(
                    flex: 2,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _TimerDisplay(
                          timeRemaining: widget.timeRemainingSeconds,
                          isLowTime: isLowTime,
                        ),
                        // Overlay de cambio de tiempo
                        if (_timeChangeText != null)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: _TimeChangeOverlay(text: _timeChangeText!),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Stats compactas
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatChip(
                          icon: Icons.trending_up,
                          label: 'Nv.${widget.session.currentLevel}',
                          color: colorScheme.primary,
                        ),
                        _StatChip(
                          icon: Icons.local_fire_department,
                          label: 'x${widget.session.currentStreak}',
                          color: Colors.orange,
                        ),
                        _StatChip(
                          icon: Icons.stars,
                          label: '${widget.session.currentScore}',
                          color: Colors.amber.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Barra de progreso del tiempo
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: isLowTime ? Colors.red : Colors.blue,
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que muestra el cambio de tiempo (+5s o -2s)
class _TimeChangeOverlay extends StatefulWidget {
  final String text;

  const _TimeChangeOverlay({required this.text});

  @override
  State<_TimeChangeOverlay> createState() => _TimeChangeOverlayState();
}

class _TimeChangeOverlayState extends State<_TimeChangeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.text.startsWith('+');
    final color = isPositive ? Colors.green : Colors.red;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget que muestra el timer con formato mm:ss con animación
class _TimerDisplay extends StatelessWidget {
  final int timeRemaining;
  final bool isLowTime;

  const _TimerDisplay({
    required this.timeRemaining,
    required this.isLowTime,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isLowTime
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLowTime ? Colors.red : Colors.blue,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: isLowTime ? Colors.red : Colors.blue,
            size: 18,
          ),
          const SizedBox(width: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Text(
              timeText,
              key: ValueKey(timeText),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLowTime ? Colors.red : Colors.blue,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de estadística compacto
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
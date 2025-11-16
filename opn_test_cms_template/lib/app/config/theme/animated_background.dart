import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Color begin;
  final Color end;
  final Color middle;

  const AnimatedBackground({
    super.key,
    required this.begin,
    required this.end,
    required this.middle,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  late Animation<Color?> _colorAnimation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation1 = ColorTween(
      begin: widget.begin,
      end: widget.middle,
    ).animate(_controller);

    _colorAnimation2 = ColorTween(
      begin: widget.middle,
      end: widget.end,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _colorAnimation1.value ?? widget.begin,
                _colorAnimation2.value ?? widget.end,
              ],
            ),
          ),
        );
      },
    );
  }
}


import 'dart:math';
import 'package:flutter/material.dart';

import '../../model/question_model.dart';
import '../../model/question_option_model.dart';

class FlashcardView extends StatefulWidget {
  const FlashcardView({
    super.key,
    required this.question,
    required this.options,
    required this.onDifficultySelected,
    this.canFlip = true,
    this.initiallyFlipped = false,
    this.onFlipChanged,
    this.selectedDifficulty,
  });

  final Question question;
  final List<QuestionOption> options;
  final void Function(String difficulty) onDifficultySelected;
  final bool canFlip;
  final bool initiallyFlipped;
  final ValueChanged<bool>? onFlipChanged;
  final String? selectedDifficulty;

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _showBack = widget.initiallyFlipped;
    if (_showBack) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant FlashcardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyFlipped != widget.initiallyFlipped) {
      _showBack = widget.initiallyFlipped;
      if (_showBack) {
        _controller.value = 1;
      } else {
        _controller.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (!widget.canFlip) return;

    if (_showBack) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _showBack = !_showBack;
    });
    widget.onFlipChanged?.call(_showBack);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Ordenar opciones por order
    final sortedOptions = List<QuestionOption>.from(widget.options)
      ..sort((a, b) => a.optionOrder.compareTo(b.optionOrder));

    final frontOption = sortedOptions.isNotEmpty ? sortedOptions[0] : null;
    final backOption = sortedOptions.length > 1 ? sortedOptions[1] : null;

    return Column(
      children: [
        if (_showBack)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Text(
              widget.question.question,
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final angle = _animation.value * pi;
                final transform = Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle);

                return Transform(
                  transform: transform,
                  alignment: Alignment.center,
                  child: angle >= pi / 2
                      ? Transform(
                          transform: Matrix4.identity()..rotateY(pi),
                          alignment: Alignment.center,
                          child: _CardBack(
                            backOption: backOption,
                            colors: colors,
                            textTheme: textTheme.copyWith(
                              headlineSmall: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      : _CardFront(
                          frontOption: frontOption,
                          colors: colors,
                          textTheme: textTheme,
                        ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (!_showBack)
          _FlipButton(
            onPressed: widget.canFlip ? _flip : null,
            colors: colors,
          )
        else
          _DifficultyButtons(
            onDifficultySelected: widget.onDifficultySelected,
            colors: colors,
            selectedDifficulty: widget.selectedDifficulty,
            onShowQuestion: widget.canFlip ? _flip : null,
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({
    required this.frontOption,
    required this.colors,
    required this.textTheme,
  });

  final QuestionOption? frontOption;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 500,
        minHeight: 300,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.style_outlined,
            size: 48,
            color: colors.onPrimaryContainer.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            frontOption?.answer ?? 'Sin pregunta',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.onPrimaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Pregunta',
              style: textTheme.labelMedium?.copyWith(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({
    required this.backOption,
    required this.colors,
    required this.textTheme,
  });

  final QuestionOption? backOption;
  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 500,
        minHeight: 300,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 48,
            color: colors.onSecondaryContainer.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            backOption?.answer ?? 'Sin respuesta',
            style: textTheme.headlineSmall?.copyWith(
              color: colors.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colors.onSecondaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Respuesta',
              style: textTheme.labelMedium?.copyWith(
                color: colors.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlipButton extends StatelessWidget {
  const _FlipButton({
    required this.onPressed,
    required this.colors,
  });

  final VoidCallback? onPressed;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.flip),
          label: const Text(
            'Ver respuesta',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyButtons extends StatelessWidget {
  const _DifficultyButtons({
    required this.onDifficultySelected,
    required this.colors,
    required this.selectedDifficulty,
    required this.onShowQuestion,
  });

  final void Function(String difficulty) onDifficultySelected;
  final ColorScheme colors;
  final String? selectedDifficulty;
  final VoidCallback? onShowQuestion;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedDifficulty != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '¿Qué tan bien la recordaste?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DifficultyButton(
                  label: 'Otra vez',
                  sublabel: '< 1d',
                  color: Colors.red,
                  isSelected: selectedDifficulty == 'again',
                  isDimmed: hasSelection && selectedDifficulty != 'again',
                  scheme: colors,
                  onPressed: () => onDifficultySelected('again'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DifficultyButton(
                  label: 'Difícil',
                  sublabel: '1-2d',
                  color: Colors.orange,
                  isSelected: selectedDifficulty == 'hard',
                  isDimmed: hasSelection && selectedDifficulty != 'hard',
                  scheme: colors,
                  onPressed: () => onDifficultySelected('hard'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DifficultyButton(
                  label: 'Bien',
                  sublabel: '3-6d',
                  color: Colors.green,
                  isSelected: selectedDifficulty == 'medium',
                  isDimmed: hasSelection && selectedDifficulty != 'medium',
                  scheme: colors,
                  onPressed: () => onDifficultySelected('medium'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DifficultyButton(
                  label: 'Fácil',
                  sublabel: '7+d',
                  color: Colors.blue,
                  isSelected: selectedDifficulty == 'easy',
                  isDimmed: hasSelection && selectedDifficulty != 'easy',
                  scheme: colors,
                  onPressed: () => onDifficultySelected('easy'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  const _DifficultyButton({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onPressed,
    required this.isSelected,
    required this.isDimmed,
    required this.scheme,
  });

  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool isDimmed;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color foregroundColor;
    final Color borderColor;

    if (isSelected) {
      backgroundColor = color;
      foregroundColor = Colors.white;
      borderColor = Colors.white.withValues(alpha: 0.9);
    } else if (isDimmed) {
      backgroundColor = scheme.surfaceVariant.withValues(alpha: 0.15);
      foregroundColor = scheme.onSurface.withValues(alpha: 0.3);
      borderColor = scheme.outlineVariant.withValues(alpha: 0.3);
    } else {
      backgroundColor = scheme.surface;
      foregroundColor = scheme.onSurface;
      borderColor = scheme.outline.withValues(alpha: 0.3);
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

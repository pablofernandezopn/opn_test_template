import 'dart:math';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';

class Countup extends StatelessWidget {
  const Countup({
    super.key,
    this.begin = 0,
    required this.end,
    this.duration = const Duration(seconds: 1),
    this.curve = Curves.easeOut,
    this.precision = 0,
    this.style,
    this.textAlign,
    this.prefix = '',
    this.suffix = '',
    this.digits,
  });

  final double begin;
  final num end;
  final int precision;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final TextAlign? textAlign;
  final String prefix;
  final String suffix;
  final int? digits;

  @override
  Widget build(BuildContext context) {
    final effectiveDigits = digits ??
        (end.toInt() == 0 ? 1 : (log(end.abs()) / ln10).floor() + 1);

    final textStyle = style ?? Theme.of(context).textTheme.titleLarge;

    final alignment = switch (textAlign) {
      TextAlign.center => MainAxisAlignment.center,
      TextAlign.right => MainAxisAlignment.end,
      _ => MainAxisAlignment.start,
    };

    return Row(
      mainAxisAlignment: alignment,
      children: [
        AnimatedFlipCounter(
          value: end,
          duration: duration,
          prefix: prefix,
          suffix: suffix,
          curve: curve,
          textStyle: textStyle,
          fractionDigits: precision,
          wholeDigits: effectiveDigits,
          decimalSeparator: ',',
        ),
      ],
    );
  }
}

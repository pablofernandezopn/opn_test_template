import 'package:flutter/material.dart';
import '../../../../config/widgets/numbers/count_up.dart';

class QuestionResult extends StatelessWidget {
  const QuestionResult({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.textColor,
    this.color,
    required this.iconColor,
  });

  final Color? color;
  final String label;
  final int value;
  final IconData icon;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? colorScheme.primary;


    return Container(
        height: 54,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Countup(
                  end: value.toDouble(),
                  precision: 0,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                  ),
                ),
                Icon(icon, color: iconColor, size: 18),
              ],
            ),
          ],
        ),

    );
  }
}



//--------------------------------------------------------



class StatisticData extends StatelessWidget {
  const StatisticData({
    super.key,
    // ignore: always_put_required_named_parameters_first
    required this.label,
    this.precision = 0,
    this.value,
    this.valueTotal,
    this.color,
    this.borderColor,
    this.backgroundColor,
    this.isTime = false,
  });

  final String label;
  final num? value;
  final num? valueTotal;
  final Color? color;
  final Color? borderColor;
  final Color? backgroundColor;
  final int precision;
  final bool isTime;

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_final_locals
    final scheme = Theme.of(context).colorScheme;
    var valueStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    // ✅ REMOVIDO EL Flexible - El widget padre (Expanded) ya maneja el espacio
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor ?? scheme.onPrimary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: color,
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isTime && value != null) ...[
                    Countup(
                      begin: 0,
                      end: value! ~/ (60 * 1000),
                      style: valueStyle,
                      precision: 0,
                      suffix: "'",
                    ),
                    const SizedBox(width: 2),
                    Countup(
                      begin: 0,
                      end: ((value! - (value! ~/ (60 * 1000)) * 60 * 1000) /
                          1000)
                          .ceil(),
                      precision: 0,
                      style: valueStyle,
                      digits: 2,
                      suffix: '"',
                    ),
                  ] else ...[
                    Countup(
                      begin: 0,
                      end: value ?? 0,
                      precision: precision,
                      textAlign: TextAlign.center,
                      style: valueStyle,
                    ),
                    if (valueTotal != null)
                      Text(
                        '/$valueTotal',
                        style: valueStyle,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


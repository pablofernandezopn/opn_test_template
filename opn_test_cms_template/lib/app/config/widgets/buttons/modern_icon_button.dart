import 'package:flutter/material.dart';

class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? iconColor;
  final BorderSide? borderSide;
  final double? iconSize;

  const ModernIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.height,
    this.width,
    this.backgroundColor,
    this.iconColor,
    this.borderSide,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveHeight = height ?? 48.0;
    final effectiveWidth = width ?? 48.0;
    final effectiveIconSize = (iconSize ?? 24.0).clamp(0.0, effectiveHeight * 0.8); // Clamp to fit within height
    final effectivePadding = EdgeInsets.symmetric(
      horizontal: (effectiveWidth - effectiveIconSize) / 2,
      vertical: (effectiveHeight - effectiveIconSize) / 2,
    ).clamp(EdgeInsets.zero, const EdgeInsets.all(16.0)); // Adaptive padding, clamped
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surfaceVariant;
    final effectiveIconColor = iconColor ?? colorScheme.onSurfaceVariant;
    final effectiveBorderSide = borderSide ?? BorderSide(
      color: colorScheme.outline.withOpacity(0.12),
      width: 1,
    );

    final buttonContent = Material(
      color: effectiveBackgroundColor,
      elevation: onPressed != null ? 2.0 : 0.0,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(effectiveHeight / 2), // Circular-ish based on size
        side: effectiveBorderSide,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(effectiveHeight / 2),
        onTap: onPressed,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveHeight / 2),
        ),
        child: Padding(
          padding: effectivePadding,
          child: Icon(
            icon,
            size: effectiveIconSize,
            color: effectiveIconColor,
          ),
        ),
      ),
    );

    Widget result = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: effectiveHeight,
        minWidth: effectiveWidth,
        maxHeight: effectiveHeight,
        maxWidth: effectiveWidth,
      ),
      child: buttonContent,
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      result = Tooltip(
        message: tooltip!,
        preferBelow: true,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        child: result,
      );
    }

    return result;
  }
}
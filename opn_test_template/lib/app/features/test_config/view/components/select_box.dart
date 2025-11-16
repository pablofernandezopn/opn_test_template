import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../config/widgets/premium/premium_content.dart';


/// Widget de caja seleccionable con soporte premium
///
/// Características:
/// - Overlay premium automático cuando está bloqueado
/// - Animaciones fluidas de selección
/// - Haptic feedback diferenciado
/// - Checkmark visual cuando está seleccionado
/// - Soporte completo para accesibilidad
class SelectBox extends StatelessWidget {
  const SelectBox({
    super.key,
    required this.title,
    required this.selected,
    this.subtitle,
    this.onSelect,
    this.onLock,
    this.lock = false,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final bool lock;
  final VoidCallback? onSelect;
  final VoidCallback? onLock;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semanticLabel = '$title${subtitle != null ? ' - $subtitle' : ''}';

    return Semantics(
      label: lock ? 'Premium: $semanticLabel' : semanticLabel,
      hint: lock
          ? 'Contenido premium bloqueado'
          : selected
          ? 'Seleccionado'
          : 'Seleccionar opción',
      checked: selected && !lock,
      enabled: true,
      button: true,
      child: PremiumContent(
        requiresPremium: lock,
        onPressed: onLock,
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: lock
                    ? null
                    : () {
                  HapticFeedback.lightImpact();
                  onSelect?.call();
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  constraints: const BoxConstraints(minHeight: 90),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getBorderColor(context),
                      width: selected && !lock ? 2.5 : 1.5,
                    ),
                    boxShadow: selected && !lock
                        ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: _buildContent(context),
                ),
              ),
            ),
            // Checkmark cuando está seleccionado y desbloqueado
            if (selected && !lock)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final textColor = _getTextColor(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null && !lock)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              icon,
              size: 28,
              color: textColor,
            ),
          ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: selected && !lock
                      ? FontWeight.w700
                      : FontWeight.w600,
                  color: textColor,
                  fontSize: 15,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (lock) return colorScheme.surfaceContainerHighest.withOpacity(0.6);
    if (selected) return colorScheme.primaryContainer;
    return colorScheme.surface;
  }

  Color _getBorderColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (lock) return colorScheme.outline.withOpacity(0.4);
    if (selected) return colorScheme.primary;
    return colorScheme.outlineVariant;
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (lock) return colorScheme.onSurface.withOpacity(0.45);
    if (selected) return colorScheme.onPrimaryContainer;
    return colorScheme.onSurface;
  }
}
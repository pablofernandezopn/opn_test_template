import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// AppBar personalizado de OPN que siempre muestra el logo
///
/// Características:
/// - Logo de OPN siempre visible
/// - Adapta colores de iconos según el fondo (blanco en primary, primary en otros)
/// - Soporte para acciones personalizadas
/// - Altura estándar de 56px
class OpnAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OpnAppBar({
    super.key,
    this.title,
    this.actions,
    this.backgroundColor,
    this.showBackButton = true,
    this.onBackPressed,
    this.elevation = 0,
    this.centerTitle = false,
  });

  /// Título opcional del AppBar (texto o widget)
  final Widget? title;

  /// Acciones del AppBar (botones a la derecha)
  final List<Widget>? actions;

  /// Color de fondo del AppBar
  /// Si no se especifica, usa el color del tema
  final Color? backgroundColor;

  /// Si debe mostrar el botón de back
  final bool showBackButton;

  /// Callback cuando se presiona el botón back
  /// Si no se especifica, usa Navigator.pop
  final VoidCallback? onBackPressed;

  /// Elevación del AppBar
  final double elevation;

  /// Si el título debe estar centrado
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final actualBackgroundColor = backgroundColor ?? colors.primary;

    // Determinar si el fondo es primary (verde)
    final isPrimaryBackground = actualBackgroundColor == colors.primary;

    // Color de los iconos y texto: blanco si fondo es primary, sino primary
    final foregroundColor = isPrimaryBackground ? colors.onPrimary : colors.primary;

    return AppBar(
      backgroundColor: actualBackgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: foregroundColor),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo de OPN
          SvgPicture.asset(
            Theme.of(context).brightness == Brightness.dark
                ? 'assets/images/opn_logos/opn_intelligence_dark.svg'
                : 'assets/images/opn_logos/opn_intelligence.svg',
            height: 32,
            colorFilter: isPrimaryBackground
                ? ColorFilter.mode(colors.onPrimary, BlendMode.srcIn)
                : null,
          ),
          if (title != null) ...[
            const SizedBox(width: 12),
            Flexible(child: title!),
          ],
        ],
      ),
      actions: actions,
    );
  }
}

/// Variante simplificada del OpnAppBar para pantallas que solo necesitan logo y back button
class OpnSimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OpnSimpleAppBar({
    super.key,
    this.onBackPressed,
  });

  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return OpnAppBar(
      showBackButton: true,
      onBackPressed: onBackPressed,
    );
  }
}

/// AppBar con fondo verde (primary) y logo visible
class OpnPrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OpnPrimaryAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
  });

  final Widget? title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return OpnAppBar(
      title: title,
      actions: actions,
      backgroundColor: Theme.of(context).colorScheme.primary,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
    );
  }
}

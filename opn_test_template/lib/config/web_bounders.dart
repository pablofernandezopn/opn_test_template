import 'package:flutter/material.dart';

import 'device_info.dart';

/// 📱 Breakpoints responsivos para diferentes dispositivos
class AppBreakpoints {
  // Ancho máximo de móvil (portrait)
  static const double mobile = 600.0;

  // Ancho máximo de tablet pequeño (portrait) o móvil landscape
  static const double tabletSmall = 768.0;

  // Ancho máximo de tablet (landscape) / iPad
  static const double tablet = 1024.0;

  // Ancho máximo de desktop pequeño
  static const double desktopSmall = 1280.0;

  // Ancho máximo para contenido (desktop)
  static const double contentMaxWidth = 1400.0;

  // Ancho del contenedor móvil en web/desktop
  static const double mobileContainer = 700;
}

/// 🎨 Configuración de diseño según el tamaño de pantalla
class LayoutConfig {
  final double maxWidth;
  final bool showContainer;
  final bool showShadow;
  final EdgeInsets padding;
  final Color? backgroundColor;

  const LayoutConfig({
    required this.maxWidth,
    required this.showContainer,
    required this.showShadow,
    this.padding = EdgeInsets.zero,
    this.backgroundColor,
  });

  /// Obtiene la configuración según el ancho de pantalla
  static LayoutConfig fromWidth(double width) {
    // 📱 Móvil (< 600px) - Sin contenedor, sin padding
    if (width < AppBreakpoints.mobile) {
      return const LayoutConfig(
        maxWidth: double.infinity,
        showContainer: false,
        showShadow: false,
        padding: EdgeInsets.zero,
      );
    }

    // 📱 Tablet pequeño en portrait o móvil landscape (600-768px) - Sin contenedor, sin padding
    if (width < AppBreakpoints.tabletSmall) {
      return const LayoutConfig(
        maxWidth: double.infinity,
        showContainer: false,
        showShadow: false,
        padding: EdgeInsets.zero,
      );
    }

    // 📱 Tablet en portrait / iPad (768-1024px) - Contenedor de 700px
    if (width < AppBreakpoints.tablet) {
      return const LayoutConfig(
        maxWidth: 700.0, // Aumentado de 600 a 700
        showContainer: true,
        showShadow: true,
        padding: EdgeInsets.symmetric(vertical: 12.0),
      );
    }

    // 💻 Tablet landscape / Desktop pequeño (1024-1280px) - Contenedor de 950px
    if (width < AppBreakpoints.desktopSmall) {
      return const LayoutConfig(
        maxWidth: 950.0, // Aumentado de 800 a 950
        showContainer: true,
        showShadow: true,
        padding: EdgeInsets.symmetric(vertical: 16.0),
      );
    }

    // 🖥️ Desktop (>1280px) - Contenedor de 720px
    return const LayoutConfig(
      maxWidth: AppBreakpoints.mobileContainer, // 720px
      showContainer: true,
      showShadow: true,
      padding: EdgeInsets.symmetric(vertical: 20.0),
      backgroundColor: Colors.grey,
    );
  }
}

/// 🌈 Fondo animado con gradiente desenfocado
class _AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const _AnimatedGradientBackground({required this.child});

  @override
  State<_AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colores oficiales Guardia Civil
    final verdeGuardiaCivil = const Color(0xFF007A5E); // Verde oficial
    final verdeTrafico = const Color(0xFF308446); // Verde tráfico
    final doradoGala = const Color(0xFFD4AF37); // Dorado militar

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          color: Colors.white, // Fondo blanco sólido de base
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    verdeGuardiaCivil.withOpacity(0.30), // Verde Guardia Civil dominante
                    verdeTrafico.withOpacity(0.35), // Verde tráfico
                    _animation.value,
                  )!,
                  Color.lerp(
                    verdeTrafico.withOpacity(0.25),
                    doradoGala.withOpacity(0.20), // Toque dorado sutil
                    _animation.value,
                  )!,
                  Color.lerp(
                    verdeGuardiaCivil.withOpacity(0.20),
                    verdeTrafico.withOpacity(0.30),
                    _animation.value,
                  )!,
                ],
                stops: [
                  0.0 + (_animation.value * 0.2),
                  0.5 + (_animation.value * 0.2),
                  1.0,
                ],
              ),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class AppWeb extends StatelessWidget {
  const AppWeb({super.key, required this.child, required this.dev});

  final bool dev;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Determinar si necesitamos mostrar el contenedor móvil
        // Ahora también incluye tabletas en horizontal (>= 768px)
        final isLargeScreen = ((isWeb || isDesktopDevice) && !isMobileDeviceAndWeb) ||
            (screenWidth >= AppBreakpoints.tabletSmall);

        // Obtener configuración de layout según el ancho
        final layoutConfig = LayoutConfig.fromWidth(screenWidth);

        // Calcular ancho real que verá ScreenUtil
        final effectiveWidth = isLargeScreen
            ? screenWidth.clamp(0.0, layoutConfig.maxWidth)
            : screenWidth;

        return Directionality(
          textDirection: TextDirection.ltr,
          child: _AnimatedGradientBackground(
            child: Container(
              color: isLargeScreen && layoutConfig.showContainer
                  ? Colors.transparent // Dejar que se vea el gradiente animado
                  : null,
              child: Center(
                child: Padding(
                  padding: isLargeScreen ? layoutConfig.padding : EdgeInsets.zero,
                  child: Container(
                    decoration: isLargeScreen && layoutConfig.showContainer
                        ? BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: layoutConfig.showShadow
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          )
                        : null,
                    clipBehavior: isLargeScreen && layoutConfig.showContainer
                        ? Clip.antiAlias
                        : Clip.none,
                    constraints: isLargeScreen && layoutConfig.showContainer
                        ? BoxConstraints(maxWidth: layoutConfig.maxWidth)
                        : null,

                    // MediaQuery ajustado para limitar el ancho percibido por el árbol
                    child: MediaQuery(
                      data: MediaQuery.of(ctx).copyWith(
                        size: Size(effectiveWidth, screenHeight),
                      ),
                      child: _buildContent(
                        child,
                        screenWidth,
                        isLargeScreen,
                        dev,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construye el contenido con información de debug opcional
  Widget _buildContent(
    Widget child,
    double screenWidth,
    bool isLargeScreen,
    bool showDebug,
  ) {
    if (!showDebug) return child;

    return Stack(
      children: [
        child,
        // 🐛 Indicador de breakpoint (solo en modo dev)
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Text(
              _getBreakpointLabel(screenWidth),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Obtiene la etiqueta del breakpoint actual
  String _getBreakpointLabel(double width) {
    if (width < AppBreakpoints.mobile) return '📱 Mobile';
    if (width < AppBreakpoints.tabletSmall) return '📱 Mobile L';
    if (width < AppBreakpoints.tablet) return '📱 Tablet';
    if (width < AppBreakpoints.desktopSmall) return '💻 Tablet L';
    return '🖥️ Desktop';
  }
}

// lib/core/layout/cubit/app_layout_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'state.freezed.dart';

/// Tipo de navegación según el tamaño de pantalla
enum NavigationType {
  drawer,          // < 600px - Menú drawer (móvil)
  rail,            // 600-1200px - NavigationRail colapsado (tablet)
  railExtended,    // > 1200px - NavigationRail extendido (desktop)
}

/// Densidad de la interfaz de usuario
enum UIDensity {
  compact,      // UI más compacta, más información visible
  comfortable,  // Balance entre espacio y contenido
  spacious,     // Más espacio, menos contenido por pantalla
}

@freezed
class AppLayoutState with _$AppLayoutState {
  const factory AppLayoutState({
    /// Si el menú está expandido (solo aplica a NavigationRail)
    @Default(true) bool isNavigationExpanded,

    /// Si el drawer está abierto (solo móvil)
    @Default(false) bool isDrawerOpen,

    /// Tema actual (light/dark)
    @Default(false) bool isDarkMode,

    /// Densidad de la UI (comfortable/compact/spacious)
    @Default(UIDensity.comfortable) UIDensity density,

    /// Tipo de navegación actual
    @Default(NavigationType.railExtended) NavigationType navigationType,

    /// Ancho actual de la pantalla
    @Default(1920.0) double screenWidth,
  }) = _AppLayoutState;

  const AppLayoutState._();

  // ==========================================
  // 🔍 GETTERS CONVENIENTES
  // ==========================================

  /// Verifica si estamos en móvil
  bool get isMobile => navigationType == NavigationType.drawer;

  /// Verifica si estamos en tablet
  bool get isTablet => navigationType == NavigationType.rail;

  /// Verifica si estamos en desktop
  bool get isDesktop => navigationType == NavigationType.railExtended;

  /// Padding según la densidad
  double get contentPadding {
    switch (density) {
      case UIDensity.compact:
        return 12.0;
      case UIDensity.comfortable:
        return 16.0;
      case UIDensity.spacious:
        return 24.0;
    }
  }

  /// Espaciado entre elementos según densidad
  double get spacing {
    switch (density) {
      case UIDensity.compact:
        return 8.0;
      case UIDensity.comfortable:
        return 12.0;
      case UIDensity.spacious:
        return 16.0;
    }
  }

  /// Altura del AppBar según densidad
  double get appBarHeight {
    switch (density) {
      case UIDensity.compact:
        return 48.0;
      case UIDensity.comfortable:
        return 56.0;
      case UIDensity.spacious:
        return 64.0;
    }
  }

  /// Tamaño de iconos según densidad
  double get iconSize {
    switch (density) {
      case UIDensity.compact:
        return 20.0;
      case UIDensity.comfortable:
        return 24.0;
      case UIDensity.spacious:
        return 28.0;
    }
  }
}
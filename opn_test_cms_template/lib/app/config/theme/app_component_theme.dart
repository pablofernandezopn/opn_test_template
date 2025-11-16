import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'color.dart';

/// 🎨 Configuración de Componentes Diversos
///
/// Define los estilos para todos los componentes adicionales de la app:
/// - AppBar
/// - Checkboxes
/// - Switches
/// - Tabs
/// - Sliders
/// - ProgressIndicators
/// - Scrollbars
/// - BottomSheets
/// - Icons
///
/// Estos componentes heredan automáticamente estos estilos.
abstract class AppComponentTheme {
  // ==========================================
  // 🌞 TEMA CLARO
  // ==========================================

  /// AppBar - Tema Claro
  /// - Fondo: surface color con gradiente sutil
  /// - Con elevación y sombra suave
  /// - Bordes redondeados en la parte inferior
  /// - Iconos en color primary
  /// - Barra de estado clara
  static AppBarTheme get appBarLight {
    return AppBarTheme(
      backgroundColor: AppColorsLight.surface,
      surfaceTintColor: AppColorsLight.primary.withValues(alpha: 0.05),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      iconTheme: const IconThemeData(
        color: AppColorsLight.primary,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: AppColorsLight.primary,
        size: 24,
      ),
      titleTextStyle: const TextStyle(
        color: AppColorsLight.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlusJakartaSans',
        letterSpacing: -0.5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      centerTitle: false,
      toolbarHeight: 64,
    );
  }

  /// Checkboxes - Tema Claro
  /// - Seleccionado: primary color
  /// - No seleccionado: blanco con borde primary
  /// - Borde: 2px
  static CheckboxThemeData get checkboxLight {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColorsLight.primary
            : Colors.white,
      ),
      side: const BorderSide(
        color: AppColorsLight.primary,
        width: 2,
      ),
    );
  }

  /// Switches - Tema Claro
  /// - Track (fondo): primary cuando activo, gris cuando inactivo
  /// - Thumb (círculo): blanco siempre
  /// - Con elevación para mejor visualización
  static SwitchThemeData get switchLight {
    return SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsLight.primary;
        }
        return Colors.grey.shade300;
      }),
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsLight.primary;
        }
        return Colors.grey.shade400;
      }),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  /// Tabs - Tema Claro
  /// - Tab seleccionada: primary color
  /// - Tab no seleccionada: gris con opacidad
  /// - Indicador: tertiary color con border radius
  static TabBarThemeData get tabBarLight {
    return TabBarThemeData(
      labelColor: AppColorsLight.primary,
      unselectedLabelColor: AppColorsLight.onSurface.withValues(alpha: 0.6),
      indicatorColor: AppColorsLight.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: AppColorsLight.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Sliders - Tema Claro
  /// Configuración personalizada para sliders con colores morados/rosas
  static SliderThemeData get sliderLight {
    return SliderThemeData(
      trackHeight: 10.0,
      trackShape: const RoundedRectSliderTrackShape(),
      activeTrackColor: Colors.purple.shade800,
      inactiveTrackColor: Colors.purple.shade100,
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 14.0,
        pressedElevation: 8.0,
      ),
      thumbColor: Colors.pinkAccent,
      overlayColor: Colors.pink.withValues(alpha: 0.2),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 32.0),
      tickMarkShape: const RoundSliderTickMarkShape(),
      activeTickMarkColor: Colors.pinkAccent,
      inactiveTickMarkColor: Colors.white,
      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      valueIndicatorColor: Colors.black,
      valueIndicatorTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
    );
  }

  /// Iconos - Tema Claro
  /// - Color: primary
  /// - Tamaño: 24px
  static IconThemeData get iconLight {
    return const IconThemeData(
      color: AppColorsLight.primary,
      size: 24,
    );
  }

  /// ProgressIndicator (CircularProgressIndicator, LinearProgressIndicator)
  /// - Color: primary
  static ProgressIndicatorThemeData get progressIndicatorLight {
    return const ProgressIndicatorThemeData(
      color: AppColorsLight.primary,
    );
  }

  /// Scrollbars
  /// - Ocultas por defecto (no visibles)
  static ScrollbarThemeData get scrollbarLight {
    return const ScrollbarThemeData(
      thumbVisibility: WidgetStatePropertyAll(false),
      trackVisibility: WidgetStatePropertyAll(false),
    );
  }

  /// SnackBars - Tema Claro
  /// - Forma redondeada con elevación
  /// - Colores según tipo (success: verde, error: rojo, info: azul)
  /// - Comportamiento flotante
  static SnackBarThemeData get snackBarLight {
    return SnackBarThemeData(
      backgroundColor: AppColorsLight.surfaceContainer,
      contentTextStyle: const TextStyle(
        color: AppColorsLight.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'PlusJakartaSans',
      ),
      actionTextColor: AppColorsLight.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// BottomSheets
  /// - Fondo transparente (para personalización)
  static BottomSheetThemeData get bottomSheetLight {
    return const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
    );
  }

  // ==========================================
  // 🌙 TEMA OSCURO
  // ==========================================

  /// AppBar - Tema Oscuro
  /// - Fondo: surface color oscuro con tinte sutil
  /// - Con elevación y sombra suave
  /// - Bordes redondeados en la parte inferior
  /// - Iconos en color primary
  /// - Barra de estado oscura
  static AppBarTheme get appBarDark {
    return AppBarTheme(
      backgroundColor: AppColorsDark.surface,
      surfaceTintColor: AppColorsDark.primary.withValues(alpha: 0.08),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      iconTheme: const IconThemeData(
        color: AppColorsDark.primary,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: AppColorsDark.primary,
        size: 24,
      ),
      titleTextStyle: const TextStyle(
        color: AppColorsDark.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlusJakartaSans',
        letterSpacing: -0.5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      centerTitle: false,
      toolbarHeight: 64,
    );
  }

  /// Checkboxes - Tema Oscuro
  static CheckboxThemeData get checkboxDark {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColorsDark.primaryContainer
            : Colors.grey,
      ),
      side: const BorderSide(
        color: AppColorsDark.primary,
        width: 2,
      ),
      checkColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColorsDark.onPrimaryContainer
            : Colors.grey,
      ),
    );
  }

  /// Switches - Tema Oscuro
  /// - Track (fondo): primary cuando activo, gris oscuro cuando inactivo
  /// - Thumb (círculo): blanco siempre
  /// - Con elevación para mejor visualización
  static SwitchThemeData get switchDark {
    return SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.primary;
        }
        return Colors.grey.shade700;
      }),
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.primary;
        }
        return Colors.grey.shade600;
      }),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  /// Tabs - Tema Oscuro
  static TabBarThemeData get tabBarDark {
    return TabBarThemeData(
      labelColor: AppColorsDark.primary,
      unselectedLabelColor: AppColorsDark.onSurface.withValues(alpha: 0.6),
      indicatorColor: AppColorsDark.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: AppColorsDark.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Iconos - Tema Oscuro
  static IconThemeData get iconDark {
    return const IconThemeData(
      color: AppColorsDark.primary,
      size: 24,
    );
  }

  /// ProgressIndicator - Tema Oscuro
  static ProgressIndicatorThemeData get progressIndicatorDark {
    return const ProgressIndicatorThemeData(
      color: AppColorsDark.primary,
    );
  }

  /// SnackBars - Tema Oscuro
  /// - Forma redondeada con elevación
  /// - Colores adaptados para modo oscuro
  /// - Comportamiento flotante
  static SnackBarThemeData get snackBarDark {
    return SnackBarThemeData(
      backgroundColor: AppColorsDark.surfaceContainer,
      contentTextStyle: const TextStyle(
        color: AppColorsDark.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'PlusJakartaSans',
      ),
      actionTextColor: AppColorsDark.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// BottomSheets - Tema Oscuro
  static BottomSheetThemeData get bottomSheetDark {
    return const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
    );
  }
}

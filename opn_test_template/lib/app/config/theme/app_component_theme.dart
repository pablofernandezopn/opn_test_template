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
/// - SnackBars (modernos y flotantes)
/// - Cards
/// - Icons
///
/// Estos componentes heredan automáticamente estos estilos.
/// Para SnackBars personalizados con iconos, usa `CustomSnackBar` en `shared/widgets/custom_snackbar.dart`
abstract class AppComponentTheme {
  // ==========================================
  // 🌞 TEMA CLARO
  // ==========================================

  /// AppBar - Tema Claro
  /// - Fondo: background color
  /// - Sin elevación (flat)
  /// - Iconos en color primary por defecto
  /// - Cuando se usa con backgroundColor primary, los iconos serán blancos
  /// - Barra de estado clara
  static AppBarTheme get appBarLight {
    return  AppBarTheme(
      backgroundColor: AppColorsLight.background,
      foregroundColor: AppColorsLight.primary, // Color por defecto de iconos y texto
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
      ),
      elevation: 0, // Sin sombra
      iconTheme: IconThemeData(
        color: AppColorsLight.primary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: AppColorsLight.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlusJakartaSans',
      ),
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
      side:  BorderSide(
        color: AppColorsLight.primary,
        width: 2,
      ),
    );
  }

  /// Switches - Tema Claro
  /// - Track activo: primary con opacidad
  /// - Track inactivo: outline
  /// - Thumb activo: primary
  /// - Thumb inactivo: surfaceContainerHighest
  static SwitchThemeData get switchLight {
    return SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsLight.primary.withValues(alpha: 0.5);
        }
        return AppColorsLight.outline;
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsLight.primary;
        }
        return AppColorsLight.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsLight.primary;
        }
        return AppColorsLight.outline;
      }),
    );
  }

  /// Tabs - Tema Claro
  /// - Tab seleccionada: primary color con fondo
  /// - Tab no seleccionada: gris con opacidad
  /// - Indicador: tertiary color con border radius y padding
  /// - Tipografía mejorada con mejor peso y tamaño
  static TabBarThemeData get tabBarLight {
    return TabBarThemeData(
      labelColor: AppColorsLight.onPrimary,
      unselectedLabelColor: AppColorsLight.onSurface.withValues(alpha: 0.7),
      indicatorColor: AppColorsLight.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: AppColorsLight.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColorsLight.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      labelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        fontFamily: 'PlusJakartaSans',
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        fontFamily: 'PlusJakartaSans',
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColorsLight.primary.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColorsLight.primary.withValues(alpha: 0.05);
        }
        return null;
      }),
      splashFactory: InkRipple.splashFactory,
      dividerColor: AppColorsLight.outline.withValues(alpha: 0.1),
      dividerHeight: 1,
    );
  }

  /// Sliders - Tema Claro
  /// - Track activo: primary (verde)
  /// - Track inactivo: primary con baja opacidad
  /// - Thumb: primary
  /// - Overlay: primary con opacidad
  static SliderThemeData get sliderLight {
    return SliderThemeData(
      trackHeight: 4.0,
      trackShape: const RoundedRectSliderTrackShape(),
      activeTrackColor: AppColorsLight.primary,
      inactiveTrackColor: AppColorsLight.primary.withValues(alpha: 0.2),
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 10.0,
        pressedElevation: 4.0,
      ),
      thumbColor: AppColorsLight.primary,
      overlayColor: AppColorsLight.primary.withValues(alpha: 0.15),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
      tickMarkShape: const RoundSliderTickMarkShape(),
      activeTickMarkColor: AppColorsLight.onPrimary,
      inactiveTickMarkColor: AppColorsLight.primary.withValues(alpha: 0.3),
      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      valueIndicatorColor: AppColorsLight.primary,
      valueIndicatorTextStyle: const TextStyle(
        color: AppColorsLight.onPrimary,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlusJakartaSans',
      ),
    );
  }

  /// Iconos - Tema Claro
  /// - Color: primary
  /// - Tamaño: 24px
  static IconThemeData get iconLight {
    return IconThemeData(
      color: AppColorsLight.primary,
      size: 24,
    );
  }

  /// ProgressIndicator (CircularProgressIndicator, LinearProgressIndicator)
  /// - Color: primary
  static ProgressIndicatorThemeData get progressIndicatorLight {
    return  ProgressIndicatorThemeData(
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

  /// BottomSheets - Tema Claro
  /// - Fondo: surfaceContainer
  /// - Bordes redondeados superiores
  static BottomSheetThemeData get bottomSheetLight {
    return const BottomSheetThemeData(
      backgroundColor: AppColorsLight.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  /// Cards - Tema Claro
  /// - Bordes redondeados con radio 12
  /// - Elevación 0 (sin sombra por defecto)
  static CardThemeData get cardLight {
    return const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  /// Dialogs - Tema Claro
  /// - Bordes redondeados modernos (12px)
  /// - Fondo surface
  /// - Elevación suave
  static DialogThemeData get dialogLight {
    return DialogThemeData(
      backgroundColor: AppColorsLight.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        color: AppColorsLight.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlusJakartaSans',
      ),
      contentTextStyle: const TextStyle(
        color: AppColorsLight.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'PlusJakartaSans',
        height: 1.5,
      ),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    );
  }

  /// SnackBars - Tema Claro
  /// - Diseño moderno flotante con bordes
  /// - Fondo blanco con borde de color según tipo
  /// - Texto en negro
  /// - Comportamiento flotante desde abajo
  /// NOTA: El color del borde se debe especificar en cada SnackBar individual
  static SnackBarThemeData get snackBarLight {
    return SnackBarThemeData(
      backgroundColor: Colors.white,
      contentTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'PlusJakartaSans',
        letterSpacing: 0.2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColorsLight.outline, // Borde por defecto
          width: 1.5,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 3,
      actionTextColor: AppColorsLight.primary,
      closeIconColor: Colors.black54,
      showCloseIcon: false,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      width: null,
    );
  }

  // ==========================================
  // 🌙 TEMA OSCURO
  // ==========================================

  /// AppBar - Tema Oscuro
  /// Similar al claro pero con fondo negro
  static AppBarTheme get appBarDark {
    return  AppBarTheme(
      backgroundColor: Colors.black,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      ),
      elevation: 0,
      iconTheme: IconThemeData(
        color: AppColorsDark.primary,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: AppColorsDark.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlusJakartaSans',
      ),
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
      side:  BorderSide(
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
  /// - Track activo: primary con opacidad
  /// - Track inactivo: outline
  /// - Thumb activo: primary
  /// - Thumb inactivo: surfaceContainerHighest
  static SwitchThemeData get switchDark {
    return SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.primary.withValues(alpha: 0.5);
        }
        return AppColorsDark.outline;
      }),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.primary;
        }
        return AppColorsDark.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsDark.primary;
        }
        return AppColorsDark.outline;
      }),
    );
  }

  /// Tabs - Tema Oscuro
  /// - Tab seleccionada: primary color con fondo
  /// - Tab no seleccionada: gris con opacidad
  /// - Indicador: primary color con border radius y sombra
  /// - Tipografía mejorada con mejor peso y tamaño
  static TabBarThemeData get tabBarDark {
    return TabBarThemeData(
      labelColor: AppColorsDark.onPrimary,
      unselectedLabelColor: AppColorsDark.onSurface.withValues(alpha: 0.7),
      indicatorColor: AppColorsDark.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: BoxDecoration(
        color: AppColorsDark.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColorsDark.primary.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      labelStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        fontFamily: 'PlusJakartaSans',
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        fontFamily: 'PlusJakartaSans',
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColorsDark.primary.withValues(alpha: 0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return AppColorsDark.primary.withValues(alpha: 0.05);
        }
        return null;
      }),
      splashFactory: InkRipple.splashFactory,
      dividerColor: AppColorsDark.outline.withValues(alpha: 0.1),
      dividerHeight: 1,
    );
  }

  /// Sliders - Tema Oscuro
  /// - Track activo: primary (verde)
  /// - Track inactivo: primary con baja opacidad
  /// - Thumb: primary
  /// - Overlay: primary con opacidad
  static SliderThemeData get sliderDark {
    return SliderThemeData(
      trackHeight: 4.0,
      trackShape: const RoundedRectSliderTrackShape(),
      activeTrackColor: AppColorsDark.primary,
      inactiveTrackColor: AppColorsDark.primary.withValues(alpha: 0.2),
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 10.0,
        pressedElevation: 4.0,
      ),
      thumbColor: AppColorsDark.primary,
      overlayColor: AppColorsDark.primary.withValues(alpha: 0.15),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
      tickMarkShape: const RoundSliderTickMarkShape(),
      activeTickMarkColor: AppColorsDark.onPrimary,
      inactiveTickMarkColor: AppColorsDark.primary.withValues(alpha: 0.3),
      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      valueIndicatorColor: AppColorsDark.primary,
      valueIndicatorTextStyle: const TextStyle(
        color: AppColorsDark.onPrimary,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlusJakartaSans',
      ),
    );
  }

  /// Iconos - Tema Oscuro
  static IconThemeData get iconDark {
    return IconThemeData(
      color: AppColorsDark.primary,
      size: 24,
    );
  }

  /// ProgressIndicator - Tema Oscuro
  static ProgressIndicatorThemeData get progressIndicatorDark {
    return ProgressIndicatorThemeData(
      color: AppColorsDark.primary,
    );
  }

  /// BottomSheets - Tema Oscuro
  /// - Fondo: surfaceContainer
  /// - Bordes redondeados superiores
  static BottomSheetThemeData get bottomSheetDark {
    return const BottomSheetThemeData(
      backgroundColor: AppColorsDark.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  /// Cards - Tema Oscuro
  /// - Bordes redondeados con radio 12
  /// - Elevación 0 (sin sombra por defecto)
  static CardThemeData get cardDark {
    return const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  /// Dialogs - Tema Oscuro
  /// - Bordes redondeados modernos (20px)
  /// - Fondo surfaceContainer
  /// - Elevación suave
  static DialogThemeData get dialogDark {
    return DialogThemeData(
      backgroundColor: AppColorsDark.surfaceContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        color: AppColorsDark.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlusJakartaSans',
      ),
      contentTextStyle: const TextStyle(
        color: AppColorsDark.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'PlusJakartaSans',
        height: 1.5,
      ),
      actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    );
  }

  /// SnackBars - Tema Oscuro
  /// - Diseño moderno flotante
  /// - Bordes redondeados
  /// - Sombra suave
  /// - Comportamiento flotante desde abajo
  static SnackBarThemeData get snackBarDark {
    return SnackBarThemeData(
      backgroundColor: AppColorsDark.surfaceContainerHighest,
      contentTextStyle: const TextStyle(
        color: AppColorsDark.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'PlusJakartaSans',
        letterSpacing: 0.2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      actionTextColor: AppColorsDark.primary,
      closeIconColor: AppColorsDark.onSurface.withValues(alpha: 0.6),
      showCloseIcon: false, // Lo controlaremos manualmente si es necesario
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      width: null, // Ancho automático con padding
    );
  }
}

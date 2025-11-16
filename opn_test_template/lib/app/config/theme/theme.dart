import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_button_theme.dart';
import 'app_component_theme.dart';
import 'app_input_theme.dart';
import 'app_text_theme.dart';
import 'color.dart';

/// 🎨 Configuración Principal de Temas de la Aplicación
///
/// Este archivo define los temas claro y oscuro de la app.
/// Los temas están organizados en módulos separados para facilitar el mantenimiento.
///
/// **Módulos del sistema de temas:**
/// - `color.dart` - Paleta de colores
/// - `app_text_theme.dart` - Estilos de tipografía
/// - `app_button_theme.dart` - Estilos de botones
/// - `app_input_theme.dart` - Estilos de campos de texto
/// - `app_component_theme.dart` - Otros componentes (AppBar, Checkbox, etc.)
/// - `app_icons.dart` - Iconos personalizados
///
/// **Cómo usar:**
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,        // Tema claro
///   darkTheme: AppTheme.dark,     // Tema oscuro
///   themeMode: ThemeMode.system,  // Automático según el sistema
/// )
/// ```
///
/// **Ver también:** `theme/README.md` para documentación completa
abstract class AppTheme {
  // ==========================================
  // 🌞 TEMA CLARO
  // ==========================================

  /// Configuración completa del tema claro
  /// Incluye todos los estilos y componentes de la app
  static ThemeData get light {
    return ThemeData(
      // Desactiva Material 3 para mantener compatibilidad
      useMaterial3: false,

      // 🎨 Esquema de colores
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColorsLight.primary,
        primary: AppColorsLight.primary,
        primaryContainer: AppColorsLight.primaryContainer,
        secondary: AppColorsLight.secondary,
        secondaryContainer: AppColorsLight.secondaryContainer,
        tertiary: AppColorsLight.tertiary,
        tertiaryContainer: AppColorsLight.tertiaryContainer,
        surface: AppColorsLight.surface,
        surfaceContainer: AppColorsLight.surfaceContainer,
        surfaceContainerHighest: AppColorsLight.surfaceContainerHighest,
        surfaceContainerLowest: AppColorsLight.surfaceContainerLowest,
        error: AppColorsLight.error,
        onPrimary: AppColorsLight.onPrimary,
        onPrimaryContainer: AppColorsLight.onPrimaryContainer,
        onSecondary: AppColorsLight.onSecondary,
        onSecondaryContainer: AppColorsLight.onSecondaryContainer,
        onTertiary: AppColorsLight.onTertiary,
        onTertiaryContainer: AppColorsLight.onTertiaryContainer,
        onSurface: AppColorsLight.onSurface,
        onError: AppColorsLight.onError,
        brightness: Brightness.light,
        outline: AppColorsLight.outline,
        outlineVariant: AppColorsLight.outlineVariant,
        shadow: const Color.fromARGB(255, 63, 62, 62),
      ),

      // 🏞️ Fondo del Scaffold
      scaffoldBackgroundColor: AppColorsLight.background,

      // 📝 Tipografía
      fontFamily: AppTextTheme.fontFamily,
      textTheme: AppTextTheme.light,

      // 🔘 Botones
      elevatedButtonTheme: AppButtonTheme.elevatedLight,
      filledButtonTheme: AppButtonTheme.filledLight,
      outlinedButtonTheme: AppButtonTheme.outlinedLight,

      // 📝 Campos de texto
      inputDecorationTheme: AppInputTheme.light,

      // 🎯 Componentes diversos
      appBarTheme: AppComponentTheme.appBarLight,
      iconTheme: AppComponentTheme.iconLight,
      progressIndicatorTheme: AppComponentTheme.progressIndicatorLight,
      checkboxTheme: AppComponentTheme.checkboxLight,
      switchTheme: AppComponentTheme.switchLight,
      tabBarTheme: AppComponentTheme.tabBarLight,
      sliderTheme: AppComponentTheme.sliderLight,
      scrollbarTheme: AppComponentTheme.scrollbarLight,
      bottomSheetTheme: AppComponentTheme.bottomSheetLight,
      cardTheme: AppComponentTheme.cardLight,
      dialogTheme: AppComponentTheme.dialogLight,
      snackBarTheme: AppComponentTheme.snackBarLight,

      // 📱 Transiciones de página (estilo iOS en Android)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ==========================================
  // 🌙 TEMA OSCURO
  // ==========================================

  /// Configuración completa del tema oscuro
  /// Optimizado para ambientes con poca luz
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: false,

      // 🎨 Esquema de colores oscuro
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColorsDark.primary,
        primary: AppColorsDark.primary,
        primaryContainer: AppColorsDark.primaryContainer,
        secondary: AppColorsDark.secondary,
        secondaryContainer: AppColorsDark.secondaryContainer,
        tertiary: AppColorsDark.tertiary,
        tertiaryContainer: AppColorsDark.tertiaryContainer,
        surface: AppColorsDark.surface,
        surfaceContainer: AppColorsDark.surfaceContainer,
        surfaceContainerHighest: AppColorsDark.surfaceContainerHighest,
        surfaceContainerLowest: AppColorsDark.surfaceContainerLowest,
        error: AppColorsDark.error,
        onPrimary: AppColorsDark.onPrimary,
        onPrimaryContainer: AppColorsDark.onPrimaryContainer,
        onSecondary: AppColorsDark.onSecondary,
        onSecondaryContainer: AppColorsDark.onSecondaryContainer,
        onTertiary: AppColorsDark.onTertiary,
        onTertiaryContainer: AppColorsDark.onTertiaryContainer,
        onSurface: AppColorsDark.onSurface,
        onError: AppColorsDark.onError,
        brightness: Brightness.dark,
        outline: AppColorsDark.outline,
        outlineVariant: AppColorsDark.outlineVariant,
        shadow: const Color.fromARGB(255, 207, 207, 207),
      ),

      // 🏞️ Fondo del Scaffold
      scaffoldBackgroundColor: AppColorsDark.surface,

      // 📝 Tipografía
      fontFamily: AppTextTheme.fontFamily,
      textTheme: AppTextTheme.dark,

      // 🔘 Botones
      elevatedButtonTheme: AppButtonTheme.elevatedDark,
      filledButtonTheme: AppButtonTheme.filledDark,
      outlinedButtonTheme: AppButtonTheme.outlinedDark,

      // 📝 Campos de texto
      inputDecorationTheme: AppInputTheme.dark,

      // 🎯 Componentes diversos
      appBarTheme: AppComponentTheme.appBarDark,
      iconTheme: AppComponentTheme.iconDark,
      progressIndicatorTheme: AppComponentTheme.progressIndicatorDark,
      checkboxTheme: AppComponentTheme.checkboxDark,
      switchTheme: AppComponentTheme.switchDark,
      tabBarTheme: AppComponentTheme.tabBarDark,
      sliderTheme: AppComponentTheme.sliderDark,
      scrollbarTheme: AppComponentTheme.scrollbarLight, // Mismo que light
      bottomSheetTheme: AppComponentTheme.bottomSheetDark,
      cardTheme: AppComponentTheme.cardDark,
      dialogTheme: AppComponentTheme.dialogDark,
      snackBarTheme: AppComponentTheme.snackBarDark,

      // 📱 Transiciones de página (estilo iOS en Android)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ==========================================
  // 🎨 UTILIDADES ADICIONALES
  // ==========================================

  /// Configuración de Slider personalizada
  /// Puede usarse para sobrescribir el slider del tema si es necesario
  ///
  /// **Uso:**
  /// ```dart
  /// SliderTheme(
  ///   data: AppTheme.sliderTheme,
  ///   child: Slider(...),
  /// )
  /// ```
  @Deprecated('Usa AppComponentTheme.sliderLight directamente')
  static SliderThemeData get slideTheme => AppComponentTheme.sliderLight;
}

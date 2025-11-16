import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_button_theme.dart';
import 'app_component_theme.dart';
import 'app_input_theme.dart';
import 'app_text_theme.dart';
import 'color.dart';

/// 🎨 Configuración Principal de Temas de la Aplicación
abstract class AppTheme {
  // ==========================================
  // 🌞 TEMA CLARO
  // ==========================================
  static ThemeData get light {
    return ThemeData(
      useMaterial3: false,
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
      scaffoldBackgroundColor: AppColorsLight.background,
      fontFamily: AppTextTheme.fontFamily,
      textTheme: AppTextTheme.light,
      elevatedButtonTheme: AppButtonTheme.elevatedLight,
      outlinedButtonTheme: AppButtonTheme.outlinedLight,
      inputDecorationTheme: AppInputTheme.light,
      appBarTheme: AppComponentTheme.appBarLight,
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColorsLight.outlineVariant,
            width: 1,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColorsLight.outlineVariant,
            width: 1,
          ),
        ),
      ),
      iconTheme: AppComponentTheme.iconLight,
      progressIndicatorTheme: AppComponentTheme.progressIndicatorLight,
      checkboxTheme: AppComponentTheme.checkboxLight,
      switchTheme: AppComponentTheme.switchLight,
      tabBarTheme: AppComponentTheme.tabBarLight,
      sliderTheme: AppComponentTheme.sliderLight,
      scrollbarTheme: AppComponentTheme.scrollbarLight,
      snackBarTheme: AppComponentTheme.snackBarLight,
      bottomSheetTheme: AppComponentTheme.bottomSheetLight,
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
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: false,
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
      scaffoldBackgroundColor: AppColorsDark.surface,
      fontFamily: AppTextTheme.fontFamily,
      textTheme: AppTextTheme.dark,
      elevatedButtonTheme: AppButtonTheme.elevatedDark,
      outlinedButtonTheme: AppButtonTheme.outlinedDark,
      inputDecorationTheme: AppInputTheme.dark,
      appBarTheme: AppComponentTheme.appBarDark,
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColorsDark.outlineVariant,
            width: 1,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColorsDark.outlineVariant,
            width: 1,
          ),
        ),
      ),
      iconTheme: AppComponentTheme.iconDark,
      progressIndicatorTheme: AppComponentTheme.progressIndicatorDark,
      checkboxTheme: AppComponentTheme.checkboxDark,
      switchTheme: AppComponentTheme.switchDark,
      tabBarTheme: AppComponentTheme.tabBarDark,
      scrollbarTheme: AppComponentTheme.scrollbarLight,
      snackBarTheme: AppComponentTheme.snackBarDark,
      bottomSheetTheme: AppComponentTheme.bottomSheetDark,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

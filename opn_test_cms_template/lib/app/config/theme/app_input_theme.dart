import 'package:flutter/material.dart';
import 'color.dart';

/// 📝 Configuración de Estilos para Campos de Texto
abstract class AppInputTheme {
  // ==========================================
  // 🌞 TEMA CLARO
  // ==========================================

  static InputDecorationTheme get light {
    return InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorsLight.outlineVariant,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorsLight.outlineVariant,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorsLight.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorsLight.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorsLight.error,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColorsLight.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      fillColor: AppColorsLight.surface,
      filled: true,
      labelStyle: TextStyle(
        color: AppColorsLight.onSurfaceVariant,
        fontSize: 12,
      ),
      hintStyle: TextStyle(
        color: AppColorsLight.onSurfaceVariant,
        fontSize: 12,
      ),
      errorStyle: const TextStyle(
        color: AppColorsLight.error,
        fontSize: 12,
      ),
      iconColor: AppColorsLight.onSurface,
      prefixIconColor: AppColorsLight.onSurface,
      suffixIconColor: AppColorsLight.onSurface,

    );
  }

  // ==========================================
  // 🌙 TEMA OSCURO
  // ==========================================

  static InputDecorationTheme get dark {
    return InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorsDark.outlineVariant,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorsDark.outlineVariant,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorsDark.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorsDark.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColorsDark.error,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColorsDark.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      fillColor: AppColorsDark.surfaceContainer,
      filled: true,
      labelStyle: TextStyle(
        color: AppColorsDark.onSurfaceVariant,
        fontSize: 12,
      ),
      hintStyle: TextStyle(
        color: AppColorsDark.onSurfaceVariant,
        fontSize: 12,
      ),
      errorStyle: const TextStyle(
        color: AppColorsDark.error,
        fontSize: 12,
      ),
      iconColor: AppColorsDark.onSurface,
      prefixIconColor: AppColorsDark.onSurface,
      suffixIconColor: AppColorsDark.onSurface,
    );
  }
}
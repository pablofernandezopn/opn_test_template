import 'package:flutter/material.dart';


import 'color.dart';

/// 📝 Configuración de Campos de Texto (TextField/TextFormField)
///
/// Define los estilos para todos los campos de entrada de texto.
/// Los TextFields automáticamente heredan estos estilos.
///
/// **Características:**
/// - Border radius: 8px
/// - Padding interno: 16px horizontal, 12px vertical
/// - Fondo relleno (filled)
/// - Diseño compacto (isDense: true)
///
/// **Uso:**
/// ```dart
/// TextField(
///   decoration: InputDecoration(
///     labelText: 'Email',
///     hintText: 'Ingresa tu email',
///   ),
/// )
/// ```
abstract class AppInputTheme {
  // ==========================================
  // 🌞 TEMA CLARO
  // ==========================================

  /// Decoración de campos de texto - Tema Claro
  /// - Fondo: Blanco
  /// - Borde: primary (cuando está enfocado)
  /// - Border radius: 8px
  /// - Iconos: color primary
  static InputDecorationTheme get light {
    return InputDecorationTheme(
      // Fondo relleno
      filled: true,
      fillColor: Colors.white,

      // Borde del campo
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorsLight.outline),
      ),

      // Borde cuando el campo está enfocado
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColorsLight.primary,
          width: 2,
        ),
      ),

      // Borde cuando hay un error
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColorsLight.error,
          width: 1,
        ),
      ),

      // Padding interno del campo
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      // Diseño más compacto
      isDense: true,

      // Color de los iconos
      iconColor: AppColorsLight.primary,
      prefixIconColor: AppColorsLight.primary,
      suffixIconColor: AppColorsLight.primary,
    );
  }

  // ==========================================
  // 🌙 TEMA OSCURO
  // ==========================================

  /// Decoración de campos de texto - Tema Oscuro
  /// - Fondo: Gris oscuro (grey[800])
  /// - Borde: primary oscuro
  /// - Border radius: 8px
  /// - Iconos: color primary
  static InputDecorationTheme get dark {
    return InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColorsDark.outline),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColorsDark.primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColorsDark.error,
          width: 1,
        ),
      ),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      isDense: true,

      iconColor: AppColorsDark.primary,
      prefixIconColor: AppColorsDark.primary,
      suffixIconColor: AppColorsDark.primary,
    );
  }
}


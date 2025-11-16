import 'package:flutter/material.dart';

import 'color.dart';

/// 🔘 Configuración de Botones de la Aplicación
///
/// Define los estilos para todos los tipos de botones.
/// Los botones automáticamente heredan estos estilos.
///
/// **Tipos de botones:**
/// - ElevatedButton: Botón principal con fondo sólido
/// - OutlinedButton: Botón secundario con borde
///
/// **Uso:**
/// ```dart
/// ElevatedButton(
///   onPressed: () {},
///   child: Text('Acción Principal'),
/// )
///
/// OutlinedButton(
///   onPressed: () {},
///   child: Text('Acción Secundaria'),
/// )
/// ```
abstract class AppButtonTheme {
  // ==========================================
  // 🌞 TEMA CLARO
  // ==========================================

  /// Botón elevado (fondo sólido) - Tema Claro
  /// - Color de fondo: primary
  /// - Color de texto: blanco
  /// - Altura mínima: 48px
  /// - Ancho: 100% del contenedor
  /// - Border radius: 8px
  /// - Sin elevación (flat design)
  static ElevatedButtonThemeData get elevatedLight {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'PlusJakartaSans',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(double.infinity, 48),
        elevation: 0, // Sin sombra - diseño plano
      ).merge(
        ButtonStyle(
          // Color de fondo según estado
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColorsLight.disabled; // Gris cuando está deshabilitado
            }
            return AppColorsLight.primary; // Verde principal cuando está activo
          }),
          // Color del texto siempre blanco
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        ),
      ),
    );
  }

  /// Botón con borde (outline) - Tema Claro
  /// - Sin fondo (transparente)
  /// - Borde: primary (1px)
  /// - Color de texto: primary
  /// - Altura mínima: 48px
  /// - Ancho: 100% del contenedor
  /// - Border radius: 8px
  static OutlinedButtonThemeData get outlinedLight {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'PlusJakartaSans',
        ),
        foregroundColor: AppColorsLight.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(double.infinity, 48),
      ).copyWith(
        // Borde del botón
        side: WidgetStateProperty.all<BorderSide>(
          const BorderSide(color: AppColorsLight.primary, width: 1),
        ),
      ),
    );
  }

  // ==========================================
  // 🌙 TEMA OSCURO
  // ==========================================

  /// Botón elevado (fondo sólido) - Tema Oscuro
  /// Mismas características que el tema claro pero con colores adaptados
  static ElevatedButtonThemeData get elevatedDark {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'PlusJakartaSans',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(double.infinity, 48),
        elevation: 0,
      ).merge(
        ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColorsDark.disabled;
            }
            return AppColorsDark.primary;
          }),
          foregroundColor: WidgetStateProperty.all<Color>(
            AppColorsDark.onPrimary, // Texto sobre el color primario
          ),
        ),
      ),
    );
  }

  /// Botón con borde (outline) - Tema Oscuro
  /// Mismas características que el tema claro pero con colores adaptados
  static OutlinedButtonThemeData get outlinedDark {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'PlusJakartaSans',
        ),
        foregroundColor: AppColorsDark.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: const Size(double.infinity, 48),
      ).copyWith(
        side: WidgetStateProperty.all<BorderSide>(
          const BorderSide(color: AppColorsDark.primary, width: 1),
        ),
      ),
    );
  }
}


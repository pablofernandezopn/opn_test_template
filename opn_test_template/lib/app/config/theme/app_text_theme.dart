import 'package:flutter/material.dart';

import 'color.dart';

/// 📝 Configuración de Tipografía de la Aplicación
///
/// Define todos los estilos de texto utilizados en la app.
/// Basado en la fuente Plus Jakarta Sans.
///
/// **Cómo usar:**
/// ```dart
/// Text('Título', style: Theme.of(context).textTheme.titleLarge)
/// Text('Cuerpo', style: Theme.of(context).textTheme.bodyMedium)
/// ```
///
/// **Jerarquía de tamaños:**
/// - titleLarge: 32px (Títulos principales de pantalla)
/// - bodyLarge: 16px (Párrafos importantes)
/// - bodyMedium: 14px (Texto normal)
/// - bodySmall: 12px (Texto secundario)
/// - labelLarge: 14px (Etiquetas de botones)
abstract class AppTextTheme {
  /// Nombre de la fuente utilizada en toda la app
  static const String fontFamily = 'PlusJakartaSans';

  /// 🌞 Tema de texto CLARO
  /// Aplica colores para modo claro
  static TextTheme get light {
    return const TextTheme(
      // Títulos grandes - 32px Bold
      // Uso: Títulos principales de pantallas
      titleLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),

      // Texto grande - 16px Regular
      // Uso: Párrafos destacados, contenido importante
      bodyLarge: TextStyle(fontSize: 16),

      // Texto medio - 14px Regular
      // Uso: Contenido principal, descripción general
      bodyMedium: TextStyle(fontSize: 14),

      // Texto pequeño - 12px Regular
      // Uso: Notas, texto secundario, metadata
      bodySmall: TextStyle(fontSize: 12),

      // Etiquetas - 14px Medium
      // Uso: Botones, chips, tabs
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ).apply(
      fontFamily: fontFamily,
      bodyColor: AppColorsLight.onSurface, // Color del texto general
    );
  }

  /// 🌙 Tema de texto OSCURO
  /// Aplica colores para modo oscuro
  static TextTheme get dark {
    return const TextTheme(
      // Mismo tamaño que light theme
      titleLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 12),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ).apply(
      fontFamily: fontFamily,
      bodyColor: AppColorsDark.onSurface, // Color claro para modo oscuro
    );
  }
}


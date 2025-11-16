import 'package:flutter/material.dart';

/// 🎯 Iconos personalizados de la aplicación
///
/// Esta clase centraliza todos los iconos utilizados en la app.
/// Usar estos iconos en lugar de Icons directamente facilita:
/// - Mantener consistencia visual
/// - Cambiar iconos desde un solo lugar
/// - Documentar el propósito de cada icono
///
/// **Uso:**
/// ```dart
/// Icon(AppIcons.lockIcon)
/// Icon(AppIcons.correctIcon, color: Colors.green)
/// ```
abstract class AppIcons {
  // 🔒 Iconos de estado de bloqueo
  /// Representa contenido bloqueado o no accesible
  static const IconData lockIcon = Icons.lock;

  /// Representa contenido desbloqueado o accesible
  static const IconData unlockIcon = Icons.lock_open_outlined;

  // ✅ Iconos de respuestas y estados
  /// Marca de verificación para respuestas correctas o completadas
  static const IconData doneIcon = Icons.check;

  /// Marca de correcto (igual que doneIcon, pero más explícito)
  static const IconData correctIcon = Icons.check;

  /// Marca X para respuestas incorrectas
  static const IconData wrongIcon = Icons.close;

  /// Círculo vacío para respuestas en blanco o sin contestar
  static const IconData blankIcon = Icons.circle_outlined;

  // ▶️ Iconos de control de exámenes
  /// Botón de inicio o play para comenzar exámenes
  static const IconData makeTestIcon = Icons.play_circle_outline;

  /// Botón de parada para detener o finalizar exámenes
  static const IconData stopTestIcon = Icons.stop_circle_outlined;

  // 🏆 Iconos de logros y estadísticas
  /// Medalla o premio para logros destacados
  static const IconData medalIcon = Icons.workspace_premium_sharp;

  /// Tendencia al alza para mejores temas
  static const IconData bestTopicIcon = Icons.trending_up_rounded;

  /// Advertencia para temas con peor rendimiento
  static const IconData worstTopicIcon = Icons.warning_amber_rounded;

  // 📊 Iconos de comparación
  /// Indica igualdad en comparaciones
  static const IconData compareEquals = Icons.compare_arrows;

  /// Flecha hacia abajo, indica disminución o peor rendimiento
  static const IconData compareLess = Icons.arrow_downward;

  /// Flecha hacia arriba, indica aumento o mejor rendimiento
  static const IconData compareMore = Icons.arrow_upward;
}

import 'package:flutter/material.dart';

/// 🎨 Extensiones para ColorScheme
///
/// Estas extensiones añaden colores personalizados de la aplicación
/// al ColorScheme estándar de Material Design.
///
/// **Uso:**
/// ```dart
/// final color = Theme.of(context).colorScheme.success;
/// final warningColor = Theme.of(context).colorScheme.warning;
/// ```
extension TopicStateColorExtention on ColorScheme {
  // ==========================================
  // 🎨 COLORES ESPECIALES DE LA APP
  // ==========================================

  /// ✅ Color topics con estado 'Freemium'
  Color get freemium => brightness == Brightness.light
      ? Colors.green.shade600
      : Colors.green.shade600;

  /// ✅ Color topics con estado 'Premium'
  Color get premium => brightness == Brightness.light
      ? Colors.amber.shade700
      : Colors.amber.shade700;

  /// ✅ Color topics con estado 'hiddenButPremium'

  Color get hiddenButPremium => brightness == Brightness.light
      ? Colors.purple.shade600
      : Colors.purple.shade600;
}

/// 🎨 Extensión adicional para facilitar el acceso a variantes de colores
extension ValidationItemExtention on ColorScheme {
  /// Genera una versión más clara del color primario
  Color get completedBackground => brightness == Brightness.light
      ? Colors.green.withValues(alpha: 0.1)
      : Colors.green.withValues(alpha: 0.1);

  Color get notCompletedBackground => brightness == Brightness.light
      ? Colors.orange.withValues(alpha: 0.1)
      : Colors.orange.withValues(alpha: 0.1);

  Color get completed =>
      brightness == Brightness.light ? Colors.green : Colors.green;

  Color get notCompleted =>
      brightness == Brightness.light ? Colors.orange : Colors.orange;

  Color get barCompleted => brightness == Brightness.light
      ? Colors.green.withValues(alpha: 0.1)
      : Colors.green.withValues(alpha: 0.1);

  Color get barNotCompleted => brightness == Brightness.light
      ? Colors.orange.withValues(alpha: 0.1)
      : Colors.orange.withValues(alpha: 0.1);

  Color get progressBarBackground => brightness == Brightness.light
      ? Colors.grey.shade100
      : Colors.grey.shade100;

  Color get success => brightness == Brightness.light
      ? Colors.green.shade600
      : Colors.green.shade600;
}

/// 🎯 Extensión para obtener colores semánticos según el contexto
extension UserStatsPageColorsExtention on ColorScheme {
  Color get totalTests =>
      brightness == Brightness.light ? Colors.blue : Colors.blue;

  Color get mediumScores =>
      brightness == Brightness.light ? Colors.orange : Colors.orange;

  Color get successRate =>
      brightness == Brightness.light ? Colors.green : Colors.green;

  Color get errorRate =>
      brightness == Brightness.light ? Colors.red : Colors.red;

  Color get dropRate =>
      brightness == Brightness.light ? Colors.grey : Colors.grey;

  // ==========================================
  // 🏆 COLORES PARA BADGES E INDICADORES
  // ==========================================

  /// Badge Elite (Índice OPN >= 800)
  Color get badgeElite =>
      brightness == Brightness.light ? Colors.purple : Colors.purple;

  /// Badge Excelente (Índice OPN >= 600 o Nota >= 7)
  Color get badgeExcellent =>
      brightness == Brightness.light ? Colors.green : Colors.green;

  /// Badge Bueno (Índice OPN >= 400 o Nota >= 5)
  Color get badgeGood =>
      brightness == Brightness.light ? Colors.blue : Colors.blue;

  /// Badge Regular (Índice OPN >= 200 o Nota >= 4)
  Color get badgeRegular =>
      brightness == Brightness.light ? Colors.orange : Colors.orange;

  /// Badge Inicial/Sin datos (Índice OPN > 0 o Nota < 4)
  Color get badgeInitial =>
      brightness == Brightness.light ? Colors.grey : Colors.grey;

  /// Badge para actividad muy activa
  Color get badgeVeryActive =>
      brightness == Brightness.light ? Colors.green : Colors.green;

  /// Badge para actividad intermedia
  Color get badgeActive =>
      brightness == Brightness.light ? Colors.blue : Colors.blue;

  /// Badge para poca actividad
  Color get badgeLowActivity =>
      brightness == Brightness.light ? Colors.orange : Colors.orange;

  /// Badge para experiencia veterano
  Color get badgeVeteran =>
      brightness == Brightness.light ? Colors.purple : Colors.purple;

  /// Badge para experiencia nuevo
  Color get badgeNew =>
      brightness == Brightness.light ? Colors.green : Colors.green;

  /// Badge para mejorar (nota < 4)
  Color get badgeNeedsImprovement =>
      brightness == Brightness.light ? Colors.red : Colors.red;

  // ==========================================
  // 📊 COLORES PARA GRÁFICAS
  // ==========================================

  /// Color de línea para tasa de acierto en gráficas
  Color get chartSuccessLine =>
      brightness == Brightness.light ? Colors.green : Colors.green;

  /// Color de línea para tasa de error en gráficas
  Color get chartErrorLine =>
      brightness == Brightness.light ? Colors.red : Colors.red;

  /// Color de línea para tasa de abandono en gráficas
  Color get chartEmptyLine =>
      brightness == Brightness.light ? Colors.grey : Colors.grey;

  /// Color oscuro para puntos destacados en gráfico de acierto
  Color get chartSuccessDot => brightness == Brightness.light
      ? Colors.green.shade700
      : Colors.green.shade700;

  /// Color de área bajo la línea de acierto
  Color get chartSuccessAreaLight => brightness == Brightness.light
      ? Colors.green.withOpacity(0.1)
      : Colors.green.withOpacity(0.1);

  /// Color de área bajo la línea de error
  Color get chartErrorAreaLight => brightness == Brightness.light
      ? Colors.red.withOpacity(0.1)
      : Colors.red.withOpacity(0.1);

  /// Color de área bajo la línea de abandono
  Color get chartEmptyAreaLight => brightness == Brightness.light
      ? Colors.grey.withOpacity(0.1)
      : Colors.grey.withOpacity(0.1);

  /// Color de stroke para puntos en el gráfico
  Color get chartDotStroke =>
      brightness == Brightness.light ? Colors.white : Colors.white;

  /// Color de texto en tooltips
  Color get chartTooltipText =>
      brightness == Brightness.light ? Colors.white : Colors.white;

  // ==========================================
  // 🎯 COLORES PARA PROGRESO Y BARRAS
  // ==========================================

  /// Color de progreso alto (>= 0.8)
  Color get progressHigh =>
      brightness == Brightness.light ? Colors.green : Colors.green;

  /// Color de progreso medio-alto (>= 0.6)
  Color get progressMediumHigh =>
      brightness == Brightness.light ? Colors.blue : Colors.blue;

  /// Color de progreso medio-bajo (>= 0.4)
  Color get progressMediumLow =>
      brightness == Brightness.light ? Colors.orange : Colors.orange;

  /// Color de progreso bajo (< 0.4)
  Color get progressLow =>
      brightness == Brightness.light ? Colors.red : Colors.red;

  /// Color verde para aciertos en barra segmentada
  Color get segmentedBarSuccess =>
      brightness == Brightness.light ? Colors.green : Colors.green;

  /// Color rojo para errores en barra segmentada
  Color get segmentedBarError =>
      brightness == Brightness.light ? Colors.red : Colors.red;

  // ==========================================
  // 🎨 COLORES DE SOMBRA Y OVERLAY
  // ==========================================

  /// Sombra ligera para elevación baja
  Color get shadowLight => brightness == Brightness.light
      ? Colors.black.withOpacity(0.05)
      : Colors.black.withOpacity(0.05);

  /// Sombra media para elevación estándar
  Color get shadowMedium => brightness == Brightness.light
      ? Colors.black.withOpacity(0.1)
      : Colors.black.withOpacity(0.1);

  // ==========================================
  // 🔧 COLORES UTILITARIOS
  // ==========================================

  /// Color transparente para fondos
  Color get transparent => Colors.transparent;

  /// Color verde para SnackBar de éxito
  Color get snackbarSuccess =>
      brightness == Brightness.light ? Colors.green : Colors.green;

  /// Color rojo para SnackBar de error
  Color get snackbarError =>
      brightness == Brightness.light ? Colors.red : Colors.red;

  /// Color para notas excelentes (>= 8.0)
  Color get scoreExcellent =>
      brightness == Brightness.light ? Colors.green : Colors.green;

  /// Color para notas buenas (>= 5.0)
  Color get scoreGood =>
      brightness == Brightness.light ? Colors.orange : Colors.orange;

  /// Color para notas bajas (< 5.0)
  Color get scorePoor =>
      brightness == Brightness.light ? Colors.red : Colors.red;
}

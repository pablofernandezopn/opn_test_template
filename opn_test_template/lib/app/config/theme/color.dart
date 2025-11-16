import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:opn_test_template/config/flavor_config.dart';

/// 🎨 Paleta de Colores Base de la Aplicación
///
/// ⚠️ IMPORTANTE: Los colores ahora vienen del FlavorConfig.
/// Cada flavor (Guardia Civil, Policía Nacional, etc.) tiene su propia paleta.
///
/// Colores genéricos utilizados en toda la app.
/// Estos colores NO están vinculados al tema (light/dark).
///
/// **⚠️ Nota:** Preferir usar colores del ColorScheme del tema
/// en lugar de estos colores directamente.
///
/// **Uso:**
/// ```dart
/// // ❌ Evitar:
/// Container(color: AppColors.blue)
///
/// // ✅ Preferir:
/// Container(color: Theme.of(context).colorScheme.primary)
/// ```
abstract class AppColors {
  // ==========================================
  // 🎨 COLORES PRINCIPALES DE LA APP
  // ==========================================

  /// Blanco principal
  static const white = Color(0xFFFFFFFF);

  /// Negro principal
  static const black = Color(0xFF242424);

  /// Amarillo principal
  static const yellow = Color(0xFFFFD15C);

  /// Rojo principal
  static const red = Color(0xFFFF4949);

  /// Verde principal
  static const green = Color(0xFF018b5e);

  // ==========================================
  // 🎨 VARIACIONES Y GRISES
  // ==========================================

  static const grey = Color(0xFF666666);
  static const greyLight = Color(0xFFF2F2F2);
  static const greyMedium = Color(0xFFB4B4B4);

  // ==========================================
  // 🏆 COLORES DE LOGROS/MEDALLAS
  // ==========================================

  static const gold = Color(0xffffd700);
  static const goldLight = Color(0xFFE4A200);
  static const silver = Color(0xffafafaf);
  static const silverLight = Color(0xFF688389);
  static const bronze = Color(0xffCD7F32);
  static const bronzeLight = Color(0xFFCC7E48);

  // Colores de acción
  static const orange = Color(0xFFFFD15C);
  static const orangeHight = Color(0xFFEDA90E);
  static const orangeMedium = Color(0xFFFFD785);
  static const greenAction = Color(0xFF168F4F);
  static const redAction = Color(0xFFFF4949);
  static const yellowAction = Colors.yellow;

  // ==========================================
  // 🎨 COLORES ESPECIALES
  // ==========================================

  /// Amarillo para warnings y destacados
  static const Color accent = Color(0xFFFFD15C);

  /// Verde para éxito
  static const Color success = Color(0xFF018b5e);

  // ==========================================
  // ⏱️ POMODORO (COLORES ESPECIALES)
  // ==========================================

  /// Fondo para modo Focus del Pomodoro
  static Color pomodoroBgColorFocus =
      const Color(0xFFFF4949).withValues(alpha: 0.15);

  /// Fondo para descanso corto del Pomodoro
  static Color pomodoroBgColorShortBreak =
      const Color(0xFF018b5e).withValues(alpha: 0.15);

  /// Fondo para descanso largo del Pomodoro
  static Color pomodoroBgColorLongBreak =
      const Color(0xFFFFD15C).withValues(alpha: 0.15);
}

// ============================================
// 🌞 TEMA CLARO (LIGHT THEME)
// ============================================

/// Paleta de colores para el Tema Claro
///
/// ⚠️ LOS COLORES AHORA VIENEN DEL FLAVORCONFIG
/// Cada flavor tiene su propia paleta de colores definida en config.json
///
/// **Guardia Civil:** Verde (#018b5e)
/// **Policía Nacional:** Azul (#042771)
abstract class AppColorsLight {
  // ==========================================
  // 🎨 COLORES PRINCIPALES (DESDE FLAVORCONFIG)
  // ==========================================

  /// 🎨 Color Principal (Primary) - Viene del flavor
  static Color get primary => FlavorConfig.instance.primaryColor;

  /// 🎨 Color Principal Claro - Viene del flavor
  static Color get primaryLight => FlavorConfig.instance.primaryLight;

  /// 🎨 Color Principal Oscuro - Viene del flavor
  static Color get primaryDark => FlavorConfig.instance.primaryDark;

  /// 🎨 Contenedor Principal (Primary Container) - Viene del flavor
  static Color get primaryContainer => FlavorConfig.instance.primaryContainer;

  // ==========================================
  // 🔹 COLORES SECUNDARIOS (DESDE FLAVORCONFIG)
  // ==========================================

  /// 🟡 Color Secundario (Secondary) - Viene del flavor
  static Color get secondary => FlavorConfig.instance.secondaryColor;

  /// 📦 Contenedor Secundario (Secondary Container) - Viene del flavor
  static Color get secondaryContainer => FlavorConfig.instance.secondaryContainer;

  // ==========================================
  // ⭐ COLORES TERCIARIOS/ACENTO (DESDE FLAVORCONFIG)
  // ==========================================

  /// 🟡 Color Terciario (Tertiary/Accent) - Viene del flavor
  static Color get tertiary => FlavorConfig.instance.accentColor;

  /// 💡 Contenedor Terciario (Tertiary Container) - Viene del flavor
  static Color get tertiaryContainer => FlavorConfig.instance.tertiaryContainer;

  // ==========================================
  // 🏞️ FONDOS Y SUPERFICIES (DESDE FLAVORCONFIG)
  // ==========================================

  /// 🏞️ Fondo General (Background) - Viene del flavor
  static Color get background => FlavorConfig.instance.backgroundColor;

  /// 🃏 Superficie (Surface) - Viene del flavor
  static Color get surface => FlavorConfig.instance.surfaceColor;

  /// 📋 Contenedor de Superficie (Surface Container)
  static const Color surfaceContainer = Color(0xFFFFFFFF);

  /// 📊 Contenedor de Superficie Máximo
  static const Color surfaceContainerHighest = Color(0xFFF5F5F5);

  /// 📄 Contenedor de Superficie Mínimo
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  // ==========================================
  // ✍️ COLORES "ON" (TEXTO/ICONOS)
  // ==========================================

  /// Texto blanco sobre verde
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Texto verde oscuro sobre fondos claros
  static const Color onPrimaryContainer = Color(0xFF004D3D);

  /// Texto oscuro sobre amarillo
  static const Color onSecondary = Color(0xFF242424);

  /// Texto sobre contenedor secundario
  static const Color onSecondaryContainer = Color(0xFF242424);

  /// Texto oscuro sobre terciario
  static const Color onTertiary = Color(0xFF242424);

  /// Texto sobre contenedor terciario
  static const Color onTertiaryContainer = Color(0xFF242424);

  /// Texto principal de la app
  static const Color onBackground = Color(0xFF242424);

  /// Texto en cards, dialogs, etc.
  static const Color onSurface = Color(0xFF242424);

  /// Texto secundario/hint
  static const Color onSurfaceVariant = Color(0xFF666666);

  // ==========================================
  // 🚨 ESTADOS ESPECIALES (DESDE FLAVORCONFIG)
  // ==========================================

  /// 🔴 Error - Viene del flavor
  static Color get error => FlavorConfig.instance.errorColor;

  /// Texto sobre error
  static const Color onError = Color(0xFFFFFFFF);

  // ==========================================
  // 🔲 BORDES Y DIVISORES
  // ==========================================

  /// Borde estándar
  static const Color outline = Color(0xFFD1D5DB);

  /// Variante de borde
  static const Color outlineVariant = Color(0xFFE5E7EB);

  // ==========================================
  // 🚫 DESHABILITADO
  // ==========================================

  /// Elementos deshabilitados
  static const Color disabled = Color(0xFF9CA3AF);

  // ==========================================
  // 🎨 COLORES ESPECIALES
  // ==========================================

  /// Amarillo para warnings y destacados
  static Color get accent => FlavorConfig.instance.warningColor;

  /// Verde para éxito
  static Color get success => FlavorConfig.instance.successColor;

  // ==========================================
  // ⏱️ POMODORO (COLORES ESPECIALES)
  // ==========================================

  /// Fondo para modo Focus del Pomodoro
  static Color pomodoroBgColorFocus =
      const Color(0xFFFF4949).withValues(alpha: 0.15);

  /// Fondo para descanso corto del Pomodoro
  static Color pomodoroBgColorShortBreak =
      const Color(0xFF018b5e).withValues(alpha: 0.15);

  /// Fondo para descanso largo del Pomodoro
  static Color pomodoroBgColorLongBreak =
      const Color(0xFFFFD15C).withValues(alpha: 0.15);
}

// ============================================
// 🌙 TEMA OSCURO (DARK THEME)
// ============================================

/// Paleta de colores para el Tema Oscuro
///
/// ⚠️ LOS COLORES PRINCIPALES VIENEN DEL FLAVORCONFIG
/// Los colores de superficie y fondos oscuros se mantienen fijos
abstract class AppColorsDark {
  // ==========================================
  // 🎨 COLORES PRINCIPALES (DESDE FLAVORCONFIG)
  // ==========================================

  /// Color principal más claro para contraste en modo oscuro
  static Color get primary => FlavorConfig.instance.primaryLight;

  /// Container oscuro con tinte del color principal
  static Color get primaryContainer => FlavorConfig.instance.primaryDark;

  /// Color secundario para modo oscuro
  static Color get secondary => FlavorConfig.instance.secondaryColor;

  /// Container oscuro para contenido secundario
  static Color get secondaryContainer => FlavorConfig.instance.secondaryContainer;

  /// Color terciario/acento para modo oscuro
  static Color get tertiary => FlavorConfig.instance.accentColor;

  /// Container oscuro para acentos
  static Color get tertiaryContainer => FlavorConfig.instance.tertiaryContainer;

  // ==========================================
  // 🏞️ FONDOS Y SUPERFICIES
  // ==========================================

  /// Superficie oscura
  static const Color surface = Color(0xFF1A1A1A);

  /// Container intermedio
  static const Color surfaceContainer = Color(0xFF242424);

  static const Color surfaceContainerHighest = Color(0xFF2C2C2C);
  static const Color surfaceContainerLowest = Color(0xFF121212);

  // ==========================================
  // ✍️ COLORES "ON" (TEXTO/ICONOS)
  // ==========================================

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF00D19A);
  static const Color onSecondary = Color(0xFF242424);
  static const Color onSecondaryContainer = Color(0xFFFFD15C);
  static const Color onTertiary = Color(0xFF242424);
  static const Color onTertiaryContainer = Color(0xFFFFD15C);
  static const Color onBackground = Color(0xFFE5E5E5);
  static const Color onSurface = Color(0xFFE5E5E5);
  static const Color onSurfaceVariant = Color(0xFFB0B0B0);

  // ==========================================
  // 🚨 ESTADOS ESPECIALES (DESDE FLAVORCONFIG)
  // ==========================================

  static Color get error => FlavorConfig.instance.errorColor;
  static const Color onError = Color(0xFFFFFFFF);

  // ==========================================
  // 🔲 BORDES Y DIVISORES
  // ==========================================

  static const Color outline = Color(0xFF3A3A3A);
  static const Color outlineVariant = Color(0xFF2A2A2A);

  // ==========================================
  // 🚫 DESHABILITADO
  // ==========================================

  static const Color disabled = Color(0xFF6B7280);

  // ==========================================
  // 🎨 COLORES ESPECIALES (DESDE FLAVORCONFIG)
  // ==========================================

  static Color get accent => FlavorConfig.instance.warningColor;
  static Color get success => FlavorConfig.instance.successColor;

  // ==========================================
  // ⏱️ POMODORO
  // ==========================================

  static Color pomodoroBgColorFocus =
      const Color(0xFFFF4949).withValues(alpha: 0.20);

  static Color pomodoroBgColorShortBreak =
      const Color(0xFF018b5e).withValues(alpha: 0.20);

  static Color pomodoroBgColorLongBreak =
      const Color(0xFFFFD15C).withValues(alpha: 0.20);
}

import 'package:flutter/material.dart';

/// Tipos de SnackBar según su propósito
enum SnackBarType {
  success,
  error,
  info,
  warning,
}

/// Helper para mostrar SnackBars modernos y personalizados
///
/// **Uso:**
/// ```dart
/// CustomSnackBar.show(
///   context: context,
///   message: 'Operación exitosa',
///   type: SnackBarType.success,
/// );
/// ```
class CustomSnackBar {
  /// Muestra un SnackBar moderno con iconos y colores personalizados
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final config = _getConfig(type, context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Icono del tipo de mensaje
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: config.iconBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                config.icon,
                color: config.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Mensaje
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: config.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: config.borderColor,
            width: 1,
          ),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: config.actionColor,
                onPressed: onActionPressed ?? () {},
              )
            : null,
        elevation: 8,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// Atajo para mostrar un SnackBar de éxito
  static void success({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  /// Atajo para mostrar un SnackBar de error
  static void error({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  /// Atajo para mostrar un SnackBar de información
  static void info({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
    );
  }

  /// Atajo para mostrar un SnackBar de advertencia
  static void warning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  /// Obtiene la configuración de colores e iconos según el tipo
  static _SnackBarConfig _getConfig(SnackBarType type, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          icon: Icons.check_circle,
          iconColor: Colors.white,
          iconBackgroundColor: const Color(0xFF4CAF50),
          backgroundColor: isDark
              ? const Color(0xFF1B5E20).withValues(alpha: 0.95)
              : const Color(0xFFE8F5E9),
          textColor: isDark ? Colors.white : const Color(0xFF1B5E20),
          borderColor: const Color(0xFF4CAF50),
          actionColor: const Color(0xFF4CAF50),
        );

      case SnackBarType.error:
        return _SnackBarConfig(
          icon: Icons.error,
          iconColor: Colors.white,
          iconBackgroundColor: const Color(0xFFF44336),
          backgroundColor: isDark
              ? const Color(0xFFB71C1C).withValues(alpha: 0.95)
              : const Color(0xFFFFEBEE),
          textColor: isDark ? Colors.white : const Color(0xFFB71C1C),
          borderColor: const Color(0xFFF44336),
          actionColor: const Color(0xFFF44336),
        );

      case SnackBarType.warning:
        return _SnackBarConfig(
          icon: Icons.warning,
          iconColor: Colors.white,
          iconBackgroundColor: const Color(0xFFFF9800),
          backgroundColor: isDark
              ? const Color(0xFFE65100).withValues(alpha: 0.95)
              : const Color(0xFFFFF3E0),
          textColor: isDark ? Colors.white : const Color(0xFFE65100),
          borderColor: const Color(0xFFFF9800),
          actionColor: const Color(0xFFFF9800),
        );

      case SnackBarType.info:
        return _SnackBarConfig(
          icon: Icons.info,
          iconColor: Colors.white,
          iconBackgroundColor: const Color(0xFF2196F3),
          backgroundColor: isDark
              ? const Color(0xFF0D47A1).withValues(alpha: 0.95)
              : const Color(0xFFE3F2FD),
          textColor: isDark ? Colors.white : const Color(0xFF0D47A1),
          borderColor: const Color(0xFF2196F3),
          actionColor: const Color(0xFF2196F3),
        );
    }
  }
}

/// Configuración interna de colores e iconos para un SnackBar
class _SnackBarConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color actionColor;

  const _SnackBarConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.actionColor,
  });
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/go_route/app_routes.dart';

class CustomAiChatAppBar extends StatelessWidget {
  const CustomAiChatAppBar({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colors.onPrimary),
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          // Logo IA
          Icon(Icons.auto_awesome, color: colors.onPrimary, size: 28),
          const SizedBox(width: 12),
          // Título
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inteligencia OPN',
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BETA',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Botón de configuración
          IconButton(
            icon: Icon(Icons.settings, color: colors.onPrimary),
            tooltip: 'Configuración del Chat',
            onPressed: () => context.push(AppRoutes.chatSettings),
          ),
        ],
      ),
    );
  }
}
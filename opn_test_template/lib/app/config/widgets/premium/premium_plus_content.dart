import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../authentification/auth/cubit/auth_state.dart';

/// Widget minimalista para contenido bloqueado premium plus
///
/// Características:
/// - Lee automáticamente del usuario si tiene acceso Premium+ (nivel == 3)
/// - Overlay con gradiente suave que cubre todo el área
/// - Candado animado con efecto de pulso y glow dorado/oro
/// - Ripple effect al tocar
/// - Soporte completo para temas claros/oscuros
/// - Accesibilidad integrada
class PremiumPlusContent extends StatefulWidget {
  const PremiumPlusContent({
    super.key,
    required this.requiresPremiumPlus,
    required this.child,
    this.onPressed,
  });

  /// Indica si este contenido requiere membresía Premium+ (nivel == 3)
  final bool requiresPremiumPlus;
  final Widget child;
  final VoidCallback? onPressed;

  @override
  State<PremiumPlusContent> createState() => _PremiumPlusContentState();
}

class _PremiumPlusContentState extends State<PremiumPlusContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState.user;

        // Determinar si está bloqueado:
        // - Si no requiere premium plus, nunca está bloqueado
        // - Si requiere premium plus, está bloqueado solo si el usuario NO es premium plus
        final isLocked = widget.requiresPremiumPlus && !user.isPremiumPlus;

        if (!isLocked) {
          return widget.child;
        }

        final colorScheme = Theme.of(context).colorScheme;
        // Color dorado/oro para Premium+
        final premiumPlusColor = const Color(0xFFFFD700);

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Contenido bloqueado
            AbsorbPointer(child: widget.child),

            // Overlay premium plus
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: _handleTap,
                  splashColor: premiumPlusColor.withOpacity(0.3),
                  highlightColor: premiumPlusColor.withOpacity(0.1),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          premiumPlusColor.withOpacity(0.25),
                          premiumPlusColor.withOpacity(0.08),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Semantics(
                        label: 'Contenido premium plus bloqueado',
                        hint: 'Toca para ver opciones de desbloqueo',
                        button: true,
                        child: _buildLockIcon(premiumPlusColor, colorScheme.surface),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLockIcon(Color premiumPlusColor, Color backgroundColor) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 0.6).animate(_pulseAnimation),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            // Glow exterior dorado
            BoxShadow(
              color: premiumPlusColor.withOpacity(0.5),
              blurRadius: 18,
              spreadRadius: 3,
            ),
            // Glow interior dorado
            BoxShadow(
              color: premiumPlusColor.withOpacity(0.7),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
            // Sombra
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.workspace_premium_rounded,
          size: 32,
          color: premiumPlusColor,
        ),
      ),
    );
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    widget.onPressed?.call();
  }
}
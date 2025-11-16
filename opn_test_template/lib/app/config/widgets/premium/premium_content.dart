import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../authentification/auth/cubit/auth_state.dart';

/// Widget minimalista para contenido bloqueado premium
///
/// Características:
/// - Lee automáticamente del usuario si tiene acceso Premium (nivel >= 2)
/// - Overlay con gradiente suave que cubre todo el área
/// - Candado animado con efecto de pulso y glow
/// - Ripple effect al tocar
/// - Soporte completo para temas claros/oscuros
/// - Accesibilidad integrada
class PremiumContent extends StatefulWidget {
  const PremiumContent({
    super.key,
    required this.requiresPremium,
    required this.child,
    this.onPressed,
  });

  /// Indica si este contenido requiere membresía Premium (nivel >= 2)
  final bool requiresPremium;
  final Widget child;
  final VoidCallback? onPressed;

  @override
  State<PremiumContent> createState() => _PremiumContentState();
}

class _PremiumContentState extends State<PremiumContent>
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
        // - Si no requiere premium, nunca está bloqueado
        // - Si requiere premium, está bloqueado solo si el usuario NO es premium
        final isLocked = widget.requiresPremium && !user.isPremium;

        if (!isLocked) {
          return widget.child;
        }

        final colorScheme = Theme.of(context).colorScheme;
        final primaryColor = colorScheme.primary;

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Contenido bloqueado
              AbsorbPointer(child: widget.child),

              // Overlay premium
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleTap,
                    splashColor: primaryColor.withOpacity(0.3),
                    highlightColor: primaryColor.withOpacity(0.1),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            primaryColor.withOpacity(0.25),
                            primaryColor.withOpacity(0.08),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Semantics(
                          label: 'Contenido premium bloqueado',
                          hint: 'Toca para ver opciones de desbloqueo',
                          button: true,
                          child: _buildLockIcon(primaryColor, colorScheme.surface),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLockIcon(Color primaryColor, Color backgroundColor) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 0.6).animate(_pulseAnimation),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            // Glow exterior
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
            // Glow interior
            BoxShadow(
              color: primaryColor.withOpacity(0.6),
              blurRadius: 8,
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
          Icons.lock_rounded,
          size: 32,
          color: primaryColor,
        ),
      ),
    );
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    widget.onPressed?.call();
  }
}
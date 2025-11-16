import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../config/preferences_service.dart';
import '../../../config/service_locator.dart';
import '../../../config/go_route/app_routes.dart';
import '../onboarding_constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;
  int _currentIndex = 0;
  bool _isProcessing = false;
  bool _permissionRequested = false;
  bool _notificationsGranted = false;

  final _slides = const [
    _OnboardingSlide(
      title: 'Bienvenido a OPN',
      description: 'Prepara tus oposiciones con test actualizados, estadísticas en tiempo real y una experiencia adaptada a tu nivel.',
      icon: Icons.shield_outlined,
    ),
    _OnboardingSlide(
      title: 'Aprende en cualquier momento',
      description: 'Organiza tus sesiones, revisa errores y descubre tips creados por tutores especializados.',
      icon: Icons.schedule_outlined,
    ),
    _OnboardingSlide(
      title: 'Activa las notificaciones',
      description: 'Mantente enfocado en tu objetivo. Te recordaremos tus sesiones de estudio diarias y te motivaremos a mantener tu racha. ¡No dejes que nada te detenga en tu camino hacia las oposiciones!',
      icon: Icons.notifications_active_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    await getIt<PreferencesService>().set(onboardingPreferenceKey, 'true');

    if (!mounted) return;
    context.go(AppRoutes.welcome);
  }

  Future<void> _requestNotificationPermissions() async {
    if (!_shouldRequestNotificationPermission || _permissionRequested) {
      // Si no es necesario pedir permisos (web/desktop), solo continuar
      await _finishOnboarding();
      return;
    }

    setState(() {
      _isProcessing = true;
      _permissionRequested = true;
    });

    try {
      // Solicitar permiso de notificaciones con OneSignal
      await OneSignal.Notifications.requestPermission(true);

      if (!mounted) return;

      // Verificar si se concedieron los permisos
      final hasPermission = OneSignal.Notifications.permission;

      if (hasPermission) {
        // Cambiar el icono a verde (notificaciones activadas)
        setState(() {
          _notificationsGranted = true;
          _isProcessing = false;
        });

        // Esperar un momento para que el usuario vea el cambio de color
        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;
      }

      // Continuar con el onboarding después de solicitar permiso
      await _finishOnboarding();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Puedes activar las notificaciones más tarde desde ajustes.'),
          ),
        );

      // Continuar de todos modos
      await _finishOnboarding();
    }
  }

  void _nextPage() {
    final isLast = _currentIndex == _slides.length - 1;
    if (isLast) {
      // En la última página, solicitar notificaciones
      unawaited(_requestNotificationPermissions());
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  final isNotificationSlide = index == _slides.length - 1;
                  final showSuccess = isNotificationSlide && _notificationsGranted;

                  // Color del icono: verde si las notificaciones están activadas, primary en caso contrario
                  final iconColor = showSuccess ? Colors.green : colors.primary;
                  final backgroundColor = showSuccess
                      ? Colors.green.withValues(alpha: 0.08)
                      : colors.primary.withValues(alpha: 0.08);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Icon(
                              slide.icon,
                              key: ValueKey(showSuccess),
                              size: 92,
                              color: iconColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _DotsIndicator(
              length: _slides.length,
              currentIndex: _currentIndex,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isProcessing ? null : _nextPage,
                  child: _isProcessing
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          _currentIndex == _slides.length - 1
                              ? 'Activar notificaciones'
                              : 'Continuar',
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

bool get _shouldRequestNotificationPermission {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.fuchsia:
      return true;
    case TargetPlatform.macOS:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return false;
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.length,
    required this.currentIndex,
  });

  final int length;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == currentIndex ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == currentIndex
                  ? colors.primary
                  : colors.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

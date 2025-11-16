import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../config/go_route/app_routes.dart';
import '../../../config/widgets/app_bar/app_bar_menu.dart';

/// Página de preview del Modo Contra Reloj
/// Muestra información sobre el juego e invita al usuario a jugarlo
class TimeAttackPreviewPage extends StatelessWidget {
  const TimeAttackPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarMenu(title: 'Modo Contra Reloj'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            const SizedBox(height: 24),
            _Description(),
            const SizedBox(height: 24),
            _GameFeatures(),
            const SizedBox(height: 24),
            _HowItWorks(),
            const SizedBox(height: 32),
            _PlayButton(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.cyan.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.timer,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Modo Contra Reloj',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Demuestra tu velocidad y conocimiento',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                '¿Qué es el Modo Contra Reloj?',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Un desafío emocionante donde comienzas con 20 segundos en el reloj. '
            'Cada respuesta correcta suma 5 segundos, pero cada error resta 2 segundos. '
            '¡Responde correctamente para mantener el tiempo a tu favor!',
            style: textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GameFeatures extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Características',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _FeatureCard(
          icon: Icons.timer,
          iconColor: Colors.blue,
          title: 'Tiempo dinámico',
          description: 'Comienza con 20 segundos. +5s por acierto, -2s por fallo',
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.flash_on,
          iconColor: Colors.green,
          title: 'Corrección instantánea',
          description: 'Sabes al instante si tu respuesta es correcta o incorrecta',
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          title: 'Sistema de rachas',
          description: 'Respuestas consecutivas correctas multiplican tu puntuación',
        ),
        const SizedBox(height: 12),
        _FeatureCard(
          icon: Icons.trending_up,
          iconColor: Colors.purple,
          title: 'Dificultad adaptativa',
          description: 'Las preguntas se vuelven más difíciles conforme avanzas',
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cómo funciona',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _HowItWorksStep(
          number: 1,
          text: 'Comienza con 20 segundos en el reloj',
        ),
        _HowItWorksStep(
          number: 2,
          text: 'Cada respuesta correcta suma 5 segundos al reloj',
        ),
        _HowItWorksStep(
          number: 3,
          text: 'Cada respuesta incorrecta resta 2 segundos',
        ),
        _HowItWorksStep(
          number: 4,
          text: 'La dificultad aumenta cada 3 respuestas correctas',
        ),
        _HowItWorksStep(
          number: 5,
          text: '¡Mantén el tiempo vivo y consigue la máxima puntuación!',
        ),
      ],
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final int number;
  final String text;

  const _HowItWorksStep({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _startGame(context),
      icon: const Icon(Icons.play_arrow_rounded, size: 28),
      label: const Text(
        'Jugar Ahora',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _startGame(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final user = authCubit.state.user;

    if (user.id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para jugar'),
        ),
      );
      return;
    }

    // Navegar a la página del test con tiempo inicial de 20 segundos
    context.push(
      AppRoutes.timeAttackTest,
      extra: {
        'timeLimitSeconds': 20,
      },
    );
  }
}
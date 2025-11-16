import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../config/go_route/app_routes.dart';
import '../../../config/widgets/app_bar/app_bar_menu.dart';

/// Página de preview del Modo Supervivencia
/// Muestra información sobre el juego e invita al usuario a jugarlo
class SurvivalPreviewPage extends StatelessWidget {
  const SurvivalPreviewPage({
    super.key,
    this.topicTypeId,
  });

  final int? topicTypeId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const AppBarMenu(title: 'Modo Supervivencia'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icono y título
            _Header(),
            const SizedBox(height: 24),

            // Descripción principal
            _Description(),
            const SizedBox(height: 24),

            // Características del juego
            _GameFeatures(),
            const SizedBox(height: 24),

            // Cómo funciona
            _HowItWorks(),
            const SizedBox(height: 32),

            // Botón de jugar
            _PlayButton(topicTypeId: topicTypeId),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// HEADER
// ======================================================

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono grande de fuego
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepOrange.shade400,
                Colors.red.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'Modo Supervivencia',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '¿Hasta dónde llegarás?',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================
// DESCRIPTION
// ======================================================

class _Description extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

              Text(
                '¿Qué es el Modo Supervivencia?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Un desafío emocionante donde pondrás a prueba tus conocimientos. '
            'Responde preguntas para avanzar de nivel, pero ten cuidado: '
            'cada error te costará una vida. Si pierdes todas tus vidas, el juego termina. '
            '¿Hasta qué nivel llegarás?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// GAME FEATURES
// ======================================================

class _GameFeatures extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Características',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          icon: Icons.favorite,
          iconColor: Colors.red,
          title: '3 Vidas',
          description: 'Comienza con 3 vidas. Cada error te costará una vida.',
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          icon: Icons.trending_up,
          iconColor: Colors.blue,
          title: 'Dificultad Creciente',
          description: 'Las preguntas se vuelven más difíciles a medida que avanzas.',
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          icon: Icons.military_tech,
          iconColor: Colors.amber,
          title: 'Sistema de Niveles',
          description: 'Cada 5 preguntas avanzas de nivel. Más nivel, más difícil.',
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          icon: Icons.emoji_events,
          iconColor: Colors.purple,
          title: 'Puntuación y Rachas',
          description: 'Acumula puntos y mantén tu racha de respuestas correctas.',
        ),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.3,
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

// ======================================================
// HOW IT WORKS
// ======================================================

class _HowItWorks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cómo Jugar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        _StepTile(
          number: 1,
          title: 'Comienza el desafío',
          description: 'Pulsa "Jugar Ahora" para iniciar tu partida.',
        ),
        const SizedBox(height: 8),
        _StepTile(
          number: 2,
          title: 'Responde correctamente',
          description: 'Lee cada pregunta con atención y selecciona la respuesta correcta.',
        ),
        const SizedBox(height: 8),
        _StepTile(
          number: 3,
          title: 'Sube de nivel',
          description: 'Cada 5 preguntas avanzas al siguiente nivel con mayor dificultad.',
        ),
        const SizedBox(height: 8),
        _StepTile(
          number: 4,
          title: 'Mantén tus vidas',
          description: 'Si pierdes las 3 vidas, el juego termina. ¡Intenta llegar lo más lejos posible!',
        ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.description,
  });

  final int number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================
// PLAY BUTTON
// ======================================================

class _PlayButton extends StatelessWidget {
  const _PlayButton({this.topicTypeId});

  final int? topicTypeId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handlePlay(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        icon: const Icon(Icons.play_arrow_rounded, size: 28),
        label: const Text(
          'Jugar Ahora',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _handlePlay(BuildContext context) {
    // Navegar al juego de supervivencia
    // Pasar topicTypeId si está disponible, sino pasar un mapa vacío
    final extra = topicTypeId != null
      ? <String, dynamic>{'topicTypeId': topicTypeId}
      : <String, dynamic>{};

    context.pushNamed(
      AppRoutes.survivalTest,
      extra: extra,
    );
  }
}
import 'package:flutter/material.dart';
import '../../../test_config/model/saved_test_config.dart';

/// Tarjeta para mostrar una configuración guardada en la home
class SavedConfigCard extends StatelessWidget {
  const SavedConfigCard({
    super.key,
    required this.config,
    required this.onTap,
  });

  final SavedTestConfig config;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 168,
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primaryContainer.withOpacity(0.9),
                  colors.secondaryContainer.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.primary.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título de la configuración
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.bookmark,
                              color: colors.primary,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              config.configName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: colors.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        // Información de la configuración
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              context,
                              Icons.help_outline,
                              '${config.numQuestions} preguntas',
                              colors.onPrimaryContainer.withOpacity(0.9),
                            ),
                            const SizedBox(height: 4),
                            _buildInfoRow(
                              context,
                              Icons.library_books_outlined,
                              '${config.selectedTopicIds.length} tema(s)',
                              colors.onPrimaryContainer.withOpacity(0.9),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: colors.onSurfaceVariant);

    // Mostrar información adicional sobre dificultades o modos
    final hasCustomDifficulties = config.difficulties.isNotEmpty;
    final hasCustomModes = config.testModes.isNotEmpty;

    String footerText = 'Configuración personalizada';

    if (hasCustomDifficulties && config.difficulties.length == 1) {
      footerText = config.difficulties.first;
    } else if (hasCustomModes && config.testModes.isNotEmpty) {
      final mode = config.testModes.first;
      switch (mode) {
        case 'topics':
          footerText = 'Preguntas nuevas';
          break;
        case 'failed':
          footerText = 'Preguntas falladas';
          break;
        case 'skipped':
          footerText = 'Preguntas omitidas';
          break;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.tune, size: 14, color: colors.primary),
        const SizedBox(width: 4),
        Text(footerText, style: style),
      ],
    );
  }
}

/// Tarjeta para "Ver todas las configuraciones"
class ViewAllSavedConfigsCard extends StatelessWidget {
  const ViewAllSavedConfigsCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 168,
        height: 150,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 40,
              color: colors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Ver todas',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
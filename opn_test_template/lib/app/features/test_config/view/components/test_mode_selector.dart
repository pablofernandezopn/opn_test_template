import 'package:flutter/material.dart';
import '../../model/test_mode.dart';

/// Selector de modos de test (Temas, Falladas, En Blanco)
class TestModeSelector extends StatelessWidget {
  final List<TestMode> selectedModes;
  final ValueChanged<TestMode> onModeToggled;

  const TestModeSelector({
    super.key,
    required this.selectedModes,
    required this.onModeToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 16, 8),
          child: Text(
            'Modo de Test',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
          child: Text(
            'Elige entre Temas o Repaso (Falladas/En Blanco se pueden combinar)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Lista de modos (excluyendo survival y timeAttack que son modos de juego)
        ...TestMode.values.where((mode) =>
          mode != TestMode.survival && mode != TestMode.timeAttack
        ).map((mode) {
          final isSelected = selectedModes.contains(mode);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.6)
                    : colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onModeToggled(mode),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    // Icono del modo
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.15)
                            : colorScheme.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          mode.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Contenido
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mode.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Checkbox
                    AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
      ],
    );
  }
}
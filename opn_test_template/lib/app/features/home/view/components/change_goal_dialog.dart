import 'package:flutter/material.dart';

/// Diálogo para que el usuario cambie su objetivo semanal de preguntas
class ChangeGoalDialog extends StatefulWidget {
  const ChangeGoalDialog({
    super.key,
    required this.currentGoal,
  });

  final int currentGoal;

  @override
  State<ChangeGoalDialog> createState() => _ChangeGoalDialogState();
}

class _ChangeGoalDialogState extends State<ChangeGoalDialog> {
  late int _selectedGoal;

  // Opciones predefinidas de objetivos
  static const List<int> goalOptions = [50, 100, 200, 300, 500, 1000];

  @override
  void initState() {
    super.initState();
    // Inicializar con el objetivo actual o el más cercano
    _selectedGoal = _findClosestGoal(widget.currentGoal);
  }

  int _findClosestGoal(int current) {
    if (goalOptions.contains(current)) return current;

    // Encontrar el objetivo más cercano
    int closest = goalOptions.first;
    int minDiff = (current - closest).abs();

    for (final goal in goalOptions) {
      final diff = (current - goal).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = goal;
      }
    }

    return closest;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.flag_rounded, color: colors.primary),
          const SizedBox(width: 12),
          const Text('Cambiar Objetivo', style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona tu objetivo semanal de preguntas:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Lista de opciones
          ...goalOptions.map((goal) {
            final isSelected = _selectedGoal == goal;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedGoal = goal;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primaryContainer
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? colors.primary
                          : colors.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? colors.primary : colors.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$goal preguntas',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
                        ),
                      ),
                      if (goal == widget.currentGoal) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Actual',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colors.onSecondaryContainer,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedGoal),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../model/answer_display_mode.dart';

/// Widget para seleccionar el modo de mostrar respuestas
class AnswerModeSelector extends StatelessWidget {
  final AnswerDisplayMode selectedMode;
  final ValueChanged<AnswerDisplayMode> onModeChanged;

  const AnswerModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AnswerDisplayMode.values.map((mode) {
        final isSelected = selectedMode == mode;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onModeChanged(mode),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
              ),
              child: Row(
                children: [
                  Radio<AnswerDisplayMode>(
                    value: mode,
                    groupValue: selectedMode,
                    onChanged: (value) {
                      if (value != null) {
                        onModeChanged(value);
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.displayName,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mode.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

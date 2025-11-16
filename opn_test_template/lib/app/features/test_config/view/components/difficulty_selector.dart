import 'package:flutter/material.dart';
import '../../model/test_difficulty.dart';

/// Widget para seleccionar la dificultad del test
class DifficultySelector extends StatelessWidget {
  final TestDifficulty selectedDifficulty;
  final ValueChanged<TestDifficulty> onDifficultyChanged;

  const DifficultySelector({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TestDifficulty>(
      segments: TestDifficulty.values.map((difficulty) {
        return ButtonSegment<TestDifficulty>(
          value: difficulty,
          label: Text(difficulty.displayName),
          icon: _getIcon(difficulty),
        );
      }).toList(),
      selected: {selectedDifficulty},
      onSelectionChanged: (Set<TestDifficulty> newSelection) {
        onDifficultyChanged(newSelection.first);
      },
    );
  }

  Icon _getIcon(TestDifficulty difficulty) {
    switch (difficulty) {
      case TestDifficulty.easy:
        return const Icon(Icons.sentiment_satisfied);
      case TestDifficulty.normal:
        return const Icon(Icons.sentiment_neutral);
      case TestDifficulty.hard:
        return const Icon(Icons.sentiment_very_dissatisfied);
    }
  }
}

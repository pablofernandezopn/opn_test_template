import 'package:json_annotation/json_annotation.dart';

/// Enumerador para la dificultad del test
@JsonEnum(valueField: 'value')
enum TestDifficulty {
  easy('easy'),
  normal('normal'),
  hard('hard');

  final String value;
  const TestDifficulty(this.value);

  /// Obtiene el nombre legible para la UI
  String get displayName {
    switch (this) {
      case TestDifficulty.easy:
        return 'Fácil';
      case TestDifficulty.normal:
        return 'Normal';
      case TestDifficulty.hard:
        return 'Difícil';
    }
  }

  /// Obtiene el TestDifficulty desde un string
  static TestDifficulty fromString(String value) {
    return TestDifficulty.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TestDifficulty.normal,
    );
  }
}
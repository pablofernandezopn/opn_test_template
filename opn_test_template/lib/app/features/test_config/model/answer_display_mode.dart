import 'package:json_annotation/json_annotation.dart';

/// Enumerador para el modo de mostrar las respuestas
@JsonEnum(valueField: 'value')
enum AnswerDisplayMode {
  /// Mostrar respuesta inmediatamente después de responder cada pregunta
  immediate('immediate'),

  /// Mostrar todas las respuestas al finalizar el test
  atEnd('at_end');

  final String value;
  const AnswerDisplayMode(this.value);

  /// Obtiene el nombre legible para la UI
  String get displayName {
    switch (this) {
      case AnswerDisplayMode.immediate:
        return 'Mostrar respuesta inmediatamente';
      case AnswerDisplayMode.atEnd:
        return 'Mostrar respuestas al finalizar';
    }
  }

  /// Obtiene una descripción más detallada
  String get description {
    switch (this) {
      case AnswerDisplayMode.immediate:
        return 'Verás si acertaste después de cada pregunta';
      case AnswerDisplayMode.atEnd:
        return 'Verás los resultados al terminar el test';
    }
  }

  /// Obtiene el AnswerDisplayMode desde un string
  static AnswerDisplayMode fromString(String value) {
    return AnswerDisplayMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnswerDisplayMode.atEnd,
    );
  }
}
import 'package:json_annotation/json_annotation.dart';

part 'question_option_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class QuestionOption {
  /// ID único de la opción
  final int? id;

  /// ID de la pregunta a la que pertenece (requerido, FK)
  final int questionId;

  /// Texto de la respuesta (requerido, no puede estar vacío)
  /// Constraint: length(TRIM(answer)) > 0
  final String answer;

  /// Si esta opción es la correcta (default: false)
  @JsonKey(defaultValue: false)
  final bool isCorrect;

  /// Orden de la opción (default: 1)
  /// Constraint: unique(question_id, option_order)
  @JsonKey(defaultValue: 1)
  final int optionOrder;

  /// Fecha de creación (default: now())
  final DateTime? createdAt;

  const QuestionOption({
    this.id,
    required this.questionId,
    required this.answer,
    this.isCorrect = false,
    this.optionOrder = 1,
    this.createdAt,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) =>
      _$QuestionOptionFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$QuestionOptionToJson(this);
    // Remover campos que no deberían enviarse en INSERT/UPDATE
    if (id == null) {
      json.remove('id'); // No enviar ID en INSERT
      json.remove('created_at'); // La BD lo genera automáticamente
    }
    // Asegurar que answer no esté vacío (trim)
    if (json.containsKey('answer')) {
      json['answer'] = (json['answer'] as String).trim();
    }
    return json;
  }

  QuestionOption copyWith({
    int? id,
    int? questionId,
    String? answer,
    bool? isCorrect,
    int? optionOrder,
    DateTime? createdAt,
  }) {
    return QuestionOption(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      answer: answer ?? this.answer,
      isCorrect: isCorrect ?? this.isCorrect,
      optionOrder: optionOrder ?? this.optionOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Valida que la respuesta no esté vacía (para cumplir constraint de BD)
  bool get isValid => answer.trim().isNotEmpty;
}

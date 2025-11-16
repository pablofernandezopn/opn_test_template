import 'package:json_annotation/json_annotation.dart';
import '../../questions/model/question_model.dart';
import '../../questions/model/question_option_model.dart';
import 'survival_session.dart';

part 'survival_question_response.g.dart';

/// Respuesta de la edge function cuando se solicita la siguiente pregunta
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SurvivalQuestionResponse {
  /// Si la operación fue exitosa
  final bool success;

  /// La pregunta seleccionada (null si gameOver o error)
  final Question? question;

  /// Las opciones de la pregunta
  final List<QuestionOption>? options;

  /// Estado actualizado de la sesión
  final SurvivalSession session;

  /// Si el juego ha terminado (por falta de vidas o preguntas)
  final bool gameOver;

  /// Mensaje adicional (opcional)
  final String? message;

  const SurvivalQuestionResponse({
    required this.success,
    this.question,
    this.options,
    required this.session,
    this.gameOver = false,
    this.message,
  });

  factory SurvivalQuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$SurvivalQuestionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SurvivalQuestionResponseToJson(this);

  /// Verifica si hay una pregunta disponible
  bool get hasQuestion => question != null && options != null && options!.isNotEmpty;

  @override
  String toString() {
    return 'SurvivalQuestionResponse(success: $success, gameOver: $gameOver, '
        'hasQuestion: $hasQuestion, level: ${session.currentLevel}, '
        'lives: ${session.livesRemaining})';
  }
}
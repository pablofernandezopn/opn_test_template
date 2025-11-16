import 'package:json_annotation/json_annotation.dart';
import 'survival_session.dart';

part 'survival_answer_response.g.dart';

/// Respuesta de la edge function después de enviar una respuesta
@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SurvivalAnswerResponse {
  /// Si la operación fue exitosa
  final bool success;

  /// Estado actualizado de la sesión
  final SurvivalSession session;

  /// Si el juego ha terminado
  final bool gameOver;

  /// Puntuación final (solo cuando gameOver es true)
  final double? finalScore;

  /// Mensaje adicional (opcional)
  final String? message;

  const SurvivalAnswerResponse({
    required this.success,
    required this.session,
    this.gameOver = false,
    this.finalScore,
    this.message,
  });

  factory SurvivalAnswerResponse.fromJson(Map<String, dynamic> json) =>
      _$SurvivalAnswerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SurvivalAnswerResponseToJson(this);

  @override
  String toString() {
    return 'SurvivalAnswerResponse(success: $success, gameOver: $gameOver, '
        'finalScore: $finalScore, lives: ${session.livesRemaining})';
  }
}
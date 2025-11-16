import 'package:json_annotation/json_annotation.dart';
import 'time_attack_session.dart';

part 'time_attack_answer_response.g.dart';

/// Respuesta de la edge function al enviar una respuesta
@JsonSerializable(explicitToJson: true)
class TimeAttackAnswerResponse {
  final bool success;
  final TimeAttackSession session;
  @JsonKey(name: 'time_up')
  final bool timeUp;
  @JsonKey(name: 'final_score')
  final int? finalScore;
  @JsonKey(name: 'points_earned')
  final int? pointsEarned;

  const TimeAttackAnswerResponse({
    required this.success,
    required this.session,
    required this.timeUp,
    this.finalScore,
    this.pointsEarned,
  });

  factory TimeAttackAnswerResponse.fromJson(Map<String, dynamic> json) =>
      _$TimeAttackAnswerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TimeAttackAnswerResponseToJson(this);
}
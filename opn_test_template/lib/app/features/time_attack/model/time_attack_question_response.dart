import 'package:json_annotation/json_annotation.dart';
import '../../questions/model/question_model.dart';
import '../../questions/model/question_option_model.dart';
import 'time_attack_session.dart';

part 'time_attack_question_response.g.dart';

/// Respuesta de la edge function al solicitar la siguiente pregunta
@JsonSerializable(explicitToJson: true)
class TimeAttackQuestionResponse {
  final bool success;
  final Question? question;
  final List<QuestionOption>? options;
  final TimeAttackSession? session;
  @JsonKey(name: 'time_up')
  final bool? timeUp;
  final String? message;

  const TimeAttackQuestionResponse({
    required this.success,
    this.question,
    this.options,
    this.session,
    this.timeUp,
    this.message,
  });

  factory TimeAttackQuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$TimeAttackQuestionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TimeAttackQuestionResponseToJson(this);
}
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_attack_answer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeAttackAnswerResponse _$TimeAttackAnswerResponseFromJson(
        Map<String, dynamic> json) =>
    TimeAttackAnswerResponse(
      success: json['success'] as bool,
      session:
          TimeAttackSession.fromJson(json['session'] as Map<String, dynamic>),
      timeUp: json['time_up'] as bool,
      finalScore: (json['final_score'] as num?)?.toInt(),
      pointsEarned: (json['points_earned'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TimeAttackAnswerResponseToJson(
        TimeAttackAnswerResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'session': instance.session.toJson(),
      'time_up': instance.timeUp,
      'final_score': instance.finalScore,
      'points_earned': instance.pointsEarned,
    };

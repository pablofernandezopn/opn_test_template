// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survival_answer_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurvivalAnswerResponse _$SurvivalAnswerResponseFromJson(
        Map<String, dynamic> json) =>
    SurvivalAnswerResponse(
      success: json['success'] as bool,
      session:
          SurvivalSession.fromJson(json['session'] as Map<String, dynamic>),
      gameOver: json['game_over'] as bool? ?? false,
      finalScore: (json['final_score'] as num?)?.toDouble(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SurvivalAnswerResponseToJson(
        SurvivalAnswerResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'session': instance.session.toJson(),
      'game_over': instance.gameOver,
      'final_score': instance.finalScore,
      'message': instance.message,
    };

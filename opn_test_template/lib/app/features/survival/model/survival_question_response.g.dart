// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survival_question_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurvivalQuestionResponse _$SurvivalQuestionResponseFromJson(
        Map<String, dynamic> json) =>
    SurvivalQuestionResponse(
      success: json['success'] as bool,
      question: json['question'] == null
          ? null
          : Question.fromJson(json['question'] as Map<String, dynamic>),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      session:
          SurvivalSession.fromJson(json['session'] as Map<String, dynamic>),
      gameOver: json['game_over'] as bool? ?? false,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$SurvivalQuestionResponseToJson(
        SurvivalQuestionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'question': instance.question?.toJson(),
      'options': instance.options?.map((e) => e.toJson()).toList(),
      'session': instance.session.toJson(),
      'game_over': instance.gameOver,
      'message': instance.message,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_attack_question_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeAttackQuestionResponse _$TimeAttackQuestionResponseFromJson(
        Map<String, dynamic> json) =>
    TimeAttackQuestionResponse(
      success: json['success'] as bool,
      question: json['question'] == null
          ? null
          : Question.fromJson(json['question'] as Map<String, dynamic>),
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      session: json['session'] == null
          ? null
          : TimeAttackSession.fromJson(json['session'] as Map<String, dynamic>),
      timeUp: json['time_up'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$TimeAttackQuestionResponseToJson(
        TimeAttackQuestionResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'question': instance.question?.toJson(),
      'options': instance.options?.map((e) => e.toJson()).toList(),
      'session': instance.session?.toJson(),
      'time_up': instance.timeUp,
      'message': instance.message,
    };

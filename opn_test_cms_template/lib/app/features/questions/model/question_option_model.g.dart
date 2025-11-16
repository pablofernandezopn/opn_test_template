// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionOption _$QuestionOptionFromJson(Map<String, dynamic> json) =>
    QuestionOption(
      id: (json['id'] as num?)?.toInt(),
      questionId: (json['question_id'] as num).toInt(),
      answer: json['answer'] as String,
      isCorrect: json['is_correct'] as bool? ?? false,
      optionOrder: (json['option_order'] as num?)?.toInt() ?? 1,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$QuestionOptionToJson(QuestionOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question_id': instance.questionId,
      'answer': instance.answer,
      'is_correct': instance.isCorrect,
      'option_order': instance.optionOrder,
      'created_at': instance.createdAt?.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteQuestion _$FavoriteQuestionFromJson(Map<String, dynamic> json) =>
    FavoriteQuestion(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num).toInt(),
      questionId: (json['question_id'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$FavoriteQuestionToJson(FavoriteQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'question_id': instance.questionId,
      'created_at': instance.createdAt?.toIso8601String(),
    };

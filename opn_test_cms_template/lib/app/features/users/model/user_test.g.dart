// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_test.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTest _$UserTestFromJson(Map<String, dynamic> json) => UserTest(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      topicIds: (json['topic_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      rightQuestions: (json['right_questions'] as num).toInt(),
      wrongQuestions: (json['wrong_questions'] as num).toInt(),
      questionCount: (json['question_count'] as num).toInt(),
      score: (json['score'] as num?)?.toDouble(),
      finalized: json['finalized'] as bool,
      timeSpentMillis: (json['time_spent_millis'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserTestToJson(UserTest instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'topic_ids': instance.topicIds,
      'right_questions': instance.rightQuestions,
      'wrong_questions': instance.wrongQuestions,
      'question_count': instance.questionCount,
      'score': instance.score,
      'finalized': instance.finalized,
      'time_spent_millis': instance.timeSpentMillis,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'topics': instance.topics,
    };

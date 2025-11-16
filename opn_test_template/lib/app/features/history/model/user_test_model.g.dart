// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTest _$UserTestFromJson(Map<String, dynamic> json) => UserTest(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num).toInt(),
      topicIds: (json['topic_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      options: (json['options'] as num?)?.toInt() ?? 4,
      rightQuestions: (json['right_questions'] as num?)?.toInt() ?? 0,
      wrongQuestions: (json['wrong_questions'] as num?)?.toInt() ?? 0,
      questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
      totalAnswered: (json['total_answered'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toDouble(),
      finalized: json['finalized'] as bool? ?? false,
      visible: json['visible'] as bool? ?? true,
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      timeSpentMillis: (json['time_spent_millis'] as num?)?.toInt(),
      totalTimeSeconds: (json['total_time_seconds'] as num?)?.toInt() ?? 0,
      specialTopic: (json['special_topic'] as num?)?.toInt(),
      specialTopicTitle: json['special_topic_title'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      isFlashcardMode: json['is_flashcard_mode'] as bool? ?? false,
      topicGroupId: (json['topic_group_id'] as num?)?.toInt(),
      survivalSessionId: (json['survival_session_id'] as num?)?.toInt(),
      timeAttackSessionId: (json['time_attack_session_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserTestToJson(UserTest instance) => <String, dynamic>{
      'user_id': instance.userId,
      'topic_ids': instance.topicIds,
      'special_topic_title': instance.specialTopicTitle,
      'options': instance.options,
      'right_questions': instance.rightQuestions,
      'wrong_questions': instance.wrongQuestions,
      'question_count': instance.questionCount,
      'total_answered': instance.totalAnswered,
      'score': instance.score,
      'finalized': instance.finalized,
      'visible': instance.visible,
      'duration_seconds': instance.durationSeconds,
      'time_spent_millis': instance.timeSpentMillis,
      'total_time_seconds': instance.totalTimeSeconds,
      'special_topic': instance.specialTopic,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'is_flashcard_mode': instance.isFlashcardMode,
      'topic_group_id': instance.topicGroupId,
      'survival_session_id': instance.survivalSessionId,
      'time_attack_session_id': instance.timeAttackSessionId,
    };

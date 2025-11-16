// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survival_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SurvivalSession _$SurvivalSessionFromJson(Map<String, dynamic> json) =>
    SurvivalSession(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num).toInt(),
      academyId: (json['academy_id'] as num).toInt(),
      topicTypeId: (json['topic_type_id'] as num?)?.toInt(),
      specialtyId: (json['specialty_id'] as num?)?.toInt(),
      livesRemaining: (json['lives_remaining'] as num?)?.toInt() ?? 3,
      currentLevel: (json['current_level'] as num?)?.toInt() ?? 1,
      questionsAnswered: (json['questions_answered'] as num?)?.toInt() ?? 0,
      questionsCorrect: (json['questions_correct'] as num?)?.toInt() ?? 0,
      questionsSeen: (json['questions_seen'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      difficultyFloor: (json['difficulty_floor'] as num?)?.toDouble() ?? 0.0,
      difficultyCeiling:
          (json['difficulty_ceiling'] as num?)?.toDouble() ?? 0.3,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      finalScore: (json['final_score'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SurvivalSessionToJson(SurvivalSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'academy_id': instance.academyId,
      'topic_type_id': instance.topicTypeId,
      'specialty_id': instance.specialtyId,
      'lives_remaining': instance.livesRemaining,
      'current_level': instance.currentLevel,
      'questions_answered': instance.questionsAnswered,
      'questions_correct': instance.questionsCorrect,
      'questions_seen': instance.questionsSeen,
      'difficulty_floor': instance.difficultyFloor,
      'difficulty_ceiling': instance.difficultyCeiling,
      'started_at': instance.startedAt?.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
      'is_active': instance.isActive,
      'final_score': instance.finalScore,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

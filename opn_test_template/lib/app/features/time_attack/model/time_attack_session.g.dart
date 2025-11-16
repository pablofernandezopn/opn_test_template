// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_attack_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeAttackSession _$TimeAttackSessionFromJson(Map<String, dynamic> json) =>
    TimeAttackSession(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num).toInt(),
      academyId: (json['academy_id'] as num).toInt(),
      topicTypeId: (json['topic_type_id'] as num?)?.toInt(),
      specialtyId: (json['specialty_id'] as num?)?.toInt(),
      timeLimitSeconds: (json['time_limit_seconds'] as num).toInt(),
      timeRemainingSeconds: (json['time_remaining_seconds'] as num).toInt(),
      questionsAnswered: (json['questions_answered'] as num?)?.toInt() ?? 0,
      questionsCorrect: (json['questions_correct'] as num?)?.toInt() ?? 0,
      questionsSeen: (json['questions_seen'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      bestStreak: (json['best_streak'] as num?)?.toInt() ?? 0,
      currentLevel: (json['current_level'] as num?)?.toInt() ?? 1,
      difficultyFloor: (json['difficulty_floor'] as num?)?.toDouble() ?? 0.0,
      difficultyCeiling:
          (json['difficulty_ceiling'] as num?)?.toDouble() ?? 0.3,
      currentScore: (json['current_score'] as num?)?.toInt() ?? 0,
      finalScore: (json['final_score'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      lastActivityAt: json['last_activity_at'] == null
          ? null
          : DateTime.parse(json['last_activity_at'] as String),
    );

Map<String, dynamic> _$TimeAttackSessionToJson(TimeAttackSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'academy_id': instance.academyId,
      'topic_type_id': instance.topicTypeId,
      'specialty_id': instance.specialtyId,
      'time_limit_seconds': instance.timeLimitSeconds,
      'time_remaining_seconds': instance.timeRemainingSeconds,
      'questions_answered': instance.questionsAnswered,
      'questions_correct': instance.questionsCorrect,
      'questions_seen': instance.questionsSeen,
      'current_streak': instance.currentStreak,
      'best_streak': instance.bestStreak,
      'current_level': instance.currentLevel,
      'difficulty_floor': instance.difficultyFloor,
      'difficulty_ceiling': instance.difficultyCeiling,
      'current_score': instance.currentScore,
      'final_score': instance.finalScore,
      'is_active': instance.isActive,
      'started_at': instance.startedAt?.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
      'last_activity_at': instance.lastActivityAt?.toIso8601String(),
    };

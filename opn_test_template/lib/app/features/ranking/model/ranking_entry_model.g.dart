// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RankingEntry _$RankingEntryFromJson(Map<String, dynamic> json) => RankingEntry(
      id: (json['id'] as num?)?.toInt(),
      topicId: (json['topic_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      topicGroupId: (json['topic_group_id'] as num?)?.toInt(),
      firstScore: (json['first_score'] as num).toDouble(),
      bestScore: (json['best_score'] as num).toDouble(),
      attempts: (json['attempts'] as num).toInt(),
      rankPosition: (json['rank_position'] as num?)?.toInt(),
      lastAttemptDate: DateTime.parse(json['last_attempt_date'] as String),
      firstAttemptDate: DateTime.parse(json['first_attempt_date'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      profileImage: json['profile_image'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );

Map<String, dynamic> _$RankingEntryToJson(RankingEntry instance) =>
    <String, dynamic>{
      'topic_id': instance.topicId,
      'user_id': instance.userId,
      'topic_group_id': instance.topicGroupId,
      'first_score': instance.firstScore,
      'best_score': instance.bestScore,
      'attempts': instance.attempts,
      'rank_position': instance.rankPosition,
      'last_attempt_date': instance.lastAttemptDate.toIso8601String(),
      'first_attempt_date': instance.firstAttemptDate.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'username': instance.username,
      'display_name': instance.displayName,
      'profile_image': instance.profileImage,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };

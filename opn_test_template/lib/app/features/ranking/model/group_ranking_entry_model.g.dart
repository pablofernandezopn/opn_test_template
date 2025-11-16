// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_ranking_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupRankingEntry _$GroupRankingEntryFromJson(Map<String, dynamic> json) =>
    GroupRankingEntry(
      userId: (json['user_id'] as num).toInt(),
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      profileImage: json['profile_image'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      averageFirstScore: (json['average_first_score'] as num).toDouble(),
      totalAttempts: (json['total_attempts'] as num).toInt(),
      topicsCompleted: (json['topics_completed'] as num).toInt(),
      totalTopicsInGroup: (json['total_topics_in_group'] as num).toInt(),
      rankPosition: (json['rank_position'] as num).toInt(),
      firstAttemptDate: DateTime.parse(json['first_attempt_date'] as String),
      lastAttemptDate: DateTime.parse(json['last_attempt_date'] as String),
    );

Map<String, dynamic> _$GroupRankingEntryToJson(GroupRankingEntry instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'display_name': instance.displayName,
      'profile_image': instance.profileImage,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'average_first_score': instance.averageFirstScore,
      'total_attempts': instance.totalAttempts,
      'topics_completed': instance.topicsCompleted,
      'total_topics_in_group': instance.totalTopicsInGroup,
      'rank_position': instance.rankPosition,
      'first_attempt_date': instance.firstAttemptDate.toIso8601String(),
      'last_attempt_date': instance.lastAttemptDate.toIso8601String(),
    };

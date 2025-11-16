// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'opn_ranking_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpnRankingEntry _$OpnRankingEntryFromJson(Map<String, dynamic> json) =>
    OpnRankingEntry(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num).toInt(),
      opnIndex: (json['opn_index'] as num).toInt(),
      qualityTrendScore: (json['quality_trend_score'] as num?)?.toDouble(),
      recentActivityScore: (json['recent_activity_score'] as num?)?.toDouble(),
      competitiveScore: (json['competitive_score'] as num?)?.toDouble(),
      momentumScore: (json['momentum_score'] as num?)?.toDouble(),
      globalRank: (json['global_rank'] as num?)?.toInt(),
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      profileImage: json['profile_image'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );

Map<String, dynamic> _$OpnRankingEntryToJson(OpnRankingEntry instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'opn_index': instance.opnIndex,
      'quality_trend_score': instance.qualityTrendScore,
      'recent_activity_score': instance.recentActivityScore,
      'competitive_score': instance.competitiveScore,
      'momentum_score': instance.momentumScore,
      'global_rank': instance.globalRank,
      'calculated_at': instance.calculatedAt.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'username': instance.username,
      'display_name': instance.displayName,
      'profile_image': instance.profileImage,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };

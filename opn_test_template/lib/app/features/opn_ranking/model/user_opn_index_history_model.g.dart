// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_opn_index_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserOpnIndexHistory _$UserOpnIndexHistoryFromJson(Map<String, dynamic> json) =>
    UserOpnIndexHistory(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num).toInt(),
      opnIndex: (json['opn_index'] as num).toInt(),
      qualityTrendScore: (json['quality_trend_score'] as num?)?.toDouble(),
      recentActivityScore: (json['recent_activity_score'] as num?)?.toDouble(),
      competitiveScore: (json['competitive_score'] as num?)?.toDouble(),
      momentumScore: (json['momentum_score'] as num?)?.toDouble(),
      globalRank: (json['global_rank'] as num?)?.toInt(),
      calculatedAt: json['calculated_at'] == null
          ? null
          : DateTime.parse(json['calculated_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$UserOpnIndexHistoryToJson(
        UserOpnIndexHistory instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'opn_index': instance.opnIndex,
      'quality_trend_score': instance.qualityTrendScore,
      'recent_activity_score': instance.recentActivityScore,
      'competitive_score': instance.competitiveScore,
      'momentum_score': instance.momentumScore,
      'global_rank': instance.globalRank,
      'calculated_at': instance.calculatedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };

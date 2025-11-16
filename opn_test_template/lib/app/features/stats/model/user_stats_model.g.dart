// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      totalMockTests: (json['total_mock_tests'] as num?)?.toInt() ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      bestScore: (json['best_score'] as num?)?.toDouble() ?? 0.0,
      totalAttempts: (json['total_attempts'] as num?)?.toInt() ?? 0,
      averageRankPosition: (json['average_rank_position'] as num?)?.toDouble(),
      bestRankPosition: (json['best_rank_position'] as num?)?.toInt(),
      top3Count: (json['top_3_count'] as num?)?.toInt() ?? 0,
      top10Count: (json['top_10_count'] as num?)?.toInt() ?? 0,
      lastAttemptDate: json['last_attempt_date'] == null
          ? null
          : DateTime.parse(json['last_attempt_date'] as String),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'total_mock_tests': instance.totalMockTests,
      'average_score': instance.averageScore,
      'best_score': instance.bestScore,
      'total_attempts': instance.totalAttempts,
      'average_rank_position': instance.averageRankPosition,
      'best_rank_position': instance.bestRankPosition,
      'top_3_count': instance.top3Count,
      'top_10_count': instance.top10Count,
      'last_attempt_date': instance.lastAttemptDate?.toIso8601String(),
    };

TopicMockStats _$TopicMockStatsFromJson(Map<String, dynamic> json) =>
    TopicMockStats(
      topicId: (json['topic_id'] as num).toInt(),
      topicName: json['topic_name'] as String,
      firstScore: (json['first_score'] as num).toDouble(),
      bestScore: (json['best_score'] as num).toDouble(),
      attempts: (json['attempts'] as num).toInt(),
      rankPosition: (json['rank_position'] as num?)?.toInt(),
      totalParticipants: (json['total_participants'] as num).toInt(),
      firstAttemptDate: DateTime.parse(json['first_attempt_date'] as String),
      lastAttemptDate: DateTime.parse(json['last_attempt_date'] as String),
    );

Map<String, dynamic> _$TopicMockStatsToJson(TopicMockStats instance) =>
    <String, dynamic>{
      'topic_id': instance.topicId,
      'topic_name': instance.topicName,
      'first_score': instance.firstScore,
      'best_score': instance.bestScore,
      'attempts': instance.attempts,
      'rank_position': instance.rankPosition,
      'total_participants': instance.totalParticipants,
      'first_attempt_date': instance.firstAttemptDate.toIso8601String(),
      'last_attempt_date': instance.lastAttemptDate.toIso8601String(),
    };

StatsDataPoint _$StatsDataPointFromJson(Map<String, dynamic> json) =>
    StatsDataPoint(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
      topicName: json['topic_name'] as String?,
      topicId: (json['topic_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StatsDataPointToJson(StatsDataPoint instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'score': instance.score,
      'topic_name': instance.topicName,
      'topic_id': instance.topicId,
    };

TopicTypeEvolutionData _$TopicTypeEvolutionDataFromJson(
        Map<String, dynamic> json) =>
    TopicTypeEvolutionData(
      topicTypeId: (json['topic_type_id'] as num).toInt(),
      topicTypeName: json['topic_type_name'] as String,
      topics: (json['topics'] as List<dynamic>)
          .map((e) => TopicEvolutionLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TopicTypeEvolutionDataToJson(
        TopicTypeEvolutionData instance) =>
    <String, dynamic>{
      'topic_type_id': instance.topicTypeId,
      'topic_type_name': instance.topicTypeName,
      'topics': instance.topics.map((e) => e.toJson()).toList(),
    };

TopicEvolutionLine _$TopicEvolutionLineFromJson(Map<String, dynamic> json) =>
    TopicEvolutionLine(
      topicId: (json['topic_id'] as num).toInt(),
      topicName: json['topic_name'] as String,
      firstScore: (json['first_score'] as num).toDouble(),
      firstAttemptDate: DateTime.parse(json['first_attempt_date'] as String),
      rankPosition: (json['rank_position'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TopicEvolutionLineToJson(TopicEvolutionLine instance) =>
    <String, dynamic>{
      'topic_id': instance.topicId,
      'topic_name': instance.topicName,
      'first_score': instance.firstScore,
      'first_attempt_date': instance.firstAttemptDate.toIso8601String(),
      'rank_position': instance.rankPosition,
    };

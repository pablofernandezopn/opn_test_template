import 'package:json_annotation/json_annotation.dart';

part 'user_stats_model.g.dart';

/// Estadísticas globales del usuario en topics tipo Mock
@JsonSerializable(explicitToJson: true)
class UserStats {
  /// Total de topics Mock completados
  @JsonKey(name: 'total_mock_tests')
  final int totalMockTests;

  /// Puntuación promedio de todos los Mock tests
  @JsonKey(name: 'average_score')
  final double averageScore;

  /// Mejor puntuación obtenida
  @JsonKey(name: 'best_score')
  final double bestScore;

  /// Total de intentos en todos los Mock tests
  @JsonKey(name: 'total_attempts')
  final int totalAttempts;

  /// Promedio de posición en rankings
  @JsonKey(name: 'average_rank_position')
  final double? averageRankPosition;

  /// Mejor posición en cualquier ranking
  @JsonKey(name: 'best_rank_position')
  final int? bestRankPosition;

  /// Número de veces en top 3
  @JsonKey(name: 'top_3_count')
  final int top3Count;

  /// Número de veces en top 10
  @JsonKey(name: 'top_10_count')
  final int top10Count;

  /// Última fecha de intento
  @JsonKey(name: 'last_attempt_date')
  final DateTime? lastAttemptDate;

  const UserStats({
    this.totalMockTests = 0,
    this.averageScore = 0.0,
    this.bestScore = 0.0,
    this.totalAttempts = 0,
    this.averageRankPosition,
    this.bestRankPosition,
    this.top3Count = 0,
    this.top10Count = 0,
    this.lastAttemptDate,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);

  factory UserStats.empty() => const UserStats();

  bool get isEmpty => totalMockTests == 0;
  bool get hasData => totalMockTests > 0;

  @override
  String toString() {
    return 'UserStats(totalMockTests: $totalMockTests, averageScore: $averageScore, bestRankPosition: $bestRankPosition)';
  }
}

/// Estadísticas detalladas por cada topic Mock
@JsonSerializable(explicitToJson: true)
class TopicMockStats {
  /// ID del topic
  @JsonKey(name: 'topic_id')
  final int topicId;

  /// Nombre del topic
  @JsonKey(name: 'topic_name')
  final String topicName;

  /// Primera puntuación (define el ranking)
  @JsonKey(name: 'first_score')
  final double firstScore;

  /// Mejor puntuación obtenida
  @JsonKey(name: 'best_score')
  final double bestScore;

  /// Número de intentos
  final int attempts;

  /// Posición en el ranking
  @JsonKey(name: 'rank_position')
  final int? rankPosition;

  /// Total de participantes en este topic
  @JsonKey(name: 'total_participants')
  final int totalParticipants;

  /// Fecha del primer intento
  @JsonKey(name: 'first_attempt_date')
  final DateTime firstAttemptDate;

  /// Fecha del último intento
  @JsonKey(name: 'last_attempt_date')
  final DateTime lastAttemptDate;

  const TopicMockStats({
    required this.topicId,
    required this.topicName,
    required this.firstScore,
    required this.bestScore,
    required this.attempts,
    this.rankPosition,
    required this.totalParticipants,
    required this.firstAttemptDate,
    required this.lastAttemptDate,
  });

  factory TopicMockStats.fromJson(Map<String, dynamic> json) =>
      _$TopicMockStatsFromJson(json);

  Map<String, dynamic> toJson() => _$TopicMockStatsToJson(this);

  /// Calcula cuánto mejoró desde el primer intento
  double get improvementPercentage {
    if (firstScore == 0) return 0;
    return ((bestScore - firstScore) / firstScore) * 100;
  }

  /// Calcula el percentil (mejor = menor número)
  double get percentile {
    if (rankPosition == null || totalParticipants == 0) return 0;
    return ((totalParticipants - rankPosition!) / totalParticipants) * 100;
  }

  /// Indica si está en el top 3
  bool get isTop3 => rankPosition != null && rankPosition! <= 3;

  /// Indica si está en el top 10
  bool get isTop10 => rankPosition != null && rankPosition! <= 10;

  @override
  String toString() {
    return 'TopicMockStats(topicId: $topicId, topicName: $topicName, rankPosition: $rankPosition, firstScore: $firstScore)';
  }
}

/// Datos para gráficos de evolución temporal
@JsonSerializable(explicitToJson: true)
class StatsDataPoint {
  /// Fecha del dato
  final DateTime date;

  /// Puntuación obtenida
  final double score;

  /// Nombre del topic (opcional)
  @JsonKey(name: 'topic_name')
  final String? topicName;

  /// ID del topic (opcional)
  @JsonKey(name: 'topic_id')
  final int? topicId;

  const StatsDataPoint({
    required this.date,
    required this.score,
    this.topicName,
    this.topicId,
  });

  factory StatsDataPoint.fromJson(Map<String, dynamic> json) =>
      _$StatsDataPointFromJson(json);

  Map<String, dynamic> toJson() => _$StatsDataPointToJson(this);
}

/// Datos de evolución por Topic Type (agrupa múltiples topics)
@JsonSerializable(explicitToJson: true)
class TopicTypeEvolutionData {
  /// ID del topic type
  @JsonKey(name: 'topic_type_id')
  final int topicTypeId;

  /// Nombre del topic type
  @JsonKey(name: 'topic_type_name')
  final String topicTypeName;

  /// Lista de topics con sus datos de evolución
  final List<TopicEvolutionLine> topics;

  const TopicTypeEvolutionData({
    required this.topicTypeId,
    required this.topicTypeName,
    required this.topics,
  });

  factory TopicTypeEvolutionData.fromJson(Map<String, dynamic> json) =>
      _$TopicTypeEvolutionDataFromJson(json);

  Map<String, dynamic> toJson() => _$TopicTypeEvolutionDataToJson(this);

  bool get isEmpty => topics.isEmpty;
  bool get hasData => topics.isNotEmpty;
}

/// Línea de evolución para un topic específico
@JsonSerializable(explicitToJson: true)
class TopicEvolutionLine {
  /// ID del topic
  @JsonKey(name: 'topic_id')
  final int topicId;

  /// Nombre del topic
  @JsonKey(name: 'topic_name')
  final String topicName;

  /// Puntuación del primer intento
  @JsonKey(name: 'first_score')
  final double firstScore;

  /// Fecha del primer intento
  @JsonKey(name: 'first_attempt_date')
  final DateTime firstAttemptDate;

  /// Posición en el ranking
  @JsonKey(name: 'rank_position')
  final int? rankPosition;

  const TopicEvolutionLine({
    required this.topicId,
    required this.topicName,
    required this.firstScore,
    required this.firstAttemptDate,
    this.rankPosition,
  });

  factory TopicEvolutionLine.fromJson(Map<String, dynamic> json) =>
      _$TopicEvolutionLineFromJson(json);

  Map<String, dynamic> toJson() => _$TopicEvolutionLineToJson(this);
}
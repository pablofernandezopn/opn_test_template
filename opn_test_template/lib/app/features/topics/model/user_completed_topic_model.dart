/// Modelo que representa un topic completado por el usuario con información básica
class UserCompletedTopic {
  final int topicId;
  final int attempts;
  final double? bestScore;
  final DateTime lastAttemptDate;
  final int? rankPosition;

  const UserCompletedTopic({
    required this.topicId,
    required this.attempts,
    this.bestScore,
    required this.lastAttemptDate,
    this.rankPosition,
  });

  /// Crea una instancia desde JSON de Supabase
  factory UserCompletedTopic.fromJson(Map<String, dynamic> json) {
    return UserCompletedTopic(
      topicId: json['topic_id'] as int,
      attempts: json['attempts'] as int? ?? 0,
      bestScore: (json['best_score'] as num?)?.toDouble(),
      lastAttemptDate: DateTime.parse(json['last_attempt_date'] as String),
      rankPosition: json['rank_position'] as int?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'topic_id': topicId,
      'attempts': attempts,
      'best_score': bestScore,
      'last_attempt_date': lastAttemptDate.toIso8601String(),
      'rank_position': rankPosition,
    };
  }

  @override
  String toString() {
    return 'UserCompletedTopic(id: $topicId, attempts: $attempts, bestScore: $bestScore, rankPosition: $rankPosition)';
  }
}
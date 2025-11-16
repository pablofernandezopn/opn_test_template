/// Modelo para representar la información de completado y ranking de un topic group por un usuario
class UserCompletedTopicGroup {
  final int topicGroupId;
  final int topicsCompleted;
  final int totalTopicsInGroup;
  final int totalAttempts;
  final double? averageFirstScore;
  final DateTime? firstAttemptDate;
  final DateTime? lastAttemptDate;
  final int? rankPosition;

  const UserCompletedTopicGroup({
    required this.topicGroupId,
    required this.topicsCompleted,
    required this.totalTopicsInGroup,
    required this.totalAttempts,
    this.averageFirstScore,
    this.firstAttemptDate,
    this.lastAttemptDate,
    this.rankPosition,
  });

  /// Verifica si el usuario completó todos los topics del grupo
  bool get isCompleted => topicsCompleted == totalTopicsInGroup && totalTopicsInGroup > 0;

  /// Crea una instancia desde JSON de Supabase
  factory UserCompletedTopicGroup.fromJson(Map<String, dynamic> json) {
    return UserCompletedTopicGroup(
      topicGroupId: json['topic_group_id'] as int? ?? 0,
      topicsCompleted: json['topics_completed'] as int? ?? 0,
      totalTopicsInGroup: json['total_topics_in_group'] as int? ?? 0,
      totalAttempts: json['total_attempts'] as int? ?? 0,
      averageFirstScore: (json['average_first_score'] as num?)?.toDouble(),
      firstAttemptDate: json['first_attempt_date'] != null
          ? DateTime.parse(json['first_attempt_date'] as String)
          : null,
      lastAttemptDate: json['last_attempt_date'] != null
          ? DateTime.parse(json['last_attempt_date'] as String)
          : null,
      rankPosition: json['rank_position'] as int?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'topic_group_id': topicGroupId,
      'topics_completed': topicsCompleted,
      'total_topics_in_group': totalTopicsInGroup,
      'total_attempts': totalAttempts,
      'average_first_score': averageFirstScore,
      'first_attempt_date': firstAttemptDate?.toIso8601String(),
      'last_attempt_date': lastAttemptDate?.toIso8601String(),
      'rank_position': rankPosition,
    };
  }

  @override
  String toString() {
    return 'UserCompletedTopicGroup(topicGroupId: $topicGroupId, completed: $topicsCompleted/$totalTopicsInGroup, rank: $rankPosition)';
  }
}
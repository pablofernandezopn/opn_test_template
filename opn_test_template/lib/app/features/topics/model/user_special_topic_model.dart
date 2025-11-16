/// Modelo que representa un topic especial completado por el usuario con estadísticas agregadas
class UserSpecialTopic {
  final int specialTopicId;
  final String specialTopicTitle;
  final int totalAttempts;
  final double? bestScore;
  final double? firstScore;
  final DateTime lastAttemptDate;
  final DateTime firstAttemptDate;
  final double? averageScore;
  final int totalQuestions;
  final int totalCorrect;
  final int totalWrong;

  const UserSpecialTopic({
    required this.specialTopicId,
    required this.specialTopicTitle,
    required this.totalAttempts,
    this.bestScore,
    this.firstScore,
    required this.lastAttemptDate,
    required this.firstAttemptDate,
    this.averageScore,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.totalWrong,
  });

  /// Crea una instancia desde JSON de Supabase
  factory UserSpecialTopic.fromJson(Map<String, dynamic> json) {
    return UserSpecialTopic(
      specialTopicId: json['special_topic_id'] as int,
      specialTopicTitle: json['special_topic_title'] as String? ?? 'Sin título',
      totalAttempts: json['total_attempts'] as int? ?? 0,
      bestScore: (json['best_score'] as num?)?.toDouble(),
      firstScore: (json['first_score'] as num?)?.toDouble(),
      lastAttemptDate: DateTime.parse(json['last_attempt_date'] as String),
      firstAttemptDate: DateTime.parse(json['first_attempt_date'] as String),
      averageScore: (json['average_score'] as num?)?.toDouble(),
      totalQuestions: json['total_questions'] as int? ?? 0,
      totalCorrect: json['total_correct'] as int? ?? 0,
      totalWrong: json['total_wrong'] as int? ?? 0,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'special_topic_id': specialTopicId,
      'special_topic_title': specialTopicTitle,
      'total_attempts': totalAttempts,
      'best_score': bestScore,
      'first_score': firstScore,
      'last_attempt_date': lastAttemptDate.toIso8601String(),
      'first_attempt_date': firstAttemptDate.toIso8601String(),
      'average_score': averageScore,
      'total_questions': totalQuestions,
      'total_correct': totalCorrect,
      'total_wrong': totalWrong,
    };
  }

  /// Calcula la tasa de éxito
  double get successRate {
    if (totalQuestions == 0) return 0.0;
    return (totalCorrect / totalQuestions) * 100;
  }

  /// Calcula si el usuario está mejorando
  bool get isImproving {
    if (firstScore == null || bestScore == null) return false;
    return bestScore! > firstScore!;
  }

  @override
  String toString() {
    return 'UserSpecialTopic(id: $specialTopicId, title: $specialTopicTitle, attempts: $totalAttempts, bestScore: $bestScore)';
  }
}
import 'package:json_annotation/json_annotation.dart';

part 'time_attack_session.g.dart';

/// Modelo que representa una sesión del modo contra reloj
@JsonSerializable(explicitToJson: true)
class TimeAttackSession {
  final int? id;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'academy_id')
  final int academyId;

  @JsonKey(name: 'topic_type_id')
  final int? topicTypeId;

  @JsonKey(name: 'specialty_id')
  final int? specialtyId;

  // Configuración del juego
  @JsonKey(name: 'time_limit_seconds')
  final int timeLimitSeconds;

  @JsonKey(name: 'time_remaining_seconds')
  final int timeRemainingSeconds;

  // Estadísticas del juego
  @JsonKey(name: 'questions_answered')
  final int questionsAnswered;

  @JsonKey(name: 'questions_correct')
  final int questionsCorrect;

  @JsonKey(name: 'questions_seen')
  final List<int> questionsSeen;

  @JsonKey(name: 'current_streak')
  final int currentStreak;

  @JsonKey(name: 'best_streak')
  final int bestStreak;

  // Sistema de dificultad adaptativa
  @JsonKey(name: 'current_level')
  final int currentLevel;

  @JsonKey(name: 'difficulty_floor')
  final double difficultyFloor;

  @JsonKey(name: 'difficulty_ceiling')
  final double difficultyCeiling;

  // Puntuación
  @JsonKey(name: 'current_score')
  final int currentScore;

  @JsonKey(name: 'final_score')
  final int? finalScore;

  // Control de sesión
  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'started_at')
  final DateTime? startedAt;

  @JsonKey(name: 'ended_at')
  final DateTime? endedAt;

  @JsonKey(name: 'last_activity_at')
  final DateTime? lastActivityAt;

  const TimeAttackSession({
    this.id,
    required this.userId,
    required this.academyId,
    this.topicTypeId,
    this.specialtyId,
    required this.timeLimitSeconds,
    required this.timeRemainingSeconds,
    this.questionsAnswered = 0,
    this.questionsCorrect = 0,
    this.questionsSeen = const [],
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.currentLevel = 1,
    this.difficultyFloor = 0.0,
    this.difficultyCeiling = 0.3,
    this.currentScore = 0,
    this.finalScore,
    this.isActive = true,
    this.startedAt,
    this.endedAt,
    this.lastActivityAt,
  });

  factory TimeAttackSession.fromJson(Map<String, dynamic> json) =>
      _$TimeAttackSessionFromJson(json);

  Map<String, dynamic> toJson() => _$TimeAttackSessionToJson(this);

  TimeAttackSession copyWith({
    int? id,
    int? userId,
    int? academyId,
    int? topicTypeId,
    int? specialtyId,
    int? timeLimitSeconds,
    int? timeRemainingSeconds,
    int? questionsAnswered,
    int? questionsCorrect,
    List<int>? questionsSeen,
    int? currentStreak,
    int? bestStreak,
    int? currentLevel,
    double? difficultyFloor,
    double? difficultyCeiling,
    int? currentScore,
    int? finalScore,
    bool? isActive,
    DateTime? startedAt,
    DateTime? endedAt,
    DateTime? lastActivityAt,
  }) {
    return TimeAttackSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      academyId: academyId ?? this.academyId,
      topicTypeId: topicTypeId ?? this.topicTypeId,
      specialtyId: specialtyId ?? this.specialtyId,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      timeRemainingSeconds: timeRemainingSeconds ?? this.timeRemainingSeconds,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      questionsCorrect: questionsCorrect ?? this.questionsCorrect,
      questionsSeen: questionsSeen ?? this.questionsSeen,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      currentLevel: currentLevel ?? this.currentLevel,
      difficultyFloor: difficultyFloor ?? this.difficultyFloor,
      difficultyCeiling: difficultyCeiling ?? this.difficultyCeiling,
      currentScore: currentScore ?? this.currentScore,
      finalScore: finalScore ?? this.finalScore,
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  /// Retorna el número de preguntas incorrectas
  int get questionsIncorrect => questionsAnswered - questionsCorrect;

  /// Retorna el porcentaje de precisión
  double get accuracy {
    if (questionsAnswered == 0) return 0;
    return (questionsCorrect / questionsAnswered) * 100;
  }

  /// Retorna el progreso hacia el siguiente nivel (0.0 a 1.0)
  double get progressToNextLevel {
    const questionsPerLevel = 3;
    return (questionsCorrect % questionsPerLevel) / questionsPerLevel;
  }

  /// Retorna cuántas preguntas correctas faltan para el siguiente nivel
  int get questionsUntilNextLevel {
    const questionsPerLevel = 3;
    return questionsPerLevel - (questionsCorrect % questionsPerLevel);
  }

  /// Retorna el tiempo transcurrido en segundos
  int get timeElapsedSeconds {
    return timeLimitSeconds - timeRemainingSeconds;
  }

  /// Retorna si el tiempo se agotó
  bool get isTimeUp => timeRemainingSeconds <= 0;

  @override
  String toString() {
    return 'TimeAttackSession(id: $id, level: $currentLevel, score: $currentScore, '
        'answered: $questionsAnswered, correct: $questionsCorrect, streak: $currentStreak)';
  }
}
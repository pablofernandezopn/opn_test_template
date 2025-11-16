import 'package:json_annotation/json_annotation.dart';

part 'user_test_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserTest {
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'topic_ids')
  final List<int> topicIds;

  @JsonKey(name: 'special_topic_title')
  final String? specialTopicTitle;

  final int options;

  @JsonKey(name: 'right_questions')
  final int rightQuestions;

  @JsonKey(name: 'wrong_questions')
  final int wrongQuestions;

  @JsonKey(name: 'question_count')
  final int questionCount;

  @JsonKey(name: 'total_answered')
  final int totalAnswered;

  final double? score;

  final bool finalized;

  final bool visible;

  @JsonKey(name: 'duration_seconds')
  final int durationSeconds;

  @JsonKey(name: 'time_spent_millis')
  final int? timeSpentMillis;

  @JsonKey(name: 'total_time_seconds')
  final int totalTimeSeconds;

  @JsonKey(name: 'special_topic')
  final int? specialTopic;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'is_flashcard_mode')
  final bool isFlashcardMode;



  /// ID del grupo de examen al que pertenece este test
  /// Permite agrupar múltiples user_tests que forman parte del mismo examen secuencial
  @JsonKey(name: 'topic_group_id')
  final int? topicGroupId;

  /// ID de la sesión de supervivencia asociada
  /// Si no es null, permite continuar la partida desde el historial
  @JsonKey(name: 'survival_session_id')
  final int? survivalSessionId;

  /// ID de la sesión de contra reloj asociada
  /// Si no es null, permite continuar la partida desde el historial
  @JsonKey(name: 'time_attack_session_id')
  final int? timeAttackSessionId;

  const UserTest({
    this.id,
    required this.userId,
    required this.topicIds,
    this.options = 4,
    this.rightQuestions = 0,
    this.wrongQuestions = 0,
    this.questionCount = 0,
    this.totalAnswered = 0,
    this.score,
    this.finalized = false,
    this.visible = true,
    required this.durationSeconds,
    this.timeSpentMillis,
    this.totalTimeSeconds = 0,
    this.specialTopic,
    this.specialTopicTitle,
    required this.createdAt,
    required this.updatedAt,
    this.isFlashcardMode = false,
    this.topicGroupId,
    this.survivalSessionId,
    this.timeAttackSessionId,
  });

  /// Crea una instancia desde JSON
  factory UserTest.fromJson(Map<String, dynamic> json) => _$UserTestFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$UserTestToJson(this);

  /// Crea una copia con campos modificados
  UserTest copyWith({
    int? id,
    int? userId,
    List<int>? topicIds,
    int? options,
    int? rightQuestions,
    int? wrongQuestions,
    int? questionCount,
    int? totalAnswered,
    double? score,
    bool? finalized,
    bool? visible,
    int? durationSeconds,
    int? timeSpentMillis,
    int? totalTimeSeconds,
    int? specialTopic,
    String? specialTopicTitle,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFlashcardMode,
    int? topicGroupId,
    int? survivalSessionId,
    int? timeAttackSessionId,
  }) {
    return UserTest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topicIds: topicIds ?? this.topicIds,
      options: options ?? this.options,
      rightQuestions: rightQuestions ?? this.rightQuestions,
      wrongQuestions: wrongQuestions ?? this.wrongQuestions,
      questionCount: questionCount ?? this.questionCount,
      totalAnswered: totalAnswered ?? this.totalAnswered,
      score: score ?? this.score,
      finalized: finalized ?? this.finalized,
      visible: visible ?? this.visible,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      timeSpentMillis: timeSpentMillis ?? this.timeSpentMillis,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      specialTopic: specialTopic ?? this.specialTopic,
      specialTopicTitle: specialTopicTitle ?? this.specialTopicTitle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFlashcardMode: isFlashcardMode ?? this.isFlashcardMode,
      topicGroupId: topicGroupId ?? this.topicGroupId,
      survivalSessionId: survivalSessionId ?? this.survivalSessionId,
      timeAttackSessionId: timeAttackSessionId ?? this.timeAttackSessionId,
    );
  }

  @override
  String toString() {
    return 'UserTest(id: $id, userId: $userId, score: $score, finalized: $finalized, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserTest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Retorna el porcentaje de acierto
  double get successRate {
    if (totalAnswered == 0) return 0;
    return (rightQuestions / totalAnswered) * 100;
  }

  /// Retorna la tasa de error (porcentaje de preguntas incorrectas)
  double get errorRate {
    if (totalAnswered == 0) return 0;
    return (wrongQuestions / totalAnswered) * 100;
  }

  /// Retorna el tipo de test basado en los flags
  String get testType {
    if (isFlashcardMode) return 'Flashcards';
    return 'Test Normal';
  }

  /// Retorna si el test fue realizado hoy
  bool get isToday {
    final now = DateTime.now();
    return createdAt?.year == now.year &&
        createdAt?.month == now.month &&
        createdAt?.day == now.day;
  }

  /// Retorna si el test está pausado (guardado para continuar más tarde)
  bool get isPaused => !finalized && totalAnswered > 0;

  /// Retorna si es una sesión de supervivencia que puede reanudarse
  bool get isSurvivalSessionResumable =>
      specialTopic == -2 && survivalSessionId != null && !finalized;

  /// Convierte la instancia a un Map para inserción en la base de datos
  /// Excluye campos auto-generados (id, created_at, updated_at)
  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'topic_ids': topicIds,
      'options': options,
      'right_questions': rightQuestions,
      'wrong_questions': wrongQuestions,
      'question_count': questionCount,
      'total_answered': totalAnswered,
      if (score != null) 'score': score,
      'finalized': finalized,
      'visible': visible,
      'duration_seconds': durationSeconds,
      if (timeSpentMillis != null) 'time_spent_millis': timeSpentMillis,
      'total_time_seconds': totalTimeSeconds,
      if (specialTopic != null) 'special_topic': specialTopic,
      if (specialTopicTitle != null) 'special_topic_title': specialTopicTitle,
      'is_flashcard_mode': isFlashcardMode,
      if (topicGroupId != null) 'topic_group_id': topicGroupId,
      if (survivalSessionId != null) 'survival_session_id': survivalSessionId,
      if (timeAttackSessionId != null) 'time_attack_session_id': timeAttackSessionId,
    };
  }
}
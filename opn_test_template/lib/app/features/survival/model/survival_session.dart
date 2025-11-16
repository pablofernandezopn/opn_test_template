import 'package:json_annotation/json_annotation.dart';

part 'survival_session.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SurvivalSession {
  /// ID único de la sesión
  final int? id;

  /// ID del usuario
  final int userId;

  /// ID de la academia
  final int academyId;

  /// ID del tipo de topic (opcional, para filtrar preguntas)
  final int? topicTypeId;

  /// ID de la especialidad (opcional)
  final int? specialtyId;

  /// Vidas restantes (empieza en 3)
  final int livesRemaining;

  /// Nivel actual (aumenta cada 5 preguntas)
  final int currentLevel;

  /// Número total de preguntas respondidas
  final int questionsAnswered;

  /// Número de preguntas correctas
  final int questionsCorrect;

  /// IDs de preguntas ya vistas en esta sesión
  final List<int> questionsSeen;

  /// Límite inferior del rango de dificultad actual
  final double difficultyFloor;

  /// Límite superior del rango de dificultad actual
  final double difficultyCeiling;

  /// Fecha y hora de inicio
  final DateTime? startedAt;

  /// Fecha y hora de finalización
  final DateTime? endedAt;

  /// Si la sesión está activa
  final bool isActive;

  /// Puntuación final (calculada al terminar)
  final double? finalScore;

  /// Fecha de creación
  final DateTime? createdAt;

  /// Fecha de última actualización
  final DateTime? updatedAt;

  const SurvivalSession({
    this.id,
    required this.userId,
    required this.academyId,
    this.topicTypeId,
    this.specialtyId,
    this.livesRemaining = 3,
    this.currentLevel = 1,
    this.questionsAnswered = 0,
    this.questionsCorrect = 0,
    this.questionsSeen = const [],
    this.difficultyFloor = 0.0,
    this.difficultyCeiling = 0.3,
    this.startedAt,
    this.endedAt,
    this.isActive = true,
    this.finalScore,
    this.createdAt,
    this.updatedAt,
  });

  factory SurvivalSession.fromJson(Map<String, dynamic> json) =>
      _$SurvivalSessionFromJson(json);

  Map<String, dynamic> toJson() => _$SurvivalSessionToJson(this);

  /// Verifica si el juego ha terminado
  bool get isGameOver => livesRemaining <= 0 || !isActive;

  /// Calcula la precisión del jugador
  double get accuracy {
    if (questionsAnswered == 0) return 0.0;
    return (questionsCorrect / questionsAnswered) * 100;
  }

  /// Calcula el número de preguntas incorrectas
  int get questionsIncorrect => questionsAnswered - questionsCorrect;

  /// Calcula el progreso hacia el siguiente nivel (0.0 - 1.0)
  double get progressToNextLevel {
    const questionsPerLevel = 5;
    final questionsInCurrentLevel = questionsAnswered % questionsPerLevel;
    return questionsInCurrentLevel / questionsPerLevel;
  }

  /// Calcula el número de preguntas hasta el siguiente nivel
  int get questionsUntilNextLevel {
    const questionsPerLevel = 5;
    final questionsInCurrentLevel = questionsAnswered % questionsPerLevel;
    return questionsPerLevel - questionsInCurrentLevel;
  }

  /// Crea una copia con campos modificados
  SurvivalSession copyWith({
    int? id,
    int? userId,
    int? academyId,
    int? topicTypeId,
    int? specialtyId,
    int? livesRemaining,
    int? currentLevel,
    int? questionsAnswered,
    int? questionsCorrect,
    List<int>? questionsSeen,
    double? difficultyFloor,
    double? difficultyCeiling,
    DateTime? startedAt,
    DateTime? endedAt,
    bool? isActive,
    double? finalScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SurvivalSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      academyId: academyId ?? this.academyId,
      topicTypeId: topicTypeId ?? this.topicTypeId,
      specialtyId: specialtyId ?? this.specialtyId,
      livesRemaining: livesRemaining ?? this.livesRemaining,
      currentLevel: currentLevel ?? this.currentLevel,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      questionsCorrect: questionsCorrect ?? this.questionsCorrect,
      questionsSeen: questionsSeen ?? this.questionsSeen,
      difficultyFloor: difficultyFloor ?? this.difficultyFloor,
      difficultyCeiling: difficultyCeiling ?? this.difficultyCeiling,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      isActive: isActive ?? this.isActive,
      finalScore: finalScore ?? this.finalScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SurvivalSession(id: $id, level: $currentLevel, lives: $livesRemaining, '
        'answered: $questionsAnswered, correct: $questionsCorrect, '
        'accuracy: ${accuracy.toStringAsFixed(1)}%)';
  }
}
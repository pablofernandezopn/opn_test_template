import 'topic_group_model.dart';
import 'topic_model.dart';

/// Sesión de test agrupado (solo runtime, no se persiste en BD)
///
/// Gestiona el estado de un examen compuesto por múltiples topics
/// que se deben realizar secuencialmente con un timer global compartido.
class GroupedTestSession {
  /// El grupo de topics al que pertenece este test
  final TopicGroup topicGroup;

  /// Lista de topics ordenados por group_order
  final List<Topic> orderedTopics;

  /// Duración total en segundos (del topic_group)
  final int totalDurationSeconds;

  /// Índice del topic actual (0-based)
  int currentTopicIndex;

  /// Segundos restantes del timer global
  int remainingSeconds;

  /// IDs de user_test ya guardados en BD
  final List<int> savedUserTestIds;

  /// Momento en que comenzó la sesión
  final DateTime sessionStartTime;

  GroupedTestSession({
    required this.topicGroup,
    required this.orderedTopics,
    required this.totalDurationSeconds,
    this.currentTopicIndex = 0,
    int? remainingSeconds,
    List<int>? savedUserTestIds,
    DateTime? sessionStartTime,
  })  : remainingSeconds = remainingSeconds ?? totalDurationSeconds,
        savedUserTestIds = savedUserTestIds ?? [],
        sessionStartTime = sessionStartTime ?? DateTime.now();

  /// ¿Es la última parte del examen?
  bool get isLastPart => currentTopicIndex >= orderedTopics.length - 1;

  /// Topic actual
  Topic get currentTopic => orderedTopics[currentTopicIndex];

  /// Número total de partes
  int get totalParts => orderedTopics.length;

  /// Número de parte actual (1-based para mostrar al usuario)
  int get currentPartNumber => currentTopicIndex + 1;

  /// Porcentaje de progreso (0-100)
  int get progressPercentage => ((currentPartNumber / totalParts) * 100).round();

  /// Tiempo transcurrido en segundos
  int get elapsedSeconds => totalDurationSeconds - remainingSeconds;

  /// Avanza al siguiente topic
  void moveToNext() {
    if (!isLastPart) {
      currentTopicIndex++;
    }else {
      throw StateError('Ya se está en la última parte del examen.');
    }
  }

  @override
  String toString() {
    return 'GroupedTestSession(group: ${topicGroup.name}, '
        'part: $currentPartNumber/$totalParts, '
        'remaining: ${remainingSeconds}s)';
  }
}
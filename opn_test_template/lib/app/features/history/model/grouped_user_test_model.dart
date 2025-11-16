import 'user_test_model.dart';

/// Modelo que agrupa múltiples UserTest que pertenecen al mismo topic_group
///
/// Se usa para mostrar tests agrupados en el historial de forma consolidada
class GroupedUserTest {
  /// ID del grupo de topics
  final int topicGroupId;

  /// Nombre del grupo de topics
  final String? topicGroupName;

  /// Lista de UserTest que forman parte de este grupo
  final List<UserTest> tests;

  const GroupedUserTest({
    required this.topicGroupId,
    this.topicGroupName,
    required this.tests,
  });

  /// Fecha de creación (del test más antiguo del grupo)
  DateTime? get createdAt {
    if (tests.isEmpty) return null;
    return tests
        .map((t) => t.createdAt)
        .whereType<DateTime>()
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// Número de partes del examen
  int get partCount => tests.length;

  /// Nota promedio de todas las partes
  double get averageScore {
    if (tests.isEmpty) return 0;
    final scores = tests.where((t) => t.score != null).map((t) => t.score!);
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Suma total de todas las notas
  double get totalScore {
    if (tests.isEmpty) return 0;
    return tests.where((t) => t.score != null).map((t) => t.score!).fold(0, (a, b) => a + b);
  }

  /// Tasa de error promedio de todas las partes
  double get averageErrorRate {
    if (tests.isEmpty) return 0;
    return tests.map((t) => t.errorRate).reduce((a, b) => a + b) / tests.length;
  }

  /// Total de preguntas correctas en todas las partes
  int get totalRightQuestions {
    return tests.fold(0, (sum, test) => sum + test.rightQuestions);
  }

  /// Total de preguntas incorrectas en todas las partes
  int get totalWrongQuestions {
    return tests.fold(0, (sum, test) => sum + test.wrongQuestions);
  }

  /// Total de preguntas en blanco en todas las partes
  int get totalBlankQuestions {
    return tests.fold(0, (sum, test) => sum + (test.questionCount - test.rightQuestions - test.wrongQuestions));
  }

  /// Total de preguntas en todas las partes
  int get totalQuestions {
    return tests.fold(0, (sum, test) => sum + test.questionCount);
  }

  /// Total de preguntas respondidas en todas las partes
  int get totalAnswered {
    return tests.fold(0, (sum, test) => sum + test.totalAnswered);
  }

  /// Porcentaje de acierto global
  double get successRate {
    if (totalAnswered == 0) return 0;
    return (totalRightQuestions / totalAnswered) * 100;
  }

  /// Retorna si el grupo fue realizado hoy
  bool get isToday {
    final now = DateTime.now();
    final date = createdAt;
    if (date == null) return false;
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Retorna si todos los tests del grupo están finalizados
  bool get isFinalized {
    if (tests.isEmpty) return false;
    return tests.every((test) => test.finalized);
  }

  /// Título para mostrar (nombre del grupo o genérico)
  String get displayTitle {
    return topicGroupName ?? 'Examen agrupado';
  }

  @override
  String toString() {
    return 'GroupedUserTest(topicGroupId: $topicGroupId, partCount: $partCount, averageScore: $averageScore)';
  }
}
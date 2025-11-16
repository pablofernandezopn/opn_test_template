/// Modo de test que determina de dónde se obtienen las preguntas
enum TestMode {
  /// Modo estudio: preguntas de topics seleccionados
  topics,

  /// Modo repaso: preguntas falladas históricamente
  failedQuestions,

  /// Modo repaso: preguntas dejadas en blanco históricamente
  skippedQuestions,

  /// Modo supervivencia: preguntas infinitas con dificultad creciente y 3 vidas
  survival,

  /// Modo contra reloj: máxima puntuación en tiempo límite
  timeAttack,
}

extension TestModeExtension on TestMode {
  /// Nombre para mostrar en la UI
  String get displayName {
    switch (this) {
      case TestMode.topics:
        return 'Temas';
      case TestMode.failedQuestions:
        return 'Preguntas Falladas';
      case TestMode.skippedQuestions:
        return 'Preguntas en Blanco';
      case TestMode.survival:
        return 'Supervivencia';
      case TestMode.timeAttack:
        return 'Contra Reloj';
    }
  }

  /// Descripción del modo
  String get description {
    switch (this) {
      case TestMode.topics:
        return 'Preguntas de los temas seleccionados';
      case TestMode.failedQuestions:
        return 'Repasa preguntas que has fallado anteriormente';
      case TestMode.skippedQuestions:
        return 'Repasa preguntas que dejaste en blanco';
      case TestMode.survival:
        return '3 vidas, dificultad creciente, ¡hasta dónde llegarás?';
      case TestMode.timeAttack:
        return 'Máxima puntuación antes de que se acabe el tiempo';
    }
  }

  /// Icono representativo
  String get icon {
    switch (this) {
      case TestMode.topics:
        return '📚';
      case TestMode.failedQuestions:
        return '❌';
      case TestMode.skippedQuestions:
        return '⏭️';
      case TestMode.survival:
        return '🔥';
      case TestMode.timeAttack:
        return '⏱️';
    }
  }

  /// Valor para enviar al backend
  String get value {
    switch (this) {
      case TestMode.topics:
        return 'topics';
      case TestMode.failedQuestions:
        return 'failed';
      case TestMode.skippedQuestions:
        return 'skipped';
      case TestMode.survival:
        return 'survival';
      case TestMode.timeAttack:
        return 'time_attack';
    }
  }

  /// Crear TestMode desde string
  static TestMode fromValue(String value) {
    switch (value) {
      case 'topics':
        return TestMode.topics;
      case 'failed':
        return TestMode.failedQuestions;
      case 'skipped':
        return TestMode.skippedQuestions;
      case 'survival':
        return TestMode.survival;
      case 'time_attack':
        return TestMode.timeAttack;
      default:
        return TestMode.topics;
    }
  }
}
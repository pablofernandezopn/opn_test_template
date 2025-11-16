import 'package:json_annotation/json_annotation.dart';
import 'answer_display_mode.dart';
import 'test_difficulty.dart';
import 'test_mode.dart';

part 'test_config.g.dart';

/// Modelo de configuración para crear un test personalizado
@JsonSerializable(explicitToJson: true)
class TestConfig {
  /// Número de preguntas del test
  @JsonKey(name: 'num_questions')
  final int numQuestions;

  /// Modo de mostrar las respuestas (inmediato o al finalizar)
  @JsonKey(name: 'answer_display_mode')
  final AnswerDisplayMode answerDisplayMode;

  /// Dificultades seleccionadas (puede ser múltiple)
  /// Si está vacío, se seleccionan todas las dificultades
  @JsonKey(name: 'difficulties')
  final List<TestDifficulty> difficulties;

  /// Lista de IDs de topics seleccionados (solo topics de tipo Study)
  @JsonKey(name: 'selected_topic_ids')
  final List<int> selectedTopicIds;

  /// Modos de test seleccionados (temas, falladas, en blanco)
  /// Se pueden combinar múltiples modos
  @JsonKey(name: 'test_modes')
  final List<TestMode> testModes;

  /// ID del tipo de tema seleccionado (TopicType)
  /// Usado para filtrar las preguntas en las edge functions
  @JsonKey(name: 'topic_type_id')
  final int? topicTypeId;

  const TestConfig({
    required this.numQuestions,
    required this.answerDisplayMode,
    required this.difficulties,
    required this.selectedTopicIds,
    this.testModes = const [TestMode.topics],
    this.topicTypeId,
  });

  /// Configuración por defecto (todas las dificultades)
  static const TestConfig defaultConfig = TestConfig(
    numQuestions: 10,
    answerDisplayMode: AnswerDisplayMode.atEnd,
    difficulties: [], // Vacío = todas las dificultades
    selectedTopicIds: [],
    testModes: [TestMode.topics],
  );

  /// Crea una instancia desde JSON
  factory TestConfig.fromJson(Map<String, dynamic> json) =>
      _$TestConfigFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$TestConfigToJson(this);

  /// Crea una copia con campos modificados
  TestConfig copyWith({
    int? numQuestions,
    AnswerDisplayMode? answerDisplayMode,
    List<TestDifficulty>? difficulties,
    List<int>? selectedTopicIds,
    List<TestMode>? testModes,
    int? topicTypeId,
  }) {
    return TestConfig(
      numQuestions: numQuestions ?? this.numQuestions,
      answerDisplayMode: answerDisplayMode ?? this.answerDisplayMode,
      difficulties: difficulties ?? this.difficulties,
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
      testModes: testModes ?? this.testModes,
      topicTypeId: topicTypeId ?? this.topicTypeId,
    );
  }

  /// Verifica si el modo topics está seleccionado
  bool get hasTopicsMode => testModes.contains(TestMode.topics);

  /// Verifica si hay algún modo de repaso seleccionado
  bool get hasReviewMode =>
      testModes.contains(TestMode.failedQuestions) ||
      testModes.contains(TestMode.skippedQuestions);

  /// Verifica si el modo survival está seleccionado
  bool get hasSurvivalMode => testModes.contains(TestMode.survival);

  /// Valida que la configuración sea correcta
  bool get isValid {
    if (numQuestions <= 0) return false;
    if (testModes.isEmpty) return false;

    // Si está en modo survival, no se requieren temas
    if (hasSurvivalMode) return true;

    // Si el modo topics está seleccionado y NO hay modos de repaso,
    // debe haber al menos un topic seleccionado
    // Si solo hay modos de repaso (sin modo topics), los topics son opcionales
    if (hasTopicsMode && !hasReviewMode && selectedTopicIds.isEmpty) return false;

    return true;
  }

  /// Obtiene el mensaje de error si la configuración no es válida
  String? get validationError {
    if (numQuestions <= 0) {
      return 'El número de preguntas debe ser mayor a 0';
    }
    if (testModes.isEmpty) {
      return 'Debes seleccionar al menos un modo de test';
    }

    // Si está en modo survival, no se requieren temas
    if (hasSurvivalMode) return null;

    // Solo requerir temas si el modo topics está seleccionado y no hay modos de repaso
    if (hasTopicsMode && !hasReviewMode && selectedTopicIds.isEmpty) {
      return 'Debes seleccionar al menos un tema';
    }
    return null;
  }

  @override
  String toString() {
    return 'TestConfig(numQuestions: $numQuestions, answerDisplayMode: $answerDisplayMode, difficulties: $difficulties, selectedTopicIds: $selectedTopicIds, testModes: $testModes, topicTypeId: $topicTypeId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestConfig &&
        other.numQuestions == numQuestions &&
        other.answerDisplayMode == answerDisplayMode &&
        _listEqualsGeneric(other.difficulties, difficulties) &&
        _listEqualsGeneric(other.selectedTopicIds, selectedTopicIds) &&
        _listEqualsGeneric(other.testModes, testModes) &&
        other.topicTypeId == topicTypeId;
  }

  @override
  int get hashCode {
    return numQuestions.hashCode ^
        answerDisplayMode.hashCode ^
        difficulties.hashCode ^
        selectedTopicIds.hashCode ^
        testModes.hashCode ^
        topicTypeId.hashCode;
  }

  /// Compara dos listas genéricas
  bool _listEqualsGeneric<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
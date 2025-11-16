import 'package:json_annotation/json_annotation.dart';
import 'answer_display_mode.dart';
import 'test_config.dart';
import 'test_difficulty.dart';
import 'test_mode.dart';

part 'saved_test_config.g.dart';

/// Modelo para configuración de test guardada
@JsonSerializable(explicitToJson: true)
class SavedTestConfig {
  /// ID único de la configuración guardada
  final int? id;

  /// ID del usuario propietario
  @JsonKey(name: 'user_id')
  final int userId;

  /// Nombre personalizado de la configuración
  @JsonKey(name: 'config_name')
  final String configName;

  /// Número de preguntas del test
  @JsonKey(name: 'num_questions')
  final int numQuestions;

  /// Modo de mostrar las respuestas
  @JsonKey(name: 'answer_display_mode')
  final String answerDisplayMode;

  /// Dificultades seleccionadas (puede estar vacío = todas)
  @JsonKey(name: 'difficulties')
  final List<String> difficulties;

  /// IDs de topics seleccionados
  @JsonKey(name: 'selected_topic_ids')
  final List<int> selectedTopicIds;

  /// Modos de test seleccionados
  @JsonKey(name: 'test_modes')
  final List<String> testModes;

  /// Fecha de creación
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const SavedTestConfig({
    this.id,
    required this.userId,
    required this.configName,
    required this.numQuestions,
    required this.answerDisplayMode,
    required this.difficulties,
    required this.selectedTopicIds,
    required this.testModes,
    this.createdAt,
    this.updatedAt,
  });

  /// Crea una instancia desde JSON
  factory SavedTestConfig.fromJson(Map<String, dynamic> json) =>
      _$SavedTestConfigFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$SavedTestConfigToJson(this);

  /// Crea una SavedTestConfig desde un TestConfig
  factory SavedTestConfig.fromTestConfig({
    required int userId,
    required String configName,
    required TestConfig config,
    int? id,
  }) {
    return SavedTestConfig(
      id: id,
      userId: userId,
      configName: configName,
      numQuestions: config.numQuestions,
      answerDisplayMode: config.answerDisplayMode.value,
      difficulties: config.difficulties.map((d) => d.value).toList(),
      selectedTopicIds: config.selectedTopicIds,
      testModes: config.testModes.map((m) => m.value).toList(),
    );
  }

  /// Convierte a TestConfig para usar en la aplicación
  TestConfig toTestConfig() {
    return TestConfig(
      numQuestions: numQuestions,
      answerDisplayMode: AnswerDisplayMode.fromString(answerDisplayMode),
      difficulties: difficulties
          .map((d) => TestDifficulty.fromString(d))
          .toList(),
      selectedTopicIds: selectedTopicIds,
      testModes: testModes
          .map((m) => TestModeExtension.fromValue(m))
          .toList(),
    );
  }

  /// Crea una copia con campos modificados
  SavedTestConfig copyWith({
    int? id,
    int? userId,
    String? configName,
    int? numQuestions,
    String? answerDisplayMode,
    List<String>? difficulties,
    List<int>? selectedTopicIds,
    List<String>? testModes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedTestConfig(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      configName: configName ?? this.configName,
      numQuestions: numQuestions ?? this.numQuestions,
      answerDisplayMode: answerDisplayMode ?? this.answerDisplayMode,
      difficulties: difficulties ?? this.difficulties,
      selectedTopicIds: selectedTopicIds ?? this.selectedTopicIds,
      testModes: testModes ?? this.testModes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SavedTestConfig(id: $id, configName: $configName, numQuestions: $numQuestions)';
  }
}
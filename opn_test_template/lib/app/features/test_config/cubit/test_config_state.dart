import 'package:freezed_annotation/freezed_annotation.dart';
import '../../topics/model/topic_model.dart';
import '../model/test_config.dart';
import '../model/saved_test_config.dart';

part 'test_config_state.freezed.dart';

enum StatusNames { loading, done, error }

class Status {
  final StatusNames status;
  final String message;

  Status({
    required this.status,
    String? message,
  }) : message = message ?? '';

  // Factory methods
  factory Status.loading([String? message]) =>
      Status(status: StatusNames.loading, message: message);

  factory Status.done([String? message]) =>
      Status(status: StatusNames.done, message: message);

  factory Status.error([String? message]) =>
      Status(status: StatusNames.error, message: message);

  // Getters de conveniencia
  bool get isLoading => status == StatusNames.loading;
  bool get isDone => status == StatusNames.done;
  bool get isError => status == StatusNames.error;

  // Necesario para Freezed
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Status &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          message == other.message;

  @override
  int get hashCode => status.hashCode ^ message.hashCode;

  @override
  String toString() => 'Status(status: $status, message: $message)';
}

@freezed
class TestConfigState with _$TestConfigState {
  const factory TestConfigState({
    /// Configuración actual del test
    required TestConfig config,

    /// Lista de topics disponibles de tipo Study
    @Default([]) List<Topic> availableTopics,

    /// Estado de carga de los topics
    required Status fetchTopicsStatus,

    /// Estado de validación de la configuración
    required Status validationStatus,

    /// Configuraciones guardadas del usuario
    @Default([]) List<SavedTestConfig> savedConfigs,

    /// Estado de carga de las configuraciones guardadas
    required Status savedConfigsStatus,

    /// Indica si está en modo juego (true) o estudio (false)
    @Default(false) bool isGameMode,

    /// Mensaje de error si hay alguno
    String? error,
  }) = _TestConfigState;

  const TestConfigState._();

  /// Helper para crear estado inicial
  factory TestConfigState.initial() => TestConfigState(
        config: TestConfig.defaultConfig,
        fetchTopicsStatus: Status.done(),
        validationStatus: Status.done(),
        savedConfigsStatus: Status.done(),
        error: null,
      );

  /// Verifica si hay topics seleccionados
  bool get hasSelectedTopics => config.selectedTopicIds.isNotEmpty;

  /// Verifica si la configuración es válida
  bool get isConfigValid => config.isValid;

  /// Obtiene los topics seleccionados
  List<Topic> get selectedTopics {
    return availableTopics
        .where((topic) => config.selectedTopicIds.contains(topic.id))
        .toList();
  }

  /// Verifica si un topic está seleccionado
  bool isTopicSelected(int topicId) {
    return config.selectedTopicIds.contains(topicId);
  }
}
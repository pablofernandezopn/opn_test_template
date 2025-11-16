import 'package:flutter_bloc/flutter_bloc.dart';
import '../../topics/model/topic_model.dart';
import '../model/answer_display_mode.dart';
import '../model/test_config.dart';
import '../model/test_difficulty.dart';
import '../model/test_mode.dart';
import '../model/saved_test_config.dart';
import '../repository/saved_test_config_repository.dart';
import 'test_config_state.dart';

class TestConfigCubit extends Cubit<TestConfigState> {
  final SavedTestConfigRepository _savedConfigRepository;

  TestConfigCubit(this._savedConfigRepository) : super(TestConfigState.initial());

  /// Establece manualmente los topics disponibles (pasados desde TopicCubit)
  /// Por defecto, selecciona todos los topics automáticamente
  void setAvailableTopics(List topics) {
    print('✅ [TEST_CONFIG_CUBIT] Estableciendo ${topics.length} topics disponibles');

    final topicList = topics as List<Topic>;

    // Obtener IDs de todos los topics disponibles
    final allTopicIds = topicList
        .where((topic) => topic.id != null)
        .map((topic) => topic.id!)
        .toList();

    // Si no hay topics ya seleccionados, seleccionar todos por defecto
    final currentSelectedIds = state.config.selectedTopicIds;
    final shouldSelectAll = currentSelectedIds.isEmpty;

    if (shouldSelectAll && allTopicIds.isNotEmpty) {
      print('✅ [TEST_CONFIG_CUBIT] Seleccionando todos los ${allTopicIds.length} topics por defecto');
      final newConfig = state.config.copyWith(selectedTopicIds: allTopicIds);
      emit(state.copyWith(
        availableTopics: topicList,
        fetchTopicsStatus: Status.done(),
        config: newConfig,
        error: null,
      ));
    } else {
      emit(state.copyWith(
        availableTopics: topicList,
        fetchTopicsStatus: Status.done(),
        error: null,
      ));
    }
  }

  /// Establece el ID del tipo de tema seleccionado (TopicType)
  void setTopicTypeId(int? topicTypeId) {
    final newConfig = state.config.copyWith(topicTypeId: topicTypeId);
    emit(state.copyWith(config: newConfig));
    print('✅ [TEST_CONFIG_CUBIT] TopicType ID establecido: $topicTypeId');
  }

  /// Actualiza el número de preguntas
  void updateNumQuestions(int numQuestions) {
    if (numQuestions < 1) return;

    final newConfig = state.config.copyWith(numQuestions: numQuestions);
    emit(state.copyWith(config: newConfig));
    _validateConfig();
  }

  /// Actualiza el modo de mostrar respuestas
  void updateAnswerDisplayMode(AnswerDisplayMode mode) {
    final newConfig = state.config.copyWith(answerDisplayMode: mode);
    emit(state.copyWith(config: newConfig));
  }

  /// Alterna una dificultad en la lista (toggle)
  void toggleDifficulty(TestDifficulty difficulty) {
    final currentDifficulties = List<TestDifficulty>.from(state.config.difficulties);

    if (currentDifficulties.contains(difficulty)) {
      currentDifficulties.remove(difficulty);
    } else {
      currentDifficulties.add(difficulty);
    }

    final newConfig = state.config.copyWith(difficulties: currentDifficulties);
    emit(state.copyWith(config: newConfig));
  }

  /// Establece todas las dificultades
  void selectAllDifficulties() {
    final newConfig = state.config.copyWith(
      difficulties: TestDifficulty.values.toList(),
    );
    emit(state.copyWith(config: newConfig));
  }

  /// Limpia todas las dificultades (todas seleccionadas por defecto)
  void clearDifficulties() {
    final newConfig = state.config.copyWith(difficulties: []);
    emit(state.copyWith(config: newConfig));
  }

  /// Alterna un modo de test (toggle)
  /// Los modos son mutuamente excluyentes:
  /// - "topics" no se puede combinar con "failed" o "skipped"
  /// - "failed" y "skipped" se pueden combinar entre sí
  void toggleTestMode(TestMode mode) {
    final currentModes = List<TestMode>.from(state.config.testModes);

    if (currentModes.contains(mode)) {
      // Si ya está seleccionado, deseleccionarlo
      currentModes.remove(mode);
    } else {
      // Si no está seleccionado, agregarlo y aplicar reglas de exclusión
      if (mode == TestMode.topics) {
        // Si seleccionamos topics, remover failed y skipped
        currentModes.clear();
        currentModes.add(TestMode.topics);
      } else {
        // Si seleccionamos failed o skipped, remover topics
        currentModes.remove(TestMode.topics);
        currentModes.add(mode);
      }
    }

    // Si la lista queda vacía, por defecto poner topics
    if (currentModes.isEmpty) {
      currentModes.add(TestMode.topics);
    }

    final newConfig = state.config.copyWith(testModes: currentModes);
    emit(state.copyWith(config: newConfig));
    _validateConfig();
  }

  /// Establece todos los modos de test
  void selectAllTestModes() {
    final newConfig = state.config.copyWith(
      testModes: TestMode.values.toList(),
    );
    emit(state.copyWith(config: newConfig));
    _validateConfig();
  }

  /// Establece un único modo de test (reemplaza los existentes)
  void setTestMode(TestMode mode) {
    final newConfig = state.config.copyWith(
      testModes: [mode],
    );
    emit(state.copyWith(config: newConfig));
    _validateConfig();
  }

  /// Establece si está en modo juego o estudio
  void setGameMode(bool isGameMode) {
    emit(state.copyWith(isGameMode: isGameMode));
    print('✅ [TEST_CONFIG_CUBIT] Modo de juego: $isGameMode');
  }

  /// Alterna la selección de un topic
  void toggleTopicSelection(int topicId) {
    final currentIds = List<int>.from(state.config.selectedTopicIds);

    if (currentIds.contains(topicId)) {
      currentIds.remove(topicId);
    } else {
      currentIds.add(topicId);
    }

    final newConfig = state.config.copyWith(selectedTopicIds: currentIds);
    emit(state.copyWith(config: newConfig));
    _validateConfig();
  }

  /// Selecciona múltiples topics
  void selectTopics(List<int> topicIds) {
    final newConfig = state.config.copyWith(selectedTopicIds: topicIds);
    emit(state.copyWith(config: newConfig));
    _validateConfig();
  }

  /// Deselecciona todos los topics
  void clearSelectedTopics() {
    final newConfig = state.config.copyWith(selectedTopicIds: []);
    emit(state.copyWith(config: newConfig));
    _validateConfig();
  }

  /// Selecciona todos los topics disponibles
  void selectAllTopics() {
    final allTopicIds = state.availableTopics
        .where((topic) => topic.id != null)
        .map((topic) => topic.id!)
        .toList();

    final newConfig = state.config.copyWith(selectedTopicIds: allTopicIds);
    emit(state.copyWith(config: newConfig));
    _validateConfig();
  }

  /// Valida la configuración actual
  void _validateConfig() {
    final error = state.config.validationError;

    if (error != null) {
      emit(state.copyWith(
        validationStatus: Status.error(error),
        error: error,
      ));
    } else {
      emit(state.copyWith(
        validationStatus: Status.done(),
        error: null,
      ));
    }
  }

  /// Valida la configuración actual de forma pública
  bool validateConfig() {
    _validateConfig();
    return state.config.isValid;
  }

  /// Resetea la configuración a los valores por defecto
  void resetConfig() {
    emit(state.copyWith(config: TestConfig.defaultConfig));
    _validateConfig();
  }

  /// Obtiene la configuración actual (para usarla al iniciar el test)
  TestConfig getConfig() {
    return state.config;
  }

  /// Obtiene una configuración para usuarios freemium
  /// Usuarios freemium tienen limitaciones:
  /// - Solo 10 preguntas
  /// - Todas las dificultades
  /// - Mostrar respuestas al final
  /// - Todos los temas disponibles (no pueden elegir)
  /// - Solo modo topics
  TestConfig getFreemiumConfig() {
    final allTopicIds = state.availableTopics
        .where((topic) => topic.id != null)
        .map((topic) => topic.id!)
        .toList();

    return TestConfig(
      numQuestions: 10,
      difficulties: [], // Vacío = todas las dificultades
      answerDisplayMode: AnswerDisplayMode.atEnd,
      selectedTopicIds: allTopicIds,
      testModes: [TestMode.topics], // Solo modo topics para freemium
      topicTypeId: state.config.topicTypeId, // Mantener el topicType seleccionado
    );
  }

  // ============================================================================
  // MÉTODOS PARA SAVED CONFIGS
  // ============================================================================

  /// Carga las configuraciones guardadas del usuario
  Future<void> loadSavedConfigs(int userId) async {
    try {
      emit(state.copyWith(savedConfigsStatus: Status.loading('Cargando configuraciones...')));

      final configs = await _savedConfigRepository.getUserConfigs(userId);

      emit(state.copyWith(
        savedConfigs: configs,
        savedConfigsStatus: Status.done(),
      ));

      print('✅ [TEST_CONFIG_CUBIT] ${configs.length} configuraciones cargadas');
    } catch (e) {
      print('❌ [TEST_CONFIG_CUBIT] Error cargando configs: $e');
      emit(state.copyWith(
        savedConfigsStatus: Status.error('Error cargando configuraciones'),
        error: e.toString(),
      ));
    }
  }

  /// Guarda la configuración actual con un nombre
  Future<bool> saveCurrentConfig({
    required int userId,
    required String configName,
  }) async {
    try {
      // Validar la configuración antes de guardar
      if (!state.config.isValid) {
        final error = state.config.validationError ?? 'Configuración inválida';
        emit(state.copyWith(
          savedConfigsStatus: Status.error(error),
          error: error,
        ));
        return false;
      }

      // Validación adicional: si el modo es topics, debe haber al menos un tema
      if (state.config.hasTopicsMode &&
          !state.config.hasReviewMode &&
          state.config.selectedTopicIds.isEmpty) {
        const error = 'No puedes guardar una configuración sin temas seleccionados';
        emit(state.copyWith(
          savedConfigsStatus: Status.error(error),
          error: error,
        ));
        return false;
      }

      emit(state.copyWith(savedConfigsStatus: Status.loading('Guardando configuración...')));

      final savedConfig = SavedTestConfig.fromTestConfig(
        userId: userId,
        configName: configName,
        config: state.config,
      );

      final saved = await _savedConfigRepository.saveConfig(savedConfig);

      // Actualizar la lista de configuraciones guardadas
      // Crear una nueva lista para asegurar que se detecte el cambio
      final updatedConfigs = List<SavedTestConfig>.from(state.savedConfigs)
        ..insert(0, saved);

      print('📋 [TEST_CONFIG_CUBIT] Lista antes de guardar: ${state.savedConfigs.length} configs');
      print('📋 [TEST_CONFIG_CUBIT] Lista después de guardar: ${updatedConfigs.length} configs');

      emit(state.copyWith(
        savedConfigs: updatedConfigs,
        savedConfigsStatus: Status.done('Configuración guardada ${DateTime.now().millisecondsSinceEpoch}'),
      ));

      print('✅ [TEST_CONFIG_CUBIT] Configuración guardada: $configName');
      print('✅ [TEST_CONFIG_CUBIT] Estado actualizado con ${state.savedConfigs.length} configs');
      return true;
    } catch (e) {
      print('❌ [TEST_CONFIG_CUBIT] Error guardando config: $e');

      String errorMessage = 'Error guardando configuración';
      if (e.toString().contains('Ya existe una configuración')) {
        errorMessage = 'Ya existe una configuración con ese nombre';
      }

      emit(state.copyWith(
        savedConfigsStatus: Status.error(errorMessage),
        error: e.toString(),
      ));

      return false;
    }
  }

  /// Carga una configuración guardada
  void loadSavedConfig(SavedTestConfig savedConfig) {
    try {
      print('🔄 [TEST_CONFIG_CUBIT] Cargando configuración: ${savedConfig.configName}');

      final testConfig = savedConfig.toTestConfig();

      print('📋 [TEST_CONFIG_CUBIT] Configuración cargada:');
      print('   - TopicTypeId: ${testConfig.topicTypeId}');
      print('   - Topics seleccionados: ${testConfig.selectedTopicIds.length}');
      print('   - Número de preguntas: ${testConfig.numQuestions}');
      print('   - Dificultades: ${testConfig.difficulties}');


      emit(state.copyWith(
        config: testConfig,
        isGameMode: false, // Al cargar config, cambiar a modo estudio
      ));
      _validateConfig();

      print('✅ [TEST_CONFIG_CUBIT] Configuración cargada exitosamente: ${savedConfig.configName}');
    } catch (e) {
      print('❌ [TEST_CONFIG_CUBIT] Error cargando config: $e');
      emit(state.copyWith(
        error: 'Error cargando configuración: ${e.toString()}',
      ));
    }
  }

  /// Elimina una configuración guardada
  Future<bool> deleteSavedConfig(int configId) async {
    try {
      emit(state.copyWith(savedConfigsStatus: Status.loading('Eliminando configuración...')));

      await _savedConfigRepository.deleteConfig(configId);

      // Actualizar la lista de configuraciones guardadas
      // Crear una nueva lista para asegurar que se detecte el cambio
      final updatedConfigs = List<SavedTestConfig>.from(state.savedConfigs)
        ..removeWhere((config) => config.id == configId);

      print('📋 [TEST_CONFIG_CUBIT] Lista antes de eliminar: ${state.savedConfigs.length} configs');
      print('📋 [TEST_CONFIG_CUBIT] Lista después de eliminar: ${updatedConfigs.length} configs');

      emit(state.copyWith(
        savedConfigs: updatedConfigs,
        savedConfigsStatus: Status.done('Configuración eliminada ${DateTime.now().millisecondsSinceEpoch}'),
      ));

      print('✅ [TEST_CONFIG_CUBIT] Configuración eliminada');
      return true;
    } catch (e) {
      print('❌ [TEST_CONFIG_CUBIT] Error eliminando config: $e');
      emit(state.copyWith(
        savedConfigsStatus: Status.error('Error eliminando configuración'),
        error: e.toString(),
      ));

      return false;
    }
  }

  /// Actualiza una configuración guardada
  Future<bool> updateSavedConfig(SavedTestConfig config) async {
    try {
      emit(state.copyWith(savedConfigsStatus: Status.loading('Actualizando configuración...')));

      final updated = await _savedConfigRepository.updateConfig(config);

      // Actualizar la lista de configuraciones guardadas
      final updatedConfigs = state.savedConfigs.map((c) {
        return c.id == updated.id ? updated : c;
      }).toList();

      emit(state.copyWith(
        savedConfigs: updatedConfigs,
        savedConfigsStatus: Status.done('Configuración actualizada'),
      ));

      print('✅ [TEST_CONFIG_CUBIT] Configuración actualizada');
      return true;
    } catch (e) {
      print('❌ [TEST_CONFIG_CUBIT] Error actualizando config: $e');

      String errorMessage = 'Error actualizando configuración';
      if (e.toString().contains('Ya existe una configuración')) {
        errorMessage = 'Ya existe una configuración con ese nombre';
      }

      emit(state.copyWith(
        savedConfigsStatus: Status.error(errorMessage),
        error: e.toString(),
      ));

      return false;
    }
  }
}

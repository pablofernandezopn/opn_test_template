import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/ai_model.dart';
import '../model/chat_user_preferences.dart';
import '../repository/chat_preferences_repository.dart';
import 'chat_preferences_state.dart';

class ChatPreferencesCubit extends Cubit<ChatPreferencesState> {
  final ChatPreferencesRepository _repository;
  final int _userId;

  ChatPreferencesCubit({
    required ChatPreferencesRepository repository,
    required int userId,
  })  : _repository = repository,
        _userId = userId,
        super(const ChatPreferencesState());

  /// Inicializa el cubit cargando modelos y preferencias
  Future<void> initialize() async {
    await Future.wait([
      loadAvailableModels(),
      loadUserPreferences(),
    ]);
  }

  /// Carga los modelos de IA disponibles
  Future<void> loadAvailableModels() async {
    emit(state.copyWith(isLoadingModels: true, hasError: false));

    try {
      final models = await _repository.getAvailableModels();
      emit(state.copyWith(
        availableModels: models,
        isLoadingModels: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingModels: false,
        hasError: true,
        errorMessage: 'Error al cargar modelos: $e',
      ));
    }
  }

  /// Carga las preferencias del usuario
  Future<void> loadUserPreferences() async {
    emit(state.copyWith(isLoadingPreferences: true, hasError: false));

    try {
      final preferences = await _repository.getUserPreferences(_userId);

      // Si hay un modelo seleccionado, cargarlo
      AiModel? selectedModel;
      if (preferences.aiModelId != null) {
        selectedModel = await _repository.getModelById(preferences.aiModelId!);
      }

      emit(state.copyWith(
        preferences: preferences,
        selectedModel: selectedModel,
        isLoadingPreferences: false,
        hasUnsavedChanges: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingPreferences: false,
        hasError: true,
        errorMessage: 'Error al cargar preferencias: $e',
      ));
    }
  }

  /// Actualiza el modelo seleccionado
  void updateSelectedModel(AiModel? model) {
    if (state.preferences == null) return;

    final updatedPreferences = state.preferences!.copyWith(
      aiModelId: model?.id,
    );

    emit(state.copyWith(
      preferences: updatedPreferences,
      selectedModel: model,
      hasUnsavedChanges: true,
    ));
  }

  /// Actualiza la longitud de respuesta
  void updateResponseLength(ResponseLength length) {
    if (state.preferences == null) return;

    final updatedPreferences = state.preferences!.copyWith(
      responseLength: length,
    );

    emit(state.copyWith(
      preferences: updatedPreferences,
      hasUnsavedChanges: true,
    ));
  }

  /// Actualiza el tono de conversación
  void updateTone(ConversationTone tone) {
    if (state.preferences == null) return;

    final updatedPreferences = state.preferences!.copyWith(
      tone: tone,
    );

    emit(state.copyWith(
      preferences: updatedPreferences,
      hasUnsavedChanges: true,
    ));
  }

  /// Actualiza si se deben usar emojis
  void updateEnableEmojis(bool enable) {
    if (state.preferences == null) return;

    final updatedPreferences = state.preferences!.copyWith(
      enableEmojis: enable,
    );

    emit(state.copyWith(
      preferences: updatedPreferences,
      hasUnsavedChanges: true,
    ));
  }

  /// Actualiza el límite máximo de tokens
  void updateMaxTokens(int? maxTokens) {
    if (state.preferences == null) return;

    final updatedPreferences = state.preferences!.copyWith(
      maxTokens: maxTokens,
    );

    emit(state.copyWith(
      preferences: updatedPreferences,
      hasUnsavedChanges: true,
    ));
  }

  /// Actualiza el system prompt personalizado
  void updateCustomSystemPrompt(String? prompt) {
    if (state.preferences == null) return;

    final updatedPreferences = state.preferences!.copyWith(
      customSystemPrompt: prompt?.trim().isEmpty == true ? null : prompt?.trim(),
    );

    emit(state.copyWith(
      preferences: updatedPreferences,
      hasUnsavedChanges: true,
    ));
  }

  /// Guarda las preferencias en la base de datos
  Future<void> savePreferences() async {
    if (state.preferences == null) return;

    emit(state.copyWith(isSaving: true, hasError: false));

    try {
      final savedPreferences = await _repository.upsertUserPreferences(
        state.preferences!,
      );

      emit(state.copyWith(
        preferences: savedPreferences,
        isSaving: false,
        hasUnsavedChanges: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        hasError: true,
        errorMessage: 'Error al guardar preferencias: $e',
      ));
    }
  }

  /// Restaura las preferencias a los valores por defecto
  Future<void> resetToDefaults() async {
    emit(state.copyWith(isSaving: true, hasError: false));

    try {
      // Eliminar preferencias actuales
      await _repository.deleteUserPreferences(_userId);

      // Cargar las preferencias por defecto
      final defaultPreferences =
          ChatUserPreferences.defaultPreferences(_userId);

      emit(state.copyWith(
        preferences: defaultPreferences,
        selectedModel: null,
        isSaving: false,
        hasUnsavedChanges: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        hasError: true,
        errorMessage: 'Error al restaurar preferencias: $e',
      ));
    }
  }

  /// Limpia el mensaje de error
  void clearError() {
    emit(state.copyWith(hasError: false, errorMessage: null));
  }

  /// Descarta los cambios no guardados
  Future<void> discardChanges() async {
    await loadUserPreferences();
  }
}

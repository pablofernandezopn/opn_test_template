import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/ai_model.dart';
import '../model/chat_user_preferences.dart';

part 'chat_preferences_state.freezed.dart';

@freezed
class ChatPreferencesState with _$ChatPreferencesState {
  const factory ChatPreferencesState({
    // Lista de modelos disponibles
    @Default([]) List<AiModel> availableModels,

    // Preferencias actuales del usuario
    ChatUserPreferences? preferences,

    // Modelo actualmente seleccionado
    AiModel? selectedModel,

    // Estados de carga
    @Default(false) bool isLoadingModels,
    @Default(false) bool isLoadingPreferences,
    @Default(false) bool isSaving,

    // Estados de error
    String? errorMessage,
    @Default(false) bool hasError,

    // Flag para saber si hubo cambios sin guardar
    @Default(false) bool hasUnsavedChanges,
  }) = _ChatPreferencesState;

  const ChatPreferencesState._();

  /// Si está cargando algo
  bool get isLoading =>
      isLoadingModels || isLoadingPreferences || isSaving;
}

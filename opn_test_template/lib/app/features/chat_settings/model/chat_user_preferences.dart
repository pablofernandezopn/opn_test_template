import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_user_preferences.freezed.dart';
part 'chat_user_preferences.g.dart';

/// Enum para la longitud de respuestas
enum ResponseLength {
  @JsonValue('short')
  short,
  @JsonValue('normal')
  normal,
  @JsonValue('long')
  long;

  String get displayName {
    switch (this) {
      case ResponseLength.short:
        return 'Corta';
      case ResponseLength.normal:
        return 'Normal';
      case ResponseLength.long:
        return 'Larga';
    }
  }

  String get description {
    switch (this) {
      case ResponseLength.short:
        return 'Respuestas concisas y al punto';
      case ResponseLength.normal:
        return 'Balance entre detalle y brevedad';
      case ResponseLength.long:
        return 'Respuestas detalladas y completas';
    }
  }
}

/// Enum para el tono de conversación
enum ConversationTone {
  @JsonValue('formal')
  formal,
  @JsonValue('casual')
  casual,
  @JsonValue('friendly')
  friendly,
  @JsonValue('professional')
  professional;

  String get displayName {
    switch (this) {
      case ConversationTone.formal:
        return 'Formal';
      case ConversationTone.casual:
        return 'Casual';
      case ConversationTone.friendly:
        return 'Amigable';
      case ConversationTone.professional:
        return 'Profesional';
    }
  }

  String get description {
    switch (this) {
      case ConversationTone.formal:
        return 'Tono serio y respetuoso';
      case ConversationTone.casual:
        return 'Tono relajado e informal';
      case ConversationTone.friendly:
        return 'Tono cercano y amable';
      case ConversationTone.professional:
        return 'Tono técnico y directo';
    }
  }
}

/// Modelo que representa las preferencias de chat del usuario
@freezed
class ChatUserPreferences with _$ChatUserPreferences {
  const factory ChatUserPreferences({
    int? id,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'ai_model_id') int? aiModelId,
    @JsonKey(name: 'response_length')
    @Default(ResponseLength.normal)
    ResponseLength responseLength,
    @JsonKey(name: 'max_tokens') int? maxTokens,
    @JsonKey(name: 'custom_system_prompt') String? customSystemPrompt,
    @Default(ConversationTone.friendly) ConversationTone tone,
    @JsonKey(name: 'enable_emojis') @Default(true) bool enableEmojis,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _ChatUserPreferences;

  factory ChatUserPreferences.fromJson(Map<String, dynamic> json) =>
      _$ChatUserPreferencesFromJson(json);

  /// Factory para crear preferencias por defecto
  factory ChatUserPreferences.defaultPreferences(int userId) =>
      ChatUserPreferences(
        userId: userId,
        responseLength: ResponseLength.normal,
        tone: ConversationTone.friendly,
        enableEmojis: true,
      );
}

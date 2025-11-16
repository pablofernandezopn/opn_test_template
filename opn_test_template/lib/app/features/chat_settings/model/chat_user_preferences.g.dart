// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_user_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatUserPreferencesImpl _$$ChatUserPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatUserPreferencesImpl(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num).toInt(),
      aiModelId: (json['ai_model_id'] as num?)?.toInt(),
      responseLength: $enumDecodeNullable(
              _$ResponseLengthEnumMap, json['response_length']) ??
          ResponseLength.normal,
      maxTokens: (json['max_tokens'] as num?)?.toInt(),
      customSystemPrompt: json['custom_system_prompt'] as String?,
      tone: $enumDecodeNullable(_$ConversationToneEnumMap, json['tone']) ??
          ConversationTone.friendly,
      enableEmojis: json['enable_emojis'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ChatUserPreferencesImplToJson(
        _$ChatUserPreferencesImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'ai_model_id': instance.aiModelId,
      'response_length': _$ResponseLengthEnumMap[instance.responseLength]!,
      'max_tokens': instance.maxTokens,
      'custom_system_prompt': instance.customSystemPrompt,
      'tone': _$ConversationToneEnumMap[instance.tone]!,
      'enable_emojis': instance.enableEmojis,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$ResponseLengthEnumMap = {
  ResponseLength.short: 'short',
  ResponseLength.normal: 'normal',
  ResponseLength.long: 'long',
};

const _$ConversationToneEnumMap = {
  ConversationTone.formal: 'formal',
  ConversationTone.casual: 'casual',
  ConversationTone.friendly: 'friendly',
  ConversationTone.professional: 'professional',
};

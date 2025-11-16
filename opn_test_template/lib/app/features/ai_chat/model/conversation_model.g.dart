// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      systemPromptId: (json['system_prompt_id'] as num?)?.toInt(),
      title: json['title'] as String?,
      status:
          $enumDecodeNullable(_$ConversationStatusEnumMap, json['status']) ??
              ConversationStatus.active,
      aiProvider:
          $enumDecodeNullable(_$AiProviderEnumMap, json['ai_provider']) ??
              AiProvider.openai,
      model: json['model'] as String? ?? 'gpt-4o-mini',
      totalTokens: (json['total_tokens'] as num?)?.toInt() ?? 0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      messageCount: (json['message_count'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'system_prompt_id': instance.systemPromptId,
      'title': instance.title,
      'status': _$ConversationStatusEnumMap[instance.status]!,
      'ai_provider': _$AiProviderEnumMap[instance.aiProvider]!,
      'model': instance.model,
      'total_tokens': instance.totalTokens,
      'total_cost': instance.totalCost,
      'message_count': instance.messageCount,
      'metadata': instance.metadata,
      'last_message_at': instance.lastMessageAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$ConversationStatusEnumMap = {
  ConversationStatus.active: 'active',
  ConversationStatus.archived: 'archived',
  ConversationStatus.deleted: 'deleted',
};

const _$AiProviderEnumMap = {
  AiProvider.openai: 'openai',
  AiProvider.deepseek: 'deepseek',
  AiProvider.anthropic: 'anthropic',
  AiProvider.custom: 'custom',
};

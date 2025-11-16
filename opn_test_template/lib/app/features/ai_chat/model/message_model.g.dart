// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: (json['id'] as num).toInt(),
      conversationId: (json['conversation_id'] as num).toInt(),
      role: $enumDecode(_$MessageRoleDbEnumMap, json['role']),
      content: json['content'] as String,
      tokens: (json['tokens'] as num?)?.toInt(),
      cost: (json['cost'] as num?)?.toDouble(),
      model: json['model'] as String?,
      finishReason: json['finish_reason'] as String?,
      functionCall: json['function_call'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'role': _$MessageRoleDbEnumMap[instance.role]!,
      'content': instance.content,
      'tokens': instance.tokens,
      'cost': instance.cost,
      'model': instance.model,
      'finish_reason': instance.finishReason,
      'function_call': instance.functionCall,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$MessageRoleDbEnumMap = {
  MessageRoleDb.system: 'system',
  MessageRoleDb.user: 'user',
  MessageRoleDb.assistant: 'assistant',
  MessageRoleDb.function: 'function',
};

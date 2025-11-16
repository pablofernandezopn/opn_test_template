// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiModelImpl _$$AiModelImplFromJson(Map<String, dynamic> json) =>
    _$AiModelImpl(
      id: (json['id'] as num).toInt(),
      modelKey: json['model_key'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String?,
      provider: json['provider'] as String,
      speedRating: (json['speed_rating'] as num?)?.toInt(),
      thinkingCapability: (json['thinking_capability'] as num?)?.toInt(),
      maxTokens: (json['max_tokens'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$AiModelImplToJson(_$AiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'model_key': instance.modelKey,
      'display_name': instance.displayName,
      'description': instance.description,
      'provider': instance.provider,
      'speed_rating': instance.speedRating,
      'thinking_capability': instance.thinkingCapability,
      'max_tokens': instance.maxTokens,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

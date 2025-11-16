// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopicGroup _$TopicGroupFromJson(Map<String, dynamic> json) => TopicGroup(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      academyId: (json['academy_id'] as num?)?.toInt() ?? 1,
      enabled: json['enabled'] as bool? ?? true,
      isPremium: json['is_premium'] as bool? ?? false,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TopicGroupToJson(TopicGroup instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'academy_id': instance.academyId,
      'enabled': instance.enabled,
      'is_premium': instance.isPremium,
      'published_at': instance.publishedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

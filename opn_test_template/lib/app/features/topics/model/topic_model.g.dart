// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
      id: (json['id'] as num?)?.toInt(),
      order: (json['order'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 55 * 60,
      topicTypeId: (json['topic_type_id'] as num).toInt(),
      topicName: json['topic_name'] as String,
      description: json['description'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      isPremium: json['is_premium'] as bool? ?? false,
      isHiddenButPremium: json['is_hidden_but_premium'] as bool? ?? false,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      totalParticipants: (json['total_participants'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      totalScore: (json['total_score'] as num?)?.toInt() ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      options: (json['options'] as num?)?.toInt() ?? 3,
      maxScore: (json['max_score'] as num?)?.toInt() ?? 0,
      minScore: (json['min_score'] as num?)?.toInt() ?? 0,
      academyId: (json['academy_id'] as num?)?.toInt() ?? 1,
      categoryId: (json['category_id'] as num?)?.toInt(),
      topicGroupId: (json['topic_group_id'] as num?)?.toInt(),
      groupOrder: (json['group_order'] as num?)?.toInt(),
      specialtyId: (json['specialty_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
      'topic_type_id': instance.topicTypeId,
      'order': instance.order,
      'topic_name': instance.topicName,
      'image_url': instance.imageUrl,
      'description': instance.description,
      'enabled': instance.enabled,
      'duration_seconds': instance.durationSeconds,
      'is_premium': instance.isPremium,
      'is_hidden_but_premium': instance.isHiddenButPremium,
      'published_at': instance.publishedAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'options': instance.options,
      'category_id': instance.categoryId,
      'academy_id': instance.academyId,
      'topic_group_id': instance.topicGroupId,
      'group_order': instance.groupOrder,
      'specialty_id': instance.specialtyId,
    };

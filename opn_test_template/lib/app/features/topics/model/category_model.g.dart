// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      name: json['name'] as String?,
      topicType: (json['topic_type'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      'created_at': instance.createdAt?.toIso8601String(),
      'name': instance.name,
      'topic_type': instance.topicType,
    };

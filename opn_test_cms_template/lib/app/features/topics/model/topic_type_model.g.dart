// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopicType _$TopicTypeFromJson(Map<String, dynamic> json) => TopicType(
      id: (json['id'] as num?)?.toInt(),
      topicTypeName: json['topic_type_name'] as String,
      defaultNumberOptions:
          (json['default_number_options'] as num?)?.toInt() ?? 4,
      description: json['description'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      penalty: (json['penalty'] as num?)?.toDouble() ?? 0.5,
      level: $enumDecodeNullable(_$TopicLevelEnumMap, json['level']) ??
          TopicLevel.Mock,
      orderOfAppearance: (json['order_of_appearance'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TopicTypeToJson(TopicType instance) => <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      'topic_type_name': instance.topicTypeName,
      'default_number_options': instance.defaultNumberOptions,
      'description': instance.description,
      'created_at': instance.createdAt?.toIso8601String(),
      'penalty': instance.penalty,
      'level': _$TopicLevelEnumMap[instance.level],
      'order_of_appearance': instance.orderOfAppearance,
    };

const _$TopicLevelEnumMap = {
  TopicLevel.Mock: 'Mock',
  TopicLevel.Study: 'Study',
  TopicLevel.Flashcard: 'Flashcard',
  TopicLevel.Unknown: 'Unknown',
};

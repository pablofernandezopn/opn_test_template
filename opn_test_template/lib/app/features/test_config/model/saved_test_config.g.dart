// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_test_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavedTestConfig _$SavedTestConfigFromJson(Map<String, dynamic> json) =>
    SavedTestConfig(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num).toInt(),
      configName: json['config_name'] as String,
      numQuestions: (json['num_questions'] as num).toInt(),
      answerDisplayMode: json['answer_display_mode'] as String,
      difficulties: (json['difficulties'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      selectedTopicIds: (json['selected_topic_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      testModes: (json['test_modes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SavedTestConfigToJson(SavedTestConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'config_name': instance.configName,
      'num_questions': instance.numQuestions,
      'answer_display_mode': instance.answerDisplayMode,
      'difficulties': instance.difficulties,
      'selected_topic_ids': instance.selectedTopicIds,
      'test_modes': instance.testModes,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestConfig _$TestConfigFromJson(Map<String, dynamic> json) => TestConfig(
      numQuestions: (json['num_questions'] as num).toInt(),
      answerDisplayMode:
          $enumDecode(_$AnswerDisplayModeEnumMap, json['answer_display_mode']),
      difficulties: (json['difficulties'] as List<dynamic>)
          .map((e) => $enumDecode(_$TestDifficultyEnumMap, e))
          .toList(),
      selectedTopicIds: (json['selected_topic_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      testModes: (json['test_modes'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$TestModeEnumMap, e))
              .toList() ??
          const [TestMode.topics],
      topicTypeId: (json['topic_type_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TestConfigToJson(TestConfig instance) =>
    <String, dynamic>{
      'num_questions': instance.numQuestions,
      'answer_display_mode':
          _$AnswerDisplayModeEnumMap[instance.answerDisplayMode]!,
      'difficulties': instance.difficulties
          .map((e) => _$TestDifficultyEnumMap[e]!)
          .toList(),
      'selected_topic_ids': instance.selectedTopicIds,
      'test_modes':
          instance.testModes.map((e) => _$TestModeEnumMap[e]!).toList(),
      'topic_type_id': instance.topicTypeId,
    };

const _$AnswerDisplayModeEnumMap = {
  AnswerDisplayMode.immediate: 'immediate',
  AnswerDisplayMode.atEnd: 'at_end',
};

const _$TestDifficultyEnumMap = {
  TestDifficulty.easy: 'easy',
  TestDifficulty.normal: 'normal',
  TestDifficulty.hard: 'hard',
};

const _$TestModeEnumMap = {
  TestMode.topics: 'topics',
  TestMode.failedQuestions: 'failedQuestions',
  TestMode.skippedQuestions: 'skippedQuestions',
  TestMode.survival: 'survival',
  TestMode.timeAttack: 'timeAttack',
};

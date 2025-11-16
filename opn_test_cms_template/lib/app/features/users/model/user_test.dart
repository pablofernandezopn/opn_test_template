import 'package:json_annotation/json_annotation.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_model.dart';

part 'user_test.g.dart';

@JsonSerializable()
class UserTest {
  final int id;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'topic_ids')
  final List<int> topicIds;

  @JsonKey(name: 'right_questions')
  final int rightQuestions;

  @JsonKey(name: 'wrong_questions')
  final int wrongQuestions;

  @JsonKey(name: 'question_count')
  final int questionCount;

  final double? score;

  final bool finalized;

  @JsonKey(name: 'time_spent_millis')
  final int? timeSpentMillis;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  final List<Topic>? topics;

  const UserTest({
    required this.id,
    required this.userId,
    required this.topicIds,
    required this.rightQuestions,
    required this.wrongQuestions,
    required this.questionCount,
    this.score,
    required this.finalized,
    this.timeSpentMillis,
    required this.createdAt,
    required this.updatedAt,
    this.topics,
  });

  factory UserTest.fromJson(Map<String, dynamic> json) =>
      _$UserTestFromJson(json);

  Map<String, dynamic> toJson() => _$UserTestToJson(this);

  double get successRate =>
      questionCount > 0 ? rightQuestions / questionCount : 0;

  double get errorRate =>
      questionCount > 0 ? wrongQuestions / questionCount : 0;

  double get emptyRate => questionCount > 0
      ? (questionCount - rightQuestions - wrongQuestions) / questionCount
      : 0;

  int get emptyQuestions => questionCount - rightQuestions - wrongQuestions;
}

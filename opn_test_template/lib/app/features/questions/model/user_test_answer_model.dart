import 'package:json_annotation/json_annotation.dart';

part 'user_test_answer_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserTestAnswer {
  const UserTestAnswer({
    this.id,
    required this.userTestId,
    required this.questionId,
    this.selectedOptionId,
    this.correct,
    this.timeTakenSeconds,
    required this.questionOrder,
    this.challengeByTutor = false,
    this.answeredAt,
    this.difficultyRating,
    this.nextReviewDate,
    this.reviewIntervalDays,
    this.easeFactor,
    this.repetitions,
    this.time,
    this.shuffledOptionIds,
  });

  final int? id;
  final int userTestId;
  final int questionId;
  final int? selectedOptionId;
  final bool? correct;
  final int? timeTakenSeconds;
  final int questionOrder;
  final bool challengeByTutor;
  final DateTime? answeredAt;
  final String? difficultyRating;
  final DateTime? nextReviewDate;
  final int? reviewIntervalDays;
  final double? easeFactor;
  final int? repetitions;
  final int? time;

  /// Array de IDs de opciones en el orden presentado al usuario
  /// Permite preservar el orden shuffle al revisar desde historial
  final List<int>? shuffledOptionIds;

  factory UserTestAnswer.fromJson(Map<String, dynamic> json) => _$UserTestAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$UserTestAnswerToJson(this);

  Map<String, dynamic> toInsertMap() {
    final map = toJson()
      ..remove('id');
    map.removeWhere((key, value) => value == null);
    return map;
  }
}

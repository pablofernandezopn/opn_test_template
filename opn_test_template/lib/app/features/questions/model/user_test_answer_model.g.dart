// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_test_answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserTestAnswer _$UserTestAnswerFromJson(Map<String, dynamic> json) =>
    UserTestAnswer(
      id: (json['id'] as num?)?.toInt(),
      userTestId: (json['user_test_id'] as num).toInt(),
      questionId: (json['question_id'] as num).toInt(),
      selectedOptionId: (json['selected_option_id'] as num?)?.toInt(),
      correct: json['correct'] as bool?,
      timeTakenSeconds: (json['time_taken_seconds'] as num?)?.toInt(),
      questionOrder: (json['question_order'] as num).toInt(),
      challengeByTutor: json['challenge_by_tutor'] as bool? ?? false,
      answeredAt: json['answered_at'] == null
          ? null
          : DateTime.parse(json['answered_at'] as String),
      difficultyRating: json['difficulty_rating'] as String?,
      nextReviewDate: json['next_review_date'] == null
          ? null
          : DateTime.parse(json['next_review_date'] as String),
      reviewIntervalDays: (json['review_interval_days'] as num?)?.toInt(),
      easeFactor: (json['ease_factor'] as num?)?.toDouble(),
      repetitions: (json['repetitions'] as num?)?.toInt(),
      time: (json['time'] as num?)?.toInt(),
      shuffledOptionIds: (json['shuffled_option_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$UserTestAnswerToJson(UserTestAnswer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_test_id': instance.userTestId,
      'question_id': instance.questionId,
      'selected_option_id': instance.selectedOptionId,
      'correct': instance.correct,
      'time_taken_seconds': instance.timeTakenSeconds,
      'question_order': instance.questionOrder,
      'challenge_by_tutor': instance.challengeByTutor,
      'answered_at': instance.answeredAt?.toIso8601String(),
      'difficulty_rating': instance.difficultyRating,
      'next_review_date': instance.nextReviewDate?.toIso8601String(),
      'review_interval_days': instance.reviewIntervalDays,
      'ease_factor': instance.easeFactor,
      'repetitions': instance.repetitions,
      'time': instance.time,
      'shuffled_option_ids': instance.shuffledOptionIds,
    };

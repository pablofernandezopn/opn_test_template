// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_chat_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionChatResponse _$QuestionChatResponseFromJson(
        Map<String, dynamic> json) =>
    QuestionChatResponse(
      conversationId: (json['conversation_id'] as num).toInt(),
      messageId: (json['message_id'] as num?)?.toInt(),
      response: json['response'] as String?,
      reasoning: json['reasoning'] as String?,
      citations: (json['citations'] as List<dynamic>?)
          ?.map((e) => Citation.fromJson(e as Map<String, dynamic>))
          .toList(),
      performanceContext: json['performance_context'] == null
          ? null
          : PerformanceContext.fromJson(
              json['performance_context'] as Map<String, dynamic>),
      questionContext: json['question_context'] == null
          ? null
          : QuestionContext.fromJson(
              json['question_context'] as Map<String, dynamic>),
      ready: json['ready'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$QuestionChatResponseToJson(
        QuestionChatResponse instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'message_id': instance.messageId,
      'response': instance.response,
      'reasoning': instance.reasoning,
      'citations': instance.citations,
      'performance_context': instance.performanceContext,
      'question_context': instance.questionContext,
      'ready': instance.ready,
      'message': instance.message,
    };

Citation _$CitationFromJson(Map<String, dynamic> json) => Citation(
      lawTitle: json['law_title'] as String?,
      itemTitle: json['item_title'] as String?,
      content: json['content'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$CitationToJson(Citation instance) => <String, dynamic>{
      'law_title': instance.lawTitle,
      'item_title': instance.itemTitle,
      'content': instance.content,
      'url': instance.url,
    };

QuestionContext _$QuestionContextFromJson(Map<String, dynamic> json) =>
    QuestionContext(
      questionId: (json['question_id'] as num).toInt(),
      statement: json['statement'] as String,
      topic: json['topic'] as String,
      difficulty: (json['difficulty'] as num?)?.toDouble(),
      options: (json['options'] as List<dynamic>)
          .map(
              (e) => QuestionOptionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctAnswer: CorrectAnswer.fromJson(
          json['correct_answer'] as Map<String, dynamic>),
      userAnswer: json['user_answer'] == null
          ? null
          : UserAnswerResponse.fromJson(
              json['user_answer'] as Map<String, dynamic>),
      tip: json['tip'] as String?,
    );

Map<String, dynamic> _$QuestionContextToJson(QuestionContext instance) =>
    <String, dynamic>{
      'question_id': instance.questionId,
      'statement': instance.statement,
      'topic': instance.topic,
      'difficulty': instance.difficulty,
      'options': instance.options,
      'correct_answer': instance.correctAnswer,
      'user_answer': instance.userAnswer,
      'tip': instance.tip,
    };

QuestionOptionResponse _$QuestionOptionResponseFromJson(
        Map<String, dynamic> json) =>
    QuestionOptionResponse(
      order: (json['order'] as num).toInt(),
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool,
    );

Map<String, dynamic> _$QuestionOptionResponseToJson(
        QuestionOptionResponse instance) =>
    <String, dynamic>{
      'order': instance.order,
      'text': instance.text,
      'is_correct': instance.isCorrect,
    };

CorrectAnswer _$CorrectAnswerFromJson(Map<String, dynamic> json) =>
    CorrectAnswer(
      order: (json['order'] as num).toInt(),
      text: json['text'] as String,
    );

Map<String, dynamic> _$CorrectAnswerToJson(CorrectAnswer instance) =>
    <String, dynamic>{
      'order': instance.order,
      'text': instance.text,
    };

UserAnswerResponse _$UserAnswerResponseFromJson(Map<String, dynamic> json) =>
    UserAnswerResponse(
      order: (json['order'] as num).toInt(),
      text: json['text'] as String,
      isCorrect: json['is_correct'] as bool,
    );

Map<String, dynamic> _$UserAnswerResponseToJson(UserAnswerResponse instance) =>
    <String, dynamic>{
      'order': instance.order,
      'text': instance.text,
      'is_correct': instance.isCorrect,
    };

PerformanceContext _$PerformanceContextFromJson(Map<String, dynamic> json) =>
    PerformanceContext(
      userStats: UserStats.fromJson(json['user_stats'] as Map<String, dynamic>),
      questionPerformance: json['question_performance'] == null
          ? null
          : QuestionPerformance.fromJson(
              json['question_performance'] as Map<String, dynamic>),
      currentTest: json['current_test'] == null
          ? null
          : CurrentTest.fromJson(json['current_test'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PerformanceContextToJson(PerformanceContext instance) =>
    <String, dynamic>{
      'user_stats': instance.userStats,
      'question_performance': instance.questionPerformance,
      'current_test': instance.currentTest,
    };

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
      totalQuestions: (json['total_questions'] as num).toInt(),
      rightQuestions: (json['right_questions'] as num).toInt(),
      wrongQuestions: (json['wrong_questions'] as num).toInt(),
      accuracy: (json['accuracy'] as num).toDouble(),
    );

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
      'total_questions': instance.totalQuestions,
      'right_questions': instance.rightQuestions,
      'wrong_questions': instance.wrongQuestions,
      'accuracy': instance.accuracy,
    };

QuestionPerformance _$QuestionPerformanceFromJson(Map<String, dynamic> json) =>
    QuestionPerformance(
      timesAnswered: (json['times_answered'] as num).toInt(),
      timesCorrect: (json['times_correct'] as num).toInt(),
      timesWrong: (json['times_wrong'] as num).toInt(),
      lastAnswer: json['last_answer'] == null
          ? null
          : LastAnswer.fromJson(json['last_answer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QuestionPerformanceToJson(
        QuestionPerformance instance) =>
    <String, dynamic>{
      'times_answered': instance.timesAnswered,
      'times_correct': instance.timesCorrect,
      'times_wrong': instance.timesWrong,
      'last_answer': instance.lastAnswer,
    };

LastAnswer _$LastAnswerFromJson(Map<String, dynamic> json) => LastAnswer(
      answerIndex: (json['answer_index'] as num).toInt(),
      wasCorrect: json['was_correct'] as bool,
      testId: (json['test_id'] as num).toInt(),
      answeredAt: DateTime.parse(json['answered_at'] as String),
    );

Map<String, dynamic> _$LastAnswerToJson(LastAnswer instance) =>
    <String, dynamic>{
      'answer_index': instance.answerIndex,
      'was_correct': instance.wasCorrect,
      'test_id': instance.testId,
      'answered_at': instance.answeredAt.toIso8601String(),
    };

CurrentTest _$CurrentTestFromJson(Map<String, dynamic> json) => CurrentTest(
      testId: (json['test_id'] as num).toInt(),
      totalQuestions: (json['total_questions'] as num).toInt(),
      answeredQuestions: (json['answered_questions'] as num).toInt(),
      correctAnswers: (json['correct_answers'] as num).toInt(),
      wrongAnswers: (json['wrong_answers'] as num).toInt(),
      currentScore: (json['current_score'] as num).toDouble(),
      questionAnswered: json['question_answered'] as bool,
      questionCorrect: json['question_correct'] as bool?,
    );

Map<String, dynamic> _$CurrentTestToJson(CurrentTest instance) =>
    <String, dynamic>{
      'test_id': instance.testId,
      'total_questions': instance.totalQuestions,
      'answered_questions': instance.answeredQuestions,
      'correct_answers': instance.correctAnswers,
      'wrong_answers': instance.wrongAnswers,
      'current_score': instance.currentScore,
      'question_answered': instance.questionAnswered,
      'question_correct': instance.questionCorrect,
    };

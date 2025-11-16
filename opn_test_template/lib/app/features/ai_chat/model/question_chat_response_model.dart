import 'package:json_annotation/json_annotation.dart';

part 'question_chat_response_model.g.dart';

/// Respuesta de la Edge Function question-chat
@JsonSerializable()
class QuestionChatResponse {
  @JsonKey(name: 'conversation_id')
  final int conversationId;

  @JsonKey(name: 'message_id')
  final int? messageId;

  final String? response;
  final String? reasoning;
  final List<Citation>? citations;

  @JsonKey(name: 'performance_context')
  final PerformanceContext? performanceContext;

  @JsonKey(name: 'question_context')
  final QuestionContext? questionContext;

  final bool? ready;
  final String? message;

  const QuestionChatResponse({
    required this.conversationId,
    this.messageId,
    this.response,
    this.reasoning,
    this.citations,
    this.performanceContext,
    this.questionContext,
    this.ready,
    this.message,
  });

  factory QuestionChatResponse.fromJson(Map<String, dynamic> json) =>
      _$QuestionChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionChatResponseToJson(this);
}

/// Cita legal de la respuesta RAG
@JsonSerializable()
class Citation {
  @JsonKey(name: 'law_title')
  final String? lawTitle;

  @JsonKey(name: 'item_title')
  final String? itemTitle;

  final String? content;
  final String? url;

  const Citation({
    this.lawTitle,
    this.itemTitle,
    this.content,
    this.url,
  });

  factory Citation.fromJson(Map<String, dynamic> json) =>
      _$CitationFromJson(json);

  Map<String, dynamic> toJson() => _$CitationToJson(this);
}

/// Contexto de la pregunta del test
@JsonSerializable()
class QuestionContext {
  @JsonKey(name: 'question_id')
  final int questionId;

  final String statement;
  final String topic;
  final double? difficulty;
  final List<QuestionOptionResponse> options;

  @JsonKey(name: 'correct_answer')
  final CorrectAnswer correctAnswer;

  @JsonKey(name: 'user_answer')
  final UserAnswerResponse? userAnswer;

  final String? tip;

  const QuestionContext({
    required this.questionId,
    required this.statement,
    required this.topic,
    this.difficulty,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
    this.tip,
  });

  factory QuestionContext.fromJson(Map<String, dynamic> json) =>
      _$QuestionContextFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionContextToJson(this);
}

/// Opción de respuesta en el contexto de la pregunta
@JsonSerializable()
class QuestionOptionResponse {
  final int order;
  final String text;

  @JsonKey(name: 'is_correct')
  final bool isCorrect;

  const QuestionOptionResponse({
    required this.order,
    required this.text,
    required this.isCorrect,
  });

  factory QuestionOptionResponse.fromJson(Map<String, dynamic> json) =>
      _$QuestionOptionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionOptionResponseToJson(this);
}

/// Respuesta correcta
@JsonSerializable()
class CorrectAnswer {
  final int order;
  final String text;

  const CorrectAnswer({
    required this.order,
    required this.text,
  });

  factory CorrectAnswer.fromJson(Map<String, dynamic> json) =>
      _$CorrectAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$CorrectAnswerToJson(this);
}

/// Respuesta del usuario
@JsonSerializable()
class UserAnswerResponse {
  final int order;
  final String text;

  @JsonKey(name: 'is_correct')
  final bool isCorrect;

  const UserAnswerResponse({
    required this.order,
    required this.text,
    required this.isCorrect,
  });

  factory UserAnswerResponse.fromJson(Map<String, dynamic> json) =>
      _$UserAnswerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserAnswerResponseToJson(this);
}

/// Contexto de rendimiento del usuario
@JsonSerializable()
class PerformanceContext {
  @JsonKey(name: 'user_stats')
  final UserStats userStats;

  @JsonKey(name: 'question_performance')
  final QuestionPerformance? questionPerformance;

  @JsonKey(name: 'current_test')
  final CurrentTest? currentTest;

  const PerformanceContext({
    required this.userStats,
    this.questionPerformance,
    this.currentTest,
  });

  factory PerformanceContext.fromJson(Map<String, dynamic> json) =>
      _$PerformanceContextFromJson(json);

  Map<String, dynamic> toJson() => _$PerformanceContextToJson(this);
}

/// Estadísticas generales del usuario
@JsonSerializable()
class UserStats {
  @JsonKey(name: 'total_questions')
  final int totalQuestions;

  @JsonKey(name: 'right_questions')
  final int rightQuestions;

  @JsonKey(name: 'wrong_questions')
  final int wrongQuestions;

  final double accuracy;

  const UserStats({
    required this.totalQuestions,
    required this.rightQuestions,
    required this.wrongQuestions,
    required this.accuracy,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

/// Rendimiento en una pregunta específica
@JsonSerializable()
class QuestionPerformance {
  @JsonKey(name: 'times_answered')
  final int timesAnswered;

  @JsonKey(name: 'times_correct')
  final int timesCorrect;

  @JsonKey(name: 'times_wrong')
  final int timesWrong;

  @JsonKey(name: 'last_answer')
  final LastAnswer? lastAnswer;

  const QuestionPerformance({
    required this.timesAnswered,
    required this.timesCorrect,
    required this.timesWrong,
    this.lastAnswer,
  });

  factory QuestionPerformance.fromJson(Map<String, dynamic> json) =>
      _$QuestionPerformanceFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionPerformanceToJson(this);
}

/// Última respuesta a una pregunta
@JsonSerializable()
class LastAnswer {
  @JsonKey(name: 'answer_index')
  final int answerIndex;

  @JsonKey(name: 'was_correct')
  final bool wasCorrect;

  @JsonKey(name: 'test_id')
  final int testId;

  @JsonKey(name: 'answered_at')
  final DateTime answeredAt;

  const LastAnswer({
    required this.answerIndex,
    required this.wasCorrect,
    required this.testId,
    required this.answeredAt,
  });

  factory LastAnswer.fromJson(Map<String, dynamic> json) =>
      _$LastAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$LastAnswerToJson(this);
}

/// Test actual en curso
@JsonSerializable()
class CurrentTest {
  @JsonKey(name: 'test_id')
  final int testId;

  @JsonKey(name: 'total_questions')
  final int totalQuestions;

  @JsonKey(name: 'answered_questions')
  final int answeredQuestions;

  @JsonKey(name: 'correct_answers')
  final int correctAnswers;

  @JsonKey(name: 'wrong_answers')
  final int wrongAnswers;

  @JsonKey(name: 'current_score')
  final double currentScore;

  @JsonKey(name: 'question_answered')
  final bool questionAnswered;

  @JsonKey(name: 'question_correct')
  final bool? questionCorrect;

  const CurrentTest({
    required this.testId,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.currentScore,
    required this.questionAnswered,
    this.questionCorrect,
  });

  factory CurrentTest.fromJson(Map<String, dynamic> json) =>
      _$CurrentTestFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentTestToJson(this);
}
import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/question_model.dart';
import '../model/question_option_model.dart';
import '../../test_config/model/answer_display_mode.dart';

part 'state.freezed.dart';

enum StatusNames { loading, done, error }

class Status {
  final StatusNames status;
  final String message;

  Status({
    required this.status,
    String? message,
  }) : message = message ?? '';

  // Factory methods
  factory Status.loading([String? message]) =>
      Status(status: StatusNames.loading, message: message);

  factory Status.done([String? message]) =>
      Status(status: StatusNames.done, message: message);

  factory Status.error([String? message]) =>
      Status(status: StatusNames.error, message: message);

  // Getters de conveniencia
  bool get isLoading => status == StatusNames.loading;
  bool get isDone => status == StatusNames.done;
  bool get isError => status == StatusNames.error;

  // Necesario para Freezed
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Status &&
              runtimeType == other.runtimeType &&
              status == other.status &&
              message == other.message;

  @override
  int get hashCode => status.hashCode ^ message.hashCode;

  @override
  String toString() => 'Status(status: $status, message: $message)';
}

@freezed
class QuestionState with _$QuestionState {
  const factory QuestionState({
    @Default([]) List<Question> questions,
    @Default([]) List<QuestionOption> questionOptions,
    int? selectedTopicId,
    int? selectedQuestionId,
    @Default(AnswerDisplayMode.atEnd) AnswerDisplayMode answerDisplayMode,
    required Status fetchQuestionsStatus,
    required Status createQuestionStatus,
    required Status updateQuestionStatus,
    required Status deleteQuestionStatus,
    required Status fetchQuestionOptionsStatus,
    required Status createQuestionOptionStatus,
    required Status updateQuestionOptionStatus,
    required Status deleteQuestionOptionStatus,
    String? error,
  }) = _QuestionState;

  const QuestionState._();

  // Helper para crear estado inicial
  factory QuestionState.initial() => QuestionState(
    fetchQuestionsStatus: Status.done(),
    createQuestionStatus: Status.done(),
    updateQuestionStatus: Status.done(),
    deleteQuestionStatus: Status.done(),
    fetchQuestionOptionsStatus: Status.done(),
    createQuestionOptionStatus: Status.done(),
    updateQuestionOptionStatus: Status.done(),
    deleteQuestionOptionStatus: Status.done(),
    error: null,
  );
}

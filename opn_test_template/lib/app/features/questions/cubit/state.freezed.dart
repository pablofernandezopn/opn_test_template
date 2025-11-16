// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$QuestionState {
  List<Question> get questions => throw _privateConstructorUsedError;
  List<QuestionOption> get questionOptions =>
      throw _privateConstructorUsedError;
  int? get selectedTopicId => throw _privateConstructorUsedError;
  int? get selectedQuestionId => throw _privateConstructorUsedError;
  AnswerDisplayMode get answerDisplayMode => throw _privateConstructorUsedError;
  Status get fetchQuestionsStatus => throw _privateConstructorUsedError;
  Status get createQuestionStatus => throw _privateConstructorUsedError;
  Status get updateQuestionStatus => throw _privateConstructorUsedError;
  Status get deleteQuestionStatus => throw _privateConstructorUsedError;
  Status get fetchQuestionOptionsStatus => throw _privateConstructorUsedError;
  Status get createQuestionOptionStatus => throw _privateConstructorUsedError;
  Status get updateQuestionOptionStatus => throw _privateConstructorUsedError;
  Status get deleteQuestionOptionStatus => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of QuestionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuestionStateCopyWith<QuestionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionStateCopyWith<$Res> {
  factory $QuestionStateCopyWith(
          QuestionState value, $Res Function(QuestionState) then) =
      _$QuestionStateCopyWithImpl<$Res, QuestionState>;
  @useResult
  $Res call(
      {List<Question> questions,
      List<QuestionOption> questionOptions,
      int? selectedTopicId,
      int? selectedQuestionId,
      AnswerDisplayMode answerDisplayMode,
      Status fetchQuestionsStatus,
      Status createQuestionStatus,
      Status updateQuestionStatus,
      Status deleteQuestionStatus,
      Status fetchQuestionOptionsStatus,
      Status createQuestionOptionStatus,
      Status updateQuestionOptionStatus,
      Status deleteQuestionOptionStatus,
      String? error});
}

/// @nodoc
class _$QuestionStateCopyWithImpl<$Res, $Val extends QuestionState>
    implements $QuestionStateCopyWith<$Res> {
  _$QuestionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuestionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questions = null,
    Object? questionOptions = null,
    Object? selectedTopicId = freezed,
    Object? selectedQuestionId = freezed,
    Object? answerDisplayMode = null,
    Object? fetchQuestionsStatus = null,
    Object? createQuestionStatus = null,
    Object? updateQuestionStatus = null,
    Object? deleteQuestionStatus = null,
    Object? fetchQuestionOptionsStatus = null,
    Object? createQuestionOptionStatus = null,
    Object? updateQuestionOptionStatus = null,
    Object? deleteQuestionOptionStatus = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      questions: null == questions
          ? _value.questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<Question>,
      questionOptions: null == questionOptions
          ? _value.questionOptions
          : questionOptions // ignore: cast_nullable_to_non_nullable
              as List<QuestionOption>,
      selectedTopicId: freezed == selectedTopicId
          ? _value.selectedTopicId
          : selectedTopicId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedQuestionId: freezed == selectedQuestionId
          ? _value.selectedQuestionId
          : selectedQuestionId // ignore: cast_nullable_to_non_nullable
              as int?,
      answerDisplayMode: null == answerDisplayMode
          ? _value.answerDisplayMode
          : answerDisplayMode // ignore: cast_nullable_to_non_nullable
              as AnswerDisplayMode,
      fetchQuestionsStatus: null == fetchQuestionsStatus
          ? _value.fetchQuestionsStatus
          : fetchQuestionsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createQuestionStatus: null == createQuestionStatus
          ? _value.createQuestionStatus
          : createQuestionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateQuestionStatus: null == updateQuestionStatus
          ? _value.updateQuestionStatus
          : updateQuestionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteQuestionStatus: null == deleteQuestionStatus
          ? _value.deleteQuestionStatus
          : deleteQuestionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchQuestionOptionsStatus: null == fetchQuestionOptionsStatus
          ? _value.fetchQuestionOptionsStatus
          : fetchQuestionOptionsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createQuestionOptionStatus: null == createQuestionOptionStatus
          ? _value.createQuestionOptionStatus
          : createQuestionOptionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateQuestionOptionStatus: null == updateQuestionOptionStatus
          ? _value.updateQuestionOptionStatus
          : updateQuestionOptionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteQuestionOptionStatus: null == deleteQuestionOptionStatus
          ? _value.deleteQuestionOptionStatus
          : deleteQuestionOptionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QuestionStateImplCopyWith<$Res>
    implements $QuestionStateCopyWith<$Res> {
  factory _$$QuestionStateImplCopyWith(
          _$QuestionStateImpl value, $Res Function(_$QuestionStateImpl) then) =
      __$$QuestionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Question> questions,
      List<QuestionOption> questionOptions,
      int? selectedTopicId,
      int? selectedQuestionId,
      AnswerDisplayMode answerDisplayMode,
      Status fetchQuestionsStatus,
      Status createQuestionStatus,
      Status updateQuestionStatus,
      Status deleteQuestionStatus,
      Status fetchQuestionOptionsStatus,
      Status createQuestionOptionStatus,
      Status updateQuestionOptionStatus,
      Status deleteQuestionOptionStatus,
      String? error});
}

/// @nodoc
class __$$QuestionStateImplCopyWithImpl<$Res>
    extends _$QuestionStateCopyWithImpl<$Res, _$QuestionStateImpl>
    implements _$$QuestionStateImplCopyWith<$Res> {
  __$$QuestionStateImplCopyWithImpl(
      _$QuestionStateImpl _value, $Res Function(_$QuestionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of QuestionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? questions = null,
    Object? questionOptions = null,
    Object? selectedTopicId = freezed,
    Object? selectedQuestionId = freezed,
    Object? answerDisplayMode = null,
    Object? fetchQuestionsStatus = null,
    Object? createQuestionStatus = null,
    Object? updateQuestionStatus = null,
    Object? deleteQuestionStatus = null,
    Object? fetchQuestionOptionsStatus = null,
    Object? createQuestionOptionStatus = null,
    Object? updateQuestionOptionStatus = null,
    Object? deleteQuestionOptionStatus = null,
    Object? error = freezed,
  }) {
    return _then(_$QuestionStateImpl(
      questions: null == questions
          ? _value._questions
          : questions // ignore: cast_nullable_to_non_nullable
              as List<Question>,
      questionOptions: null == questionOptions
          ? _value._questionOptions
          : questionOptions // ignore: cast_nullable_to_non_nullable
              as List<QuestionOption>,
      selectedTopicId: freezed == selectedTopicId
          ? _value.selectedTopicId
          : selectedTopicId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedQuestionId: freezed == selectedQuestionId
          ? _value.selectedQuestionId
          : selectedQuestionId // ignore: cast_nullable_to_non_nullable
              as int?,
      answerDisplayMode: null == answerDisplayMode
          ? _value.answerDisplayMode
          : answerDisplayMode // ignore: cast_nullable_to_non_nullable
              as AnswerDisplayMode,
      fetchQuestionsStatus: null == fetchQuestionsStatus
          ? _value.fetchQuestionsStatus
          : fetchQuestionsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createQuestionStatus: null == createQuestionStatus
          ? _value.createQuestionStatus
          : createQuestionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateQuestionStatus: null == updateQuestionStatus
          ? _value.updateQuestionStatus
          : updateQuestionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteQuestionStatus: null == deleteQuestionStatus
          ? _value.deleteQuestionStatus
          : deleteQuestionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchQuestionOptionsStatus: null == fetchQuestionOptionsStatus
          ? _value.fetchQuestionOptionsStatus
          : fetchQuestionOptionsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createQuestionOptionStatus: null == createQuestionOptionStatus
          ? _value.createQuestionOptionStatus
          : createQuestionOptionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateQuestionOptionStatus: null == updateQuestionOptionStatus
          ? _value.updateQuestionOptionStatus
          : updateQuestionOptionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteQuestionOptionStatus: null == deleteQuestionOptionStatus
          ? _value.deleteQuestionOptionStatus
          : deleteQuestionOptionStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$QuestionStateImpl extends _QuestionState {
  const _$QuestionStateImpl(
      {final List<Question> questions = const [],
      final List<QuestionOption> questionOptions = const [],
      this.selectedTopicId,
      this.selectedQuestionId,
      this.answerDisplayMode = AnswerDisplayMode.atEnd,
      required this.fetchQuestionsStatus,
      required this.createQuestionStatus,
      required this.updateQuestionStatus,
      required this.deleteQuestionStatus,
      required this.fetchQuestionOptionsStatus,
      required this.createQuestionOptionStatus,
      required this.updateQuestionOptionStatus,
      required this.deleteQuestionOptionStatus,
      this.error})
      : _questions = questions,
        _questionOptions = questionOptions,
        super._();

  final List<Question> _questions;
  @override
  @JsonKey()
  List<Question> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  final List<QuestionOption> _questionOptions;
  @override
  @JsonKey()
  List<QuestionOption> get questionOptions {
    if (_questionOptions is EqualUnmodifiableListView) return _questionOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questionOptions);
  }

  @override
  final int? selectedTopicId;
  @override
  final int? selectedQuestionId;
  @override
  @JsonKey()
  final AnswerDisplayMode answerDisplayMode;
  @override
  final Status fetchQuestionsStatus;
  @override
  final Status createQuestionStatus;
  @override
  final Status updateQuestionStatus;
  @override
  final Status deleteQuestionStatus;
  @override
  final Status fetchQuestionOptionsStatus;
  @override
  final Status createQuestionOptionStatus;
  @override
  final Status updateQuestionOptionStatus;
  @override
  final Status deleteQuestionOptionStatus;
  @override
  final String? error;

  @override
  String toString() {
    return 'QuestionState(questions: $questions, questionOptions: $questionOptions, selectedTopicId: $selectedTopicId, selectedQuestionId: $selectedQuestionId, answerDisplayMode: $answerDisplayMode, fetchQuestionsStatus: $fetchQuestionsStatus, createQuestionStatus: $createQuestionStatus, updateQuestionStatus: $updateQuestionStatus, deleteQuestionStatus: $deleteQuestionStatus, fetchQuestionOptionsStatus: $fetchQuestionOptionsStatus, createQuestionOptionStatus: $createQuestionOptionStatus, updateQuestionOptionStatus: $updateQuestionOptionStatus, deleteQuestionOptionStatus: $deleteQuestionOptionStatus, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuestionStateImpl &&
            const DeepCollectionEquality()
                .equals(other._questions, _questions) &&
            const DeepCollectionEquality()
                .equals(other._questionOptions, _questionOptions) &&
            (identical(other.selectedTopicId, selectedTopicId) ||
                other.selectedTopicId == selectedTopicId) &&
            (identical(other.selectedQuestionId, selectedQuestionId) ||
                other.selectedQuestionId == selectedQuestionId) &&
            (identical(other.answerDisplayMode, answerDisplayMode) ||
                other.answerDisplayMode == answerDisplayMode) &&
            (identical(other.fetchQuestionsStatus, fetchQuestionsStatus) ||
                other.fetchQuestionsStatus == fetchQuestionsStatus) &&
            (identical(other.createQuestionStatus, createQuestionStatus) ||
                other.createQuestionStatus == createQuestionStatus) &&
            (identical(other.updateQuestionStatus, updateQuestionStatus) ||
                other.updateQuestionStatus == updateQuestionStatus) &&
            (identical(other.deleteQuestionStatus, deleteQuestionStatus) ||
                other.deleteQuestionStatus == deleteQuestionStatus) &&
            (identical(other.fetchQuestionOptionsStatus,
                    fetchQuestionOptionsStatus) ||
                other.fetchQuestionOptionsStatus ==
                    fetchQuestionOptionsStatus) &&
            (identical(other.createQuestionOptionStatus,
                    createQuestionOptionStatus) ||
                other.createQuestionOptionStatus ==
                    createQuestionOptionStatus) &&
            (identical(other.updateQuestionOptionStatus,
                    updateQuestionOptionStatus) ||
                other.updateQuestionOptionStatus ==
                    updateQuestionOptionStatus) &&
            (identical(other.deleteQuestionOptionStatus,
                    deleteQuestionOptionStatus) ||
                other.deleteQuestionOptionStatus ==
                    deleteQuestionOptionStatus) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_questions),
      const DeepCollectionEquality().hash(_questionOptions),
      selectedTopicId,
      selectedQuestionId,
      answerDisplayMode,
      fetchQuestionsStatus,
      createQuestionStatus,
      updateQuestionStatus,
      deleteQuestionStatus,
      fetchQuestionOptionsStatus,
      createQuestionOptionStatus,
      updateQuestionOptionStatus,
      deleteQuestionOptionStatus,
      error);

  /// Create a copy of QuestionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuestionStateImplCopyWith<_$QuestionStateImpl> get copyWith =>
      __$$QuestionStateImplCopyWithImpl<_$QuestionStateImpl>(this, _$identity);
}

abstract class _QuestionState extends QuestionState {
  const factory _QuestionState(
      {final List<Question> questions,
      final List<QuestionOption> questionOptions,
      final int? selectedTopicId,
      final int? selectedQuestionId,
      final AnswerDisplayMode answerDisplayMode,
      required final Status fetchQuestionsStatus,
      required final Status createQuestionStatus,
      required final Status updateQuestionStatus,
      required final Status deleteQuestionStatus,
      required final Status fetchQuestionOptionsStatus,
      required final Status createQuestionOptionStatus,
      required final Status updateQuestionOptionStatus,
      required final Status deleteQuestionOptionStatus,
      final String? error}) = _$QuestionStateImpl;
  const _QuestionState._() : super._();

  @override
  List<Question> get questions;
  @override
  List<QuestionOption> get questionOptions;
  @override
  int? get selectedTopicId;
  @override
  int? get selectedQuestionId;
  @override
  AnswerDisplayMode get answerDisplayMode;
  @override
  Status get fetchQuestionsStatus;
  @override
  Status get createQuestionStatus;
  @override
  Status get updateQuestionStatus;
  @override
  Status get deleteQuestionStatus;
  @override
  Status get fetchQuestionOptionsStatus;
  @override
  Status get createQuestionOptionStatus;
  @override
  Status get updateQuestionOptionStatus;
  @override
  Status get deleteQuestionOptionStatus;
  @override
  String? get error;

  /// Create a copy of QuestionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuestionStateImplCopyWith<_$QuestionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

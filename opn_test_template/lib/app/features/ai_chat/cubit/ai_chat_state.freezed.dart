// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AiChatState {
  int? get conversationId => throw _privateConstructorUsedError;
  List<ChatMessage> get messages => throw _privateConstructorUsedError;
  List<Citation> get lastCitations => throw _privateConstructorUsedError;
  PerformanceContext? get performanceContext =>
      throw _privateConstructorUsedError;
  QuestionContext? get questionContext => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  bool get ragModeEnabled => throw _privateConstructorUsedError;

  /// Create a copy of AiChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiChatStateCopyWith<AiChatState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiChatStateCopyWith<$Res> {
  factory $AiChatStateCopyWith(
          AiChatState value, $Res Function(AiChatState) then) =
      _$AiChatStateCopyWithImpl<$Res, AiChatState>;
  @useResult
  $Res call(
      {int? conversationId,
      List<ChatMessage> messages,
      List<Citation> lastCitations,
      PerformanceContext? performanceContext,
      QuestionContext? questionContext,
      bool isLoading,
      bool hasError,
      String? errorMessage,
      bool ragModeEnabled});
}

/// @nodoc
class _$AiChatStateCopyWithImpl<$Res, $Val extends AiChatState>
    implements $AiChatStateCopyWith<$Res> {
  _$AiChatStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversationId = freezed,
    Object? messages = null,
    Object? lastCitations = null,
    Object? performanceContext = freezed,
    Object? questionContext = freezed,
    Object? isLoading = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? ragModeEnabled = null,
  }) {
    return _then(_value.copyWith(
      conversationId: freezed == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as int?,
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ChatMessage>,
      lastCitations: null == lastCitations
          ? _value.lastCitations
          : lastCitations // ignore: cast_nullable_to_non_nullable
              as List<Citation>,
      performanceContext: freezed == performanceContext
          ? _value.performanceContext
          : performanceContext // ignore: cast_nullable_to_non_nullable
              as PerformanceContext?,
      questionContext: freezed == questionContext
          ? _value.questionContext
          : questionContext // ignore: cast_nullable_to_non_nullable
              as QuestionContext?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      ragModeEnabled: null == ragModeEnabled
          ? _value.ragModeEnabled
          : ragModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiChatStateImplCopyWith<$Res>
    implements $AiChatStateCopyWith<$Res> {
  factory _$$AiChatStateImplCopyWith(
          _$AiChatStateImpl value, $Res Function(_$AiChatStateImpl) then) =
      __$$AiChatStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? conversationId,
      List<ChatMessage> messages,
      List<Citation> lastCitations,
      PerformanceContext? performanceContext,
      QuestionContext? questionContext,
      bool isLoading,
      bool hasError,
      String? errorMessage,
      bool ragModeEnabled});
}

/// @nodoc
class __$$AiChatStateImplCopyWithImpl<$Res>
    extends _$AiChatStateCopyWithImpl<$Res, _$AiChatStateImpl>
    implements _$$AiChatStateImplCopyWith<$Res> {
  __$$AiChatStateImplCopyWithImpl(
      _$AiChatStateImpl _value, $Res Function(_$AiChatStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversationId = freezed,
    Object? messages = null,
    Object? lastCitations = null,
    Object? performanceContext = freezed,
    Object? questionContext = freezed,
    Object? isLoading = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? ragModeEnabled = null,
  }) {
    return _then(_$AiChatStateImpl(
      conversationId: freezed == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as int?,
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ChatMessage>,
      lastCitations: null == lastCitations
          ? _value._lastCitations
          : lastCitations // ignore: cast_nullable_to_non_nullable
              as List<Citation>,
      performanceContext: freezed == performanceContext
          ? _value.performanceContext
          : performanceContext // ignore: cast_nullable_to_non_nullable
              as PerformanceContext?,
      questionContext: freezed == questionContext
          ? _value.questionContext
          : questionContext // ignore: cast_nullable_to_non_nullable
              as QuestionContext?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      ragModeEnabled: null == ragModeEnabled
          ? _value.ragModeEnabled
          : ragModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AiChatStateImpl implements _AiChatState {
  const _$AiChatStateImpl(
      {this.conversationId,
      final List<ChatMessage> messages = const [],
      final List<Citation> lastCitations = const [],
      this.performanceContext,
      this.questionContext,
      this.isLoading = false,
      this.hasError = false,
      this.errorMessage,
      this.ragModeEnabled = false})
      : _messages = messages,
        _lastCitations = lastCitations;

  @override
  final int? conversationId;
  final List<ChatMessage> _messages;
  @override
  @JsonKey()
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  final List<Citation> _lastCitations;
  @override
  @JsonKey()
  List<Citation> get lastCitations {
    if (_lastCitations is EqualUnmodifiableListView) return _lastCitations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lastCitations);
  }

  @override
  final PerformanceContext? performanceContext;
  @override
  final QuestionContext? questionContext;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasError;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final bool ragModeEnabled;

  @override
  String toString() {
    return 'AiChatState(conversationId: $conversationId, messages: $messages, lastCitations: $lastCitations, performanceContext: $performanceContext, questionContext: $questionContext, isLoading: $isLoading, hasError: $hasError, errorMessage: $errorMessage, ragModeEnabled: $ragModeEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiChatStateImpl &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            const DeepCollectionEquality()
                .equals(other._lastCitations, _lastCitations) &&
            (identical(other.performanceContext, performanceContext) ||
                other.performanceContext == performanceContext) &&
            (identical(other.questionContext, questionContext) ||
                other.questionContext == questionContext) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.ragModeEnabled, ragModeEnabled) ||
                other.ragModeEnabled == ragModeEnabled));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      conversationId,
      const DeepCollectionEquality().hash(_messages),
      const DeepCollectionEquality().hash(_lastCitations),
      performanceContext,
      questionContext,
      isLoading,
      hasError,
      errorMessage,
      ragModeEnabled);

  /// Create a copy of AiChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiChatStateImplCopyWith<_$AiChatStateImpl> get copyWith =>
      __$$AiChatStateImplCopyWithImpl<_$AiChatStateImpl>(this, _$identity);
}

abstract class _AiChatState implements AiChatState {
  const factory _AiChatState(
      {final int? conversationId,
      final List<ChatMessage> messages,
      final List<Citation> lastCitations,
      final PerformanceContext? performanceContext,
      final QuestionContext? questionContext,
      final bool isLoading,
      final bool hasError,
      final String? errorMessage,
      final bool ragModeEnabled}) = _$AiChatStateImpl;

  @override
  int? get conversationId;
  @override
  List<ChatMessage> get messages;
  @override
  List<Citation> get lastCitations;
  @override
  PerformanceContext? get performanceContext;
  @override
  QuestionContext? get questionContext;
  @override
  bool get isLoading;
  @override
  bool get hasError;
  @override
  String? get errorMessage;
  @override
  bool get ragModeEnabled;

  /// Create a copy of AiChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiChatStateImplCopyWith<_$AiChatStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

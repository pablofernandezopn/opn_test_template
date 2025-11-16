// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_user_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatUserPreferences _$ChatUserPreferencesFromJson(Map<String, dynamic> json) {
  return _ChatUserPreferences.fromJson(json);
}

/// @nodoc
mixin _$ChatUserPreferences {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  int get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'ai_model_id')
  int? get aiModelId => throw _privateConstructorUsedError;
  @JsonKey(name: 'response_length')
  ResponseLength get responseLength => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_tokens')
  int? get maxTokens => throw _privateConstructorUsedError;
  @JsonKey(name: 'custom_system_prompt')
  String? get customSystemPrompt => throw _privateConstructorUsedError;
  ConversationTone get tone => throw _privateConstructorUsedError;
  @JsonKey(name: 'enable_emojis')
  bool get enableEmojis => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChatUserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatUserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatUserPreferencesCopyWith<ChatUserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatUserPreferencesCopyWith<$Res> {
  factory $ChatUserPreferencesCopyWith(
          ChatUserPreferences value, $Res Function(ChatUserPreferences) then) =
      _$ChatUserPreferencesCopyWithImpl<$Res, ChatUserPreferences>;
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'ai_model_id') int? aiModelId,
      @JsonKey(name: 'response_length') ResponseLength responseLength,
      @JsonKey(name: 'max_tokens') int? maxTokens,
      @JsonKey(name: 'custom_system_prompt') String? customSystemPrompt,
      ConversationTone tone,
      @JsonKey(name: 'enable_emojis') bool enableEmojis,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$ChatUserPreferencesCopyWithImpl<$Res, $Val extends ChatUserPreferences>
    implements $ChatUserPreferencesCopyWith<$Res> {
  _$ChatUserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatUserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? aiModelId = freezed,
    Object? responseLength = null,
    Object? maxTokens = freezed,
    Object? customSystemPrompt = freezed,
    Object? tone = null,
    Object? enableEmojis = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      aiModelId: freezed == aiModelId
          ? _value.aiModelId
          : aiModelId // ignore: cast_nullable_to_non_nullable
              as int?,
      responseLength: null == responseLength
          ? _value.responseLength
          : responseLength // ignore: cast_nullable_to_non_nullable
              as ResponseLength,
      maxTokens: freezed == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      customSystemPrompt: freezed == customSystemPrompt
          ? _value.customSystemPrompt
          : customSystemPrompt // ignore: cast_nullable_to_non_nullable
              as String?,
      tone: null == tone
          ? _value.tone
          : tone // ignore: cast_nullable_to_non_nullable
              as ConversationTone,
      enableEmojis: null == enableEmojis
          ? _value.enableEmojis
          : enableEmojis // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatUserPreferencesImplCopyWith<$Res>
    implements $ChatUserPreferencesCopyWith<$Res> {
  factory _$$ChatUserPreferencesImplCopyWith(_$ChatUserPreferencesImpl value,
          $Res Function(_$ChatUserPreferencesImpl) then) =
      __$$ChatUserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      @JsonKey(name: 'user_id') int userId,
      @JsonKey(name: 'ai_model_id') int? aiModelId,
      @JsonKey(name: 'response_length') ResponseLength responseLength,
      @JsonKey(name: 'max_tokens') int? maxTokens,
      @JsonKey(name: 'custom_system_prompt') String? customSystemPrompt,
      ConversationTone tone,
      @JsonKey(name: 'enable_emojis') bool enableEmojis,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$ChatUserPreferencesImplCopyWithImpl<$Res>
    extends _$ChatUserPreferencesCopyWithImpl<$Res, _$ChatUserPreferencesImpl>
    implements _$$ChatUserPreferencesImplCopyWith<$Res> {
  __$$ChatUserPreferencesImplCopyWithImpl(_$ChatUserPreferencesImpl _value,
      $Res Function(_$ChatUserPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatUserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? aiModelId = freezed,
    Object? responseLength = null,
    Object? maxTokens = freezed,
    Object? customSystemPrompt = freezed,
    Object? tone = null,
    Object? enableEmojis = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ChatUserPreferencesImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      aiModelId: freezed == aiModelId
          ? _value.aiModelId
          : aiModelId // ignore: cast_nullable_to_non_nullable
              as int?,
      responseLength: null == responseLength
          ? _value.responseLength
          : responseLength // ignore: cast_nullable_to_non_nullable
              as ResponseLength,
      maxTokens: freezed == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      customSystemPrompt: freezed == customSystemPrompt
          ? _value.customSystemPrompt
          : customSystemPrompt // ignore: cast_nullable_to_non_nullable
              as String?,
      tone: null == tone
          ? _value.tone
          : tone // ignore: cast_nullable_to_non_nullable
              as ConversationTone,
      enableEmojis: null == enableEmojis
          ? _value.enableEmojis
          : enableEmojis // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatUserPreferencesImpl implements _ChatUserPreferences {
  const _$ChatUserPreferencesImpl(
      {this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'ai_model_id') this.aiModelId,
      @JsonKey(name: 'response_length')
      this.responseLength = ResponseLength.normal,
      @JsonKey(name: 'max_tokens') this.maxTokens,
      @JsonKey(name: 'custom_system_prompt') this.customSystemPrompt,
      this.tone = ConversationTone.friendly,
      @JsonKey(name: 'enable_emojis') this.enableEmojis = true,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$ChatUserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatUserPreferencesImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'user_id')
  final int userId;
  @override
  @JsonKey(name: 'ai_model_id')
  final int? aiModelId;
  @override
  @JsonKey(name: 'response_length')
  final ResponseLength responseLength;
  @override
  @JsonKey(name: 'max_tokens')
  final int? maxTokens;
  @override
  @JsonKey(name: 'custom_system_prompt')
  final String? customSystemPrompt;
  @override
  @JsonKey()
  final ConversationTone tone;
  @override
  @JsonKey(name: 'enable_emojis')
  final bool enableEmojis;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ChatUserPreferences(id: $id, userId: $userId, aiModelId: $aiModelId, responseLength: $responseLength, maxTokens: $maxTokens, customSystemPrompt: $customSystemPrompt, tone: $tone, enableEmojis: $enableEmojis, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatUserPreferencesImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.aiModelId, aiModelId) ||
                other.aiModelId == aiModelId) &&
            (identical(other.responseLength, responseLength) ||
                other.responseLength == responseLength) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.customSystemPrompt, customSystemPrompt) ||
                other.customSystemPrompt == customSystemPrompt) &&
            (identical(other.tone, tone) || other.tone == tone) &&
            (identical(other.enableEmojis, enableEmojis) ||
                other.enableEmojis == enableEmojis) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      aiModelId,
      responseLength,
      maxTokens,
      customSystemPrompt,
      tone,
      enableEmojis,
      createdAt,
      updatedAt);

  /// Create a copy of ChatUserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatUserPreferencesImplCopyWith<_$ChatUserPreferencesImpl> get copyWith =>
      __$$ChatUserPreferencesImplCopyWithImpl<_$ChatUserPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatUserPreferencesImplToJson(
      this,
    );
  }
}

abstract class _ChatUserPreferences implements ChatUserPreferences {
  const factory _ChatUserPreferences(
      {final int? id,
      @JsonKey(name: 'user_id') required final int userId,
      @JsonKey(name: 'ai_model_id') final int? aiModelId,
      @JsonKey(name: 'response_length') final ResponseLength responseLength,
      @JsonKey(name: 'max_tokens') final int? maxTokens,
      @JsonKey(name: 'custom_system_prompt') final String? customSystemPrompt,
      final ConversationTone tone,
      @JsonKey(name: 'enable_emojis') final bool enableEmojis,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at')
      final DateTime? updatedAt}) = _$ChatUserPreferencesImpl;

  factory _ChatUserPreferences.fromJson(Map<String, dynamic> json) =
      _$ChatUserPreferencesImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'user_id')
  int get userId;
  @override
  @JsonKey(name: 'ai_model_id')
  int? get aiModelId;
  @override
  @JsonKey(name: 'response_length')
  ResponseLength get responseLength;
  @override
  @JsonKey(name: 'max_tokens')
  int? get maxTokens;
  @override
  @JsonKey(name: 'custom_system_prompt')
  String? get customSystemPrompt;
  @override
  ConversationTone get tone;
  @override
  @JsonKey(name: 'enable_emojis')
  bool get enableEmojis;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of ChatUserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatUserPreferencesImplCopyWith<_$ChatUserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

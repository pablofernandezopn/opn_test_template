// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AiModel _$AiModelFromJson(Map<String, dynamic> json) {
  return _AiModel.fromJson(json);
}

/// @nodoc
mixin _$AiModel {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'model_key')
  String get modelKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  @JsonKey(name: 'speed_rating')
  int? get speedRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'thinking_capability')
  int? get thinkingCapability => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_tokens')
  int? get maxTokens => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this AiModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiModelCopyWith<AiModel> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiModelCopyWith<$Res> {
  factory $AiModelCopyWith(AiModel value, $Res Function(AiModel) then) =
      _$AiModelCopyWithImpl<$Res, AiModel>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'model_key') String modelKey,
      @JsonKey(name: 'display_name') String displayName,
      String? description,
      String provider,
      @JsonKey(name: 'speed_rating') int? speedRating,
      @JsonKey(name: 'thinking_capability') int? thinkingCapability,
      @JsonKey(name: 'max_tokens') int? maxTokens,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$AiModelCopyWithImpl<$Res, $Val extends AiModel>
    implements $AiModelCopyWith<$Res> {
  _$AiModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? modelKey = null,
    Object? displayName = null,
    Object? description = freezed,
    Object? provider = null,
    Object? speedRating = freezed,
    Object? thinkingCapability = freezed,
    Object? maxTokens = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      modelKey: null == modelKey
          ? _value.modelKey
          : modelKey // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      speedRating: freezed == speedRating
          ? _value.speedRating
          : speedRating // ignore: cast_nullable_to_non_nullable
              as int?,
      thinkingCapability: freezed == thinkingCapability
          ? _value.thinkingCapability
          : thinkingCapability // ignore: cast_nullable_to_non_nullable
              as int?,
      maxTokens: freezed == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
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
abstract class _$$AiModelImplCopyWith<$Res> implements $AiModelCopyWith<$Res> {
  factory _$$AiModelImplCopyWith(
          _$AiModelImpl value, $Res Function(_$AiModelImpl) then) =
      __$$AiModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'model_key') String modelKey,
      @JsonKey(name: 'display_name') String displayName,
      String? description,
      String provider,
      @JsonKey(name: 'speed_rating') int? speedRating,
      @JsonKey(name: 'thinking_capability') int? thinkingCapability,
      @JsonKey(name: 'max_tokens') int? maxTokens,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$AiModelImplCopyWithImpl<$Res>
    extends _$AiModelCopyWithImpl<$Res, _$AiModelImpl>
    implements _$$AiModelImplCopyWith<$Res> {
  __$$AiModelImplCopyWithImpl(
      _$AiModelImpl _value, $Res Function(_$AiModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AiModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? modelKey = null,
    Object? displayName = null,
    Object? description = freezed,
    Object? provider = null,
    Object? speedRating = freezed,
    Object? thinkingCapability = freezed,
    Object? maxTokens = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AiModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      modelKey: null == modelKey
          ? _value.modelKey
          : modelKey // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      provider: null == provider
          ? _value.provider
          : provider // ignore: cast_nullable_to_non_nullable
              as String,
      speedRating: freezed == speedRating
          ? _value.speedRating
          : speedRating // ignore: cast_nullable_to_non_nullable
              as int?,
      thinkingCapability: freezed == thinkingCapability
          ? _value.thinkingCapability
          : thinkingCapability // ignore: cast_nullable_to_non_nullable
              as int?,
      maxTokens: freezed == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
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
class _$AiModelImpl implements _AiModel {
  const _$AiModelImpl(
      {required this.id,
      @JsonKey(name: 'model_key') required this.modelKey,
      @JsonKey(name: 'display_name') required this.displayName,
      this.description,
      required this.provider,
      @JsonKey(name: 'speed_rating') this.speedRating,
      @JsonKey(name: 'thinking_capability') this.thinkingCapability,
      @JsonKey(name: 'max_tokens') this.maxTokens,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$AiModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiModelImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'model_key')
  final String modelKey;
  @override
  @JsonKey(name: 'display_name')
  final String displayName;
  @override
  final String? description;
  @override
  final String provider;
  @override
  @JsonKey(name: 'speed_rating')
  final int? speedRating;
  @override
  @JsonKey(name: 'thinking_capability')
  final int? thinkingCapability;
  @override
  @JsonKey(name: 'max_tokens')
  final int? maxTokens;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'AiModel(id: $id, modelKey: $modelKey, displayName: $displayName, description: $description, provider: $provider, speedRating: $speedRating, thinkingCapability: $thinkingCapability, maxTokens: $maxTokens, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.modelKey, modelKey) ||
                other.modelKey == modelKey) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.speedRating, speedRating) ||
                other.speedRating == speedRating) &&
            (identical(other.thinkingCapability, thinkingCapability) ||
                other.thinkingCapability == thinkingCapability) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
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
      modelKey,
      displayName,
      description,
      provider,
      speedRating,
      thinkingCapability,
      maxTokens,
      isActive,
      createdAt,
      updatedAt);

  /// Create a copy of AiModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiModelImplCopyWith<_$AiModelImpl> get copyWith =>
      __$$AiModelImplCopyWithImpl<_$AiModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiModelImplToJson(
      this,
    );
  }
}

abstract class _AiModel implements AiModel {
  const factory _AiModel(
      {required final int id,
      @JsonKey(name: 'model_key') required final String modelKey,
      @JsonKey(name: 'display_name') required final String displayName,
      final String? description,
      required final String provider,
      @JsonKey(name: 'speed_rating') final int? speedRating,
      @JsonKey(name: 'thinking_capability') final int? thinkingCapability,
      @JsonKey(name: 'max_tokens') final int? maxTokens,
      @JsonKey(name: 'is_active') final bool isActive,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$AiModelImpl;

  factory _AiModel.fromJson(Map<String, dynamic> json) = _$AiModelImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'model_key')
  String get modelKey;
  @override
  @JsonKey(name: 'display_name')
  String get displayName;
  @override
  String? get description;
  @override
  String get provider;
  @override
  @JsonKey(name: 'speed_rating')
  int? get speedRating;
  @override
  @JsonKey(name: 'thinking_capability')
  int? get thinkingCapability;
  @override
  @JsonKey(name: 'max_tokens')
  int? get maxTokens;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of AiModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiModelImplCopyWith<_$AiModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

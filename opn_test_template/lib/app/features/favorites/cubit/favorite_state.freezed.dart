// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$FavoriteState {
  FavoriteStatus get status => throw _privateConstructorUsedError;
  List<FavoriteQuestion> get favorites => throw _privateConstructorUsedError;
  Set<int> get favoriteQuestionIds => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of FavoriteState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FavoriteStateCopyWith<FavoriteState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FavoriteStateCopyWith<$Res> {
  factory $FavoriteStateCopyWith(
          FavoriteState value, $Res Function(FavoriteState) then) =
      _$FavoriteStateCopyWithImpl<$Res, FavoriteState>;
  @useResult
  $Res call(
      {FavoriteStatus status,
      List<FavoriteQuestion> favorites,
      Set<int> favoriteQuestionIds,
      String errorMessage});
}

/// @nodoc
class _$FavoriteStateCopyWithImpl<$Res, $Val extends FavoriteState>
    implements $FavoriteStateCopyWith<$Res> {
  _$FavoriteStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FavoriteState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? favorites = null,
    Object? favoriteQuestionIds = null,
    Object? errorMessage = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FavoriteStatus,
      favorites: null == favorites
          ? _value.favorites
          : favorites // ignore: cast_nullable_to_non_nullable
              as List<FavoriteQuestion>,
      favoriteQuestionIds: null == favoriteQuestionIds
          ? _value.favoriteQuestionIds
          : favoriteQuestionIds // ignore: cast_nullable_to_non_nullable
              as Set<int>,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FavoriteStateImplCopyWith<$Res>
    implements $FavoriteStateCopyWith<$Res> {
  factory _$$FavoriteStateImplCopyWith(
          _$FavoriteStateImpl value, $Res Function(_$FavoriteStateImpl) then) =
      __$$FavoriteStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {FavoriteStatus status,
      List<FavoriteQuestion> favorites,
      Set<int> favoriteQuestionIds,
      String errorMessage});
}

/// @nodoc
class __$$FavoriteStateImplCopyWithImpl<$Res>
    extends _$FavoriteStateCopyWithImpl<$Res, _$FavoriteStateImpl>
    implements _$$FavoriteStateImplCopyWith<$Res> {
  __$$FavoriteStateImplCopyWithImpl(
      _$FavoriteStateImpl _value, $Res Function(_$FavoriteStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of FavoriteState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? favorites = null,
    Object? favoriteQuestionIds = null,
    Object? errorMessage = null,
  }) {
    return _then(_$FavoriteStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as FavoriteStatus,
      favorites: null == favorites
          ? _value._favorites
          : favorites // ignore: cast_nullable_to_non_nullable
              as List<FavoriteQuestion>,
      favoriteQuestionIds: null == favoriteQuestionIds
          ? _value._favoriteQuestionIds
          : favoriteQuestionIds // ignore: cast_nullable_to_non_nullable
              as Set<int>,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FavoriteStateImpl implements _FavoriteState {
  const _$FavoriteStateImpl(
      {this.status = FavoriteStatus.initial,
      final List<FavoriteQuestion> favorites = const [],
      final Set<int> favoriteQuestionIds = const {},
      this.errorMessage = ''})
      : _favorites = favorites,
        _favoriteQuestionIds = favoriteQuestionIds;

  @override
  @JsonKey()
  final FavoriteStatus status;
  final List<FavoriteQuestion> _favorites;
  @override
  @JsonKey()
  List<FavoriteQuestion> get favorites {
    if (_favorites is EqualUnmodifiableListView) return _favorites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favorites);
  }

  final Set<int> _favoriteQuestionIds;
  @override
  @JsonKey()
  Set<int> get favoriteQuestionIds {
    if (_favoriteQuestionIds is EqualUnmodifiableSetView)
      return _favoriteQuestionIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_favoriteQuestionIds);
  }

  @override
  @JsonKey()
  final String errorMessage;

  @override
  String toString() {
    return 'FavoriteState(status: $status, favorites: $favorites, favoriteQuestionIds: $favoriteQuestionIds, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FavoriteStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._favorites, _favorites) &&
            const DeepCollectionEquality()
                .equals(other._favoriteQuestionIds, _favoriteQuestionIds) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      const DeepCollectionEquality().hash(_favorites),
      const DeepCollectionEquality().hash(_favoriteQuestionIds),
      errorMessage);

  /// Create a copy of FavoriteState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FavoriteStateImplCopyWith<_$FavoriteStateImpl> get copyWith =>
      __$$FavoriteStateImplCopyWithImpl<_$FavoriteStateImpl>(this, _$identity);
}

abstract class _FavoriteState implements FavoriteState {
  const factory _FavoriteState(
      {final FavoriteStatus status,
      final List<FavoriteQuestion> favorites,
      final Set<int> favoriteQuestionIds,
      final String errorMessage}) = _$FavoriteStateImpl;

  @override
  FavoriteStatus get status;
  @override
  List<FavoriteQuestion> get favorites;
  @override
  Set<int> get favoriteQuestionIds;
  @override
  String get errorMessage;

  /// Create a copy of FavoriteState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FavoriteStateImplCopyWith<_$FavoriteStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChallengeState {
  List<Challenge> get challenges => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  bool get hasMoreData => throw _privateConstructorUsedError;
  Status get fetchChallengesStatus => throw _privateConstructorUsedError;
  Status get createChallengeStatus => throw _privateConstructorUsedError;
  Status get loadMoreStatus => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeStateCopyWith<ChallengeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeStateCopyWith<$Res> {
  factory $ChallengeStateCopyWith(
          ChallengeState value, $Res Function(ChallengeState) then) =
      _$ChallengeStateCopyWithImpl<$Res, ChallengeState>;
  @useResult
  $Res call(
      {List<Challenge> challenges,
      int currentPage,
      bool hasMoreData,
      Status fetchChallengesStatus,
      Status createChallengeStatus,
      Status loadMoreStatus,
      String? error});
}

/// @nodoc
class _$ChallengeStateCopyWithImpl<$Res, $Val extends ChallengeState>
    implements $ChallengeStateCopyWith<$Res> {
  _$ChallengeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenges = null,
    Object? currentPage = null,
    Object? hasMoreData = null,
    Object? fetchChallengesStatus = null,
    Object? createChallengeStatus = null,
    Object? loadMoreStatus = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      challenges: null == challenges
          ? _value.challenges
          : challenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      hasMoreData: null == hasMoreData
          ? _value.hasMoreData
          : hasMoreData // ignore: cast_nullable_to_non_nullable
              as bool,
      fetchChallengesStatus: null == fetchChallengesStatus
          ? _value.fetchChallengesStatus
          : fetchChallengesStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createChallengeStatus: null == createChallengeStatus
          ? _value.createChallengeStatus
          : createChallengeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      loadMoreStatus: null == loadMoreStatus
          ? _value.loadMoreStatus
          : loadMoreStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeStateImplCopyWith<$Res>
    implements $ChallengeStateCopyWith<$Res> {
  factory _$$ChallengeStateImplCopyWith(_$ChallengeStateImpl value,
          $Res Function(_$ChallengeStateImpl) then) =
      __$$ChallengeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Challenge> challenges,
      int currentPage,
      bool hasMoreData,
      Status fetchChallengesStatus,
      Status createChallengeStatus,
      Status loadMoreStatus,
      String? error});
}

/// @nodoc
class __$$ChallengeStateImplCopyWithImpl<$Res>
    extends _$ChallengeStateCopyWithImpl<$Res, _$ChallengeStateImpl>
    implements _$$ChallengeStateImplCopyWith<$Res> {
  __$$ChallengeStateImplCopyWithImpl(
      _$ChallengeStateImpl _value, $Res Function(_$ChallengeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenges = null,
    Object? currentPage = null,
    Object? hasMoreData = null,
    Object? fetchChallengesStatus = null,
    Object? createChallengeStatus = null,
    Object? loadMoreStatus = null,
    Object? error = freezed,
  }) {
    return _then(_$ChallengeStateImpl(
      challenges: null == challenges
          ? _value._challenges
          : challenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      hasMoreData: null == hasMoreData
          ? _value.hasMoreData
          : hasMoreData // ignore: cast_nullable_to_non_nullable
              as bool,
      fetchChallengesStatus: null == fetchChallengesStatus
          ? _value.fetchChallengesStatus
          : fetchChallengesStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createChallengeStatus: null == createChallengeStatus
          ? _value.createChallengeStatus
          : createChallengeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      loadMoreStatus: null == loadMoreStatus
          ? _value.loadMoreStatus
          : loadMoreStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ChallengeStateImpl extends _ChallengeState {
  const _$ChallengeStateImpl(
      {final List<Challenge> challenges = const [],
      this.currentPage = 0,
      this.hasMoreData = false,
      required this.fetchChallengesStatus,
      required this.createChallengeStatus,
      required this.loadMoreStatus,
      this.error})
      : _challenges = challenges,
        super._();

  final List<Challenge> _challenges;
  @override
  @JsonKey()
  List<Challenge> get challenges {
    if (_challenges is EqualUnmodifiableListView) return _challenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_challenges);
  }

  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final bool hasMoreData;
  @override
  final Status fetchChallengesStatus;
  @override
  final Status createChallengeStatus;
  @override
  final Status loadMoreStatus;
  @override
  final String? error;

  @override
  String toString() {
    return 'ChallengeState(challenges: $challenges, currentPage: $currentPage, hasMoreData: $hasMoreData, fetchChallengesStatus: $fetchChallengesStatus, createChallengeStatus: $createChallengeStatus, loadMoreStatus: $loadMoreStatus, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeStateImpl &&
            const DeepCollectionEquality()
                .equals(other._challenges, _challenges) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.hasMoreData, hasMoreData) ||
                other.hasMoreData == hasMoreData) &&
            (identical(other.fetchChallengesStatus, fetchChallengesStatus) ||
                other.fetchChallengesStatus == fetchChallengesStatus) &&
            (identical(other.createChallengeStatus, createChallengeStatus) ||
                other.createChallengeStatus == createChallengeStatus) &&
            (identical(other.loadMoreStatus, loadMoreStatus) ||
                other.loadMoreStatus == loadMoreStatus) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_challenges),
      currentPage,
      hasMoreData,
      fetchChallengesStatus,
      createChallengeStatus,
      loadMoreStatus,
      error);

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeStateImplCopyWith<_$ChallengeStateImpl> get copyWith =>
      __$$ChallengeStateImplCopyWithImpl<_$ChallengeStateImpl>(
          this, _$identity);
}

abstract class _ChallengeState extends ChallengeState {
  const factory _ChallengeState(
      {final List<Challenge> challenges,
      final int currentPage,
      final bool hasMoreData,
      required final Status fetchChallengesStatus,
      required final Status createChallengeStatus,
      required final Status loadMoreStatus,
      final String? error}) = _$ChallengeStateImpl;
  const _ChallengeState._() : super._();

  @override
  List<Challenge> get challenges;
  @override
  int get currentPage;
  @override
  bool get hasMoreData;
  @override
  Status get fetchChallengesStatus;
  @override
  Status get createChallengeStatus;
  @override
  Status get loadMoreStatus;
  @override
  String? get error;

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeStateImplCopyWith<_$ChallengeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

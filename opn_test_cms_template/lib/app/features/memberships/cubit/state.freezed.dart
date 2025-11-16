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
mixin _$MembershipState {
  List<MembershipLevel> get membershipLevels =>
      throw _privateConstructorUsedError;
  MembershipLevel? get selectedMembershipLevel =>
      throw _privateConstructorUsedError;
  Status get fetchMembershipLevelsStatus => throw _privateConstructorUsedError;
  Status get createMembershipLevelStatus => throw _privateConstructorUsedError;
  Status get updateMembershipLevelStatus => throw _privateConstructorUsedError;
  Status get deleteMembershipLevelStatus => throw _privateConstructorUsedError;
  Status get searchMembershipLevelsStatus => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get searchQuery => throw _privateConstructorUsedError; // Estadísticas
  Map<int, int> get userCountByLevel => throw _privateConstructorUsedError;
  Status get fetchStatsStatus => throw _privateConstructorUsedError;

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MembershipStateCopyWith<MembershipState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MembershipStateCopyWith<$Res> {
  factory $MembershipStateCopyWith(
          MembershipState value, $Res Function(MembershipState) then) =
      _$MembershipStateCopyWithImpl<$Res, MembershipState>;
  @useResult
  $Res call(
      {List<MembershipLevel> membershipLevels,
      MembershipLevel? selectedMembershipLevel,
      Status fetchMembershipLevelsStatus,
      Status createMembershipLevelStatus,
      Status updateMembershipLevelStatus,
      Status deleteMembershipLevelStatus,
      Status searchMembershipLevelsStatus,
      String? error,
      String? searchQuery,
      Map<int, int> userCountByLevel,
      Status fetchStatsStatus});
}

/// @nodoc
class _$MembershipStateCopyWithImpl<$Res, $Val extends MembershipState>
    implements $MembershipStateCopyWith<$Res> {
  _$MembershipStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? membershipLevels = null,
    Object? selectedMembershipLevel = freezed,
    Object? fetchMembershipLevelsStatus = null,
    Object? createMembershipLevelStatus = null,
    Object? updateMembershipLevelStatus = null,
    Object? deleteMembershipLevelStatus = null,
    Object? searchMembershipLevelsStatus = null,
    Object? error = freezed,
    Object? searchQuery = freezed,
    Object? userCountByLevel = null,
    Object? fetchStatsStatus = null,
  }) {
    return _then(_value.copyWith(
      membershipLevels: null == membershipLevels
          ? _value.membershipLevels
          : membershipLevels // ignore: cast_nullable_to_non_nullable
              as List<MembershipLevel>,
      selectedMembershipLevel: freezed == selectedMembershipLevel
          ? _value.selectedMembershipLevel
          : selectedMembershipLevel // ignore: cast_nullable_to_non_nullable
              as MembershipLevel?,
      fetchMembershipLevelsStatus: null == fetchMembershipLevelsStatus
          ? _value.fetchMembershipLevelsStatus
          : fetchMembershipLevelsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createMembershipLevelStatus: null == createMembershipLevelStatus
          ? _value.createMembershipLevelStatus
          : createMembershipLevelStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateMembershipLevelStatus: null == updateMembershipLevelStatus
          ? _value.updateMembershipLevelStatus
          : updateMembershipLevelStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteMembershipLevelStatus: null == deleteMembershipLevelStatus
          ? _value.deleteMembershipLevelStatus
          : deleteMembershipLevelStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      searchMembershipLevelsStatus: null == searchMembershipLevelsStatus
          ? _value.searchMembershipLevelsStatus
          : searchMembershipLevelsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      userCountByLevel: null == userCountByLevel
          ? _value.userCountByLevel
          : userCountByLevel // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      fetchStatsStatus: null == fetchStatsStatus
          ? _value.fetchStatsStatus
          : fetchStatsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MembershipStateImplCopyWith<$Res>
    implements $MembershipStateCopyWith<$Res> {
  factory _$$MembershipStateImplCopyWith(_$MembershipStateImpl value,
          $Res Function(_$MembershipStateImpl) then) =
      __$$MembershipStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<MembershipLevel> membershipLevels,
      MembershipLevel? selectedMembershipLevel,
      Status fetchMembershipLevelsStatus,
      Status createMembershipLevelStatus,
      Status updateMembershipLevelStatus,
      Status deleteMembershipLevelStatus,
      Status searchMembershipLevelsStatus,
      String? error,
      String? searchQuery,
      Map<int, int> userCountByLevel,
      Status fetchStatsStatus});
}

/// @nodoc
class __$$MembershipStateImplCopyWithImpl<$Res>
    extends _$MembershipStateCopyWithImpl<$Res, _$MembershipStateImpl>
    implements _$$MembershipStateImplCopyWith<$Res> {
  __$$MembershipStateImplCopyWithImpl(
      _$MembershipStateImpl _value, $Res Function(_$MembershipStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? membershipLevels = null,
    Object? selectedMembershipLevel = freezed,
    Object? fetchMembershipLevelsStatus = null,
    Object? createMembershipLevelStatus = null,
    Object? updateMembershipLevelStatus = null,
    Object? deleteMembershipLevelStatus = null,
    Object? searchMembershipLevelsStatus = null,
    Object? error = freezed,
    Object? searchQuery = freezed,
    Object? userCountByLevel = null,
    Object? fetchStatsStatus = null,
  }) {
    return _then(_$MembershipStateImpl(
      membershipLevels: null == membershipLevels
          ? _value._membershipLevels
          : membershipLevels // ignore: cast_nullable_to_non_nullable
              as List<MembershipLevel>,
      selectedMembershipLevel: freezed == selectedMembershipLevel
          ? _value.selectedMembershipLevel
          : selectedMembershipLevel // ignore: cast_nullable_to_non_nullable
              as MembershipLevel?,
      fetchMembershipLevelsStatus: null == fetchMembershipLevelsStatus
          ? _value.fetchMembershipLevelsStatus
          : fetchMembershipLevelsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createMembershipLevelStatus: null == createMembershipLevelStatus
          ? _value.createMembershipLevelStatus
          : createMembershipLevelStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateMembershipLevelStatus: null == updateMembershipLevelStatus
          ? _value.updateMembershipLevelStatus
          : updateMembershipLevelStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteMembershipLevelStatus: null == deleteMembershipLevelStatus
          ? _value.deleteMembershipLevelStatus
          : deleteMembershipLevelStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      searchMembershipLevelsStatus: null == searchMembershipLevelsStatus
          ? _value.searchMembershipLevelsStatus
          : searchMembershipLevelsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      userCountByLevel: null == userCountByLevel
          ? _value._userCountByLevel
          : userCountByLevel // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      fetchStatsStatus: null == fetchStatsStatus
          ? _value.fetchStatsStatus
          : fetchStatsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
    ));
  }
}

/// @nodoc

class _$MembershipStateImpl extends _MembershipState {
  const _$MembershipStateImpl(
      {final List<MembershipLevel> membershipLevels = const [],
      this.selectedMembershipLevel,
      required this.fetchMembershipLevelsStatus,
      required this.createMembershipLevelStatus,
      required this.updateMembershipLevelStatus,
      required this.deleteMembershipLevelStatus,
      required this.searchMembershipLevelsStatus,
      this.error,
      this.searchQuery,
      final Map<int, int> userCountByLevel = const {},
      required this.fetchStatsStatus})
      : _membershipLevels = membershipLevels,
        _userCountByLevel = userCountByLevel,
        super._();

  final List<MembershipLevel> _membershipLevels;
  @override
  @JsonKey()
  List<MembershipLevel> get membershipLevels {
    if (_membershipLevels is EqualUnmodifiableListView)
      return _membershipLevels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_membershipLevels);
  }

  @override
  final MembershipLevel? selectedMembershipLevel;
  @override
  final Status fetchMembershipLevelsStatus;
  @override
  final Status createMembershipLevelStatus;
  @override
  final Status updateMembershipLevelStatus;
  @override
  final Status deleteMembershipLevelStatus;
  @override
  final Status searchMembershipLevelsStatus;
  @override
  final String? error;
  @override
  final String? searchQuery;
// Estadísticas
  final Map<int, int> _userCountByLevel;
// Estadísticas
  @override
  @JsonKey()
  Map<int, int> get userCountByLevel {
    if (_userCountByLevel is EqualUnmodifiableMapView) return _userCountByLevel;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_userCountByLevel);
  }

  @override
  final Status fetchStatsStatus;

  @override
  String toString() {
    return 'MembershipState(membershipLevels: $membershipLevels, selectedMembershipLevel: $selectedMembershipLevel, fetchMembershipLevelsStatus: $fetchMembershipLevelsStatus, createMembershipLevelStatus: $createMembershipLevelStatus, updateMembershipLevelStatus: $updateMembershipLevelStatus, deleteMembershipLevelStatus: $deleteMembershipLevelStatus, searchMembershipLevelsStatus: $searchMembershipLevelsStatus, error: $error, searchQuery: $searchQuery, userCountByLevel: $userCountByLevel, fetchStatsStatus: $fetchStatsStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MembershipStateImpl &&
            const DeepCollectionEquality()
                .equals(other._membershipLevels, _membershipLevels) &&
            (identical(
                    other.selectedMembershipLevel, selectedMembershipLevel) ||
                other.selectedMembershipLevel == selectedMembershipLevel) &&
            (identical(other.fetchMembershipLevelsStatus, fetchMembershipLevelsStatus) ||
                other.fetchMembershipLevelsStatus ==
                    fetchMembershipLevelsStatus) &&
            (identical(other.createMembershipLevelStatus,
                    createMembershipLevelStatus) ||
                other.createMembershipLevelStatus ==
                    createMembershipLevelStatus) &&
            (identical(other.updateMembershipLevelStatus,
                    updateMembershipLevelStatus) ||
                other.updateMembershipLevelStatus ==
                    updateMembershipLevelStatus) &&
            (identical(other.deleteMembershipLevelStatus,
                    deleteMembershipLevelStatus) ||
                other.deleteMembershipLevelStatus ==
                    deleteMembershipLevelStatus) &&
            (identical(other.searchMembershipLevelsStatus,
                    searchMembershipLevelsStatus) ||
                other.searchMembershipLevelsStatus ==
                    searchMembershipLevelsStatus) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            const DeepCollectionEquality()
                .equals(other._userCountByLevel, _userCountByLevel) &&
            (identical(other.fetchStatsStatus, fetchStatsStatus) ||
                other.fetchStatsStatus == fetchStatsStatus));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_membershipLevels),
      selectedMembershipLevel,
      fetchMembershipLevelsStatus,
      createMembershipLevelStatus,
      updateMembershipLevelStatus,
      deleteMembershipLevelStatus,
      searchMembershipLevelsStatus,
      error,
      searchQuery,
      const DeepCollectionEquality().hash(_userCountByLevel),
      fetchStatsStatus);

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MembershipStateImplCopyWith<_$MembershipStateImpl> get copyWith =>
      __$$MembershipStateImplCopyWithImpl<_$MembershipStateImpl>(
          this, _$identity);
}

abstract class _MembershipState extends MembershipState {
  const factory _MembershipState(
      {final List<MembershipLevel> membershipLevels,
      final MembershipLevel? selectedMembershipLevel,
      required final Status fetchMembershipLevelsStatus,
      required final Status createMembershipLevelStatus,
      required final Status updateMembershipLevelStatus,
      required final Status deleteMembershipLevelStatus,
      required final Status searchMembershipLevelsStatus,
      final String? error,
      final String? searchQuery,
      final Map<int, int> userCountByLevel,
      required final Status fetchStatsStatus}) = _$MembershipStateImpl;
  const _MembershipState._() : super._();

  @override
  List<MembershipLevel> get membershipLevels;
  @override
  MembershipLevel? get selectedMembershipLevel;
  @override
  Status get fetchMembershipLevelsStatus;
  @override
  Status get createMembershipLevelStatus;
  @override
  Status get updateMembershipLevelStatus;
  @override
  Status get deleteMembershipLevelStatus;
  @override
  Status get searchMembershipLevelsStatus;
  @override
  String? get error;
  @override
  String? get searchQuery; // Estadísticas
  @override
  Map<int, int> get userCountByLevel;
  @override
  Status get fetchStatsStatus;

  /// Create a copy of MembershipState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MembershipStateImplCopyWith<_$MembershipStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

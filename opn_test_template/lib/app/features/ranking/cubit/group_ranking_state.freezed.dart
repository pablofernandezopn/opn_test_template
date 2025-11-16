// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_ranking_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GroupRankingState {
  GroupRankingStatus get status => throw _privateConstructorUsedError;
  List<GroupRankingEntry> get allEntries => throw _privateConstructorUsedError;
  List<GroupRankingEntry> get displayedEntries =>
      throw _privateConstructorUsedError;
  GroupRankingEntry? get userEntry => throw _privateConstructorUsedError;
  int get currentDisplayIndex => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  int get totalParticipants => throw _privateConstructorUsedError;
  int? get topicGroupId => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of GroupRankingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupRankingStateCopyWith<GroupRankingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupRankingStateCopyWith<$Res> {
  factory $GroupRankingStateCopyWith(
          GroupRankingState value, $Res Function(GroupRankingState) then) =
      _$GroupRankingStateCopyWithImpl<$Res, GroupRankingState>;
  @useResult
  $Res call(
      {GroupRankingStatus status,
      List<GroupRankingEntry> allEntries,
      List<GroupRankingEntry> displayedEntries,
      GroupRankingEntry? userEntry,
      int currentDisplayIndex,
      int pageSize,
      int totalParticipants,
      int? topicGroupId,
      String? errorMessage});
}

/// @nodoc
class _$GroupRankingStateCopyWithImpl<$Res, $Val extends GroupRankingState>
    implements $GroupRankingStateCopyWith<$Res> {
  _$GroupRankingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupRankingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? allEntries = null,
    Object? displayedEntries = null,
    Object? userEntry = freezed,
    Object? currentDisplayIndex = null,
    Object? pageSize = null,
    Object? totalParticipants = null,
    Object? topicGroupId = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GroupRankingStatus,
      allEntries: null == allEntries
          ? _value.allEntries
          : allEntries // ignore: cast_nullable_to_non_nullable
              as List<GroupRankingEntry>,
      displayedEntries: null == displayedEntries
          ? _value.displayedEntries
          : displayedEntries // ignore: cast_nullable_to_non_nullable
              as List<GroupRankingEntry>,
      userEntry: freezed == userEntry
          ? _value.userEntry
          : userEntry // ignore: cast_nullable_to_non_nullable
              as GroupRankingEntry?,
      currentDisplayIndex: null == currentDisplayIndex
          ? _value.currentDisplayIndex
          : currentDisplayIndex // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      topicGroupId: freezed == topicGroupId
          ? _value.topicGroupId
          : topicGroupId // ignore: cast_nullable_to_non_nullable
              as int?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupRankingStateImplCopyWith<$Res>
    implements $GroupRankingStateCopyWith<$Res> {
  factory _$$GroupRankingStateImplCopyWith(_$GroupRankingStateImpl value,
          $Res Function(_$GroupRankingStateImpl) then) =
      __$$GroupRankingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {GroupRankingStatus status,
      List<GroupRankingEntry> allEntries,
      List<GroupRankingEntry> displayedEntries,
      GroupRankingEntry? userEntry,
      int currentDisplayIndex,
      int pageSize,
      int totalParticipants,
      int? topicGroupId,
      String? errorMessage});
}

/// @nodoc
class __$$GroupRankingStateImplCopyWithImpl<$Res>
    extends _$GroupRankingStateCopyWithImpl<$Res, _$GroupRankingStateImpl>
    implements _$$GroupRankingStateImplCopyWith<$Res> {
  __$$GroupRankingStateImplCopyWithImpl(_$GroupRankingStateImpl _value,
      $Res Function(_$GroupRankingStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of GroupRankingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? allEntries = null,
    Object? displayedEntries = null,
    Object? userEntry = freezed,
    Object? currentDisplayIndex = null,
    Object? pageSize = null,
    Object? totalParticipants = null,
    Object? topicGroupId = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$GroupRankingStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GroupRankingStatus,
      allEntries: null == allEntries
          ? _value._allEntries
          : allEntries // ignore: cast_nullable_to_non_nullable
              as List<GroupRankingEntry>,
      displayedEntries: null == displayedEntries
          ? _value._displayedEntries
          : displayedEntries // ignore: cast_nullable_to_non_nullable
              as List<GroupRankingEntry>,
      userEntry: freezed == userEntry
          ? _value.userEntry
          : userEntry // ignore: cast_nullable_to_non_nullable
              as GroupRankingEntry?,
      currentDisplayIndex: null == currentDisplayIndex
          ? _value.currentDisplayIndex
          : currentDisplayIndex // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      topicGroupId: freezed == topicGroupId
          ? _value.topicGroupId
          : topicGroupId // ignore: cast_nullable_to_non_nullable
              as int?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$GroupRankingStateImpl extends _GroupRankingState {
  const _$GroupRankingStateImpl(
      {this.status = GroupRankingStatus.initial,
      final List<GroupRankingEntry> allEntries = const [],
      final List<GroupRankingEntry> displayedEntries = const [],
      this.userEntry,
      this.currentDisplayIndex = 0,
      this.pageSize = 20,
      this.totalParticipants = 0,
      this.topicGroupId,
      this.errorMessage})
      : _allEntries = allEntries,
        _displayedEntries = displayedEntries,
        super._();

  @override
  @JsonKey()
  final GroupRankingStatus status;
  final List<GroupRankingEntry> _allEntries;
  @override
  @JsonKey()
  List<GroupRankingEntry> get allEntries {
    if (_allEntries is EqualUnmodifiableListView) return _allEntries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allEntries);
  }

  final List<GroupRankingEntry> _displayedEntries;
  @override
  @JsonKey()
  List<GroupRankingEntry> get displayedEntries {
    if (_displayedEntries is EqualUnmodifiableListView)
      return _displayedEntries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_displayedEntries);
  }

  @override
  final GroupRankingEntry? userEntry;
  @override
  @JsonKey()
  final int currentDisplayIndex;
  @override
  @JsonKey()
  final int pageSize;
  @override
  @JsonKey()
  final int totalParticipants;
  @override
  final int? topicGroupId;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'GroupRankingState(status: $status, allEntries: $allEntries, displayedEntries: $displayedEntries, userEntry: $userEntry, currentDisplayIndex: $currentDisplayIndex, pageSize: $pageSize, totalParticipants: $totalParticipants, topicGroupId: $topicGroupId, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupRankingStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._allEntries, _allEntries) &&
            const DeepCollectionEquality()
                .equals(other._displayedEntries, _displayedEntries) &&
            (identical(other.userEntry, userEntry) ||
                other.userEntry == userEntry) &&
            (identical(other.currentDisplayIndex, currentDisplayIndex) ||
                other.currentDisplayIndex == currentDisplayIndex) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.totalParticipants, totalParticipants) ||
                other.totalParticipants == totalParticipants) &&
            (identical(other.topicGroupId, topicGroupId) ||
                other.topicGroupId == topicGroupId) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      const DeepCollectionEquality().hash(_allEntries),
      const DeepCollectionEquality().hash(_displayedEntries),
      userEntry,
      currentDisplayIndex,
      pageSize,
      totalParticipants,
      topicGroupId,
      errorMessage);

  /// Create a copy of GroupRankingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupRankingStateImplCopyWith<_$GroupRankingStateImpl> get copyWith =>
      __$$GroupRankingStateImplCopyWithImpl<_$GroupRankingStateImpl>(
          this, _$identity);
}

abstract class _GroupRankingState extends GroupRankingState {
  const factory _GroupRankingState(
      {final GroupRankingStatus status,
      final List<GroupRankingEntry> allEntries,
      final List<GroupRankingEntry> displayedEntries,
      final GroupRankingEntry? userEntry,
      final int currentDisplayIndex,
      final int pageSize,
      final int totalParticipants,
      final int? topicGroupId,
      final String? errorMessage}) = _$GroupRankingStateImpl;
  const _GroupRankingState._() : super._();

  @override
  GroupRankingStatus get status;
  @override
  List<GroupRankingEntry> get allEntries;
  @override
  List<GroupRankingEntry> get displayedEntries;
  @override
  GroupRankingEntry? get userEntry;
  @override
  int get currentDisplayIndex;
  @override
  int get pageSize;
  @override
  int get totalParticipants;
  @override
  int? get topicGroupId;
  @override
  String? get errorMessage;

  /// Create a copy of GroupRankingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupRankingStateImplCopyWith<_$GroupRankingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

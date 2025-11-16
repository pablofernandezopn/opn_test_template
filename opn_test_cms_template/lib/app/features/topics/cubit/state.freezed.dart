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
mixin _$TopicState {
  List<Topic> get topics => throw _privateConstructorUsedError;
  List<TopicType> get topicTypes => throw _privateConstructorUsedError;
  List<TopicGroup> get topicGroups =>
      throw _privateConstructorUsedError; // AÑADIR
  int? get selectedTopicTypeId => throw _privateConstructorUsedError;
  int? get selectedTopicId => throw _privateConstructorUsedError;
  int? get selectedTopicGroupId => throw _privateConstructorUsedError; // AÑADIR
  TopicGroup? get selectedTopicGroup =>
      throw _privateConstructorUsedError; // AÑADIR (opcional, para fetchById)
  Status get fetchStatus => throw _privateConstructorUsedError;
  Status get fetchTopicsStatus => throw _privateConstructorUsedError;
  Status get createTopicTypeStatus => throw _privateConstructorUsedError;
  Status get updateTopicTypeStatus => throw _privateConstructorUsedError;
  Status get deleteTopicTypeStatus => throw _privateConstructorUsedError;
  Status get createTopicStatus => throw _privateConstructorUsedError;
  Status get updateTopicStatus => throw _privateConstructorUsedError;
  Status get deleteTopicStatus => throw _privateConstructorUsedError;
  Status get fetchTopicsByTypeStatus => throw _privateConstructorUsedError;
  Status get fetchTopicGroupsStatus =>
      throw _privateConstructorUsedError; // AÑADIR
  Status get fetchTopicGroupByIdStatus =>
      throw _privateConstructorUsedError; // AÑADIR
  Status get createTopicGroupStatus =>
      throw _privateConstructorUsedError; // AÑADIR
  Status get updateTopicGroupStatus =>
      throw _privateConstructorUsedError; // AÑADIR
  Status get deleteTopicGroupStatus =>
      throw _privateConstructorUsedError; // AÑADIR
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of TopicState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopicStateCopyWith<TopicState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopicStateCopyWith<$Res> {
  factory $TopicStateCopyWith(
          TopicState value, $Res Function(TopicState) then) =
      _$TopicStateCopyWithImpl<$Res, TopicState>;
  @useResult
  $Res call(
      {List<Topic> topics,
      List<TopicType> topicTypes,
      List<TopicGroup> topicGroups,
      int? selectedTopicTypeId,
      int? selectedTopicId,
      int? selectedTopicGroupId,
      TopicGroup? selectedTopicGroup,
      Status fetchStatus,
      Status fetchTopicsStatus,
      Status createTopicTypeStatus,
      Status updateTopicTypeStatus,
      Status deleteTopicTypeStatus,
      Status createTopicStatus,
      Status updateTopicStatus,
      Status deleteTopicStatus,
      Status fetchTopicsByTypeStatus,
      Status fetchTopicGroupsStatus,
      Status fetchTopicGroupByIdStatus,
      Status createTopicGroupStatus,
      Status updateTopicGroupStatus,
      Status deleteTopicGroupStatus,
      String? error});
}

/// @nodoc
class _$TopicStateCopyWithImpl<$Res, $Val extends TopicState>
    implements $TopicStateCopyWith<$Res> {
  _$TopicStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TopicState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topics = null,
    Object? topicTypes = null,
    Object? topicGroups = null,
    Object? selectedTopicTypeId = freezed,
    Object? selectedTopicId = freezed,
    Object? selectedTopicGroupId = freezed,
    Object? selectedTopicGroup = freezed,
    Object? fetchStatus = null,
    Object? fetchTopicsStatus = null,
    Object? createTopicTypeStatus = null,
    Object? updateTopicTypeStatus = null,
    Object? deleteTopicTypeStatus = null,
    Object? createTopicStatus = null,
    Object? updateTopicStatus = null,
    Object? deleteTopicStatus = null,
    Object? fetchTopicsByTypeStatus = null,
    Object? fetchTopicGroupsStatus = null,
    Object? fetchTopicGroupByIdStatus = null,
    Object? createTopicGroupStatus = null,
    Object? updateTopicGroupStatus = null,
    Object? deleteTopicGroupStatus = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      topics: null == topics
          ? _value.topics
          : topics // ignore: cast_nullable_to_non_nullable
              as List<Topic>,
      topicTypes: null == topicTypes
          ? _value.topicTypes
          : topicTypes // ignore: cast_nullable_to_non_nullable
              as List<TopicType>,
      topicGroups: null == topicGroups
          ? _value.topicGroups
          : topicGroups // ignore: cast_nullable_to_non_nullable
              as List<TopicGroup>,
      selectedTopicTypeId: freezed == selectedTopicTypeId
          ? _value.selectedTopicTypeId
          : selectedTopicTypeId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedTopicId: freezed == selectedTopicId
          ? _value.selectedTopicId
          : selectedTopicId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedTopicGroupId: freezed == selectedTopicGroupId
          ? _value.selectedTopicGroupId
          : selectedTopicGroupId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedTopicGroup: freezed == selectedTopicGroup
          ? _value.selectedTopicGroup
          : selectedTopicGroup // ignore: cast_nullable_to_non_nullable
              as TopicGroup?,
      fetchStatus: null == fetchStatus
          ? _value.fetchStatus
          : fetchStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicsStatus: null == fetchTopicsStatus
          ? _value.fetchTopicsStatus
          : fetchTopicsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createTopicTypeStatus: null == createTopicTypeStatus
          ? _value.createTopicTypeStatus
          : createTopicTypeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateTopicTypeStatus: null == updateTopicTypeStatus
          ? _value.updateTopicTypeStatus
          : updateTopicTypeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteTopicTypeStatus: null == deleteTopicTypeStatus
          ? _value.deleteTopicTypeStatus
          : deleteTopicTypeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createTopicStatus: null == createTopicStatus
          ? _value.createTopicStatus
          : createTopicStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateTopicStatus: null == updateTopicStatus
          ? _value.updateTopicStatus
          : updateTopicStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteTopicStatus: null == deleteTopicStatus
          ? _value.deleteTopicStatus
          : deleteTopicStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicsByTypeStatus: null == fetchTopicsByTypeStatus
          ? _value.fetchTopicsByTypeStatus
          : fetchTopicsByTypeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicGroupsStatus: null == fetchTopicGroupsStatus
          ? _value.fetchTopicGroupsStatus
          : fetchTopicGroupsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicGroupByIdStatus: null == fetchTopicGroupByIdStatus
          ? _value.fetchTopicGroupByIdStatus
          : fetchTopicGroupByIdStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createTopicGroupStatus: null == createTopicGroupStatus
          ? _value.createTopicGroupStatus
          : createTopicGroupStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateTopicGroupStatus: null == updateTopicGroupStatus
          ? _value.updateTopicGroupStatus
          : updateTopicGroupStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteTopicGroupStatus: null == deleteTopicGroupStatus
          ? _value.deleteTopicGroupStatus
          : deleteTopicGroupStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TopicStateImplCopyWith<$Res>
    implements $TopicStateCopyWith<$Res> {
  factory _$$TopicStateImplCopyWith(
          _$TopicStateImpl value, $Res Function(_$TopicStateImpl) then) =
      __$$TopicStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Topic> topics,
      List<TopicType> topicTypes,
      List<TopicGroup> topicGroups,
      int? selectedTopicTypeId,
      int? selectedTopicId,
      int? selectedTopicGroupId,
      TopicGroup? selectedTopicGroup,
      Status fetchStatus,
      Status fetchTopicsStatus,
      Status createTopicTypeStatus,
      Status updateTopicTypeStatus,
      Status deleteTopicTypeStatus,
      Status createTopicStatus,
      Status updateTopicStatus,
      Status deleteTopicStatus,
      Status fetchTopicsByTypeStatus,
      Status fetchTopicGroupsStatus,
      Status fetchTopicGroupByIdStatus,
      Status createTopicGroupStatus,
      Status updateTopicGroupStatus,
      Status deleteTopicGroupStatus,
      String? error});
}

/// @nodoc
class __$$TopicStateImplCopyWithImpl<$Res>
    extends _$TopicStateCopyWithImpl<$Res, _$TopicStateImpl>
    implements _$$TopicStateImplCopyWith<$Res> {
  __$$TopicStateImplCopyWithImpl(
      _$TopicStateImpl _value, $Res Function(_$TopicStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of TopicState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topics = null,
    Object? topicTypes = null,
    Object? topicGroups = null,
    Object? selectedTopicTypeId = freezed,
    Object? selectedTopicId = freezed,
    Object? selectedTopicGroupId = freezed,
    Object? selectedTopicGroup = freezed,
    Object? fetchStatus = null,
    Object? fetchTopicsStatus = null,
    Object? createTopicTypeStatus = null,
    Object? updateTopicTypeStatus = null,
    Object? deleteTopicTypeStatus = null,
    Object? createTopicStatus = null,
    Object? updateTopicStatus = null,
    Object? deleteTopicStatus = null,
    Object? fetchTopicsByTypeStatus = null,
    Object? fetchTopicGroupsStatus = null,
    Object? fetchTopicGroupByIdStatus = null,
    Object? createTopicGroupStatus = null,
    Object? updateTopicGroupStatus = null,
    Object? deleteTopicGroupStatus = null,
    Object? error = freezed,
  }) {
    return _then(_$TopicStateImpl(
      topics: null == topics
          ? _value._topics
          : topics // ignore: cast_nullable_to_non_nullable
              as List<Topic>,
      topicTypes: null == topicTypes
          ? _value._topicTypes
          : topicTypes // ignore: cast_nullable_to_non_nullable
              as List<TopicType>,
      topicGroups: null == topicGroups
          ? _value._topicGroups
          : topicGroups // ignore: cast_nullable_to_non_nullable
              as List<TopicGroup>,
      selectedTopicTypeId: freezed == selectedTopicTypeId
          ? _value.selectedTopicTypeId
          : selectedTopicTypeId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedTopicId: freezed == selectedTopicId
          ? _value.selectedTopicId
          : selectedTopicId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedTopicGroupId: freezed == selectedTopicGroupId
          ? _value.selectedTopicGroupId
          : selectedTopicGroupId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedTopicGroup: freezed == selectedTopicGroup
          ? _value.selectedTopicGroup
          : selectedTopicGroup // ignore: cast_nullable_to_non_nullable
              as TopicGroup?,
      fetchStatus: null == fetchStatus
          ? _value.fetchStatus
          : fetchStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicsStatus: null == fetchTopicsStatus
          ? _value.fetchTopicsStatus
          : fetchTopicsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createTopicTypeStatus: null == createTopicTypeStatus
          ? _value.createTopicTypeStatus
          : createTopicTypeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateTopicTypeStatus: null == updateTopicTypeStatus
          ? _value.updateTopicTypeStatus
          : updateTopicTypeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteTopicTypeStatus: null == deleteTopicTypeStatus
          ? _value.deleteTopicTypeStatus
          : deleteTopicTypeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createTopicStatus: null == createTopicStatus
          ? _value.createTopicStatus
          : createTopicStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateTopicStatus: null == updateTopicStatus
          ? _value.updateTopicStatus
          : updateTopicStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteTopicStatus: null == deleteTopicStatus
          ? _value.deleteTopicStatus
          : deleteTopicStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicsByTypeStatus: null == fetchTopicsByTypeStatus
          ? _value.fetchTopicsByTypeStatus
          : fetchTopicsByTypeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicGroupsStatus: null == fetchTopicGroupsStatus
          ? _value.fetchTopicGroupsStatus
          : fetchTopicGroupsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicGroupByIdStatus: null == fetchTopicGroupByIdStatus
          ? _value.fetchTopicGroupByIdStatus
          : fetchTopicGroupByIdStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createTopicGroupStatus: null == createTopicGroupStatus
          ? _value.createTopicGroupStatus
          : createTopicGroupStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateTopicGroupStatus: null == updateTopicGroupStatus
          ? _value.updateTopicGroupStatus
          : updateTopicGroupStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteTopicGroupStatus: null == deleteTopicGroupStatus
          ? _value.deleteTopicGroupStatus
          : deleteTopicGroupStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TopicStateImpl extends _TopicState {
  const _$TopicStateImpl(
      {final List<Topic> topics = const [],
      final List<TopicType> topicTypes = const [],
      final List<TopicGroup> topicGroups = const [],
      this.selectedTopicTypeId,
      this.selectedTopicId,
      this.selectedTopicGroupId,
      this.selectedTopicGroup,
      required this.fetchStatus,
      required this.fetchTopicsStatus,
      required this.createTopicTypeStatus,
      required this.updateTopicTypeStatus,
      required this.deleteTopicTypeStatus,
      required this.createTopicStatus,
      required this.updateTopicStatus,
      required this.deleteTopicStatus,
      required this.fetchTopicsByTypeStatus,
      required this.fetchTopicGroupsStatus,
      required this.fetchTopicGroupByIdStatus,
      required this.createTopicGroupStatus,
      required this.updateTopicGroupStatus,
      required this.deleteTopicGroupStatus,
      this.error})
      : _topics = topics,
        _topicTypes = topicTypes,
        _topicGroups = topicGroups,
        super._();

  final List<Topic> _topics;
  @override
  @JsonKey()
  List<Topic> get topics {
    if (_topics is EqualUnmodifiableListView) return _topics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topics);
  }

  final List<TopicType> _topicTypes;
  @override
  @JsonKey()
  List<TopicType> get topicTypes {
    if (_topicTypes is EqualUnmodifiableListView) return _topicTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topicTypes);
  }

  final List<TopicGroup> _topicGroups;
  @override
  @JsonKey()
  List<TopicGroup> get topicGroups {
    if (_topicGroups is EqualUnmodifiableListView) return _topicGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topicGroups);
  }

// AÑADIR
  @override
  final int? selectedTopicTypeId;
  @override
  final int? selectedTopicId;
  @override
  final int? selectedTopicGroupId;
// AÑADIR
  @override
  final TopicGroup? selectedTopicGroup;
// AÑADIR (opcional, para fetchById)
  @override
  final Status fetchStatus;
  @override
  final Status fetchTopicsStatus;
  @override
  final Status createTopicTypeStatus;
  @override
  final Status updateTopicTypeStatus;
  @override
  final Status deleteTopicTypeStatus;
  @override
  final Status createTopicStatus;
  @override
  final Status updateTopicStatus;
  @override
  final Status deleteTopicStatus;
  @override
  final Status fetchTopicsByTypeStatus;
  @override
  final Status fetchTopicGroupsStatus;
// AÑADIR
  @override
  final Status fetchTopicGroupByIdStatus;
// AÑADIR
  @override
  final Status createTopicGroupStatus;
// AÑADIR
  @override
  final Status updateTopicGroupStatus;
// AÑADIR
  @override
  final Status deleteTopicGroupStatus;
// AÑADIR
  @override
  final String? error;

  @override
  String toString() {
    return 'TopicState(topics: $topics, topicTypes: $topicTypes, topicGroups: $topicGroups, selectedTopicTypeId: $selectedTopicTypeId, selectedTopicId: $selectedTopicId, selectedTopicGroupId: $selectedTopicGroupId, selectedTopicGroup: $selectedTopicGroup, fetchStatus: $fetchStatus, fetchTopicsStatus: $fetchTopicsStatus, createTopicTypeStatus: $createTopicTypeStatus, updateTopicTypeStatus: $updateTopicTypeStatus, deleteTopicTypeStatus: $deleteTopicTypeStatus, createTopicStatus: $createTopicStatus, updateTopicStatus: $updateTopicStatus, deleteTopicStatus: $deleteTopicStatus, fetchTopicsByTypeStatus: $fetchTopicsByTypeStatus, fetchTopicGroupsStatus: $fetchTopicGroupsStatus, fetchTopicGroupByIdStatus: $fetchTopicGroupByIdStatus, createTopicGroupStatus: $createTopicGroupStatus, updateTopicGroupStatus: $updateTopicGroupStatus, deleteTopicGroupStatus: $deleteTopicGroupStatus, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopicStateImpl &&
            const DeepCollectionEquality().equals(other._topics, _topics) &&
            const DeepCollectionEquality()
                .equals(other._topicTypes, _topicTypes) &&
            const DeepCollectionEquality()
                .equals(other._topicGroups, _topicGroups) &&
            (identical(other.selectedTopicTypeId, selectedTopicTypeId) ||
                other.selectedTopicTypeId == selectedTopicTypeId) &&
            (identical(other.selectedTopicId, selectedTopicId) ||
                other.selectedTopicId == selectedTopicId) &&
            (identical(other.selectedTopicGroupId, selectedTopicGroupId) ||
                other.selectedTopicGroupId == selectedTopicGroupId) &&
            (identical(other.selectedTopicGroup, selectedTopicGroup) ||
                other.selectedTopicGroup == selectedTopicGroup) &&
            (identical(other.fetchStatus, fetchStatus) ||
                other.fetchStatus == fetchStatus) &&
            (identical(other.fetchTopicsStatus, fetchTopicsStatus) ||
                other.fetchTopicsStatus == fetchTopicsStatus) &&
            (identical(other.createTopicTypeStatus, createTopicTypeStatus) ||
                other.createTopicTypeStatus == createTopicTypeStatus) &&
            (identical(other.updateTopicTypeStatus, updateTopicTypeStatus) ||
                other.updateTopicTypeStatus == updateTopicTypeStatus) &&
            (identical(other.deleteTopicTypeStatus, deleteTopicTypeStatus) ||
                other.deleteTopicTypeStatus == deleteTopicTypeStatus) &&
            (identical(other.createTopicStatus, createTopicStatus) ||
                other.createTopicStatus == createTopicStatus) &&
            (identical(other.updateTopicStatus, updateTopicStatus) ||
                other.updateTopicStatus == updateTopicStatus) &&
            (identical(other.deleteTopicStatus, deleteTopicStatus) ||
                other.deleteTopicStatus == deleteTopicStatus) &&
            (identical(
                    other.fetchTopicsByTypeStatus, fetchTopicsByTypeStatus) ||
                other.fetchTopicsByTypeStatus == fetchTopicsByTypeStatus) &&
            (identical(other.fetchTopicGroupsStatus, fetchTopicGroupsStatus) ||
                other.fetchTopicGroupsStatus == fetchTopicGroupsStatus) &&
            (identical(other.fetchTopicGroupByIdStatus,
                    fetchTopicGroupByIdStatus) ||
                other.fetchTopicGroupByIdStatus == fetchTopicGroupByIdStatus) &&
            (identical(other.createTopicGroupStatus, createTopicGroupStatus) ||
                other.createTopicGroupStatus == createTopicGroupStatus) &&
            (identical(other.updateTopicGroupStatus, updateTopicGroupStatus) ||
                other.updateTopicGroupStatus == updateTopicGroupStatus) &&
            (identical(other.deleteTopicGroupStatus, deleteTopicGroupStatus) ||
                other.deleteTopicGroupStatus == deleteTopicGroupStatus) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(_topics),
        const DeepCollectionEquality().hash(_topicTypes),
        const DeepCollectionEquality().hash(_topicGroups),
        selectedTopicTypeId,
        selectedTopicId,
        selectedTopicGroupId,
        selectedTopicGroup,
        fetchStatus,
        fetchTopicsStatus,
        createTopicTypeStatus,
        updateTopicTypeStatus,
        deleteTopicTypeStatus,
        createTopicStatus,
        updateTopicStatus,
        deleteTopicStatus,
        fetchTopicsByTypeStatus,
        fetchTopicGroupsStatus,
        fetchTopicGroupByIdStatus,
        createTopicGroupStatus,
        updateTopicGroupStatus,
        deleteTopicGroupStatus,
        error
      ]);

  /// Create a copy of TopicState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopicStateImplCopyWith<_$TopicStateImpl> get copyWith =>
      __$$TopicStateImplCopyWithImpl<_$TopicStateImpl>(this, _$identity);
}

abstract class _TopicState extends TopicState {
  const factory _TopicState(
      {final List<Topic> topics,
      final List<TopicType> topicTypes,
      final List<TopicGroup> topicGroups,
      final int? selectedTopicTypeId,
      final int? selectedTopicId,
      final int? selectedTopicGroupId,
      final TopicGroup? selectedTopicGroup,
      required final Status fetchStatus,
      required final Status fetchTopicsStatus,
      required final Status createTopicTypeStatus,
      required final Status updateTopicTypeStatus,
      required final Status deleteTopicTypeStatus,
      required final Status createTopicStatus,
      required final Status updateTopicStatus,
      required final Status deleteTopicStatus,
      required final Status fetchTopicsByTypeStatus,
      required final Status fetchTopicGroupsStatus,
      required final Status fetchTopicGroupByIdStatus,
      required final Status createTopicGroupStatus,
      required final Status updateTopicGroupStatus,
      required final Status deleteTopicGroupStatus,
      final String? error}) = _$TopicStateImpl;
  const _TopicState._() : super._();

  @override
  List<Topic> get topics;
  @override
  List<TopicType> get topicTypes;
  @override
  List<TopicGroup> get topicGroups; // AÑADIR
  @override
  int? get selectedTopicTypeId;
  @override
  int? get selectedTopicId;
  @override
  int? get selectedTopicGroupId; // AÑADIR
  @override
  TopicGroup? get selectedTopicGroup; // AÑADIR (opcional, para fetchById)
  @override
  Status get fetchStatus;
  @override
  Status get fetchTopicsStatus;
  @override
  Status get createTopicTypeStatus;
  @override
  Status get updateTopicTypeStatus;
  @override
  Status get deleteTopicTypeStatus;
  @override
  Status get createTopicStatus;
  @override
  Status get updateTopicStatus;
  @override
  Status get deleteTopicStatus;
  @override
  Status get fetchTopicsByTypeStatus;
  @override
  Status get fetchTopicGroupsStatus; // AÑADIR
  @override
  Status get fetchTopicGroupByIdStatus; // AÑADIR
  @override
  Status get createTopicGroupStatus; // AÑADIR
  @override
  Status get updateTopicGroupStatus; // AÑADIR
  @override
  Status get deleteTopicGroupStatus; // AÑADIR
  @override
  String? get error;

  /// Create a copy of TopicState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopicStateImplCopyWith<_$TopicStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

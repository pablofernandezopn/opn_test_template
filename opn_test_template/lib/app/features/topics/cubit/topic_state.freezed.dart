// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic_state.dart';

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
  List<Category> get categories => throw _privateConstructorUsedError;
  List<TopicGroup> get topicGroups =>
      throw _privateConstructorUsedError; // Mapa: topic_group_id -> topic_type_id (para filtrar grupos por tipo)
  Map<int, int> get topicGroupTypeMap =>
      throw _privateConstructorUsedError; // Mapa: topic_group_id -> cantidad de topics en el grupo
  Map<int, int> get topicGroupCountMap =>
      throw _privateConstructorUsedError; // Set de IDs de topics completados por el usuario
  Set<int> get completedTopicIds =>
      throw _privateConstructorUsedError; // Lista completa de topics completados con ranking
  List<UserCompletedTopic> get completedTopics =>
      throw _privateConstructorUsedError; // Lista de topic groups completados con ranking
  List<UserCompletedTopicGroup> get completedTopicGroups =>
      throw _privateConstructorUsedError;
  int? get selectedTopicTypeId => throw _privateConstructorUsedError;
  int? get selectedTopicId => throw _privateConstructorUsedError;
  Status get fetchTopicTypesStatus => throw _privateConstructorUsedError;
  Status get fetchTopicsStatus => throw _privateConstructorUsedError;
  Status get fetchTopicsByTypeStatus => throw _privateConstructorUsedError;
  Status get fetchCategoriesStatus => throw _privateConstructorUsedError;
  Status get fetchTopicGroupsStatus => throw _privateConstructorUsedError;
  Status get fetchCompletedTopicsStatus => throw _privateConstructorUsedError;
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
      List<Category> categories,
      List<TopicGroup> topicGroups,
      Map<int, int> topicGroupTypeMap,
      Map<int, int> topicGroupCountMap,
      Set<int> completedTopicIds,
      List<UserCompletedTopic> completedTopics,
      List<UserCompletedTopicGroup> completedTopicGroups,
      int? selectedTopicTypeId,
      int? selectedTopicId,
      Status fetchTopicTypesStatus,
      Status fetchTopicsStatus,
      Status fetchTopicsByTypeStatus,
      Status fetchCategoriesStatus,
      Status fetchTopicGroupsStatus,
      Status fetchCompletedTopicsStatus,
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
    Object? categories = null,
    Object? topicGroups = null,
    Object? topicGroupTypeMap = null,
    Object? topicGroupCountMap = null,
    Object? completedTopicIds = null,
    Object? completedTopics = null,
    Object? completedTopicGroups = null,
    Object? selectedTopicTypeId = freezed,
    Object? selectedTopicId = freezed,
    Object? fetchTopicTypesStatus = null,
    Object? fetchTopicsStatus = null,
    Object? fetchTopicsByTypeStatus = null,
    Object? fetchCategoriesStatus = null,
    Object? fetchTopicGroupsStatus = null,
    Object? fetchCompletedTopicsStatus = null,
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
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<Category>,
      topicGroups: null == topicGroups
          ? _value.topicGroups
          : topicGroups // ignore: cast_nullable_to_non_nullable
              as List<TopicGroup>,
      topicGroupTypeMap: null == topicGroupTypeMap
          ? _value.topicGroupTypeMap
          : topicGroupTypeMap // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      topicGroupCountMap: null == topicGroupCountMap
          ? _value.topicGroupCountMap
          : topicGroupCountMap // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      completedTopicIds: null == completedTopicIds
          ? _value.completedTopicIds
          : completedTopicIds // ignore: cast_nullable_to_non_nullable
              as Set<int>,
      completedTopics: null == completedTopics
          ? _value.completedTopics
          : completedTopics // ignore: cast_nullable_to_non_nullable
              as List<UserCompletedTopic>,
      completedTopicGroups: null == completedTopicGroups
          ? _value.completedTopicGroups
          : completedTopicGroups // ignore: cast_nullable_to_non_nullable
              as List<UserCompletedTopicGroup>,
      selectedTopicTypeId: freezed == selectedTopicTypeId
          ? _value.selectedTopicTypeId
          : selectedTopicTypeId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedTopicId: freezed == selectedTopicId
          ? _value.selectedTopicId
          : selectedTopicId // ignore: cast_nullable_to_non_nullable
              as int?,
      fetchTopicTypesStatus: null == fetchTopicTypesStatus
          ? _value.fetchTopicTypesStatus
          : fetchTopicTypesStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicsStatus: null == fetchTopicsStatus
          ? _value.fetchTopicsStatus
          : fetchTopicsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicsByTypeStatus: null == fetchTopicsByTypeStatus
          ? _value.fetchTopicsByTypeStatus
          : fetchTopicsByTypeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchCategoriesStatus: null == fetchCategoriesStatus
          ? _value.fetchCategoriesStatus
          : fetchCategoriesStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicGroupsStatus: null == fetchTopicGroupsStatus
          ? _value.fetchTopicGroupsStatus
          : fetchTopicGroupsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchCompletedTopicsStatus: null == fetchCompletedTopicsStatus
          ? _value.fetchCompletedTopicsStatus
          : fetchCompletedTopicsStatus // ignore: cast_nullable_to_non_nullable
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
      List<Category> categories,
      List<TopicGroup> topicGroups,
      Map<int, int> topicGroupTypeMap,
      Map<int, int> topicGroupCountMap,
      Set<int> completedTopicIds,
      List<UserCompletedTopic> completedTopics,
      List<UserCompletedTopicGroup> completedTopicGroups,
      int? selectedTopicTypeId,
      int? selectedTopicId,
      Status fetchTopicTypesStatus,
      Status fetchTopicsStatus,
      Status fetchTopicsByTypeStatus,
      Status fetchCategoriesStatus,
      Status fetchTopicGroupsStatus,
      Status fetchCompletedTopicsStatus,
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
    Object? categories = null,
    Object? topicGroups = null,
    Object? topicGroupTypeMap = null,
    Object? topicGroupCountMap = null,
    Object? completedTopicIds = null,
    Object? completedTopics = null,
    Object? completedTopicGroups = null,
    Object? selectedTopicTypeId = freezed,
    Object? selectedTopicId = freezed,
    Object? fetchTopicTypesStatus = null,
    Object? fetchTopicsStatus = null,
    Object? fetchTopicsByTypeStatus = null,
    Object? fetchCategoriesStatus = null,
    Object? fetchTopicGroupsStatus = null,
    Object? fetchCompletedTopicsStatus = null,
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
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<Category>,
      topicGroups: null == topicGroups
          ? _value._topicGroups
          : topicGroups // ignore: cast_nullable_to_non_nullable
              as List<TopicGroup>,
      topicGroupTypeMap: null == topicGroupTypeMap
          ? _value._topicGroupTypeMap
          : topicGroupTypeMap // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      topicGroupCountMap: null == topicGroupCountMap
          ? _value._topicGroupCountMap
          : topicGroupCountMap // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      completedTopicIds: null == completedTopicIds
          ? _value._completedTopicIds
          : completedTopicIds // ignore: cast_nullable_to_non_nullable
              as Set<int>,
      completedTopics: null == completedTopics
          ? _value._completedTopics
          : completedTopics // ignore: cast_nullable_to_non_nullable
              as List<UserCompletedTopic>,
      completedTopicGroups: null == completedTopicGroups
          ? _value._completedTopicGroups
          : completedTopicGroups // ignore: cast_nullable_to_non_nullable
              as List<UserCompletedTopicGroup>,
      selectedTopicTypeId: freezed == selectedTopicTypeId
          ? _value.selectedTopicTypeId
          : selectedTopicTypeId // ignore: cast_nullable_to_non_nullable
              as int?,
      selectedTopicId: freezed == selectedTopicId
          ? _value.selectedTopicId
          : selectedTopicId // ignore: cast_nullable_to_non_nullable
              as int?,
      fetchTopicTypesStatus: null == fetchTopicTypesStatus
          ? _value.fetchTopicTypesStatus
          : fetchTopicTypesStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicsStatus: null == fetchTopicsStatus
          ? _value.fetchTopicsStatus
          : fetchTopicsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicsByTypeStatus: null == fetchTopicsByTypeStatus
          ? _value.fetchTopicsByTypeStatus
          : fetchTopicsByTypeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchCategoriesStatus: null == fetchCategoriesStatus
          ? _value.fetchCategoriesStatus
          : fetchCategoriesStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchTopicGroupsStatus: null == fetchTopicGroupsStatus
          ? _value.fetchTopicGroupsStatus
          : fetchTopicGroupsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchCompletedTopicsStatus: null == fetchCompletedTopicsStatus
          ? _value.fetchCompletedTopicsStatus
          : fetchCompletedTopicsStatus // ignore: cast_nullable_to_non_nullable
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
      final List<Category> categories = const [],
      final List<TopicGroup> topicGroups = const [],
      final Map<int, int> topicGroupTypeMap = const {},
      final Map<int, int> topicGroupCountMap = const {},
      final Set<int> completedTopicIds = const {},
      final List<UserCompletedTopic> completedTopics = const [],
      final List<UserCompletedTopicGroup> completedTopicGroups = const [],
      this.selectedTopicTypeId,
      this.selectedTopicId,
      required this.fetchTopicTypesStatus,
      required this.fetchTopicsStatus,
      required this.fetchTopicsByTypeStatus,
      required this.fetchCategoriesStatus,
      required this.fetchTopicGroupsStatus,
      required this.fetchCompletedTopicsStatus,
      this.error})
      : _topics = topics,
        _topicTypes = topicTypes,
        _categories = categories,
        _topicGroups = topicGroups,
        _topicGroupTypeMap = topicGroupTypeMap,
        _topicGroupCountMap = topicGroupCountMap,
        _completedTopicIds = completedTopicIds,
        _completedTopics = completedTopics,
        _completedTopicGroups = completedTopicGroups,
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

  final List<Category> _categories;
  @override
  @JsonKey()
  List<Category> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<TopicGroup> _topicGroups;
  @override
  @JsonKey()
  List<TopicGroup> get topicGroups {
    if (_topicGroups is EqualUnmodifiableListView) return _topicGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_topicGroups);
  }

// Mapa: topic_group_id -> topic_type_id (para filtrar grupos por tipo)
  final Map<int, int> _topicGroupTypeMap;
// Mapa: topic_group_id -> topic_type_id (para filtrar grupos por tipo)
  @override
  @JsonKey()
  Map<int, int> get topicGroupTypeMap {
    if (_topicGroupTypeMap is EqualUnmodifiableMapView)
      return _topicGroupTypeMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_topicGroupTypeMap);
  }

// Mapa: topic_group_id -> cantidad de topics en el grupo
  final Map<int, int> _topicGroupCountMap;
// Mapa: topic_group_id -> cantidad de topics en el grupo
  @override
  @JsonKey()
  Map<int, int> get topicGroupCountMap {
    if (_topicGroupCountMap is EqualUnmodifiableMapView)
      return _topicGroupCountMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_topicGroupCountMap);
  }

// Set de IDs de topics completados por el usuario
  final Set<int> _completedTopicIds;
// Set de IDs de topics completados por el usuario
  @override
  @JsonKey()
  Set<int> get completedTopicIds {
    if (_completedTopicIds is EqualUnmodifiableSetView)
      return _completedTopicIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_completedTopicIds);
  }

// Lista completa de topics completados con ranking
  final List<UserCompletedTopic> _completedTopics;
// Lista completa de topics completados con ranking
  @override
  @JsonKey()
  List<UserCompletedTopic> get completedTopics {
    if (_completedTopics is EqualUnmodifiableListView) return _completedTopics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedTopics);
  }

// Lista de topic groups completados con ranking
  final List<UserCompletedTopicGroup> _completedTopicGroups;
// Lista de topic groups completados con ranking
  @override
  @JsonKey()
  List<UserCompletedTopicGroup> get completedTopicGroups {
    if (_completedTopicGroups is EqualUnmodifiableListView)
      return _completedTopicGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedTopicGroups);
  }

  @override
  final int? selectedTopicTypeId;
  @override
  final int? selectedTopicId;
  @override
  final Status fetchTopicTypesStatus;
  @override
  final Status fetchTopicsStatus;
  @override
  final Status fetchTopicsByTypeStatus;
  @override
  final Status fetchCategoriesStatus;
  @override
  final Status fetchTopicGroupsStatus;
  @override
  final Status fetchCompletedTopicsStatus;
  @override
  final String? error;

  @override
  String toString() {
    return 'TopicState(topics: $topics, topicTypes: $topicTypes, categories: $categories, topicGroups: $topicGroups, topicGroupTypeMap: $topicGroupTypeMap, topicGroupCountMap: $topicGroupCountMap, completedTopicIds: $completedTopicIds, completedTopics: $completedTopics, completedTopicGroups: $completedTopicGroups, selectedTopicTypeId: $selectedTopicTypeId, selectedTopicId: $selectedTopicId, fetchTopicTypesStatus: $fetchTopicTypesStatus, fetchTopicsStatus: $fetchTopicsStatus, fetchTopicsByTypeStatus: $fetchTopicsByTypeStatus, fetchCategoriesStatus: $fetchCategoriesStatus, fetchTopicGroupsStatus: $fetchTopicGroupsStatus, fetchCompletedTopicsStatus: $fetchCompletedTopicsStatus, error: $error)';
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
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality()
                .equals(other._topicGroups, _topicGroups) &&
            const DeepCollectionEquality()
                .equals(other._topicGroupTypeMap, _topicGroupTypeMap) &&
            const DeepCollectionEquality()
                .equals(other._topicGroupCountMap, _topicGroupCountMap) &&
            const DeepCollectionEquality()
                .equals(other._completedTopicIds, _completedTopicIds) &&
            const DeepCollectionEquality()
                .equals(other._completedTopics, _completedTopics) &&
            const DeepCollectionEquality()
                .equals(other._completedTopicGroups, _completedTopicGroups) &&
            (identical(other.selectedTopicTypeId, selectedTopicTypeId) ||
                other.selectedTopicTypeId == selectedTopicTypeId) &&
            (identical(other.selectedTopicId, selectedTopicId) ||
                other.selectedTopicId == selectedTopicId) &&
            (identical(other.fetchTopicTypesStatus, fetchTopicTypesStatus) ||
                other.fetchTopicTypesStatus == fetchTopicTypesStatus) &&
            (identical(other.fetchTopicsStatus, fetchTopicsStatus) ||
                other.fetchTopicsStatus == fetchTopicsStatus) &&
            (identical(
                    other.fetchTopicsByTypeStatus, fetchTopicsByTypeStatus) ||
                other.fetchTopicsByTypeStatus == fetchTopicsByTypeStatus) &&
            (identical(other.fetchCategoriesStatus, fetchCategoriesStatus) ||
                other.fetchCategoriesStatus == fetchCategoriesStatus) &&
            (identical(other.fetchTopicGroupsStatus, fetchTopicGroupsStatus) ||
                other.fetchTopicGroupsStatus == fetchTopicGroupsStatus) &&
            (identical(other.fetchCompletedTopicsStatus,
                    fetchCompletedTopicsStatus) ||
                other.fetchCompletedTopicsStatus ==
                    fetchCompletedTopicsStatus) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_topics),
      const DeepCollectionEquality().hash(_topicTypes),
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_topicGroups),
      const DeepCollectionEquality().hash(_topicGroupTypeMap),
      const DeepCollectionEquality().hash(_topicGroupCountMap),
      const DeepCollectionEquality().hash(_completedTopicIds),
      const DeepCollectionEquality().hash(_completedTopics),
      const DeepCollectionEquality().hash(_completedTopicGroups),
      selectedTopicTypeId,
      selectedTopicId,
      fetchTopicTypesStatus,
      fetchTopicsStatus,
      fetchTopicsByTypeStatus,
      fetchCategoriesStatus,
      fetchTopicGroupsStatus,
      fetchCompletedTopicsStatus,
      error);

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
      final List<Category> categories,
      final List<TopicGroup> topicGroups,
      final Map<int, int> topicGroupTypeMap,
      final Map<int, int> topicGroupCountMap,
      final Set<int> completedTopicIds,
      final List<UserCompletedTopic> completedTopics,
      final List<UserCompletedTopicGroup> completedTopicGroups,
      final int? selectedTopicTypeId,
      final int? selectedTopicId,
      required final Status fetchTopicTypesStatus,
      required final Status fetchTopicsStatus,
      required final Status fetchTopicsByTypeStatus,
      required final Status fetchCategoriesStatus,
      required final Status fetchTopicGroupsStatus,
      required final Status fetchCompletedTopicsStatus,
      final String? error}) = _$TopicStateImpl;
  const _TopicState._() : super._();

  @override
  List<Topic> get topics;
  @override
  List<TopicType> get topicTypes;
  @override
  List<Category> get categories;
  @override
  List<TopicGroup>
      get topicGroups; // Mapa: topic_group_id -> topic_type_id (para filtrar grupos por tipo)
  @override
  Map<int, int>
      get topicGroupTypeMap; // Mapa: topic_group_id -> cantidad de topics en el grupo
  @override
  Map<int, int>
      get topicGroupCountMap; // Set de IDs de topics completados por el usuario
  @override
  Set<int>
      get completedTopicIds; // Lista completa de topics completados con ranking
  @override
  List<UserCompletedTopic>
      get completedTopics; // Lista de topic groups completados con ranking
  @override
  List<UserCompletedTopicGroup> get completedTopicGroups;
  @override
  int? get selectedTopicTypeId;
  @override
  int? get selectedTopicId;
  @override
  Status get fetchTopicTypesStatus;
  @override
  Status get fetchTopicsStatus;
  @override
  Status get fetchTopicsByTypeStatus;
  @override
  Status get fetchCategoriesStatus;
  @override
  Status get fetchTopicGroupsStatus;
  @override
  Status get fetchCompletedTopicsStatus;
  @override
  String? get error;

  /// Create a copy of TopicState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopicStateImplCopyWith<_$TopicStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

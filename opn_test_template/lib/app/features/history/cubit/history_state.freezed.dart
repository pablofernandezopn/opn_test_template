// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HistoryState {
  List<UserTest> get tests => throw _privateConstructorUsedError;
  List<UserTest> get recentTests =>
      throw _privateConstructorUsedError; // Los 3 más recientes para home
  Status get fetchHistoryStatus => throw _privateConstructorUsedError;
  Status get fetchRecentTestsStatus => throw _privateConstructorUsedError;
  Status get loadMoreStatus => throw _privateConstructorUsedError;
  int? get selectedTopicTypeFilter =>
      throw _privateConstructorUsedError; // Filtro por tipo de topic
  int get currentPage => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryStateCopyWith<HistoryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryStateCopyWith<$Res> {
  factory $HistoryStateCopyWith(
          HistoryState value, $Res Function(HistoryState) then) =
      _$HistoryStateCopyWithImpl<$Res, HistoryState>;
  @useResult
  $Res call(
      {List<UserTest> tests,
      List<UserTest> recentTests,
      Status fetchHistoryStatus,
      Status fetchRecentTestsStatus,
      Status loadMoreStatus,
      int? selectedTopicTypeFilter,
      int currentPage,
      int pageSize,
      bool hasMore,
      String? error});
}

/// @nodoc
class _$HistoryStateCopyWithImpl<$Res, $Val extends HistoryState>
    implements $HistoryStateCopyWith<$Res> {
  _$HistoryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tests = null,
    Object? recentTests = null,
    Object? fetchHistoryStatus = null,
    Object? fetchRecentTestsStatus = null,
    Object? loadMoreStatus = null,
    Object? selectedTopicTypeFilter = freezed,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? hasMore = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      tests: null == tests
          ? _value.tests
          : tests // ignore: cast_nullable_to_non_nullable
              as List<UserTest>,
      recentTests: null == recentTests
          ? _value.recentTests
          : recentTests // ignore: cast_nullable_to_non_nullable
              as List<UserTest>,
      fetchHistoryStatus: null == fetchHistoryStatus
          ? _value.fetchHistoryStatus
          : fetchHistoryStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchRecentTestsStatus: null == fetchRecentTestsStatus
          ? _value.fetchRecentTestsStatus
          : fetchRecentTestsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      loadMoreStatus: null == loadMoreStatus
          ? _value.loadMoreStatus
          : loadMoreStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      selectedTopicTypeFilter: freezed == selectedTopicTypeFilter
          ? _value.selectedTopicTypeFilter
          : selectedTopicTypeFilter // ignore: cast_nullable_to_non_nullable
              as int?,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoryStateImplCopyWith<$Res>
    implements $HistoryStateCopyWith<$Res> {
  factory _$$HistoryStateImplCopyWith(
          _$HistoryStateImpl value, $Res Function(_$HistoryStateImpl) then) =
      __$$HistoryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<UserTest> tests,
      List<UserTest> recentTests,
      Status fetchHistoryStatus,
      Status fetchRecentTestsStatus,
      Status loadMoreStatus,
      int? selectedTopicTypeFilter,
      int currentPage,
      int pageSize,
      bool hasMore,
      String? error});
}

/// @nodoc
class __$$HistoryStateImplCopyWithImpl<$Res>
    extends _$HistoryStateCopyWithImpl<$Res, _$HistoryStateImpl>
    implements _$$HistoryStateImplCopyWith<$Res> {
  __$$HistoryStateImplCopyWithImpl(
      _$HistoryStateImpl _value, $Res Function(_$HistoryStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tests = null,
    Object? recentTests = null,
    Object? fetchHistoryStatus = null,
    Object? fetchRecentTestsStatus = null,
    Object? loadMoreStatus = null,
    Object? selectedTopicTypeFilter = freezed,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? hasMore = null,
    Object? error = freezed,
  }) {
    return _then(_$HistoryStateImpl(
      tests: null == tests
          ? _value._tests
          : tests // ignore: cast_nullable_to_non_nullable
              as List<UserTest>,
      recentTests: null == recentTests
          ? _value._recentTests
          : recentTests // ignore: cast_nullable_to_non_nullable
              as List<UserTest>,
      fetchHistoryStatus: null == fetchHistoryStatus
          ? _value.fetchHistoryStatus
          : fetchHistoryStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      fetchRecentTestsStatus: null == fetchRecentTestsStatus
          ? _value.fetchRecentTestsStatus
          : fetchRecentTestsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      loadMoreStatus: null == loadMoreStatus
          ? _value.loadMoreStatus
          : loadMoreStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      selectedTopicTypeFilter: freezed == selectedTopicTypeFilter
          ? _value.selectedTopicTypeFilter
          : selectedTopicTypeFilter // ignore: cast_nullable_to_non_nullable
              as int?,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      pageSize: null == pageSize
          ? _value.pageSize
          : pageSize // ignore: cast_nullable_to_non_nullable
              as int,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$HistoryStateImpl extends _HistoryState {
  const _$HistoryStateImpl(
      {final List<UserTest> tests = const [],
      final List<UserTest> recentTests = const [],
      required this.fetchHistoryStatus,
      required this.fetchRecentTestsStatus,
      required this.loadMoreStatus,
      this.selectedTopicTypeFilter,
      this.currentPage = 0,
      this.pageSize = 20,
      this.hasMore = false,
      this.error})
      : _tests = tests,
        _recentTests = recentTests,
        super._();

  final List<UserTest> _tests;
  @override
  @JsonKey()
  List<UserTest> get tests {
    if (_tests is EqualUnmodifiableListView) return _tests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tests);
  }

  final List<UserTest> _recentTests;
  @override
  @JsonKey()
  List<UserTest> get recentTests {
    if (_recentTests is EqualUnmodifiableListView) return _recentTests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentTests);
  }

// Los 3 más recientes para home
  @override
  final Status fetchHistoryStatus;
  @override
  final Status fetchRecentTestsStatus;
  @override
  final Status loadMoreStatus;
  @override
  final int? selectedTopicTypeFilter;
// Filtro por tipo de topic
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int pageSize;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  final String? error;

  @override
  String toString() {
    return 'HistoryState(tests: $tests, recentTests: $recentTests, fetchHistoryStatus: $fetchHistoryStatus, fetchRecentTestsStatus: $fetchRecentTestsStatus, loadMoreStatus: $loadMoreStatus, selectedTopicTypeFilter: $selectedTopicTypeFilter, currentPage: $currentPage, pageSize: $pageSize, hasMore: $hasMore, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryStateImpl &&
            const DeepCollectionEquality().equals(other._tests, _tests) &&
            const DeepCollectionEquality()
                .equals(other._recentTests, _recentTests) &&
            (identical(other.fetchHistoryStatus, fetchHistoryStatus) ||
                other.fetchHistoryStatus == fetchHistoryStatus) &&
            (identical(other.fetchRecentTestsStatus, fetchRecentTestsStatus) ||
                other.fetchRecentTestsStatus == fetchRecentTestsStatus) &&
            (identical(other.loadMoreStatus, loadMoreStatus) ||
                other.loadMoreStatus == loadMoreStatus) &&
            (identical(
                    other.selectedTopicTypeFilter, selectedTopicTypeFilter) ||
                other.selectedTopicTypeFilter == selectedTopicTypeFilter) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_tests),
      const DeepCollectionEquality().hash(_recentTests),
      fetchHistoryStatus,
      fetchRecentTestsStatus,
      loadMoreStatus,
      selectedTopicTypeFilter,
      currentPage,
      pageSize,
      hasMore,
      error);

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryStateImplCopyWith<_$HistoryStateImpl> get copyWith =>
      __$$HistoryStateImplCopyWithImpl<_$HistoryStateImpl>(this, _$identity);
}

abstract class _HistoryState extends HistoryState {
  const factory _HistoryState(
      {final List<UserTest> tests,
      final List<UserTest> recentTests,
      required final Status fetchHistoryStatus,
      required final Status fetchRecentTestsStatus,
      required final Status loadMoreStatus,
      final int? selectedTopicTypeFilter,
      final int currentPage,
      final int pageSize,
      final bool hasMore,
      final String? error}) = _$HistoryStateImpl;
  const _HistoryState._() : super._();

  @override
  List<UserTest> get tests;
  @override
  List<UserTest> get recentTests; // Los 3 más recientes para home
  @override
  Status get fetchHistoryStatus;
  @override
  Status get fetchRecentTestsStatus;
  @override
  Status get loadMoreStatus;
  @override
  int? get selectedTopicTypeFilter; // Filtro por tipo de topic
  @override
  int get currentPage;
  @override
  int get pageSize;
  @override
  bool get hasMore;
  @override
  String? get error;

  /// Create a copy of HistoryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryStateImplCopyWith<_$HistoryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

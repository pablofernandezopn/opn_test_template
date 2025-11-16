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
mixin _$ChallengeState {
  /// Lista de impugnaciones cargadas
  List<Challenge> get challenges => throw _privateConstructorUsedError;

  /// Impugnaciones pendientes (filtrado rápido)
  List<Challenge> get pendingChallenges => throw _privateConstructorUsedError;

  /// Impugnación seleccionada en la tabla
  Challenge? get selectedChallenge => throw _privateConstructorUsedError;

  /// Filtro actual de estado
  ChallengeStatus? get statusFilter => throw _privateConstructorUsedError;

  /// Filtro de academia
  int? get academyFilter => throw _privateConstructorUsedError;

  /// Término de búsqueda
  String get searchQuery => throw _privateConstructorUsedError;

  /// Estadísticas por estado
  Map<String, int> get stats => throw _privateConstructorUsedError;

  /// Estado de la carga inicial de impugnaciones
  Status get fetchStatus => throw _privateConstructorUsedError;

  /// Estado de la creación de impugnación
  Status get createStatus => throw _privateConstructorUsedError;

  /// Estado de la actualización de impugnación
  Status get updateStatus => throw _privateConstructorUsedError;

  /// Estado de la eliminación de impugnación
  Status get deleteStatus => throw _privateConstructorUsedError;

  /// Estado del cambio de estado (aprobar/rechazar)
  Status get statusChangeStatus => throw _privateConstructorUsedError;

  /// Estado de la carga de estadísticas
  Status get statsStatus => throw _privateConstructorUsedError;

  /// Mensaje de error general
  String? get error =>
      throw _privateConstructorUsedError; // ============================================
// Campos para paginación
// ============================================
  /// Página actual (para paginación)
  int get currentPage => throw _privateConstructorUsedError;

  /// Tamaño de página
  int get pageSize => throw _privateConstructorUsedError;

  /// Indica si hay más datos para cargar
  bool get hasMore => throw _privateConstructorUsedError;

  /// Indica si se está cargando más datos
  bool get isLoadingMore => throw _privateConstructorUsedError;

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
      List<Challenge> pendingChallenges,
      Challenge? selectedChallenge,
      ChallengeStatus? statusFilter,
      int? academyFilter,
      String searchQuery,
      Map<String, int> stats,
      Status fetchStatus,
      Status createStatus,
      Status updateStatus,
      Status deleteStatus,
      Status statusChangeStatus,
      Status statsStatus,
      String? error,
      int currentPage,
      int pageSize,
      bool hasMore,
      bool isLoadingMore});
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
    Object? pendingChallenges = null,
    Object? selectedChallenge = freezed,
    Object? statusFilter = freezed,
    Object? academyFilter = freezed,
    Object? searchQuery = null,
    Object? stats = null,
    Object? fetchStatus = null,
    Object? createStatus = null,
    Object? updateStatus = null,
    Object? deleteStatus = null,
    Object? statusChangeStatus = null,
    Object? statsStatus = null,
    Object? error = freezed,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? hasMore = null,
    Object? isLoadingMore = null,
  }) {
    return _then(_value.copyWith(
      challenges: null == challenges
          ? _value.challenges
          : challenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      pendingChallenges: null == pendingChallenges
          ? _value.pendingChallenges
          : pendingChallenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      selectedChallenge: freezed == selectedChallenge
          ? _value.selectedChallenge
          : selectedChallenge // ignore: cast_nullable_to_non_nullable
              as Challenge?,
      statusFilter: freezed == statusFilter
          ? _value.statusFilter
          : statusFilter // ignore: cast_nullable_to_non_nullable
              as ChallengeStatus?,
      academyFilter: freezed == academyFilter
          ? _value.academyFilter
          : academyFilter // ignore: cast_nullable_to_non_nullable
              as int?,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      fetchStatus: null == fetchStatus
          ? _value.fetchStatus
          : fetchStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createStatus: null == createStatus
          ? _value.createStatus
          : createStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateStatus: null == updateStatus
          ? _value.updateStatus
          : updateStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteStatus: null == deleteStatus
          ? _value.deleteStatus
          : deleteStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      statusChangeStatus: null == statusChangeStatus
          ? _value.statusChangeStatus
          : statusChangeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      statsStatus: null == statsStatus
          ? _value.statsStatus
          : statsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
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
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
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
      List<Challenge> pendingChallenges,
      Challenge? selectedChallenge,
      ChallengeStatus? statusFilter,
      int? academyFilter,
      String searchQuery,
      Map<String, int> stats,
      Status fetchStatus,
      Status createStatus,
      Status updateStatus,
      Status deleteStatus,
      Status statusChangeStatus,
      Status statsStatus,
      String? error,
      int currentPage,
      int pageSize,
      bool hasMore,
      bool isLoadingMore});
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
    Object? pendingChallenges = null,
    Object? selectedChallenge = freezed,
    Object? statusFilter = freezed,
    Object? academyFilter = freezed,
    Object? searchQuery = null,
    Object? stats = null,
    Object? fetchStatus = null,
    Object? createStatus = null,
    Object? updateStatus = null,
    Object? deleteStatus = null,
    Object? statusChangeStatus = null,
    Object? statsStatus = null,
    Object? error = freezed,
    Object? currentPage = null,
    Object? pageSize = null,
    Object? hasMore = null,
    Object? isLoadingMore = null,
  }) {
    return _then(_$ChallengeStateImpl(
      challenges: null == challenges
          ? _value._challenges
          : challenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      pendingChallenges: null == pendingChallenges
          ? _value._pendingChallenges
          : pendingChallenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      selectedChallenge: freezed == selectedChallenge
          ? _value.selectedChallenge
          : selectedChallenge // ignore: cast_nullable_to_non_nullable
              as Challenge?,
      statusFilter: freezed == statusFilter
          ? _value.statusFilter
          : statusFilter // ignore: cast_nullable_to_non_nullable
              as ChallengeStatus?,
      academyFilter: freezed == academyFilter
          ? _value.academyFilter
          : academyFilter // ignore: cast_nullable_to_non_nullable
              as int?,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      stats: null == stats
          ? _value._stats
          : stats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      fetchStatus: null == fetchStatus
          ? _value.fetchStatus
          : fetchStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createStatus: null == createStatus
          ? _value.createStatus
          : createStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateStatus: null == updateStatus
          ? _value.updateStatus
          : updateStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteStatus: null == deleteStatus
          ? _value.deleteStatus
          : deleteStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      statusChangeStatus: null == statusChangeStatus
          ? _value.statusChangeStatus
          : statusChangeStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      statsStatus: null == statsStatus
          ? _value.statsStatus
          : statsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
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
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ChallengeStateImpl extends _ChallengeState {
  const _$ChallengeStateImpl(
      {final List<Challenge> challenges = const [],
      final List<Challenge> pendingChallenges = const [],
      this.selectedChallenge,
      this.statusFilter,
      this.academyFilter,
      this.searchQuery = '',
      final Map<String, int> stats = const {},
      required this.fetchStatus,
      required this.createStatus,
      required this.updateStatus,
      required this.deleteStatus,
      required this.statusChangeStatus,
      required this.statsStatus,
      this.error,
      this.currentPage = 0,
      this.pageSize = 20,
      this.hasMore = true,
      this.isLoadingMore = false})
      : _challenges = challenges,
        _pendingChallenges = pendingChallenges,
        _stats = stats,
        super._();

  /// Lista de impugnaciones cargadas
  final List<Challenge> _challenges;

  /// Lista de impugnaciones cargadas
  @override
  @JsonKey()
  List<Challenge> get challenges {
    if (_challenges is EqualUnmodifiableListView) return _challenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_challenges);
  }

  /// Impugnaciones pendientes (filtrado rápido)
  final List<Challenge> _pendingChallenges;

  /// Impugnaciones pendientes (filtrado rápido)
  @override
  @JsonKey()
  List<Challenge> get pendingChallenges {
    if (_pendingChallenges is EqualUnmodifiableListView)
      return _pendingChallenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingChallenges);
  }

  /// Impugnación seleccionada en la tabla
  @override
  final Challenge? selectedChallenge;

  /// Filtro actual de estado
  @override
  final ChallengeStatus? statusFilter;

  /// Filtro de academia
  @override
  final int? academyFilter;

  /// Término de búsqueda
  @override
  @JsonKey()
  final String searchQuery;

  /// Estadísticas por estado
  final Map<String, int> _stats;

  /// Estadísticas por estado
  @override
  @JsonKey()
  Map<String, int> get stats {
    if (_stats is EqualUnmodifiableMapView) return _stats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stats);
  }

  /// Estado de la carga inicial de impugnaciones
  @override
  final Status fetchStatus;

  /// Estado de la creación de impugnación
  @override
  final Status createStatus;

  /// Estado de la actualización de impugnación
  @override
  final Status updateStatus;

  /// Estado de la eliminación de impugnación
  @override
  final Status deleteStatus;

  /// Estado del cambio de estado (aprobar/rechazar)
  @override
  final Status statusChangeStatus;

  /// Estado de la carga de estadísticas
  @override
  final Status statsStatus;

  /// Mensaje de error general
  @override
  final String? error;
// ============================================
// Campos para paginación
// ============================================
  /// Página actual (para paginación)
  @override
  @JsonKey()
  final int currentPage;

  /// Tamaño de página
  @override
  @JsonKey()
  final int pageSize;

  /// Indica si hay más datos para cargar
  @override
  @JsonKey()
  final bool hasMore;

  /// Indica si se está cargando más datos
  @override
  @JsonKey()
  final bool isLoadingMore;

  @override
  String toString() {
    return 'ChallengeState(challenges: $challenges, pendingChallenges: $pendingChallenges, selectedChallenge: $selectedChallenge, statusFilter: $statusFilter, academyFilter: $academyFilter, searchQuery: $searchQuery, stats: $stats, fetchStatus: $fetchStatus, createStatus: $createStatus, updateStatus: $updateStatus, deleteStatus: $deleteStatus, statusChangeStatus: $statusChangeStatus, statsStatus: $statsStatus, error: $error, currentPage: $currentPage, pageSize: $pageSize, hasMore: $hasMore, isLoadingMore: $isLoadingMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeStateImpl &&
            const DeepCollectionEquality()
                .equals(other._challenges, _challenges) &&
            const DeepCollectionEquality()
                .equals(other._pendingChallenges, _pendingChallenges) &&
            (identical(other.selectedChallenge, selectedChallenge) ||
                other.selectedChallenge == selectedChallenge) &&
            (identical(other.statusFilter, statusFilter) ||
                other.statusFilter == statusFilter) &&
            (identical(other.academyFilter, academyFilter) ||
                other.academyFilter == academyFilter) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            const DeepCollectionEquality().equals(other._stats, _stats) &&
            (identical(other.fetchStatus, fetchStatus) ||
                other.fetchStatus == fetchStatus) &&
            (identical(other.createStatus, createStatus) ||
                other.createStatus == createStatus) &&
            (identical(other.updateStatus, updateStatus) ||
                other.updateStatus == updateStatus) &&
            (identical(other.deleteStatus, deleteStatus) ||
                other.deleteStatus == deleteStatus) &&
            (identical(other.statusChangeStatus, statusChangeStatus) ||
                other.statusChangeStatus == statusChangeStatus) &&
            (identical(other.statsStatus, statsStatus) ||
                other.statsStatus == statsStatus) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_challenges),
      const DeepCollectionEquality().hash(_pendingChallenges),
      selectedChallenge,
      statusFilter,
      academyFilter,
      searchQuery,
      const DeepCollectionEquality().hash(_stats),
      fetchStatus,
      createStatus,
      updateStatus,
      deleteStatus,
      statusChangeStatus,
      statsStatus,
      error,
      currentPage,
      pageSize,
      hasMore,
      isLoadingMore);

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
      final List<Challenge> pendingChallenges,
      final Challenge? selectedChallenge,
      final ChallengeStatus? statusFilter,
      final int? academyFilter,
      final String searchQuery,
      final Map<String, int> stats,
      required final Status fetchStatus,
      required final Status createStatus,
      required final Status updateStatus,
      required final Status deleteStatus,
      required final Status statusChangeStatus,
      required final Status statsStatus,
      final String? error,
      final int currentPage,
      final int pageSize,
      final bool hasMore,
      final bool isLoadingMore}) = _$ChallengeStateImpl;
  const _ChallengeState._() : super._();

  /// Lista de impugnaciones cargadas
  @override
  List<Challenge> get challenges;

  /// Impugnaciones pendientes (filtrado rápido)
  @override
  List<Challenge> get pendingChallenges;

  /// Impugnación seleccionada en la tabla
  @override
  Challenge? get selectedChallenge;

  /// Filtro actual de estado
  @override
  ChallengeStatus? get statusFilter;

  /// Filtro de academia
  @override
  int? get academyFilter;

  /// Término de búsqueda
  @override
  String get searchQuery;

  /// Estadísticas por estado
  @override
  Map<String, int> get stats;

  /// Estado de la carga inicial de impugnaciones
  @override
  Status get fetchStatus;

  /// Estado de la creación de impugnación
  @override
  Status get createStatus;

  /// Estado de la actualización de impugnación
  @override
  Status get updateStatus;

  /// Estado de la eliminación de impugnación
  @override
  Status get deleteStatus;

  /// Estado del cambio de estado (aprobar/rechazar)
  @override
  Status get statusChangeStatus;

  /// Estado de la carga de estadísticas
  @override
  Status get statsStatus;

  /// Mensaje de error general
  @override
  String? get error; // ============================================
// Campos para paginación
// ============================================
  /// Página actual (para paginación)
  @override
  int get currentPage;

  /// Tamaño de página
  @override
  int get pageSize;

  /// Indica si hay más datos para cargar
  @override
  bool get hasMore;

  /// Indica si se está cargando más datos
  @override
  bool get isLoadingMore;

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeStateImplCopyWith<_$ChallengeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

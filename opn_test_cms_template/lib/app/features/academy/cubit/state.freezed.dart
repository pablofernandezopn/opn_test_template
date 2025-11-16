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
mixin _$AcademyState {
  /// Lista de academias cargadas
  List<Academy> get academies => throw _privateConstructorUsedError;

  /// Academia del usuario autenticado (se carga al inicio de la sesión)
  Academy? get myAcademy => throw _privateConstructorUsedError;

  /// Academia seleccionada en la tabla de gestión
  Academy? get selectedAcademy => throw _privateConstructorUsedError;

  /// Estadísticas de la academia seleccionada
  Map<String, int> get selectedAcademyStats =>
      throw _privateConstructorUsedError;

  /// Estadísticas de todas las academias (key: academyId)
  Map<int, Map<String, int>> get allAcademiesStats =>
      throw _privateConstructorUsedError;

  /// Estado de la carga inicial de academias
  Status get fetchStatus => throw _privateConstructorUsedError;

  /// Estado de la creación de academia
  Status get createStatus => throw _privateConstructorUsedError;

  /// Estado de la actualización de academia
  Status get updateStatus => throw _privateConstructorUsedError;

  /// Estado de la eliminación de academia
  Status get deleteStatus => throw _privateConstructorUsedError;

  /// Estado de la carga de estadísticas
  Status get statsStatus => throw _privateConstructorUsedError;

  /// Estado del cambio de estado (activar/desactivar)
  Status get toggleStatusStatus =>
      throw _privateConstructorUsedError; // ============================================
// TUTORS MANAGEMENT (integrado desde TutorCubit)
// ============================================
  /// Lista de tutores de la academia seleccionada
  List<CmsUser> get tutors => throw _privateConstructorUsedError;

  /// Query de búsqueda actual para tutores
  String? get searchQuery => throw _privateConstructorUsedError;

  /// Academia seleccionada para ver tutores
  int? get selectedAcademyIdForTutors => throw _privateConstructorUsedError;

  /// Estado de carga de tutores
  Status get fetchTutorsStatus => throw _privateConstructorUsedError;

  /// Estado de búsqueda de tutores
  Status get searchTutorsStatus => throw _privateConstructorUsedError;

  /// Estado de creación de tutor
  Status get createTutorStatus => throw _privateConstructorUsedError;

  /// Estado de actualización de tutor
  Status get updateTutorStatus => throw _privateConstructorUsedError;

  /// Estado de eliminación de tutor
  Status get deleteTutorStatus => throw _privateConstructorUsedError;

  /// Estado de actualización de contraseña
  Status get updatePasswordStatus => throw _privateConstructorUsedError;

  /// Mensaje de error general
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of AcademyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AcademyStateCopyWith<AcademyState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AcademyStateCopyWith<$Res> {
  factory $AcademyStateCopyWith(
          AcademyState value, $Res Function(AcademyState) then) =
      _$AcademyStateCopyWithImpl<$Res, AcademyState>;
  @useResult
  $Res call(
      {List<Academy> academies,
      Academy? myAcademy,
      Academy? selectedAcademy,
      Map<String, int> selectedAcademyStats,
      Map<int, Map<String, int>> allAcademiesStats,
      Status fetchStatus,
      Status createStatus,
      Status updateStatus,
      Status deleteStatus,
      Status statsStatus,
      Status toggleStatusStatus,
      List<CmsUser> tutors,
      String? searchQuery,
      int? selectedAcademyIdForTutors,
      Status fetchTutorsStatus,
      Status searchTutorsStatus,
      Status createTutorStatus,
      Status updateTutorStatus,
      Status deleteTutorStatus,
      Status updatePasswordStatus,
      String? error});
}

/// @nodoc
class _$AcademyStateCopyWithImpl<$Res, $Val extends AcademyState>
    implements $AcademyStateCopyWith<$Res> {
  _$AcademyStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AcademyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? academies = null,
    Object? myAcademy = freezed,
    Object? selectedAcademy = freezed,
    Object? selectedAcademyStats = null,
    Object? allAcademiesStats = null,
    Object? fetchStatus = null,
    Object? createStatus = null,
    Object? updateStatus = null,
    Object? deleteStatus = null,
    Object? statsStatus = null,
    Object? toggleStatusStatus = null,
    Object? tutors = null,
    Object? searchQuery = freezed,
    Object? selectedAcademyIdForTutors = freezed,
    Object? fetchTutorsStatus = null,
    Object? searchTutorsStatus = null,
    Object? createTutorStatus = null,
    Object? updateTutorStatus = null,
    Object? deleteTutorStatus = null,
    Object? updatePasswordStatus = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      academies: null == academies
          ? _value.academies
          : academies // ignore: cast_nullable_to_non_nullable
              as List<Academy>,
      myAcademy: freezed == myAcademy
          ? _value.myAcademy
          : myAcademy // ignore: cast_nullable_to_non_nullable
              as Academy?,
      selectedAcademy: freezed == selectedAcademy
          ? _value.selectedAcademy
          : selectedAcademy // ignore: cast_nullable_to_non_nullable
              as Academy?,
      selectedAcademyStats: null == selectedAcademyStats
          ? _value.selectedAcademyStats
          : selectedAcademyStats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      allAcademiesStats: null == allAcademiesStats
          ? _value.allAcademiesStats
          : allAcademiesStats // ignore: cast_nullable_to_non_nullable
              as Map<int, Map<String, int>>,
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
      statsStatus: null == statsStatus
          ? _value.statsStatus
          : statsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      toggleStatusStatus: null == toggleStatusStatus
          ? _value.toggleStatusStatus
          : toggleStatusStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      tutors: null == tutors
          ? _value.tutors
          : tutors // ignore: cast_nullable_to_non_nullable
              as List<CmsUser>,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedAcademyIdForTutors: freezed == selectedAcademyIdForTutors
          ? _value.selectedAcademyIdForTutors
          : selectedAcademyIdForTutors // ignore: cast_nullable_to_non_nullable
              as int?,
      fetchTutorsStatus: null == fetchTutorsStatus
          ? _value.fetchTutorsStatus
          : fetchTutorsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      searchTutorsStatus: null == searchTutorsStatus
          ? _value.searchTutorsStatus
          : searchTutorsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createTutorStatus: null == createTutorStatus
          ? _value.createTutorStatus
          : createTutorStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateTutorStatus: null == updateTutorStatus
          ? _value.updateTutorStatus
          : updateTutorStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteTutorStatus: null == deleteTutorStatus
          ? _value.deleteTutorStatus
          : deleteTutorStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updatePasswordStatus: null == updatePasswordStatus
          ? _value.updatePasswordStatus
          : updatePasswordStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AcademyStateImplCopyWith<$Res>
    implements $AcademyStateCopyWith<$Res> {
  factory _$$AcademyStateImplCopyWith(
          _$AcademyStateImpl value, $Res Function(_$AcademyStateImpl) then) =
      __$$AcademyStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Academy> academies,
      Academy? myAcademy,
      Academy? selectedAcademy,
      Map<String, int> selectedAcademyStats,
      Map<int, Map<String, int>> allAcademiesStats,
      Status fetchStatus,
      Status createStatus,
      Status updateStatus,
      Status deleteStatus,
      Status statsStatus,
      Status toggleStatusStatus,
      List<CmsUser> tutors,
      String? searchQuery,
      int? selectedAcademyIdForTutors,
      Status fetchTutorsStatus,
      Status searchTutorsStatus,
      Status createTutorStatus,
      Status updateTutorStatus,
      Status deleteTutorStatus,
      Status updatePasswordStatus,
      String? error});
}

/// @nodoc
class __$$AcademyStateImplCopyWithImpl<$Res>
    extends _$AcademyStateCopyWithImpl<$Res, _$AcademyStateImpl>
    implements _$$AcademyStateImplCopyWith<$Res> {
  __$$AcademyStateImplCopyWithImpl(
      _$AcademyStateImpl _value, $Res Function(_$AcademyStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AcademyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? academies = null,
    Object? myAcademy = freezed,
    Object? selectedAcademy = freezed,
    Object? selectedAcademyStats = null,
    Object? allAcademiesStats = null,
    Object? fetchStatus = null,
    Object? createStatus = null,
    Object? updateStatus = null,
    Object? deleteStatus = null,
    Object? statsStatus = null,
    Object? toggleStatusStatus = null,
    Object? tutors = null,
    Object? searchQuery = freezed,
    Object? selectedAcademyIdForTutors = freezed,
    Object? fetchTutorsStatus = null,
    Object? searchTutorsStatus = null,
    Object? createTutorStatus = null,
    Object? updateTutorStatus = null,
    Object? deleteTutorStatus = null,
    Object? updatePasswordStatus = null,
    Object? error = freezed,
  }) {
    return _then(_$AcademyStateImpl(
      academies: null == academies
          ? _value._academies
          : academies // ignore: cast_nullable_to_non_nullable
              as List<Academy>,
      myAcademy: freezed == myAcademy
          ? _value.myAcademy
          : myAcademy // ignore: cast_nullable_to_non_nullable
              as Academy?,
      selectedAcademy: freezed == selectedAcademy
          ? _value.selectedAcademy
          : selectedAcademy // ignore: cast_nullable_to_non_nullable
              as Academy?,
      selectedAcademyStats: null == selectedAcademyStats
          ? _value._selectedAcademyStats
          : selectedAcademyStats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      allAcademiesStats: null == allAcademiesStats
          ? _value._allAcademiesStats
          : allAcademiesStats // ignore: cast_nullable_to_non_nullable
              as Map<int, Map<String, int>>,
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
      statsStatus: null == statsStatus
          ? _value.statsStatus
          : statsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      toggleStatusStatus: null == toggleStatusStatus
          ? _value.toggleStatusStatus
          : toggleStatusStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      tutors: null == tutors
          ? _value._tutors
          : tutors // ignore: cast_nullable_to_non_nullable
              as List<CmsUser>,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedAcademyIdForTutors: freezed == selectedAcademyIdForTutors
          ? _value.selectedAcademyIdForTutors
          : selectedAcademyIdForTutors // ignore: cast_nullable_to_non_nullable
              as int?,
      fetchTutorsStatus: null == fetchTutorsStatus
          ? _value.fetchTutorsStatus
          : fetchTutorsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      searchTutorsStatus: null == searchTutorsStatus
          ? _value.searchTutorsStatus
          : searchTutorsStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      createTutorStatus: null == createTutorStatus
          ? _value.createTutorStatus
          : createTutorStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updateTutorStatus: null == updateTutorStatus
          ? _value.updateTutorStatus
          : updateTutorStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      deleteTutorStatus: null == deleteTutorStatus
          ? _value.deleteTutorStatus
          : deleteTutorStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      updatePasswordStatus: null == updatePasswordStatus
          ? _value.updatePasswordStatus
          : updatePasswordStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AcademyStateImpl extends _AcademyState {
  const _$AcademyStateImpl(
      {final List<Academy> academies = const [],
      this.myAcademy,
      this.selectedAcademy,
      final Map<String, int> selectedAcademyStats = const {},
      final Map<int, Map<String, int>> allAcademiesStats = const {},
      required this.fetchStatus,
      required this.createStatus,
      required this.updateStatus,
      required this.deleteStatus,
      required this.statsStatus,
      required this.toggleStatusStatus,
      final List<CmsUser> tutors = const [],
      this.searchQuery,
      this.selectedAcademyIdForTutors,
      required this.fetchTutorsStatus,
      required this.searchTutorsStatus,
      required this.createTutorStatus,
      required this.updateTutorStatus,
      required this.deleteTutorStatus,
      required this.updatePasswordStatus,
      this.error})
      : _academies = academies,
        _selectedAcademyStats = selectedAcademyStats,
        _allAcademiesStats = allAcademiesStats,
        _tutors = tutors,
        super._();

  /// Lista de academias cargadas
  final List<Academy> _academies;

  /// Lista de academias cargadas
  @override
  @JsonKey()
  List<Academy> get academies {
    if (_academies is EqualUnmodifiableListView) return _academies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_academies);
  }

  /// Academia del usuario autenticado (se carga al inicio de la sesión)
  @override
  final Academy? myAcademy;

  /// Academia seleccionada en la tabla de gestión
  @override
  final Academy? selectedAcademy;

  /// Estadísticas de la academia seleccionada
  final Map<String, int> _selectedAcademyStats;

  /// Estadísticas de la academia seleccionada
  @override
  @JsonKey()
  Map<String, int> get selectedAcademyStats {
    if (_selectedAcademyStats is EqualUnmodifiableMapView)
      return _selectedAcademyStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_selectedAcademyStats);
  }

  /// Estadísticas de todas las academias (key: academyId)
  final Map<int, Map<String, int>> _allAcademiesStats;

  /// Estadísticas de todas las academias (key: academyId)
  @override
  @JsonKey()
  Map<int, Map<String, int>> get allAcademiesStats {
    if (_allAcademiesStats is EqualUnmodifiableMapView)
      return _allAcademiesStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_allAcademiesStats);
  }

  /// Estado de la carga inicial de academias
  @override
  final Status fetchStatus;

  /// Estado de la creación de academia
  @override
  final Status createStatus;

  /// Estado de la actualización de academia
  @override
  final Status updateStatus;

  /// Estado de la eliminación de academia
  @override
  final Status deleteStatus;

  /// Estado de la carga de estadísticas
  @override
  final Status statsStatus;

  /// Estado del cambio de estado (activar/desactivar)
  @override
  final Status toggleStatusStatus;
// ============================================
// TUTORS MANAGEMENT (integrado desde TutorCubit)
// ============================================
  /// Lista de tutores de la academia seleccionada
  final List<CmsUser> _tutors;
// ============================================
// TUTORS MANAGEMENT (integrado desde TutorCubit)
// ============================================
  /// Lista de tutores de la academia seleccionada
  @override
  @JsonKey()
  List<CmsUser> get tutors {
    if (_tutors is EqualUnmodifiableListView) return _tutors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tutors);
  }

  /// Query de búsqueda actual para tutores
  @override
  final String? searchQuery;

  /// Academia seleccionada para ver tutores
  @override
  final int? selectedAcademyIdForTutors;

  /// Estado de carga de tutores
  @override
  final Status fetchTutorsStatus;

  /// Estado de búsqueda de tutores
  @override
  final Status searchTutorsStatus;

  /// Estado de creación de tutor
  @override
  final Status createTutorStatus;

  /// Estado de actualización de tutor
  @override
  final Status updateTutorStatus;

  /// Estado de eliminación de tutor
  @override
  final Status deleteTutorStatus;

  /// Estado de actualización de contraseña
  @override
  final Status updatePasswordStatus;

  /// Mensaje de error general
  @override
  final String? error;

  @override
  String toString() {
    return 'AcademyState(academies: $academies, myAcademy: $myAcademy, selectedAcademy: $selectedAcademy, selectedAcademyStats: $selectedAcademyStats, allAcademiesStats: $allAcademiesStats, fetchStatus: $fetchStatus, createStatus: $createStatus, updateStatus: $updateStatus, deleteStatus: $deleteStatus, statsStatus: $statsStatus, toggleStatusStatus: $toggleStatusStatus, tutors: $tutors, searchQuery: $searchQuery, selectedAcademyIdForTutors: $selectedAcademyIdForTutors, fetchTutorsStatus: $fetchTutorsStatus, searchTutorsStatus: $searchTutorsStatus, createTutorStatus: $createTutorStatus, updateTutorStatus: $updateTutorStatus, deleteTutorStatus: $deleteTutorStatus, updatePasswordStatus: $updatePasswordStatus, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcademyStateImpl &&
            const DeepCollectionEquality()
                .equals(other._academies, _academies) &&
            (identical(other.myAcademy, myAcademy) ||
                other.myAcademy == myAcademy) &&
            (identical(other.selectedAcademy, selectedAcademy) ||
                other.selectedAcademy == selectedAcademy) &&
            const DeepCollectionEquality()
                .equals(other._selectedAcademyStats, _selectedAcademyStats) &&
            const DeepCollectionEquality()
                .equals(other._allAcademiesStats, _allAcademiesStats) &&
            (identical(other.fetchStatus, fetchStatus) ||
                other.fetchStatus == fetchStatus) &&
            (identical(other.createStatus, createStatus) ||
                other.createStatus == createStatus) &&
            (identical(other.updateStatus, updateStatus) ||
                other.updateStatus == updateStatus) &&
            (identical(other.deleteStatus, deleteStatus) ||
                other.deleteStatus == deleteStatus) &&
            (identical(other.statsStatus, statsStatus) ||
                other.statsStatus == statsStatus) &&
            (identical(other.toggleStatusStatus, toggleStatusStatus) ||
                other.toggleStatusStatus == toggleStatusStatus) &&
            const DeepCollectionEquality().equals(other._tutors, _tutors) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.selectedAcademyIdForTutors,
                    selectedAcademyIdForTutors) ||
                other.selectedAcademyIdForTutors ==
                    selectedAcademyIdForTutors) &&
            (identical(other.fetchTutorsStatus, fetchTutorsStatus) ||
                other.fetchTutorsStatus == fetchTutorsStatus) &&
            (identical(other.searchTutorsStatus, searchTutorsStatus) ||
                other.searchTutorsStatus == searchTutorsStatus) &&
            (identical(other.createTutorStatus, createTutorStatus) ||
                other.createTutorStatus == createTutorStatus) &&
            (identical(other.updateTutorStatus, updateTutorStatus) ||
                other.updateTutorStatus == updateTutorStatus) &&
            (identical(other.deleteTutorStatus, deleteTutorStatus) ||
                other.deleteTutorStatus == deleteTutorStatus) &&
            (identical(other.updatePasswordStatus, updatePasswordStatus) ||
                other.updatePasswordStatus == updatePasswordStatus) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        const DeepCollectionEquality().hash(_academies),
        myAcademy,
        selectedAcademy,
        const DeepCollectionEquality().hash(_selectedAcademyStats),
        const DeepCollectionEquality().hash(_allAcademiesStats),
        fetchStatus,
        createStatus,
        updateStatus,
        deleteStatus,
        statsStatus,
        toggleStatusStatus,
        const DeepCollectionEquality().hash(_tutors),
        searchQuery,
        selectedAcademyIdForTutors,
        fetchTutorsStatus,
        searchTutorsStatus,
        createTutorStatus,
        updateTutorStatus,
        deleteTutorStatus,
        updatePasswordStatus,
        error
      ]);

  /// Create a copy of AcademyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AcademyStateImplCopyWith<_$AcademyStateImpl> get copyWith =>
      __$$AcademyStateImplCopyWithImpl<_$AcademyStateImpl>(this, _$identity);
}

abstract class _AcademyState extends AcademyState {
  const factory _AcademyState(
      {final List<Academy> academies,
      final Academy? myAcademy,
      final Academy? selectedAcademy,
      final Map<String, int> selectedAcademyStats,
      final Map<int, Map<String, int>> allAcademiesStats,
      required final Status fetchStatus,
      required final Status createStatus,
      required final Status updateStatus,
      required final Status deleteStatus,
      required final Status statsStatus,
      required final Status toggleStatusStatus,
      final List<CmsUser> tutors,
      final String? searchQuery,
      final int? selectedAcademyIdForTutors,
      required final Status fetchTutorsStatus,
      required final Status searchTutorsStatus,
      required final Status createTutorStatus,
      required final Status updateTutorStatus,
      required final Status deleteTutorStatus,
      required final Status updatePasswordStatus,
      final String? error}) = _$AcademyStateImpl;
  const _AcademyState._() : super._();

  /// Lista de academias cargadas
  @override
  List<Academy> get academies;

  /// Academia del usuario autenticado (se carga al inicio de la sesión)
  @override
  Academy? get myAcademy;

  /// Academia seleccionada en la tabla de gestión
  @override
  Academy? get selectedAcademy;

  /// Estadísticas de la academia seleccionada
  @override
  Map<String, int> get selectedAcademyStats;

  /// Estadísticas de todas las academias (key: academyId)
  @override
  Map<int, Map<String, int>> get allAcademiesStats;

  /// Estado de la carga inicial de academias
  @override
  Status get fetchStatus;

  /// Estado de la creación de academia
  @override
  Status get createStatus;

  /// Estado de la actualización de academia
  @override
  Status get updateStatus;

  /// Estado de la eliminación de academia
  @override
  Status get deleteStatus;

  /// Estado de la carga de estadísticas
  @override
  Status get statsStatus;

  /// Estado del cambio de estado (activar/desactivar)
  @override
  Status get toggleStatusStatus; // ============================================
// TUTORS MANAGEMENT (integrado desde TutorCubit)
// ============================================
  /// Lista de tutores de la academia seleccionada
  @override
  List<CmsUser> get tutors;

  /// Query de búsqueda actual para tutores
  @override
  String? get searchQuery;

  /// Academia seleccionada para ver tutores
  @override
  int? get selectedAcademyIdForTutors;

  /// Estado de carga de tutores
  @override
  Status get fetchTutorsStatus;

  /// Estado de búsqueda de tutores
  @override
  Status get searchTutorsStatus;

  /// Estado de creación de tutor
  @override
  Status get createTutorStatus;

  /// Estado de actualización de tutor
  @override
  Status get updateTutorStatus;

  /// Estado de eliminación de tutor
  @override
  Status get deleteTutorStatus;

  /// Estado de actualización de contraseña
  @override
  Status get updatePasswordStatus;

  /// Mensaje de error general
  @override
  String? get error;

  /// Create a copy of AcademyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AcademyStateImplCopyWith<_$AcademyStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

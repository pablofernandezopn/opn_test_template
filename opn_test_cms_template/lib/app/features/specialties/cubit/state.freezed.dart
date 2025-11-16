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
mixin _$SpecialtyState {
  /// Lista de especialidades cargadas
  List<Specialty> get specialties => throw _privateConstructorUsedError;

  /// Especialidades activas (filtrado rápido)
  List<Specialty> get activeSpecialties => throw _privateConstructorUsedError;

  /// Especialidad seleccionada
  Specialty? get selectedSpecialty => throw _privateConstructorUsedError;

  /// Filtro de academia
  int? get academyFilter => throw _privateConstructorUsedError;

  /// Filtro de estado activo/inactivo
  bool? get isActiveFilter => throw _privateConstructorUsedError;

  /// Estado de la carga inicial de especialidades
  Status get fetchStatus => throw _privateConstructorUsedError;

  /// Estado de la creación de especialidad
  Status get createStatus => throw _privateConstructorUsedError;

  /// Estado de la actualización de especialidad
  Status get updateStatus => throw _privateConstructorUsedError;

  /// Estado de la eliminación de especialidad
  Status get deleteStatus => throw _privateConstructorUsedError;

  /// Estado del cambio de estado activo
  Status get toggleActiveStatus => throw _privateConstructorUsedError;

  /// Mensaje de error general
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of SpecialtyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpecialtyStateCopyWith<SpecialtyState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpecialtyStateCopyWith<$Res> {
  factory $SpecialtyStateCopyWith(
          SpecialtyState value, $Res Function(SpecialtyState) then) =
      _$SpecialtyStateCopyWithImpl<$Res, SpecialtyState>;
  @useResult
  $Res call(
      {List<Specialty> specialties,
      List<Specialty> activeSpecialties,
      Specialty? selectedSpecialty,
      int? academyFilter,
      bool? isActiveFilter,
      Status fetchStatus,
      Status createStatus,
      Status updateStatus,
      Status deleteStatus,
      Status toggleActiveStatus,
      String? error});
}

/// @nodoc
class _$SpecialtyStateCopyWithImpl<$Res, $Val extends SpecialtyState>
    implements $SpecialtyStateCopyWith<$Res> {
  _$SpecialtyStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpecialtyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? specialties = null,
    Object? activeSpecialties = null,
    Object? selectedSpecialty = freezed,
    Object? academyFilter = freezed,
    Object? isActiveFilter = freezed,
    Object? fetchStatus = null,
    Object? createStatus = null,
    Object? updateStatus = null,
    Object? deleteStatus = null,
    Object? toggleActiveStatus = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      specialties: null == specialties
          ? _value.specialties
          : specialties // ignore: cast_nullable_to_non_nullable
              as List<Specialty>,
      activeSpecialties: null == activeSpecialties
          ? _value.activeSpecialties
          : activeSpecialties // ignore: cast_nullable_to_non_nullable
              as List<Specialty>,
      selectedSpecialty: freezed == selectedSpecialty
          ? _value.selectedSpecialty
          : selectedSpecialty // ignore: cast_nullable_to_non_nullable
              as Specialty?,
      academyFilter: freezed == academyFilter
          ? _value.academyFilter
          : academyFilter // ignore: cast_nullable_to_non_nullable
              as int?,
      isActiveFilter: freezed == isActiveFilter
          ? _value.isActiveFilter
          : isActiveFilter // ignore: cast_nullable_to_non_nullable
              as bool?,
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
      toggleActiveStatus: null == toggleActiveStatus
          ? _value.toggleActiveStatus
          : toggleActiveStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpecialtyStateImplCopyWith<$Res>
    implements $SpecialtyStateCopyWith<$Res> {
  factory _$$SpecialtyStateImplCopyWith(_$SpecialtyStateImpl value,
          $Res Function(_$SpecialtyStateImpl) then) =
      __$$SpecialtyStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Specialty> specialties,
      List<Specialty> activeSpecialties,
      Specialty? selectedSpecialty,
      int? academyFilter,
      bool? isActiveFilter,
      Status fetchStatus,
      Status createStatus,
      Status updateStatus,
      Status deleteStatus,
      Status toggleActiveStatus,
      String? error});
}

/// @nodoc
class __$$SpecialtyStateImplCopyWithImpl<$Res>
    extends _$SpecialtyStateCopyWithImpl<$Res, _$SpecialtyStateImpl>
    implements _$$SpecialtyStateImplCopyWith<$Res> {
  __$$SpecialtyStateImplCopyWithImpl(
      _$SpecialtyStateImpl _value, $Res Function(_$SpecialtyStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpecialtyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? specialties = null,
    Object? activeSpecialties = null,
    Object? selectedSpecialty = freezed,
    Object? academyFilter = freezed,
    Object? isActiveFilter = freezed,
    Object? fetchStatus = null,
    Object? createStatus = null,
    Object? updateStatus = null,
    Object? deleteStatus = null,
    Object? toggleActiveStatus = null,
    Object? error = freezed,
  }) {
    return _then(_$SpecialtyStateImpl(
      specialties: null == specialties
          ? _value._specialties
          : specialties // ignore: cast_nullable_to_non_nullable
              as List<Specialty>,
      activeSpecialties: null == activeSpecialties
          ? _value._activeSpecialties
          : activeSpecialties // ignore: cast_nullable_to_non_nullable
              as List<Specialty>,
      selectedSpecialty: freezed == selectedSpecialty
          ? _value.selectedSpecialty
          : selectedSpecialty // ignore: cast_nullable_to_non_nullable
              as Specialty?,
      academyFilter: freezed == academyFilter
          ? _value.academyFilter
          : academyFilter // ignore: cast_nullable_to_non_nullable
              as int?,
      isActiveFilter: freezed == isActiveFilter
          ? _value.isActiveFilter
          : isActiveFilter // ignore: cast_nullable_to_non_nullable
              as bool?,
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
      toggleActiveStatus: null == toggleActiveStatus
          ? _value.toggleActiveStatus
          : toggleActiveStatus // ignore: cast_nullable_to_non_nullable
              as Status,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SpecialtyStateImpl extends _SpecialtyState {
  const _$SpecialtyStateImpl(
      {final List<Specialty> specialties = const [],
      final List<Specialty> activeSpecialties = const [],
      this.selectedSpecialty,
      this.academyFilter,
      this.isActiveFilter,
      required this.fetchStatus,
      required this.createStatus,
      required this.updateStatus,
      required this.deleteStatus,
      required this.toggleActiveStatus,
      this.error})
      : _specialties = specialties,
        _activeSpecialties = activeSpecialties,
        super._();

  /// Lista de especialidades cargadas
  final List<Specialty> _specialties;

  /// Lista de especialidades cargadas
  @override
  @JsonKey()
  List<Specialty> get specialties {
    if (_specialties is EqualUnmodifiableListView) return _specialties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_specialties);
  }

  /// Especialidades activas (filtrado rápido)
  final List<Specialty> _activeSpecialties;

  /// Especialidades activas (filtrado rápido)
  @override
  @JsonKey()
  List<Specialty> get activeSpecialties {
    if (_activeSpecialties is EqualUnmodifiableListView)
      return _activeSpecialties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeSpecialties);
  }

  /// Especialidad seleccionada
  @override
  final Specialty? selectedSpecialty;

  /// Filtro de academia
  @override
  final int? academyFilter;

  /// Filtro de estado activo/inactivo
  @override
  final bool? isActiveFilter;

  /// Estado de la carga inicial de especialidades
  @override
  final Status fetchStatus;

  /// Estado de la creación de especialidad
  @override
  final Status createStatus;

  /// Estado de la actualización de especialidad
  @override
  final Status updateStatus;

  /// Estado de la eliminación de especialidad
  @override
  final Status deleteStatus;

  /// Estado del cambio de estado activo
  @override
  final Status toggleActiveStatus;

  /// Mensaje de error general
  @override
  final String? error;

  @override
  String toString() {
    return 'SpecialtyState(specialties: $specialties, activeSpecialties: $activeSpecialties, selectedSpecialty: $selectedSpecialty, academyFilter: $academyFilter, isActiveFilter: $isActiveFilter, fetchStatus: $fetchStatus, createStatus: $createStatus, updateStatus: $updateStatus, deleteStatus: $deleteStatus, toggleActiveStatus: $toggleActiveStatus, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpecialtyStateImpl &&
            const DeepCollectionEquality()
                .equals(other._specialties, _specialties) &&
            const DeepCollectionEquality()
                .equals(other._activeSpecialties, _activeSpecialties) &&
            (identical(other.selectedSpecialty, selectedSpecialty) ||
                other.selectedSpecialty == selectedSpecialty) &&
            (identical(other.academyFilter, academyFilter) ||
                other.academyFilter == academyFilter) &&
            (identical(other.isActiveFilter, isActiveFilter) ||
                other.isActiveFilter == isActiveFilter) &&
            (identical(other.fetchStatus, fetchStatus) ||
                other.fetchStatus == fetchStatus) &&
            (identical(other.createStatus, createStatus) ||
                other.createStatus == createStatus) &&
            (identical(other.updateStatus, updateStatus) ||
                other.updateStatus == updateStatus) &&
            (identical(other.deleteStatus, deleteStatus) ||
                other.deleteStatus == deleteStatus) &&
            (identical(other.toggleActiveStatus, toggleActiveStatus) ||
                other.toggleActiveStatus == toggleActiveStatus) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_specialties),
      const DeepCollectionEquality().hash(_activeSpecialties),
      selectedSpecialty,
      academyFilter,
      isActiveFilter,
      fetchStatus,
      createStatus,
      updateStatus,
      deleteStatus,
      toggleActiveStatus,
      error);

  /// Create a copy of SpecialtyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpecialtyStateImplCopyWith<_$SpecialtyStateImpl> get copyWith =>
      __$$SpecialtyStateImplCopyWithImpl<_$SpecialtyStateImpl>(
          this, _$identity);
}

abstract class _SpecialtyState extends SpecialtyState {
  const factory _SpecialtyState(
      {final List<Specialty> specialties,
      final List<Specialty> activeSpecialties,
      final Specialty? selectedSpecialty,
      final int? academyFilter,
      final bool? isActiveFilter,
      required final Status fetchStatus,
      required final Status createStatus,
      required final Status updateStatus,
      required final Status deleteStatus,
      required final Status toggleActiveStatus,
      final String? error}) = _$SpecialtyStateImpl;
  const _SpecialtyState._() : super._();

  /// Lista de especialidades cargadas
  @override
  List<Specialty> get specialties;

  /// Especialidades activas (filtrado rápido)
  @override
  List<Specialty> get activeSpecialties;

  /// Especialidad seleccionada
  @override
  Specialty? get selectedSpecialty;

  /// Filtro de academia
  @override
  int? get academyFilter;

  /// Filtro de estado activo/inactivo
  @override
  bool? get isActiveFilter;

  /// Estado de la carga inicial de especialidades
  @override
  Status get fetchStatus;

  /// Estado de la creación de especialidad
  @override
  Status get createStatus;

  /// Estado de la actualización de especialidad
  @override
  Status get updateStatus;

  /// Estado de la eliminación de especialidad
  @override
  Status get deleteStatus;

  /// Estado del cambio de estado activo
  @override
  Status get toggleActiveStatus;

  /// Mensaje de error general
  @override
  String? get error;

  /// Create a copy of SpecialtyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpecialtyStateImplCopyWith<_$SpecialtyStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

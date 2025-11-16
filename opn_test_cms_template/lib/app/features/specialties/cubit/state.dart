import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';

part 'state.freezed.dart';

/// Enum para representar los estados de las operaciones
enum StatusNames { loading, done, error }

/// Clase Status para manejar estados de operaciones asíncronas
class Status {
  final StatusNames status;
  final String message;

  Status({
    required this.status,
    String? message,
  }) : message = message ?? '';

  // Factory methods
  factory Status.loading([String? message]) =>
      Status(status: StatusNames.loading, message: message);

  factory Status.done([String? message]) =>
      Status(status: StatusNames.done, message: message);

  factory Status.error([String? message]) =>
      Status(status: StatusNames.error, message: message);

  // Getters de conveniencia
  bool get isLoading => status == StatusNames.loading;
  bool get isDone => status == StatusNames.done;
  bool get isError => status == StatusNames.error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Status &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          message == other.message;

  @override
  int get hashCode => status.hashCode ^ message.hashCode;

  @override
  String toString() => 'Status(status: $status, message: $message)';
}

/// Estado del SpecialtyCubit
@freezed
class SpecialtyState with _$SpecialtyState {
  const factory SpecialtyState({
    /// Lista de especialidades cargadas
    @Default([]) List<Specialty> specialties,

    /// Especialidades activas (filtrado rápido)
    @Default([]) List<Specialty> activeSpecialties,

    /// Especialidad seleccionada
    Specialty? selectedSpecialty,

    /// Filtro de academia
    int? academyFilter,

    /// Filtro de estado activo/inactivo
    bool? isActiveFilter,

    /// Estado de la carga inicial de especialidades
    required Status fetchStatus,

    /// Estado de la creación de especialidad
    required Status createStatus,

    /// Estado de la actualización de especialidad
    required Status updateStatus,

    /// Estado de la eliminación de especialidad
    required Status deleteStatus,

    /// Estado del cambio de estado activo
    required Status toggleActiveStatus,

    /// Mensaje de error general
    String? error,
  }) = _SpecialtyState;

  const SpecialtyState._();

  /// Helper para crear estado inicial
  factory SpecialtyState.initial() => SpecialtyState(
        fetchStatus: Status.done(),
        createStatus: Status.done(),
        updateStatus: Status.done(),
        deleteStatus: Status.done(),
        toggleActiveStatus: Status.done(),
        error: null,
      );

  /// Indica si hay alguna operación en curso
  bool get isLoading =>
      fetchStatus.isLoading ||
      createStatus.isLoading ||
      updateStatus.isLoading ||
      deleteStatus.isLoading ||
      toggleActiveStatus.isLoading;

  /// Indica si hay algún error en alguna operación
  bool get hasError =>
      fetchStatus.isError ||
      createStatus.isError ||
      updateStatus.isError ||
      deleteStatus.isError ||
      toggleActiveStatus.isError;

  /// Obtiene el total de especialidades
  int get totalSpecialties => specialties.length;

  /// Obtiene el total de especialidades activas
  int get totalActive => specialties.where((s) => s.isActive).length;

  /// Obtiene el total de especialidades inactivas
  int get totalInactive => specialties.where((s) => !s.isActive).length;

  /// Obtiene la especialidad por defecto
  Specialty? get defaultSpecialty =>
      specialties.where((s) => s.isDefault).firstOrNull;

  /// Obtiene especialidades ordenadas por displayOrder
  List<Specialty> get sortedSpecialties {
    final list = [...specialties];
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }
}

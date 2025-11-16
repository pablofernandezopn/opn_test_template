import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/academy_model.dart';
import '../../../authentification/auth/model/user.dart';

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

/// Estado del AcademyCubit (integrado con gestión de tutores)
@freezed
class AcademyState with _$AcademyState {
  const factory AcademyState({
    /// Lista de academias cargadas
    @Default([]) List<Academy> academies,

    /// Academia del usuario autenticado (se carga al inicio de la sesión)
    Academy? myAcademy,

    /// Academia seleccionada en la tabla de gestión
    Academy? selectedAcademy,

    /// Estadísticas de la academia seleccionada
    @Default({}) Map<String, int> selectedAcademyStats,

    /// Estadísticas de todas las academias (key: academyId)
    @Default({}) Map<int, Map<String, int>> allAcademiesStats,

    /// Estado de la carga inicial de academias
    required Status fetchStatus,

    /// Estado de la creación de academia
    required Status createStatus,

    /// Estado de la actualización de academia
    required Status updateStatus,

    /// Estado de la eliminación de academia
    required Status deleteStatus,

    /// Estado de la carga de estadísticas
    required Status statsStatus,

    /// Estado del cambio de estado (activar/desactivar)
    required Status toggleStatusStatus,

    // ============================================
    // TUTORS MANAGEMENT (integrado desde TutorCubit)
    // ============================================

    /// Lista de tutores de la academia seleccionada
    @Default([]) List<CmsUser> tutors,

    /// Query de búsqueda actual para tutores
    String? searchQuery,

    /// Academia seleccionada para ver tutores
    int? selectedAcademyIdForTutors,

    /// Estado de carga de tutores
    required Status fetchTutorsStatus,

    /// Estado de búsqueda de tutores
    required Status searchTutorsStatus,

    /// Estado de creación de tutor
    required Status createTutorStatus,

    /// Estado de actualización de tutor
    required Status updateTutorStatus,

    /// Estado de eliminación de tutor
    required Status deleteTutorStatus,

    /// Estado de actualización de contraseña
    required Status updatePasswordStatus,

    /// Mensaje de error general
    String? error,
  }) = _AcademyState;

  const AcademyState._();

  /// Helper para crear estado inicial
  factory AcademyState.initial() => AcademyState(
        fetchStatus: Status.done(),
        createStatus: Status.done(),
        updateStatus: Status.done(),
        deleteStatus: Status.done(),
        statsStatus: Status.done(),
        toggleStatusStatus: Status.done(),
        fetchTutorsStatus: Status.done(),
        searchTutorsStatus: Status.done(),
        createTutorStatus: Status.done(),
        updateTutorStatus: Status.done(),
        deleteTutorStatus: Status.done(),
        updatePasswordStatus: Status.done(),
        error: null,
      );

  /// Indica si hay alguna operación en curso
  bool get isLoading =>
      fetchStatus.isLoading ||
      createStatus.isLoading ||
      updateStatus.isLoading ||
      deleteStatus.isLoading ||
      statsStatus.isLoading ||
      toggleStatusStatus.isLoading ||
      fetchTutorsStatus.isLoading ||
      searchTutorsStatus.isLoading ||
      createTutorStatus.isLoading ||
      updateTutorStatus.isLoading ||
      deleteTutorStatus.isLoading ||
      updatePasswordStatus.isLoading;

  /// Indica si hay algún error en alguna operación
  bool get hasError =>
      fetchStatus.isError ||
      createStatus.isError ||
      updateStatus.isError ||
      deleteStatus.isError ||
      statsStatus.isError ||
      toggleStatusStatus.isError ||
      fetchTutorsStatus.isError ||
      searchTutorsStatus.isError ||
      createTutorStatus.isError ||
      updateTutorStatus.isError ||
      deleteTutorStatus.isError ||
      updatePasswordStatus.isError;

  /// Indica si está cargando operaciones CRUD de tutores
  bool get isCrudLoading =>
      createTutorStatus.isLoading ||
      updateTutorStatus.isLoading ||
      deleteTutorStatus.isLoading;

  // ============================================
  // HELPERS DE ACADEMIAS
  // ============================================

  /// Obtiene el total de academias
  int get totalAcademies => academies.length;

  /// Obtiene el total de academias activas
  int get totalActiveAcademies => academies.where((a) => a.isActive).length;

  /// Obtiene el total de academias inactivas
  int get totalInactiveAcademies => academies.where((a) => !a.isActive).length;

  /// Obtiene una academia por ID
  Academy? getAcademyById(int id) {
    try {
      return academies.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene las estadísticas de una academia específica
  Map<String, int>? getAcademyStats(int academyId) =>
      allAcademiesStats[academyId];

  // ============================================
  // HELPERS DE TUTORES
  // ============================================

  /// Indica si hay una búsqueda activa de tutores
  bool get hasActiveSearch => searchQuery != null && searchQuery!.isNotEmpty;

  /// Indica si hay una academia seleccionada para tutores
  bool get hasSelectedAcademyForTutors => selectedAcademyIdForTutors != null;

  /// Número total de tutores en la academia seleccionada
  int get totalTutors => tutors.length;

  /// Obtiene un tutor por ID
  CmsUser? getTutorById(int id) {
    try {
      return tutors.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Tutores filtrados por rol
  List<CmsUser> getTutorsByRole(int roleId) {
    return tutors.where((t) => t.roleId == roleId).toList();
  }

  /// Tutores agrupados por especialidad
  Map<int?, List<CmsUser>> get tutorsBySpecialty {
    final Map<int?, List<CmsUser>> grouped = {};
    for (final tutor in tutors) {
      if (!grouped.containsKey(tutor.specialtyId)) {
        grouped[tutor.specialtyId] = [];
      }
      grouped[tutor.specialtyId]!.add(tutor);
    }
    return grouped;
  }
}

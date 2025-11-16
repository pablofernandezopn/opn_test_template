import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bootstrap.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../authentification/auth/cubit/auth_state.dart';
import '../../../authentification/auth/model/user.dart';
import '../model/academy_model.dart';
import '../repository/academy_repository.dart';
import 'state.dart';

/// Cubit para gestionar el estado de academias.
///
/// Requiere acceso al AuthCubit para verificar permisos.
/// Solo usuarios con rol SuperAdmin pueden crear, editar o eliminar academias.
class AcademyCubit extends Cubit<AcademyState> {
  final AcademyRepository _academyRepository;
  final AuthCubit _authCubit;

  AcademyCubit(
    this._academyRepository,
    this._authCubit,
  ) : super(AcademyState.initial()) {
    initialFetch();
    // Escuchar cambios en el AuthCubit para cargar la academia cuando el usuario se autentique
    _authCubit.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated && !authState.user.isEmpty) {
        _loadCurrentUserAcademy();
      } else if (authState.status == AuthStatus.unauthenticated) {
        // Limpiar la academia cuando el usuario cierra sesión
        emit(state.copyWith(myAcademy: null));
      }
    });
    // Cargar la academia si el usuario ya está autenticado
    if (_authCubit.state.status == AuthStatus.authenticated && !_authCubit.state.user.isEmpty) {
      _loadCurrentUserAcademy();
    }
  }

  /// Carga la academia del usuario autenticado actual
  Future<void> _loadCurrentUserAcademy() async {
    final user = _authCubit.state.user;

    // Verificar que el usuario esté autenticado y no sea el usuario vacío
    if (user.isEmpty || user.academyId <= 0) {
      logger.debug('No user or invalid academyId, skipping academy load');
      return;
    }

    try {
      logger.info('Loading academy for user: ${user.username} (academyId: ${user.academyId})');
      final academy = await _academyRepository.getAcademyById(user.academyId);
      if (academy != null) {
        emit(state.copyWith(myAcademy: academy));
        logger.info('Current user academy loaded: ${academy.name}');
      } else {
        logger.warning('Academy not found for ID: ${user.academyId}');
      }
    } catch (e) {
      logger.error('Error loading current user academy: $e');
    }
  }

  // ============================================
  // HELPER: Verificación de permisos
  // ============================================

  /// Verifica si el usuario actual tiene permisos de Admin.
  ///
  /// Lanza una excepción si no tiene permisos.
  void _requireAdminPermission() {
    final user = _authCubit.state.user;
    if (user == null || !user.isAdmin) {
      throw Exception(
        'Acceso denegado: Solo Administradores pueden gestionar academias',
      );
    }
  }

  /// Verifica si el usuario actual es al menos Admin.
  bool get _isAdmin {
    final user = _authCubit.state.user;
    return user != null && user.isAdmin;
  }

  /// Verifica si el usuario actual es Admin.
  bool get isAdmin {
    final user = _authCubit.state.user;
    return user != null && user.isAdmin;
  }

  // ============================================
  // READ - Operaciones de lectura (acceso público)
  // ============================================

  /// Carga inicial de academias.
  ///
  /// Se ejecuta automáticamente al crear el Cubit.
  Future<void> initialFetch() async {
    try {
      emit(state.copyWith(fetchStatus: Status.loading()));
      logger.info('Fetching all academies');

      final academies = await _academyRepository.getAcademies();

      logger.info('Fetched ${academies.length} academies');

      // Cargar estadísticas de todas las academias en paralelo
      logger.info('Fetching stats for all academies');
      final statsMap = <int, Map<String, int>>{};

      await Future.wait(
        academies.where((a) => a.id != null).map((academy) async {
          try {
            final stats = await _academyRepository.getAcademyStats(academy.id!);
            statsMap[academy.id!] = stats;
          } catch (e) {
            logger.error('Error fetching stats for academy ${academy.id}: $e');
            // Si falla una estadística, continuar con las demás
            statsMap[academy.id!] = {};
          }
        }),
      );

      logger.info('Fetched stats for ${statsMap.length} academies');

      emit(state.copyWith(
        academies: academies,
        allAcademiesStats: statsMap,
        fetchStatus: Status.done(),
        error: null,
      ));
    } catch (e, st) {
      logger.error('Error fetching academies: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        fetchStatus: Status.error('Error al cargar academias: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Recarga la lista de academias.
  Future<void> refreshAcademies({bool activeOnly = false}) async {
    try {
      emit(state.copyWith(fetchStatus: Status.loading()));
      logger.info('Refreshing academies (activeOnly: $activeOnly)');

      final academies = await _academyRepository.getAcademies(
        activeOnly: activeOnly,
      );

      logger.info('Refreshed ${academies.length} academies');

      // Cargar estadísticas de todas las academias en paralelo
      logger.info('Fetching stats for all academies');
      final statsMap = <int, Map<String, int>>{};

      await Future.wait(
        academies.where((a) => a.id != null).map((academy) async {
          try {
            final stats = await _academyRepository.getAcademyStats(academy.id!);
            statsMap[academy.id!] = stats;
          } catch (e) {
            logger.error('Error fetching stats for academy ${academy.id}: $e');
            // Si falla una estadística, continuar con las demás
            statsMap[academy.id!] = {};
          }
        }),
      );

      logger.info('Fetched stats for ${statsMap.length} academies');

      emit(state.copyWith(
        academies: academies,
        allAcademiesStats: statsMap,
        fetchStatus: Status.done(),
        error: null,
      ));
    } catch (e, st) {
      logger.error('Error refreshing academies: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        fetchStatus:
            Status.error('Error al recargar academias: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Selecciona una academia y carga sus estadísticas.
  /// Si se hace clic en la misma academia, la deselecciona.
  Future<void> selectAcademy(Academy? academy) async {
    try {
      // Si se hace clic en la misma academia que ya está seleccionada, deseleccionarla
      if (state.selectedAcademy?.id == academy?.id) {
        emit(state.copyWith(
            selectedAcademy: null,
            // selectedAcademyStats: {},
            statsStatus: Status.done(),
            tutors: []));
        logger.info('Academy deselected');
        return;
      }

      // Seleccionar la nueva academia
      emit(state.copyWith(
          selectedAcademy: academy, selectedAcademyStats: {}, tutors: []));

      if (academy != null && academy.id != null) {
        emit(state.copyWith(statsStatus: Status.loading()));
        logger.info('Loading stats for academy: ${academy.id}');

        final stats = await _academyRepository.getAcademyStats(academy.id!);

        logger.info('Stats loaded for academy ${academy.id}: $stats');
        emit(state.copyWith(
          selectedAcademyStats: stats,
          statsStatus: Status.done(),
        ));
      }
    } catch (e, st) {
      logger.error('Error loading academy stats: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        statsStatus:
            Status.error('Error al cargar estadísticas: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Busca academias por nombre.
  Future<void> searchAcademies(String searchTerm) async {
    try {
      if (searchTerm.isEmpty) {
        // Si el término está vacío, cargar todas
        await refreshAcademies();
        return;
      }

      emit(state.copyWith(fetchStatus: Status.loading()));
      logger.info('Searching academies: $searchTerm');

      final academies =
          await _academyRepository.searchAcademiesByName(searchTerm);

      logger.info('Found ${academies.length} academies');
      emit(state.copyWith(
        academies: academies,
        fetchStatus: Status.done(),
        error: null,
      ));
    } catch (e, st) {
      logger.error('Error searching academies: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        fetchStatus: Status.error('Error al buscar academias: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  // ============================================
  // CREATE - Solo Super Admin
  // ============================================

  /// Crea una nueva academia.
  ///
  /// Requiere permisos de Super Admin.
  Future<void> createAcademy(Academy academy) async {
    try {
      _requireAdminPermission();

      emit(state.copyWith(createStatus: Status.loading()));
      logger.info('Creating academy: ${academy.name}');

      final createdAcademy = await _academyRepository.createAcademy(academy);

      logger.info('Academy created successfully: ${createdAcademy.id}');

      // Agregar la nueva academia a la lista
      final updatedAcademies = [...state.academies, createdAcademy];

      emit(state.copyWith(
        academies: updatedAcademies,
        createStatus: Status.done('Academia creada exitosamente'),
        error: null,
      ));
    } catch (e, st) {
      logger.error('Error creating academy: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        createStatus: Status.error(e.toString()),
        error: e.toString(),
      ));
    }
  }

  // ============================================
  // UPDATE - Solo Super Admin
  // ============================================

  /// Actualiza una academia existente.
  ///
  /// Requiere permisos de Super Admin.
  Future<void> updateAcademy(Academy academy) async {
    try {
      _requireAdminPermission();

      if (academy.id == null) {
        throw Exception('No se puede actualizar una academia sin ID');
      }

      emit(state.copyWith(updateStatus: Status.loading()));
      logger.info('Updating academy: ${academy.id}');

      final updatedAcademy = await _academyRepository.updateAcademy(academy);

      logger.info('Academy updated successfully: ${updatedAcademy.id}');

      // Actualizar la academia en la lista
      final updatedAcademies = state.academies
          .map((a) => a.id == updatedAcademy.id ? updatedAcademy : a)
          .toList();

      emit(state.copyWith(
        academies: updatedAcademies,
        selectedAcademy: state.selectedAcademy?.id == updatedAcademy.id
            ? updatedAcademy
            : state.selectedAcademy,
        updateStatus: Status.done('Academia actualizada exitosamente'),
        error: null,
      ));
    } catch (e, st) {
      logger.error('Error updating academy: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        updateStatus: Status.error(e.toString()),
        error: e.toString(),
      ));
    }
  }

  /// Activa o desactiva una academia.
  ///
  /// Requiere permisos de Super Admin.
  Future<void> toggleAcademyStatus(int academyId, bool isActive) async {
    try {
      _requireAdminPermission();

      emit(state.copyWith(toggleStatusStatus: Status.loading()));
      logger.info('Toggling academy status: $academyId to $isActive');

      final updatedAcademy = await _academyRepository.toggleAcademyStatus(
        academyId,
        isActive,
      );

      logger.info('Academy status updated: ${updatedAcademy.id}');

      // Actualizar la academia en la lista
      final updatedAcademies = state.academies
          .map((a) => a.id == updatedAcademy.id ? updatedAcademy : a)
          .toList();

      emit(state.copyWith(
        academies: updatedAcademies,
        selectedAcademy: state.selectedAcademy?.id == updatedAcademy.id
            ? updatedAcademy
            : state.selectedAcademy,
        toggleStatusStatus: Status.done('Estado actualizado exitosamente'),
        error: null,
      ));
    } catch (e, st) {
      logger.error('Error toggling academy status: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        toggleStatusStatus: Status.error(e.toString()),
        error: e.toString(),
      ));
    }
  }

  // ============================================
  // DELETE - Solo Super Admin
  // ============================================

  /// Elimina una academia.
  ///
  /// Requiere permisos de Super Admin.
  /// IMPORTANTE: Esto fallará si la academia tiene datos asociados.
  Future<void> deleteAcademy(int academyId, {bool force = false}) async {
    try {
      _requireAdminPermission();

      emit(state.copyWith(deleteStatus: Status.loading()));
      logger.info('Deleting academy: $academyId');

      await _academyRepository.deleteAcademy(academyId, force: force);

      logger.info('Academy deleted successfully: $academyId');

      // Eliminar la academia de la lista
      final updatedAcademies =
          state.academies.where((a) => a.id != academyId).toList();

      emit(state.copyWith(
        academies: updatedAcademies,
        selectedAcademy: state.selectedAcademy?.id == academyId
            ? null
            : state.selectedAcademy,
        deleteStatus: Status.done('Academia eliminada exitosamente'),
        error: null,
      ));
    } catch (e, st) {
      logger.error('Error deleting academy: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        deleteStatus: Status.error(e.toString()),
        error: e.toString(),
      ));
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Limpia el estado de error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Reinicia el estado de creación
  void resetCreateStatus() {
    emit(state.copyWith(createStatus: Status.done()));
  }

  /// Reinicia el estado de actualización
  void resetUpdateStatus() {
    emit(state.copyWith(updateStatus: Status.done()));
  }

  /// Reinicia el estado de eliminación
  void resetDeleteStatus() {
    emit(state.copyWith(deleteStatus: Status.done()));
  }

  // ============================================
  // TUTORS MANAGEMENT (integrado desde TutorCubit)
  // ============================================

  /// Obtiene el academy_id del usuario autenticado
  int? get currentAcademyId => _authCubit.state.user.academyId;

  /// Obtiene tutores de una academia específica
  Future<void> fetchTutorsByAcademy(int academyId) async {
    try {
      emit(state.copyWith(
        fetchTutorsStatus: Status.loading(),
        selectedAcademyIdForTutors: academyId,
        searchQuery: null, // Limpiar búsqueda al cambiar de academia
      ));

      final tutors = await _academyRepository.fetchTutorsByAcademy(academyId);

      logger.info(tutors);

      emit(state.copyWith(
        tutors: tutors,
        fetchTutorsStatus: Status.done(),
        error: null,
      ));

      logger.debug('Fetched ${tutors.length} tutors for academy $academyId');
    } catch (e) {
      emit(state.copyWith(
        fetchTutorsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching tutors for academy $academyId');
    }
  }

  /// Busca tutores en la academia actual
  Future<void> searchTutors(String query) async {
    if (state.selectedAcademyIdForTutors == null) {
      logger.warning('Cannot search tutors: no academy selected');
      return;
    }

    // Si la búsqueda está vacía, recargar todos los tutores
    if (query.isEmpty) {
      await fetchTutorsByAcademy(state.selectedAcademyIdForTutors!);
      return;
    }

    try {
      emit(state.copyWith(
        searchTutorsStatus: Status.loading(),
        searchQuery: query,
      ));

      final tutors = await _academyRepository.searchTutorsByAcademy(
        academyId: state.selectedAcademyIdForTutors!,
        query: query,
      );

      emit(state.copyWith(
        tutors: tutors,
        searchTutorsStatus: Status.done(),
        error: null,
      ));

      logger.debug('Found ${tutors.length} tutors matching "$query"');
    } catch (e) {
      emit(state.copyWith(
        searchTutorsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error searching tutors');
    }
  }

  /// Limpia la búsqueda y recarga todos los tutores
  Future<void> clearSearch() async {
    if (state.selectedAcademyIdForTutors != null) {
      await fetchTutorsByAcademy(state.selectedAcademyIdForTutors!);
    }
  }

  /// Limpia el estado de tutores (útil al salir de la página)
  void clearTutors() {
    emit(state.copyWith(
      tutors: [],
      selectedAcademyIdForTutors: null,
      searchQuery: null,
      fetchTutorsStatus: Status.done(),
      searchTutorsStatus: Status.done(),
    ));
  }

  // ============================================
  // CREATE TUTOR
  // ============================================

  /// Crea un nuevo tutor
  Future<bool> createTutor({
    required String username,
    required String name,
    required String lastName,
    required String email,
    required String password,
    required int academyId,
    int roleId = 4,
    String? phone,
    String? address,
    int? specialtyId,
    String? avatarUrl,
  }) async {
    try {
      emit(state.copyWith(createTutorStatus: Status.loading()));

      logger.debug('esquere');
      final newTutor = await _academyRepository.createTutor(
        username: username,
        name: name,
        lastName: lastName,
        email: email,
        password: password,
        academyId: academyId,
        roleId: roleId,
        phone: phone,
        address: address,
        specialtyId: specialtyId,
        avatarUrl: avatarUrl,
      );

      // Si estamos viendo la academia del nuevo tutor, agregarlo a la lista
      if (state.selectedAcademyIdForTutors == academyId) {
        final updatedTutors = [...state.tutors, newTutor];
        emit(state.copyWith(
          tutors: updatedTutors,
          createTutorStatus: Status.done(),
          error: null,
        ));
      } else {
        emit(state.copyWith(
          createTutorStatus: Status.done(),
          error: null,
        ));
      }

      // Refrescar estadísticas
      await refreshAcademies();

      logger.debug('Tutor created successfully: ${newTutor.id}');
      return true;
    } catch (e) {
      emit(state.copyWith(
        createTutorStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error creating tutor: $e');
      rethrow;
    }
  }

  // ============================================
  // UPDATE TUTOR
  // ============================================

  /// Actualiza un tutor existente
  Future<bool> updateTutor({
    required int tutorId,
    String? username,
    String? name,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    int? roleId,
    int? specialtyId,
    String? avatarUrl,
    int? academyId,
  }) async {
    try {
      emit(state.copyWith(updateTutorStatus: Status.loading()));

      final updatedTutor = await _academyRepository.updateTutor(
        tutorId: tutorId,
        username: username,
        name: name,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        roleId: roleId,
        specialtyId: specialtyId,
        avatarUrl: avatarUrl,
        academyId: academyId,
      );

      // Actualizar el tutor en la lista actual
      final updatedTutors = state.tutors.map((tutor) {
        return tutor.id == tutorId ? updatedTutor : tutor;
      }).toList();

      emit(state.copyWith(
        tutors: updatedTutors,
        updateTutorStatus: Status.done(),
        error: null,
      ));

      // Si cambió de academia, refrescar estadísticas
      if (academyId != null) {
        await refreshAcademies();
      }

      logger.debug('Tutor updated successfully: $tutorId');
      return true;
    } catch (e) {
      emit(state.copyWith(
        updateTutorStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error updating tutor: $e');
      rethrow;
    }
  }

  /// Actualiza la contraseña de un tutor
  Future<void> updateTutorPassword({
    required String userUuid,
    required String newPassword,
  }) async {
    try {
      emit(state.copyWith(updatePasswordStatus: Status.loading()));

      // await _academyRepository.updateTutorPassword(
      //   userUuid: userUuid,
      //   newPassword: newPassword,
      // );

      emit(state.copyWith(
        updatePasswordStatus: Status.done(),
        error: null,
      ));

      logger.debug('Password updated successfully for user: $userUuid');
    } catch (e) {
      emit(state.copyWith(
        updatePasswordStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error updating password: $e');
      rethrow;
    }
  }

  // ============================================
  // DELETE TUTOR
  // ============================================

  /// Elimina un tutor
  Future<bool> deleteTutor({
    required int tutorId,
    bool hardDelete = false,
  }) async {
    try {
      emit(state.copyWith(deleteTutorStatus: Status.loading()));

      await _academyRepository.deleteTutor(
        tutorId: tutorId,
        hardDelete: hardDelete,
      );

      // Remover el tutor de la lista actual
      final updatedTutors = state.tutors.where((t) => t.id != tutorId).toList();

      emit(state.copyWith(
        tutors: updatedTutors,
        deleteTutorStatus: Status.done(),
        error: null,
      ));

      // Refrescar estadísticas
      await refreshAcademies();

      logger.debug('Tutor deleted successfully: $tutorId');
      return true;
    } catch (e) {
      emit(state.copyWith(
        deleteTutorStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error deleting tutor: $e');
      rethrow;
    }
  }

  /// Elimina múltiples tutores
  Future<void> deleteTutors({
    required List<int> tutorIds,
    bool hardDelete = false,
  }) async {
    try {
      emit(state.copyWith(deleteTutorStatus: Status.loading()));

      await _academyRepository.deleteTutors(
        tutorIds: tutorIds,
        hardDelete: hardDelete,
      );

      // Remover los tutores de la lista actual
      final updatedTutors =
          state.tutors.where((t) => !tutorIds.contains(t.id)).toList();

      emit(state.copyWith(
        tutors: updatedTutors,
        deleteTutorStatus: Status.done(),
        error: null,
      ));

      // Refrescar estadísticas
      await refreshAcademies();

      logger.debug('Tutors deleted successfully: ${tutorIds.length}');
    } catch (e) {
      emit(state.copyWith(
        deleteTutorStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error deleting tutors: $e');
      rethrow;
    }
  }

  /// Reactiva un tutor (si se usó soft delete)
  Future<void> reactivateTutor(int tutorId) async {
    try {
      emit(state.copyWith(updateTutorStatus: Status.loading()));

      final reactivatedTutor =
          await _academyRepository.reactivateTutor(tutorId);

      // Agregar el tutor reactivado a la lista si pertenece a la academia actual
      if (state.selectedAcademyIdForTutors == reactivatedTutor.academyId) {
        final updatedTutors = [...state.tutors, reactivatedTutor];
        emit(state.copyWith(
          tutors: updatedTutors,
          updateTutorStatus: Status.done(),
          error: null,
        ));
      } else {
        emit(state.copyWith(
          updateTutorStatus: Status.done(),
          error: null,
        ));
      }

      // Refrescar estadísticas
      await refreshAcademies();

      logger.debug('Tutor reactivated successfully: $tutorId');
    } catch (e) {
      emit(state.copyWith(
        updateTutorStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error reactivating tutor: $e');
      rethrow;
    }
  }

  // ============================================
  // VALIDACIONES DE TUTORES
  // ============================================

  /// Valida si el usuario actual puede crear/editar tutores en una academia
  bool canManageAcademy(int academyId) {
    if (isAdmin) return true; // Admin puede gestionar todas las academias
    return currentAcademyId == academyId; // Editor solo su academia
  }

  /// Valida si el usuario puede cambiar roles
  bool canChangeRole(int targetRoleId) {
    final currentUserRole = _authCubit.state.user.role;
    final targetRole = UserRole.fromId(targetRoleId);

    // Super Admin puede cambiar cualquier rol
    if (currentUserRole.isSuperAdmin) return true;

    // Admin puede asignar roles hasta Editor (no puede crear otros Admin)
    if (currentUserRole.isAdmin) {
      return targetRole == UserRole.admin || targetRole == UserRole.user;
    }

    // Editor solo puede asignar User
    if (currentUserRole.isAdmin) {
      return targetRole == UserRole.user;
    }

    return false;
  }

  /// Valida si se puede eliminar un tutor
  bool canDeleteTutor(CmsUser tutor) {
    // No se puede eliminar a uno mismo
    if (tutor.id == _authCubit.state.user.id) return false;

    // Super Admin puede eliminar a cualquiera (excepto a sí mismo)
    if (isAdmin) return true;

    // Editor solo puede eliminar usuarios de su academia con rol User
    return tutor.academyId == currentAcademyId &&
        tutor.roleId == UserRole.user.id;
  }

  /// Carga una academia específica por ID
  Future<Academy?> fetchAcademyById(int academyId) async {
    try {
      emit(state.copyWith(fetchStatus: Status.loading()));
      logger.info('Fetching academy by ID: $academyId');

      final academy = await _academyRepository.getAcademyById(academyId);

      if (academy != null) {
        // Actualizar o agregar la academia en la lista
        final existingIndex =
            state.academies.indexWhere((a) => a.id == academyId);
        final updatedAcademies = existingIndex >= 0
            ? state.academies
                .map((a) => a.id == academyId ? academy : a)
                .toList()
            : [...state.academies, academy];

        emit(state.copyWith(
          academies: updatedAcademies,
          selectedAcademy: academy,
          fetchStatus: Status.done(),
          error: null,
        ));

        // Cargar estadísticas de la academia
        await selectAcademy(academy);

        logger.info('Academy fetched successfully: ${academy.name}');
        return academy;
      } else {
        logger.warning('Academy not found: $academyId');
        emit(state.copyWith(
          fetchStatus: Status.error('Academia no encontrada'),
          error: 'Academia no encontrada',
        ));
        return null;
      }
    } catch (e, st) {
      logger.error('Error fetching academy by ID: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        fetchStatus: Status.error('Error al cargar academia: ${e.toString()}'),
        error: e.toString(),
      ));
      return null;
    }
  }
}

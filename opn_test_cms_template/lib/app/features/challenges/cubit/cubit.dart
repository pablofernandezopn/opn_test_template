import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bootstrap.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../model/challenge_model.dart';
import '../repository/challenge_repository.dart';
import 'state.dart';

/// Cubit para gestionar el estado de impugnaciones (challenges).
///
/// Requiere acceso al AuthCubit para obtener información del usuario.
/// Gestiona la carga, creación, actualización y eliminación de impugnaciones.
class ChallengeCubit extends Cubit<ChallengeState> {
  final ChallengeRepository _challengeRepository;
  final AuthCubit _authCubit;
  Timer? _autoSaveTimer;

  ChallengeCubit(
    this._challengeRepository,
    this._authCubit,
  ) : super(ChallengeState.initial()) {
    // initialFetch();
  }

  @override
  Future<void> close() {
    _autoSaveTimer?.cancel();
    return super.close();
  }

  // ============================================
  // HELPER: Verificación de permisos
  // ============================================

  /// Verifica si el usuario actual es al menos Editor.
  bool get _canEdit {
    final user = _authCubit.state.user;
    return user != null && (user.isAdmin || user.isAdmin);
  }

  /// Verifica si el usuario actual es al menos Admin.
  bool get _isAdmin {
    final user = _authCubit.state.user;
    return user != null && (user.isSuperAdmin);
  }

  /// Verifica si el usuario actual es Admin (público).
  bool get isAdmin {
    final user = _authCubit.state.user;
    return user != null && user.isAdmin;
  }

  /// Obtiene el ID de la academia del usuario actual.
  int? get _currentAcademyId {
    final user = _authCubit.state.user;
    return user?.academyId;
  }

  /// Obtiene el ID de la especialidad del usuario actual.
  int? get _currentSpecialtyId {
    final user = _authCubit.state.user;
    return user.specialtyId;
  }

  // ============================================
  // READ - Operaciones de lectura
  // ============================================

  /// Carga inicial de impugnaciones.
  ///
  /// Se ejecuta automáticamente al crear el Cubit.
  /// Por defecto carga solo las pendientes.
  Future<void> initialFetch() async {
    try {
      emit(state.copyWith(
        fetchStatus: Status.loading(),
        currentPage: 0,
        hasMore: true,
      ));

      logger.info('Fetching pending challenges (page: 0)');
      logger.info('currentSSpecialtyId :$_currentSpecialtyId');
      logger.info('currentAcademyId :$_currentAcademyId');

      final challenges = await _challengeRepository.getPendingChallenges(
        academyId: _currentAcademyId,
        specialtyId: _currentSpecialtyId,
        page: 0,
        pageSize: state.pageSize,
      );

      logger.info('Fetched ${challenges.length} pending challenges');

      // Cargar estadísticas
      await _loadStats();

      emit(state.copyWith(
        challenges: challenges,
        pendingChallenges: challenges,
        fetchStatus: Status.done(),
        error: null,
        currentPage: 0,
        hasMore: challenges.length == state.pageSize,
      ));
    } catch (e, st) {
      logger.error('Error fetching challenges: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        fetchStatus:
            Status.error('Error al cargar impugnaciones: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Carga más impugnaciones (scroll infinito).
  ///
  /// Solo carga si no está ya cargando y si hay más datos disponibles.
  Future<void> loadMoreChallenges() async {
    // Evitar cargas múltiples simultáneas
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }

    try {
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      logger.info('Loading more challenges (page: $nextPage)');

      final newChallenges = await _challengeRepository.getChallenges(
        status: state.statusFilter,
        academyId: state.academyFilter ?? _currentAcademyId,
        pendingOnly: state.statusFilter == null,
        specialtyId: _currentSpecialtyId,
        page: nextPage,
        pageSize: state.pageSize,
      );

      logger.info('Loaded ${newChallenges.length} more challenges');

      // Combinar con los existentes
      final allChallenges = [...state.challenges, ...newChallenges];

      // Filtrar pendientes
      final pending = allChallenges.where((c) => c.isPending).toList();

      emit(state.copyWith(
        challenges: allChallenges,
        pendingChallenges: pending,
        currentPage: nextPage,
        hasMore: newChallenges.length == state.pageSize,
        isLoadingMore: false,
      ));
    } catch (e, st) {
      logger.error('Error loading more challenges: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        isLoadingMore: false,
        error: 'Error al cargar más impugnaciones: ${e.toString()}',
      ));
    }
  }

  /// Recarga todas las impugnaciones con filtros opcionales.
  Future<void> refreshChallenges({
    ChallengeStatus? status,
    int? academyId,
    bool pendingOnly = false,
  }) async {
    try {
      emit(state.copyWith(
        fetchStatus: Status.loading(),
        statusFilter: status,
        academyFilter: academyId,
        currentPage: 0,
        hasMore: true,
      ));

      logger.info(
          'Refreshing challenges (status: $status, academyId: $academyId, page: 0)');

      final challenges = await _challengeRepository.getChallenges(
        status: status,
        academyId: academyId ?? _currentAcademyId,
        pendingOnly: pendingOnly,
        specialtyId: _currentSpecialtyId,
        page: 0,
        pageSize: state.pageSize,
      );

      logger.info('Refreshed ${challenges.length} challenges');

      // Filtrar pendientes
      final pending = challenges.where((c) => c.isPending).toList();

      // Cargar estadísticas
      await _loadStats();

      emit(state.copyWith(
        challenges: challenges,
        pendingChallenges: pending,
        fetchStatus: Status.done(),
        error: null,
        currentPage: 0,
        hasMore: challenges.length == state.pageSize,
      ));
    } catch (e, st) {
      logger.error('Error refreshing challenges: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        fetchStatus:
            Status.error('Error al actualizar impugnaciones: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Carga solo las impugnaciones pendientes.
  Future<void> loadPendingChallenges() async {
    await refreshChallenges(pendingOnly: true);
  }

  /// Carga todas las impugnaciones (sin filtro).
  Future<void> loadAllChallenges() async {
    await refreshChallenges();
  }

  /// Carga impugnaciones por estado específico.
  Future<void> loadChallengesByStatus(ChallengeStatus status) async {
    await refreshChallenges(status: status);
  }

  /// Selecciona una impugnación para ver detalles.
  void selectChallenge(Challenge? challenge) {
    emit(state.copyWith(selectedChallenge: challenge));
    logger.info('Challenge selected: ${challenge?.id}');
  }

  /// Carga estadísticas de impugnaciones.
  Future<void> _loadStats() async {
    try {
      emit(state.copyWith(statsStatus: Status.loading()));

      final stats = await _challengeRepository.getChallengeStatsByStatus(
          academyId: _currentAcademyId, specialtyId: _currentAcademyId);

      emit(state.copyWith(
        stats: stats,
        statsStatus: Status.done(),
      ));
    } catch (e) {
      logger.error('Error loading challenge stats: $e');
      emit(state.copyWith(
        statsStatus: Status.error('Error al cargar estadísticas'),
      ));
    }
  }

  /// Recarga las estadísticas.
  Future<void> refreshStats() async {
    await _loadStats();
  }

  // ============================================
  // UPDATE - Actualizar impugnación
  // ============================================

  /// Actualiza una impugnación existente.
  Future<Challenge?> updateChallenge(Challenge challenge) async {
    if (!_canEdit) {
      emit(state.copyWith(
        updateStatus:
            Status.error('No tienes permisos para actualizar impugnaciones'),
      ));
      return null;
    }

    try {
      emit(state.copyWith(updateStatus: Status.loading()));
      logger.info('Updating challenge: ${challenge.id}');

      final user = _authCubit.state.user;
      // Solo establecer el editor si la impugnación no tiene uno ya asignado
      final editorId = challenge.editorId == null ? user.id : null;

      final updatedChallenge = await _challengeRepository
          .updateChallenge(challenge, editorId: editorId);

      logger.info('Challenge updated successfully: ${updatedChallenge.id}');

      // Actualizar lista
      await refreshChallenges(pendingOnly: state.statusFilter == null);

      emit(state.copyWith(
        updateStatus: Status.done('Impugnación actualizada exitosamente'),
        selectedChallenge: updatedChallenge,
        error: null,
      ));

      return updatedChallenge;
    } catch (e, st) {
      logger.error('Error updating challenge: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        updateStatus:
            Status.error('Error al actualizar impugnación: ${e.toString()}'),
        error: e.toString(),
      ));
      return null;
    }
  }

  /// Aprueba una impugnación.
  ///
  /// [id] - ID de la impugnación
  /// [reviewComments] - Comentarios del revisor
  Future<Challenge?> approveChallenge(
    int id, {
    String? reviewComments,
  }) async {
    return _changeStatus(
      id: id,
      status: ChallengeStatus.approved,
      reviewComments: reviewComments,
    );
  }

  /// Rechaza una impugnación.
  ///
  /// [id] - ID de la impugnación
  /// [reviewComments] - Comentarios del revisor
  Future<Challenge?> rejectChallenge(
    int id, {
    String? reviewComments,
  }) async {
    return _changeStatus(
      id: id,
      status: ChallengeStatus.rejected,
      reviewComments: reviewComments,
    );
  }

  /// Cambia el estado de una impugnación.
  Future<Challenge?> _changeStatus({
    required int id,
    required ChallengeStatus status,
    String? reviewComments,
  }) async {
    if (!_canEdit) {
      emit(state.copyWith(
        statusChangeStatus:
            Status.error('No tienes permisos para cambiar el estado'),
      ));
      return null;
    }

    try {
      emit(state.copyWith(statusChangeStatus: Status.loading()));
      logger.info('Changing challenge status: $id to ${status.value}');

      final user = _authCubit.state.user;

      // Buscar el challenge actual para verificar si ya tiene editor
      Challenge? currentChallenge;
      if (state.selectedChallenge?.id == id) {
        currentChallenge = state.selectedChallenge;
      } else {
        currentChallenge = state.challenges.firstWhere(
          (c) => c.id == id,
          orElse: () => Challenge.empty,
        );
      }

      // Solo establecer el editor si la impugnación no tiene uno ya asignado
      final editorId = (currentChallenge?.editorId == null) ? user?.id : null;

      final updatedChallenge = await _challengeRepository.updateChallengeStatus(
        id: id,
        status: status,
        reviewedBy: user?.userUuid,
        editorId: editorId,
        reviewComments: reviewComments,
      );

      logger.info('Challenge status updated: ${updatedChallenge.id}');

      // Actualizar lista y estadísticas
      await refreshChallenges(pendingOnly: state.statusFilter == null);

      emit(state.copyWith(
        statusChangeStatus: Status.done('Estado actualizado exitosamente'),
        selectedChallenge: updatedChallenge,
        error: null,
      ));

      return updatedChallenge;
    } catch (e, st) {
      logger.error('Error changing challenge status: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        statusChangeStatus:
            Status.error('Error al cambiar estado: ${e.toString()}'),
        error: e.toString(),
      ));
      return null;
    }
  }

  // ============================================
  // DELETE - Eliminar impugnación
  // ============================================

  /// Elimina una impugnación.
  ///
  /// Solo Admin y Super Admin pueden eliminar.
  Future<void> deleteChallenge(int id) async {
    if (!_isAdmin) {
      emit(state.copyWith(
        deleteStatus:
            Status.error('Solo administradores pueden eliminar impugnaciones'),
      ));
      return;
    }

    try {
      emit(state.copyWith(deleteStatus: Status.loading()));
      logger.info('Deleting challenge: $id');

      await _challengeRepository.deleteChallenge(id);

      logger.info('Challenge deleted successfully: $id');

      // Actualizar lista y estadísticas
      await refreshChallenges(pendingOnly: state.statusFilter == null);

      emit(state.copyWith(
        deleteStatus: Status.done('Impugnación eliminada exitosamente'),
        selectedChallenge: null,
        error: null,
      ));
    } catch (e, st) {
      logger.error('Error deleting challenge: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        deleteStatus:
            Status.error('Error al eliminar impugnación: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  // ============================================
  // FILTERS - Gestión de filtros
  // ============================================

  /// Aplica filtro por estado.
  Future<void> filterByStatus(ChallengeStatus? status) async {
    await refreshChallenges(status: status, pendingOnly: status == null);
  }

  /// Aplica filtro por academia.
  Future<void> filterByAcademy(int? academyId) async {
    await refreshChallenges(academyId: academyId);
  }

  /// Limpia todos los filtros.
  Future<void> clearFilters() async {
    emit(state.copyWith(
      statusFilter: null,
      academyFilter: null,
      searchQuery: '',
    ));
    await loadPendingChallenges();
  }

  /// Actualiza el término de búsqueda.
  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    logger.info('Search query updated: $query');
  }

  // ============================================
  // REORDER - Reordenar impugnaciones
  // ============================================

  /// Reordena las impugnaciones en la lista local.
  ///
  /// Este método solo actualiza el orden en el estado local.
  /// Si necesitas persistir el orden, debes implementar la lógica
  /// en el backend y llamar al repositorio correspondiente.
  void reorderChallenges(int oldIndex, int newIndex) {
    try {
      final challenges = List<Challenge>.from(state.challenges);

      // Ajustar el índice si es necesario
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      // Remover el item de la posición antigua e insertarlo en la nueva
      final challenge = challenges.removeAt(oldIndex);
      challenges.insert(newIndex, challenge);

      // Emitir el nuevo estado
      emit(state.copyWith(challenges: challenges));

      logger.info('Challenges reordered: moved from $oldIndex to $newIndex');
    } catch (e) {
      logger.error('Error reordering challenges: $e');
    }
  }

  // ============================================
  // MULTI-CHALLENGE - Operaciones masivas
  // ============================================

  /// Obtiene todas las impugnaciones de una pregunta específica.
  ///
  /// [questionId] - ID de la pregunta
  Future<List<Challenge>> fetchChallengesByQuestionId(int questionId) async {
    try {
      logger.info('Fetching challenges for question: $questionId');

      final challenges =
          await _challengeRepository.getChallengesByQuestionId(questionId);

      logger.info(
          'Fetched ${challenges.length} challenges for question $questionId');
      return challenges;
    } catch (e, st) {
      logger.error('Error fetching challenges by question: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener impugnaciones de la pregunta');
    }
  }

  /// Aplica una acción masiva (aprobar/rechazar) a múltiples impugnaciones.
  ///
  /// [challengeIds] - Lista de IDs de impugnaciones
  /// [status] - Estado a aplicar (approved o rejected)
  /// [reviewComments] - Comentarios de revisión
  Future<void> handleMassAction({
    required List<int> challengeIds,
    required ChallengeStatus status,
    String? reviewComments,
  }) async {
    if (!_canEdit) {
      emit(state.copyWith(
        statusChangeStatus:
            Status.error('No tienes permisos para cambiar el estado'),
      ));
      return;
    }

    try {
      emit(state.copyWith(statusChangeStatus: Status.loading()));
      logger.info(
          'Applying mass action to ${challengeIds.length} challenges: ${status.value}');

      final user = _authCubit.state.user;
      final reviewedBy = user?.userUuid;
      final currentEditorId = user?.id;

      // Actualizar cada impugnación
      for (final id in challengeIds) {
        // Buscar el challenge actual para verificar si ya tiene editor
        final currentChallenge = state.challenges.firstWhere(
          (c) => c.id == id,
          orElse: () => Challenge.empty,
        );

        // Solo establecer el editor si la impugnación no tiene uno ya asignado
        final editorId =
            (currentChallenge.editorId == null) ? currentEditorId : null;

        await _challengeRepository.updateChallengeStatus(
          id: id,
          status: status,
          reviewedBy: reviewedBy,
          editorId: editorId,
          reviewComments: reviewComments,
        );
      }

      logger.info('Mass action completed successfully');

      // Actualizar lista y estadísticas
      await refreshChallenges(pendingOnly: state.statusFilter == null);

      emit(state.copyWith(
        statusChangeStatus:
            Status.done('Impugnaciones actualizadas exitosamente'),
        error: null,
      ));
    } catch (e, st) {
      logger.error('Error in mass action: $e');
      logger.error('Stack trace: $st');
      emit(state.copyWith(
        statusChangeStatus:
            Status.error('Error al actualizar impugnaciones: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Aprueba múltiples impugnaciones a la vez.
  ///
  /// [challengeIds] - Lista de IDs de impugnaciones a aprobar
  /// [reviewComments] - Comentarios de revisión
  Future<void> approveChallenges(
    List<int> challengeIds, {
    String? reviewComments,
  }) async {
    await handleMassAction(
      challengeIds: challengeIds,
      status: ChallengeStatus.approved,
      reviewComments: reviewComments,
    );
  }

  /// Rechaza múltiples impugnaciones a la vez.
  ///
  /// [challengeIds] - Lista de IDs de impugnaciones a rechazar
  /// [reviewComments] - Comentarios de revisión
  Future<void> rejectChallenges(
    List<int> challengeIds, {
    String? reviewComments,
  }) async {
    await handleMassAction(
      challengeIds: challengeIds,
      status: ChallengeStatus.rejected,
      reviewComments: reviewComments,
    );
  }
}

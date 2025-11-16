import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/authentification/auth/cubit/auth_cubit.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/model/membership_level_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/memberships/repository/membership_repository.dart';
import '../../../../bootstrap.dart';

class MembershipCubit extends Cubit<MembershipState> {
  final MembershipRepository _membershipRepository;
  final AuthCubit _authCubit;

  MembershipCubit(this._membershipRepository, this._authCubit)
      : super(MembershipState.initial());

  /// Obtiene el specialty_id del usuario autenticado
  int? get _currentSpecialtyId => _authCubit.state.user.specialtyId;

  /// Verifica si el usuario actual es Admin o superior
  bool get _isAdmin => _authCubit.state.user.isAdmin;

  /// Obtiene todos los niveles de membresía
  Future<void> fetchMembershipLevels({
    bool activeOnly = false,
    bool withStats = false,
  }) async {
    try {
      emit(state.copyWith(
        fetchMembershipLevelsStatus: Status.loading(),
      ));

      final List<MembershipLevel> levels;

      if (_isAdmin) {
        // Admin ve todos los niveles de todas las especialidades
        levels = await _membershipRepository.getAllMembershipLevels(
          activeOnly: activeOnly,
        );
      } else {
        // Tutores solo ven los niveles de su especialidad
        if (_currentSpecialtyId == null) {
          throw Exception('No se puede determinar la especialidad del usuario');
        }
        levels = await _membershipRepository.getMembershipLevels(
          specialtyId: _currentSpecialtyId!,
          activeOnly: activeOnly,
        );
      }

      logger.debug(
          'Fetched ${levels.length} membership levels (specialtyId: $_currentSpecialtyId, isAdmin: $_isAdmin)');

      emit(state.copyWith(
        membershipLevels: levels,
        fetchMembershipLevelsStatus: Status.done(),
        error: null,
      ));

      // Si se solicitan estadísticas, cargarlas
      // if (withStats) {
      //   await fetchMembershipStats();
      // }
    } catch (e) {
      emit(state.copyWith(
        fetchMembershipLevelsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching membership levels: $e');
    }
  }

  /// Busca niveles de membresía por texto
  Future<void> searchMembershipLevels(String query) async {
    if (query.isEmpty) {
      await fetchMembershipLevels();
      return;
    }

    try {
      emit(state.copyWith(
        searchMembershipLevelsStatus: Status.loading(),
        searchQuery: query,
      ));

      if (_currentSpecialtyId == null && !_isAdmin) {
        throw Exception('No se puede determinar la especialidad del usuario');
      }

      final List<MembershipLevel> levels;

      if (_isAdmin) {
        // Admin busca en todas las especialidades
        final allLevels = await _membershipRepository.getAllMembershipLevels();
        levels = allLevels
            .where((level) =>
                level.name.toLowerCase().contains(query.toLowerCase()) ||
                (level.description
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false))
            .toList();
      } else {
        // Tutores buscan solo en su especialidad
        levels = await _membershipRepository.searchMembershipLevels(
          specialtyId: _currentSpecialtyId!,
          searchTerm: query,
        );
      }

      logger
          .debug('Found ${levels.length} membership levels matching "$query"');

      emit(state.copyWith(
        membershipLevels: levels,
        searchMembershipLevelsStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        searchMembershipLevelsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error searching membership levels: $e');
    }
  }

  /// Crea un nuevo nivel de membresía
  Future<void> createMembershipLevel(MembershipLevel membershipLevel) async {
    try {
      emit(state.copyWith(createMembershipLevelStatus: Status.loading()));

      final MembershipLevel levelToCreate;
      if (!_isAdmin && _currentSpecialtyId != null) {
        // Si no es admin, forzar la especialidad actual
        levelToCreate =
            membershipLevel.copyWith(specialtyId: _currentSpecialtyId);
      } else {
        levelToCreate = membershipLevel;
      }

      final newLevel =
          await _membershipRepository.createMembershipLevel(levelToCreate);

      // Agregar al inicio de la lista
      final updatedLevels = [newLevel, ...state.membershipLevels];
      emit(state.copyWith(
        membershipLevels: updatedLevels,
        createMembershipLevelStatus: Status.done(),
        error: null,
      ));

      logger.debug(
          'Membership level created successfully: ${newLevel.name} (specialty: ${newLevel.specialtyId})');
    } catch (e) {
      emit(state.copyWith(
        createMembershipLevelStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error creating membership level: $e');
    }
  }

  /// Actualiza un nivel de membresía existente
  Future<void> updateMembershipLevel(MembershipLevel membershipLevel) async {
    try {
      emit(state.copyWith(updateMembershipLevelStatus: Status.loading()));

      final updatedLevel =
          await _membershipRepository.updateMembershipLevel(membershipLevel);
      final updatedLevels = state.membershipLevels
          .map((level) => level.id == updatedLevel.id ? updatedLevel : level)
          .toList();

      emit(state.copyWith(
        membershipLevels: updatedLevels,
        selectedMembershipLevel:
            state.selectedMembershipLevel?.id == updatedLevel.id
                ? updatedLevel
                : state.selectedMembershipLevel,
        updateMembershipLevelStatus: Status.done(),
        error: null,
      ));

      logger
          .debug('Membership level updated successfully: ${updatedLevel.name}');
    } catch (e) {
      emit(state.copyWith(
        updateMembershipLevelStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error updating membership level: $e');
    }
  }

  /// Activa o desactiva un nivel de membresía
  Future<void> toggleMembershipLevelStatus(int id, bool isActive) async {
    try {
      emit(state.copyWith(updateMembershipLevelStatus: Status.loading()));

      final updatedLevel =
          await _membershipRepository.toggleMembershipLevelStatus(id, isActive);
      final updatedLevels = state.membershipLevels
          .map((level) => level.id == id ? updatedLevel : level)
          .toList();

      emit(state.copyWith(
        membershipLevels: updatedLevels,
        selectedMembershipLevel: state.selectedMembershipLevel?.id == id
            ? updatedLevel
            : state.selectedMembershipLevel,
        updateMembershipLevelStatus: Status.done(),
        error: null,
      ));

      logger.debug('Membership level status toggled: $id to $isActive');
    } catch (e) {
      emit(state.copyWith(
        updateMembershipLevelStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error toggling membership level status: $e');
    }
  }

  /// Elimina un nivel de membresía
  Future<void> deleteMembershipLevel(int id) async {
    try {
      emit(state.copyWith(deleteMembershipLevelStatus: Status.loading()));

      await _membershipRepository.deleteMembershipLevel(id);
      final updatedLevels =
          state.membershipLevels.where((level) => level.id != id).toList();

      emit(state.copyWith(
        membershipLevels: updatedLevels,
        selectedMembershipLevel: state.selectedMembershipLevel?.id == id
            ? null
            : state.selectedMembershipLevel,
        deleteMembershipLevelStatus: Status.done(),
        error: null,
      ));

      logger.debug('Membership level deleted successfully: ID $id');
    } catch (e) {
      emit(state.copyWith(
        deleteMembershipLevelStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error deleting membership level: $e');
    }
  }

  /// Obtiene estadísticas de usuarios por nivel de membresía
  // Future<void> fetchMembershipStats() async {
  //   try {
  //     emit(state.copyWith(fetchStatsStatus: Status.loading()));

  //     final Map<int, int> userCounts = {};

  //     // Obtener el conteo de usuarios para cada nivel
  //     for (final level in state.membershipLevels) {
  //       if (level.id != null) {
  //         final count = await _membershipRepository
  //             .countUsersWithMembershipLevel(level.id!);
  //         userCounts[level.id!] = count;
  //       }
  //     }

  //     emit(state.copyWith(
  //       userCountByLevel: userCounts,
  //       fetchStatsStatus: Status.done(),
  //       error: null,
  //     ));

  //     logger.debug('Fetched membership stats for ${userCounts.length} levels');
  //   } catch (e) {
  //     emit(state.copyWith(
  //       fetchStatsStatus: Status.error('Error: ${e.toString()}'),
  //       error: e.toString(),
  //     ));
  //     logger.error('Error fetching membership stats: $e');
  //   }
  // }

  /// Obtiene el conteo de usuarios para un nivel específico
  int getUserCountForLevel(int levelId) {
    return state.userCountByLevel[levelId] ?? 0;
  }

  /// Selecciona un nivel de membresía
  void selectMembershipLevel(MembershipLevel? level) {
    emit(state.copyWith(selectedMembershipLevel: level));
  }

  /// Limpia los errores
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Limpia la búsqueda y recarga todos los niveles
  Future<void> clearSearch() async {
    emit(state.copyWith(searchQuery: null));
    await fetchMembershipLevels();
  }
}

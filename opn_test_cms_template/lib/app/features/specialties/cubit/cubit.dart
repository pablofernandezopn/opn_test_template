import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:opn_test_guardia_civil_cms/app/features/specialties/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';
import 'package:opn_test_guardia_civil_cms/app/features/specialties/repository/repository.dart';
import '../../../../bootstrap.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';

class SpecialtyCubit extends Cubit<SpecialtyState> {
  final SpecialtyRepository _specialtyRepository;
  final AuthCubit _authCubit;

  SpecialtyCubit(this._specialtyRepository, this._authCubit)
      : super(SpecialtyState.initial()) {
    loadSpecialties();
  }

  /// Obtiene el academy_id del usuario autenticado
  int? get _currentAcademyId => _authCubit.state.user.academyId;

  /// Carga todas las especialidades
  Future<void> loadSpecialties({int? academyId}) async {
    try {
      emit(state.copyWith(fetchStatus: Status.loading()));

      // Usar el academyId del usuario autenticado si no se proporciona uno

      final specialties = await _specialtyRepository.fetchSpecialties();

      // Filtrar especialidades activas
      final activeSpecialties = specialties.where((s) => s.isActive).toList();

      logger.debug('Fetched specialties: $specialties');
      emit(state.copyWith(
        fetchStatus: Status.done(),
        specialties: specialties,
        activeSpecialties: activeSpecialties,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching specialties: $e');
    }
  }

  /// Carga una especialidad específica por ID
  Future<void> loadSpecialtyById(int id) async {
    try {
      emit(state.copyWith(fetchStatus: Status.loading()));

      final specialty = await _specialtyRepository.fetchSpecialtyById(id);
      emit(state.copyWith(
        fetchStatus: Status.done(),
        selectedSpecialty: specialty,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching specialty by id: $e');
    }
  }

  /// Crea una nueva especialidad
  Future<bool> createSpecialty(Specialty specialty) async {
    try {
      emit(state.copyWith(createStatus: Status.loading()));

      final newSpecialty =
          await _specialtyRepository.createSpecialty(specialty);
      final updatedList = [...state.specialties, newSpecialty];
      final activeList = updatedList.where((s) => s.isActive).toList();

      emit(state.copyWith(
        createStatus: Status.done('Especialidad creada exitosamente'),
        specialties: updatedList,
        activeSpecialties: activeList,
        error: null,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        createStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error creating specialty: $e');
      return false;
    }
  }

  /// Actualiza una especialidad existente
  Future<bool> updateSpecialty(int id, Specialty specialty) async {
    try {
      emit(state.copyWith(updateStatus: Status.loading()));

      final updatedSpecialty =
          await _specialtyRepository.updateSpecialty(id, specialty);
      final updatedList = state.specialties
          .map((s) => s.id == id ? updatedSpecialty : s)
          .toList();
      final activeList = updatedList.where((s) => s.isActive).toList();

      emit(state.copyWith(
        updateStatus: Status.done('Especialidad actualizada exitosamente'),
        specialties: updatedList,
        activeSpecialties: activeList,
        selectedSpecialty: updatedSpecialty,
        error: null,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        updateStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error updating specialty: $e');
      return false;
    }
  }

  /// Elimina una especialidad
  Future<bool> deleteSpecialty(int id) async {
    try {
      emit(state.copyWith(deleteStatus: Status.loading()));

      await _specialtyRepository.deleteSpecialty(id);
      final updatedList = state.specialties.where((s) => s.id != id).toList();
      final activeList = updatedList.where((s) => s.isActive).toList();

      emit(state.copyWith(
        deleteStatus: Status.done('Especialidad eliminada exitosamente'),
        specialties: updatedList,
        activeSpecialties: activeList,
        selectedSpecialty: null,
        error: null,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        deleteStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error deleting specialty: $e');
      return false;
    }
  }

  /// Cambia el estado activo de una especialidad
  Future<void> toggleActive(int id, bool isActive) async {
    try {
      emit(state.copyWith(toggleActiveStatus: Status.loading()));

      final updatedSpecialty =
          await _specialtyRepository.updateSpecialtyActive(id, isActive);
      final updatedList = state.specialties
          .map((s) => s.id == id ? updatedSpecialty : s)
          .toList();
      final activeList = updatedList.where((s) => s.isActive).toList();

      emit(state.copyWith(
        toggleActiveStatus: Status.done(),
        specialties: updatedList,
        activeSpecialties: activeList,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        toggleActiveStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error toggling specialty active status: $e');
    }
  }

  /// Reordena las especialidades
  Future<void> reorderSpecialties(List<Map<String, dynamic>> updates) async {
    try {
      emit(state.copyWith(updateStatus: Status.loading()));

      await _specialtyRepository.updateSpecialtiesOrder(updates);
      // Recargar las especialidades después de reordenar
      await loadSpecialties(academyId: state.academyFilter);
    } catch (e) {
      emit(state.copyWith(
        updateStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error reordering specialties: $e');
    }
  }

  /// Selecciona una especialidad
  void selectSpecialty(Specialty? specialty) {
    emit(state.copyWith(selectedSpecialty: specialty));
  }

  /// Limpia el error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Aplica filtros
  void applyFilters({int? academyId, bool? isActive}) {
    emit(state.copyWith(
      academyFilter: academyId,
      isActiveFilter: isActive,
    ));
  }

  /// Limpia los filtros
  void clearFilters() {
    emit(state.copyWith(
      academyFilter: null,
      isActiveFilter: null,
    ));
  }
}

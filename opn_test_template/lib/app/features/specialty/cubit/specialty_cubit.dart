import 'package:bloc/bloc.dart';
import 'package:opn_test_template/app/features/specialty/cubit/specialty_state.dart';
import 'package:opn_test_template/app/features/specialty/model/specialty_model.dart';
import 'package:opn_test_template/app/features/specialty/repository/specialty_repository.dart';
import 'package:opn_test_template/bootstrap.dart';

class SpecialtyCubit extends Cubit<SpecialtyState> {
  final SpecialtyRepository _specialtyRepository;

  SpecialtyCubit({
    required SpecialtyRepository specialtyRepository,
  })  : _specialtyRepository = specialtyRepository,
        super(const SpecialtyState());

  /// Carga las especialidades disponibles para una academia
  Future<void> loadSpecialties(int academyId) async {
    try {
      emit(state.copyWith(status: SpecialtyStatus.loading));

      final specialties =
          await _specialtyRepository.fetchSpecialtiesByAcademy(academyId);

      emit(state.copyWith(
        status: SpecialtyStatus.loaded,
        specialties: specialties,
      ));

      logger.info('Especialidades cargadas: ${specialties.length}');
    } catch (e, stackTrace) {
      logger.error('Error al cargar especialidades: $e');
      logger.debug('StackTrace: $stackTrace');

      emit(state.copyWith(
        status: SpecialtyStatus.error,
        errorMessage: 'Error al cargar especialidades: $e',
      ));
    }
  }

  /// Carga la especialidad actual del usuario
  Future<void> loadCurrentSpecialty(int userId) async {
    try {
      final specialtyId = await _specialtyRepository.fetchUserSpecialtyId(userId);

      if (specialtyId != null) {
        final specialty = await _specialtyRepository.fetchSpecialtyById(specialtyId);

        if (specialty != null) {
          emit(state.copyWith(
            currentSpecialty: specialty,
            status: SpecialtyStatus.loaded,
          ));
          logger.info('Especialidad actual del usuario: ${specialty.name}');
        }
      } else {
        logger.info('Usuario sin especialidad asignada');
      }
    } catch (e, stackTrace) {
      logger.error('Error al cargar especialidad actual: $e');
      logger.debug('StackTrace: $stackTrace');
    }
  }

  /// Inicializa las especialidades: carga las disponibles y la actual del usuario
  Future<void> initialize(int userId, int academyId) async {
    try {
      emit(state.copyWith(status: SpecialtyStatus.loading));

      // Cargar especialidades disponibles
      final specialties =
          await _specialtyRepository.fetchSpecialtiesByAcademy(academyId);

      // Cargar especialidad actual del usuario
      final specialtyId = await _specialtyRepository.fetchUserSpecialtyId(userId);
      Specialty? currentSpecialty;

      if (specialtyId != null) {
        currentSpecialty = await _specialtyRepository.fetchSpecialtyById(specialtyId);
      }

      emit(state.copyWith(
        status: SpecialtyStatus.loaded,
        specialties: specialties,
        currentSpecialty: currentSpecialty,
      ));

      logger.info('SpecialtyCubit inicializado correctamente');
      logger.info('Especialidades disponibles: ${specialties.length}');
      logger.info('Especialidad actual: ${currentSpecialty?.name ?? "Ninguna"}');
    } catch (e, stackTrace) {
      logger.error('Error al inicializar SpecialtyCubit: $e');
      logger.debug('StackTrace: $stackTrace');

      emit(state.copyWith(
        status: SpecialtyStatus.error,
        errorMessage: 'Error al inicializar especialidades: $e',
      ));
    }
  }

  /// Actualiza la especialidad del usuario
  Future<bool> updateSpecialty(int userId, Specialty specialty) async {
    try {
      emit(state.copyWith(status: SpecialtyStatus.loading));

      await _specialtyRepository.updateUserSpecialty(userId, specialty.id);

      emit(state.copyWith(
        status: SpecialtyStatus.loaded,
        currentSpecialty: specialty,
      ));

      logger.info('Especialidad actualizada a: ${specialty.name}');
      return true;
    } catch (e, stackTrace) {
      logger.error('Error al actualizar especialidad: $e');
      logger.debug('StackTrace: $stackTrace');

      emit(state.copyWith(
        status: SpecialtyStatus.error,
        errorMessage: 'Error al actualizar especialidad: $e',
      ));
      return false;
    }
  }

  /// Selecciona una especialidad temporal (sin guardar en BD)
  void selectSpecialty(Specialty specialty) {
    emit(state.copyWith(currentSpecialty: specialty));
  }

  /// Resetea el estado
  void reset() {
    emit(const SpecialtyState());
  }
}
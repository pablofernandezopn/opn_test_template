import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/streak_repository.dart';
import 'streak_state.dart';
import '../model/streak_data_model.dart';

class StreakCubit extends Cubit<StreakState> {
  final StreakRepository _repository;
  final int userId;

  StreakCubit({
    required StreakRepository repository,
    required this.userId,
  })  : _repository = repository,
        super(const StreakState.initial());

  /// Carga los datos de racha del usuario
  Future<void> loadStreakData() async {
    emit(const StreakState.loading());
    try {
      final streakData = await _repository.getUserStreakData(userId);
      emit(StreakState.loaded(streakData));
    } catch (e) {
      emit(StreakState.error('Error al cargar los datos de racha: $e'));
    }
  }

  /// Recalcula manualmente la racha del usuario
  Future<void> recalculateStreak() async {
    try {
      await _repository.recalculateUserStreak(userId);
      await loadStreakData(); // Recargar después de recalcular
    } catch (e) {
      emit(StreakState.error('Error al recalcular la racha: $e'));
    }
  }

  /// Refresca los datos de racha
  Future<void> refresh() async {
    await loadStreakData();
  }

  /// Obtiene los datos actuales si el estado es loaded
  StreakData? get currentStreakData {
    return state.maybeWhen(
      loaded: (data) => data,
      orElse: () => null,
    );
  }
}

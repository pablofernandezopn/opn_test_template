import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/challenge_model.dart';
import '../repository/challenge_repository.dart';
import 'challenge_state.dart';
import '../../../../bootstrap.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';

class ChallengeCubit extends Cubit<ChallengeState> {
  final ChallengeRepository _challengeRepository;
  final AuthCubit _authCubit;
  static const int _pageSize = 20;

  ChallengeCubit(this._challengeRepository, this._authCubit)
      : super(ChallengeState.initial());

  /// Obtiene el userId actual del usuario autenticado
  int get _userId => _authCubit.state.user.id;

  /// Carga inicial de impugnaciones
  Future<void> fetchChallenges() async {
    try {
      emit(state.copyWith(
        fetchChallengesStatus: Status.loading(),
        currentPage: 0,
      ));

      final challenges = await _challengeRepository.fetchUserChallenges(
        userId: _userId,
        offset: 0,
        limit: _pageSize,
      );

      logger.debug('✅ [CHALLENGE_CUBIT] Fetched ${challenges.length} challenges for user $_userId');

      emit(state.copyWith(
        challenges: challenges,
        fetchChallengesStatus: Status.done(),
        hasMoreData: challenges.length >= _pageSize,
        error: null,
      ));
    } catch (e) {
      logger.error('❌ [CHALLENGE_CUBIT] Error fetching challenges: $e');
      emit(state.copyWith(
        fetchChallengesStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Carga más impugnaciones (scroll infinito)
  Future<void> loadMoreChallenges() async {
    // No cargar si ya está cargando o no hay más datos
    if (state.loadMoreStatus.isLoading || !state.hasMoreData) {
      return;
    }

    try {
      emit(state.copyWith(loadMoreStatus: Status.loading()));

      final nextPage = state.currentPage + 1;
      final offset = nextPage * _pageSize;

      final moreChallenges = await _challengeRepository.fetchUserChallenges(
        userId: _userId,
        offset: offset,
        limit: _pageSize,
      );

      logger.debug('✅ [CHALLENGE_CUBIT] Loaded ${moreChallenges.length} more challenges');

      final updatedChallenges = [...state.challenges, ...moreChallenges];

      emit(state.copyWith(
        challenges: updatedChallenges,
        currentPage: nextPage,
        loadMoreStatus: Status.done(),
        hasMoreData: moreChallenges.length >= _pageSize,
        error: null,
      ));
    } catch (e) {
      logger.error('❌ [CHALLENGE_CUBIT] Error loading more challenges: $e');
      emit(state.copyWith(
        loadMoreStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Crea una nueva impugnación
  Future<bool> createChallenge({
    required int questionId,
    required int topicId,
    required String reason,
    required int academyId,
    int? specialtyId,
  }) async {
    try {
      // Validar que el usuario esté autenticado
      if (_userId == 0) {
        logger.error('❌ [CHALLENGE_CUBIT] Cannot create challenge: User not authenticated');
        emit(state.copyWith(
          createChallengeStatus: Status.error('Usuario no autenticado'),
          error: 'Usuario no autenticado',
        ));
        return false;
      }

      emit(state.copyWith(createChallengeStatus: Status.loading()));

      final challenge = Challenge(
        userId: _userId,
        questionId: questionId,
        topicId: topicId,
        reason: reason,
        academyId: academyId,
        specialtyId: specialtyId,
        state: ChallengeStatus.pendiente,
        open: true,
      );

      final createdChallenge = await _challengeRepository.createChallenge(challenge);

      logger.debug('✅ [CHALLENGE_CUBIT] Challenge created with id: ${createdChallenge.id}');

      // Agregar la nueva impugnación al inicio de la lista
      final updatedChallenges = [createdChallenge, ...state.challenges];

      emit(state.copyWith(
        challenges: updatedChallenges,
        createChallengeStatus: Status.done(),
        error: null,
      ));

      return true;
    } catch (e) {
      logger.error('❌ [CHALLENGE_CUBIT] Error creating challenge: $e');
      emit(state.copyWith(
        createChallengeStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Refresca la lista de impugnaciones
  Future<void> refresh() async {
    await fetchChallenges();
  }
}
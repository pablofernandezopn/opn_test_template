import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_template/app/features/history/cubit/history_state.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../../../authentification/auth/cubit/auth_state.dart';
import '../repository/history_repository.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final HistoryRepository _historyRepository;
  final AuthCubit _authCubit;
  StreamSubscription<AuthState>? _authSubscription;

  HistoryCubit(this._historyRepository, this._authCubit) : super(HistoryState.initial()) {
    _listenToAuthChanges();
  }

  /// Escucha los cambios en el estado de autenticación
  void _listenToAuthChanges() {
    _authSubscription = _authCubit.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated) {
        // Cuando el usuario se autentica, cargar los tests recientes para home
        fetchRecentTests();
      }
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  /// Obtiene el user_id del usuario autenticado
  int? get _currentUserId => _authCubit.state.user.id;

  /// Obtiene el historial completo con paginación
  Future<void> fetchHistory({
    bool refresh = false,
    int? topicTypeFilter,
    bool clearFilter = false,
  }) async {
    if (_currentUserId == null) return;

    try {
      // Determinar el filtro a usar
      final filterToUse = clearFilter ? null : (topicTypeFilter ?? state.selectedTopicTypeFilter);

      if (refresh) {
        emit(state.copyWith(
          fetchHistoryStatus: Status.loading(),
          currentPage: 0,
          tests: [],
        ));
      } else {
        emit(state.copyWith(fetchHistoryStatus: Status.loading()));
      }

      final tests = await _historyRepository.fetchUserTests(
        userId: _currentUserId!,
        limit: state.pageSize,
        offset: refresh ? 0 : state.currentPage * state.pageSize,
        topicTypeFilter: filterToUse,
      );

      final hasMore = tests.length == state.pageSize;

      if (refresh) {
        emit(state.copyWith(
          tests: tests,
          fetchHistoryStatus: Status.done(),
          hasMore: hasMore,
          currentPage: 0,
          selectedTopicTypeFilter: filterToUse,
          error: null,
        ));
      } else {
        emit(state.copyWith(
          tests: [...state.tests, ...tests],
          fetchHistoryStatus: Status.done(),
          hasMore: hasMore,
          selectedTopicTypeFilter: filterToUse,
          error: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        fetchHistoryStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Carga más tests (scroll infinito)
  Future<void> loadMore() async {
    if (_currentUserId == null || !state.hasMore || state.loadMoreStatus.isLoading) {
      return;
    }

    try {
      emit(state.copyWith(loadMoreStatus: Status.loading()));

      final nextPage = state.currentPage + 1;
      final tests = await _historyRepository.fetchUserTests(
        userId: _currentUserId!,
        limit: state.pageSize,
        offset: nextPage * state.pageSize,
        topicTypeFilter: state.selectedTopicTypeFilter,
      );

      final hasMore = tests.length == state.pageSize;

      emit(state.copyWith(
        tests: [...state.tests, ...tests],
        loadMoreStatus: Status.done(),
        currentPage: nextPage,
        hasMore: hasMore,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        loadMoreStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Obtiene los 3 tests más recientes para mostrar en home
  Future<void> fetchRecentTests() async {
    if (_currentUserId == null) return;

    try {
      emit(state.copyWith(fetchRecentTestsStatus: Status.loading()));

      final tests = await _historyRepository.fetchUserTests(
        userId: _currentUserId!,
        limit: 3,
        offset: 0,
      );

      emit(state.copyWith(
        recentTests: tests,
        fetchRecentTestsStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchRecentTestsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
    }
  }

  /// Aplica un filtro por tipo de topic
  void applyTopicTypeFilter(int? topicTypeId) {
    if (topicTypeId == state.selectedTopicTypeFilter) return;
    // Si topicTypeId es null, significa "Todos", así que limpiamos el filtro
    fetchHistory(
      refresh: true,
      topicTypeFilter: topicTypeId,
      clearFilter: topicTypeId == null,
    );
  }

  /// Limpia el filtro
  void clearFilter() {
    fetchHistory(refresh: true, clearFilter: true);
  }

  /// Recarga el historial (para cuando se complete un test)
  Future<void> refresh() async {
    await Future.wait([
      fetchHistory(refresh: true),
      fetchRecentTests(),
    ]);
  }

  /// Obtiene las respuestas del test como objetos UserTestAnswer
  Future<List<dynamic>> fetchTestAnswers(int userTestId) async {
    return await _historyRepository.fetchTestAnswersForReview(userTestId);
  }
}
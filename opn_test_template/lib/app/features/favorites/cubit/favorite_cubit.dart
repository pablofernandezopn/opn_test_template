import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bootstrap.dart';
import '../repository/favorite_repository.dart';
import '../model/favorite_question_model.dart';
import 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit(this._repository) : super(const FavoriteState());

  final FavoriteRepository _repository;

  /// Carga todas las preguntas favoritas de un usuario
  Future<void> loadFavorites(int userId) async {
    try {
      emit(state.copyWith(status: FavoriteStatus.loading));

      final favorites = await _repository.fetchUserFavorites(userId);
      final favoriteIds = favorites.map((f) => f.questionId).toSet();

      emit(state.copyWith(
        status: FavoriteStatus.success,
        favorites: favorites,
        favoriteQuestionIds: favoriteIds,
      ));
    } catch (e) {
      logger.error('Error loading favorites: $e');
      emit(state.copyWith(
        status: FavoriteStatus.error,
        errorMessage: 'Error al cargar favoritos',
      ));
    }
  }

  /// Añade una pregunta a favoritos
  Future<bool> addFavorite(int userId, int questionId) async {
    try {
      final favorite = await _repository.addFavorite(userId, questionId);

      final updatedFavorites = [...state.favorites, favorite];
      final updatedIds = {...state.favoriteQuestionIds, questionId};

      emit(state.copyWith(
        favorites: updatedFavorites,
        favoriteQuestionIds: updatedIds,
      ));

      return true;
    } catch (e) {
      logger.error('Error adding favorite: $e');
      return false;
    }
  }

  /// Elimina una pregunta de favoritos
  Future<bool> removeFavorite(int userId, int questionId) async {
    try {
      await _repository.removeFavorite(userId, questionId);

      final updatedFavorites = state.favorites
          .where((f) => f.questionId != questionId)
          .toList();
      final updatedIds = {...state.favoriteQuestionIds}..remove(questionId);

      emit(state.copyWith(
        favorites: updatedFavorites,
        favoriteQuestionIds: updatedIds,
      ));

      return true;
    } catch (e) {
      logger.error('Error removing favorite: $e');
      return false;
    }
  }

  /// Verifica si una pregunta es favorita
  bool isFavorite(int questionId) {
    return state.favoriteQuestionIds.contains(questionId);
  }

  /// Alterna el estado de favorito de una pregunta
  Future<bool> toggleFavorite(int userId, int questionId) async {
    if (isFavorite(questionId)) {
      return await removeFavorite(userId, questionId);
    } else {
      // Intentar agregar el favorito
      final success = await addFavorite(userId, questionId);

      // Si falla porque ya existe (error de duplicado),
      // verificar en la base de datos y actualizar el estado local
      if (!success) {
        try {
          final isActuallyFavorite = await _repository.isFavorite(userId, questionId);
          if (isActuallyFavorite) {
            logger.info('📌 [FAVORITE_CUBIT] Question $questionId was already favorite, removing it instead');
            // Actualizar el estado local primero
            final updatedIds = {...state.favoriteQuestionIds, questionId};
            emit(state.copyWith(favoriteQuestionIds: updatedIds));
            // Ahora remover
            return await removeFavorite(userId, questionId);
          }
        } catch (e) {
          logger.error('Error checking favorite status: $e');
        }
      }

      return success;
    }
  }

  /// Refresca la lista de favoritos
  Future<void> refresh(int userId) async {
    await loadFavorites(userId);
  }
}
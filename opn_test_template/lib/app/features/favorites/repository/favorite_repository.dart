import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../bootstrap.dart';
import '../model/favorite_question_model.dart';

class FavoriteRepository {
  SupabaseClient get supabase => Supabase.instance.client;

  /// Obtiene todas las preguntas favoritas de un usuario
  Future<List<FavoriteQuestion>> fetchUserFavorites(int userId) async {
    try {
      final response = await supabase
          .from('user_favorite_questions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FavoriteQuestion.fromJson(json))
          .toList();
    } catch (e) {
      logger.error('Error fetching user favorites: $e');
      throw Exception('Error fetching user favorites: $e');
    }
  }

  /// Verifica si una pregunta es favorita para un usuario
  Future<bool> isFavorite(int userId, int questionId) async {
    try {
      final response = await supabase
          .from('user_favorite_questions')
          .select()
          .eq('user_id', userId)
          .eq('question_id', questionId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      logger.error('Error checking if question is favorite: $e');
      return false;
    }
  }

  /// Añade una pregunta a favoritos
  Future<FavoriteQuestion> addFavorite(int userId, int questionId) async {
    try {
      final favorite = FavoriteQuestion(
        userId: userId,
        questionId: questionId,
      );

      final response = await supabase
          .from('user_favorite_questions')
          .insert(favorite.toJson())
          .select()
          .single();

      return FavoriteQuestion.fromJson(response);
    } catch (e) {
      logger.error('Error adding favorite: $e');
      throw Exception('Error adding favorite: $e');
    }
  }

  /// Elimina una pregunta de favoritos
  Future<void> removeFavorite(int userId, int questionId) async {
    try {
      await supabase
          .from('user_favorite_questions')
          .delete()
          .eq('user_id', userId)
          .eq('question_id', questionId);
    } catch (e) {
      logger.error('Error removing favorite: $e');
      throw Exception('Error removing favorite: $e');
    }
  }

  /// Obtiene los IDs de todas las preguntas favoritas de un usuario
  Future<Set<int>> fetchUserFavoriteQuestionIds(int userId) async {
    try {
      final response = await supabase
          .from('user_favorite_questions')
          .select('question_id')
          .eq('user_id', userId);

      return (response as List)
          .map((item) => item['question_id'] as int)
          .toSet();
    } catch (e) {
      logger.error('Error fetching user favorite question IDs: $e');
      return {};
    }
  }

  /// Elimina un favorito por su ID
  Future<void> deleteFavoriteById(int favoriteId) async {
    try {
      await supabase
          .from('user_favorite_questions')
          .delete()
          .eq('id', favoriteId);
    } catch (e) {
      logger.error('Error deleting favorite by ID: $e');
      throw Exception('Error deleting favorite by ID: $e');
    }
  }
}
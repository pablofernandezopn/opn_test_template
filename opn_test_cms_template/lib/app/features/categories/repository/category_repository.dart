import 'package:opn_test_guardia_civil_cms/app/features/categories/model/category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  /// Obtiene todas las categorías
  Future<List<Category>> fetchCategories() async {
    final response = await _supabaseClient
        .from('categories')
        .select()
        .order('created_at', ascending: false);

    return response.map((json) => Category.fromJson(json)).toList();
  }

  /// Obtiene las categorías de un topic_type específico
  Future<List<Category>> fetchCategoriesByTopicType(int topicTypeId) async {
    final response = await _supabaseClient
        .from('categories')
        .select()
        .eq('topic_type', topicTypeId)
        .order('name', ascending: true);

    return response.map((json) => Category.fromJson(json)).toList();
  }

  /// Crea una nueva categoría
  Future<Category> createCategory(Category category) async {
    final response = await _supabaseClient
        .from('categories')
        .insert(category.toJson())
        .select();

    return Category.fromJson(response.first);
  }

  /// Actualiza una categoría existente
  Future<Category> updateCategory(int id, Category category) async {
    final response = await _supabaseClient
        .from('categories')
        .update(category.toJson())
        .eq('id', id)
        .select();

    return Category.fromJson(response.first);
  }

  /// Elimina una categoría
  Future<void> deleteCategory(int id) async {
    await _supabaseClient.from('categories').delete().eq('id', id);
  }
}
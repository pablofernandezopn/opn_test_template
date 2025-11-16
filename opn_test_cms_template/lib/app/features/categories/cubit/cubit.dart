import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/categories/cubit/state.dart';
import '../../../../bootstrap.dart';
import '../../topics/cubit/state.dart';
import '../model/category_model.dart';
import '../repository/category_repository.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryCubit(this._categoryRepository) : super(CategoryState.initial());

  /// Obtiene todas las categorías
  Future<void> fetchCategories() async {
    try {
      emit(state.copyWith(fetchStatus: Status.loading()));
      final categories = await _categoryRepository.fetchCategories();
      emit(state.copyWith(
        categories: categories,
        fetchStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching categories: $e');
    }
  }

  /// Obtiene las categorías de un topic_type específico
  Future<void> fetchCategoriesByTopicType(int topicTypeId) async {
    try {
      emit(state.copyWith(fetchStatus: Status.loading()));
      final categories = await _categoryRepository.fetchCategoriesByTopicType(topicTypeId);
      emit(state.copyWith(
        categories: categories,
        fetchStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching categories by topic type: $e');
    }
  }

  /// Crea una nueva categoría
  Future<void> createCategory({
    required String name,
    required int topicTypeId,
  }) async {
    try {
      emit(state.copyWith(createStatus: Status.loading()));
      final newCategory = Category(
        name: name,
        topicType: topicTypeId,
        createdAt: DateTime.now(),
      );
      final createdCategory = await _categoryRepository.createCategory(newCategory);

      // Añadir la nueva categoría a la lista
      final updatedCategories = [...state.categories, createdCategory];

      emit(state.copyWith(
        categories: updatedCategories,
        createStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        createStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error creating category: $e');
    }
  }

  /// Actualiza una categoría existente
  Future<void> updateCategory(int id, Category category) async {
    try {
      emit(state.copyWith(updateStatus: Status.loading()));
      final updatedCategory = await _categoryRepository.updateCategory(id, category);

      // Actualizar la categoría en la lista
      final updatedCategories = state.categories
          .map((c) => c.id == id ? updatedCategory : c)
          .toList();

      emit(state.copyWith(
        categories: updatedCategories,
        updateStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        updateStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error updating category: $e');
    }
  }

  /// Elimina una categoría
  Future<void> deleteCategory(int id) async {
    try {
      emit(state.copyWith(deleteStatus: Status.loading()));
      await _categoryRepository.deleteCategory(id);

      // Eliminar la categoría de la lista
      final updatedCategories = state.categories.where((c) => c.id != id).toList();

      emit(state.copyWith(
        categories: updatedCategories,
        deleteStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        deleteStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error deleting category: $e');
    }
  }
}
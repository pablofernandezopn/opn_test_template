import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/category_model.dart';
import '../../topics/cubit/state.dart';

part 'state.freezed.dart';

@freezed
class CategoryState with _$CategoryState {
  const factory CategoryState({
    @Default([]) List<Category> categories,
    required Status fetchStatus,
    required Status createStatus,
    required Status updateStatus,
    required Status deleteStatus,
    String? error,
  }) = _CategoryState;

  const CategoryState._();

  // Helper para crear estado inicial
  factory CategoryState.initial() => CategoryState(
        fetchStatus: Status.done(),
        createStatus: Status.done(),
        updateStatus: Status.done(),
        deleteStatus: Status.done(),
        error: null,
      );
}
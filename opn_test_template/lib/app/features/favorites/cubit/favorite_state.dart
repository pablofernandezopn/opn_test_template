import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/favorite_question_model.dart';

part 'favorite_state.freezed.dart';

enum FavoriteStatus {
  initial,
  loading,
  success,
  error,
}

@freezed
class FavoriteState with _$FavoriteState {
  const factory FavoriteState({
    @Default(FavoriteStatus.initial) FavoriteStatus status,
    @Default([]) List<FavoriteQuestion> favorites,
    @Default({}) Set<int> favoriteQuestionIds,
    @Default('') String errorMessage,
  }) = _FavoriteState;
}
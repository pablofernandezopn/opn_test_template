import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/streak_data_model.dart';

part 'streak_state.freezed.dart';

@freezed
class StreakState with _$StreakState {
  const factory StreakState.initial() = _Initial;
  const factory StreakState.loading() = _Loading;
  const factory StreakState.loaded(StreakData data) = _Loaded;
  const factory StreakState.error(String message) = _Error;
}

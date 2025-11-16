import 'package:bloc/bloc.dart';

/// Controls whether the initial data required for the home screen is ready.
class LoadingCubit extends Cubit<bool> {
  LoadingCubit() : super(false);

  /// Mark the initial data as loaded.
  void markReady() {
    if (!state) {
      emit(true);
    }
  }

  /// Reset the loading state, useful for logging out or refreshing sessions.
  void reset() {
    if (state) emit(false);
  }
}

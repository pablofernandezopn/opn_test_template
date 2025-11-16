import 'package:bloc/bloc.dart';

/// Controls whether the intro video has finished playing.
class VideoLoadingCubit extends Cubit<bool> {
  VideoLoadingCubit() : super(false);

  /// Mark the video as finished.
  void markVideoFinished() {
    if (!state) {
      emit(true);
    }
  }

  /// Reset the video state, useful for restarting the app.
  void reset() {
    if (state) emit(false);
  }
}
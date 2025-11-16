import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/pomodoro_config.dart';

part 'pomodoro_state.freezed.dart';

/// Tipo de sesión del pomodoro
enum PomodoroSessionType {
  work,
  shortBreak,
  longBreak,
}

/// Estado del timer
enum TimerStatus {
  initial,
  running,
  paused,
  completed,
}

@freezed
class PomodoroState with _$PomodoroState {
  const factory PomodoroState({
    /// Configuración actual del pomodoro
    required PomodoroConfig config,

    /// Tipo de sesión actual
    required PomodoroSessionType sessionType,

    /// Estado del timer
    required TimerStatus timerStatus,

    /// Segundos restantes en la sesión actual
    required int remainingSeconds,

    /// Número de sesión de trabajo completadas
    @Default(0) int completedSessions,

    /// Total de sesiones de trabajo completadas hoy
    @Default(0) int totalSessionsToday,

    /// Total de minutos estudiados hoy
    @Default(0) int totalMinutesToday,

    /// Si se está mostrando la configuración
    @Default(false) bool showingSettings,
  }) = _PomodoroState;

  const PomodoroState._();

  /// Helper para crear estado inicial
  factory PomodoroState.initial() {
    const config = PomodoroConfig.defaultConfig;
    return PomodoroState(
      config: config,
      sessionType: PomodoroSessionType.work,
      timerStatus: TimerStatus.initial,
      remainingSeconds: config.workDuration * 60,
    );
  }

  /// Obtiene la duración total de la sesión actual en segundos
  int get sessionDurationSeconds {
    switch (sessionType) {
      case PomodoroSessionType.work:
        return config.workDuration * 60;
      case PomodoroSessionType.shortBreak:
        return config.shortBreakDuration * 60;
      case PomodoroSessionType.longBreak:
        return config.longBreakDuration * 60;
    }
  }

  /// Obtiene el progreso actual (0.0 a 1.0)
  double get progress {
    if (sessionDurationSeconds == 0) return 0.0;
    return 1.0 - (remainingSeconds / sessionDurationSeconds);
  }

  /// Formatea los segundos restantes como MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Nombre descriptivo de la sesión actual
  String get sessionName {
    switch (sessionType) {
      case PomodoroSessionType.work:
        return 'Sesión de estudio';
      case PomodoroSessionType.shortBreak:
        return 'Descanso corto';
      case PomodoroSessionType.longBreak:
        return 'Descanso largo';
    }
  }

  /// Icono representativo de la sesión
  String get sessionIcon {
    switch (sessionType) {
      case PomodoroSessionType.work:
        return '📚';
      case PomodoroSessionType.shortBreak:
        return '☕';
      case PomodoroSessionType.longBreak:
        return '🌟';
    }
  }

  /// Indica si el timer está corriendo
  bool get isRunning => timerStatus == TimerStatus.running;

  /// Indica si el timer está pausado
  bool get isPaused => timerStatus == TimerStatus.paused;

  /// Indica si el timer está completado
  bool get isCompleted => timerStatus == TimerStatus.completed;

  /// Indica si es una sesión de trabajo
  bool get isWorkSession => sessionType == PomodoroSessionType.work;
}
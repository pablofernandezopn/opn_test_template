import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_template/app/config/preferences_service.dart';
import 'package:opn_test_template/app/features/pomodoro/cubit/pomodoro_state.dart';
import '../model/pomodoro_config.dart';

class PomodoroCubit extends Cubit<PomodoroState> {
  final PreferencesService _preferencesService;
  Timer? _timer;

  static const _configKey = 'pomodoro_config';
  static const _totalSessionsTodayKey = 'pomodoro_total_sessions_today';
  static const _totalMinutesTodayKey = 'pomodoro_total_minutes_today';
  static const _lastSessionDateKey = 'pomodoro_last_session_date';

  PomodoroCubit(this._preferencesService) : super(PomodoroState.initial()) {
    _loadConfig();
    _loadDailyStats();
  }

  /// Carga la configuración guardada
  Future<void> _loadConfig() async {
    try {
      final configJson = await _preferencesService.getString(_configKey);
      if (configJson != null && configJson.isNotEmpty) {
        final configMap = json.decode(configJson) as Map<String, dynamic>;
        final config = PomodoroConfig.fromJson(configMap);
        emit(state.copyWith(config: config, remainingSeconds: config.workDuration * 60));
      }
    } catch (e) {
      print('Error cargando configuración de pomodoro: $e');
    }
  }

  /// Carga las estadísticas diarias
  Future<void> _loadDailyStats() async {
    try {
      final lastDate = await _preferencesService.getString(_lastSessionDateKey) ?? '';
      final today = DateTime.now().toIso8601String().split('T')[0];

      // Si es un nuevo día, resetear las estadísticas
      if (lastDate != today) {
        await _resetDailyStats();
        return;
      }

      final totalSessions = await _preferencesService.getInt(_totalSessionsTodayKey) ?? 0;
      final totalMinutes = await _preferencesService.getInt(_totalMinutesTodayKey) ?? 0;

      emit(state.copyWith(
        totalSessionsToday: totalSessions,
        totalMinutesToday: totalMinutes,
      ));
    } catch (e) {
      print('Error cargando estadísticas diarias: $e');
    }
  }

  /// Resetea las estadísticas diarias
  Future<void> _resetDailyStats() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _preferencesService.setInt(_totalSessionsTodayKey, 0);
    await _preferencesService.setInt(_totalMinutesTodayKey, 0);
    await _preferencesService.setString(_lastSessionDateKey, today);
    emit(state.copyWith(totalSessionsToday: 0, totalMinutesToday: 0));
  }

  /// Inicia el timer
  void start() {
    if (state.isRunning) return;

    emit(state.copyWith(timerStatus: TimerStatus.running));
    _startTimer();
  }

  /// Pausa el timer
  void pause() {
    if (!state.isRunning) return;

    _timer?.cancel();
    _timer = null;
    emit(state.copyWith(timerStatus: TimerStatus.paused));
  }

  /// Resetea el timer a la duración inicial de la sesión actual
  void reset() {
    _timer?.cancel();
    _timer = null;
    emit(state.copyWith(
      timerStatus: TimerStatus.initial,
      remainingSeconds: state.sessionDurationSeconds,
    ));
  }

  /// Salta a la siguiente sesión
  void skipSession() {
    _timer?.cancel();
    _timer = null;
    _completeSession(skipToNext: true);
  }

  /// Inicia el timer interno
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
      } else {
        _completeSession();
      }
    });
  }

  /// Completa la sesión actual y pasa a la siguiente
  void _completeSession({bool skipToNext = false}) {
    _timer?.cancel();
    _timer = null;

    final isWorkSession = state.isWorkSession;
    final completedSessions = isWorkSession ? state.completedSessions + 1 : state.completedSessions;

    // Actualizar estadísticas si es una sesión de trabajo completada
    if (isWorkSession && !skipToNext) {
      _updateDailyStats();
    }

    // Determinar el siguiente tipo de sesión
    PomodoroSessionType nextSessionType;
    if (isWorkSession) {
      // Si completamos una sesión de trabajo
      if (completedSessions >= state.config.sessionsBeforeLongBreak) {
        nextSessionType = PomodoroSessionType.longBreak;
      } else {
        nextSessionType = PomodoroSessionType.shortBreak;
      }
    } else {
      // Si completamos un descanso, volver al trabajo
      nextSessionType = PomodoroSessionType.work;
      // Si completamos un descanso largo, resetear el contador de sesiones
      if (state.sessionType == PomodoroSessionType.longBreak) {
        emit(state.copyWith(completedSessions: 0));
      }
    }

    // Calcular la duración de la siguiente sesión
    final nextDuration = _getDurationForSessionType(nextSessionType);

    emit(state.copyWith(
      sessionType: nextSessionType,
      remainingSeconds: nextDuration,
      completedSessions: state.sessionType == PomodoroSessionType.longBreak ? 0 : completedSessions,
      timerStatus: TimerStatus.completed,
    ));

    // Auto-iniciar si está configurado
    if (_shouldAutoStart(nextSessionType)) {
      Future.delayed(const Duration(milliseconds: 500), start);
    }
  }

  /// Obtiene la duración en segundos para un tipo de sesión
  int _getDurationForSessionType(PomodoroSessionType sessionType) {
    switch (sessionType) {
      case PomodoroSessionType.work:
        return state.config.workDuration * 60;
      case PomodoroSessionType.shortBreak:
        return state.config.shortBreakDuration * 60;
      case PomodoroSessionType.longBreak:
        return state.config.longBreakDuration * 60;
    }
  }

  /// Determina si debe auto-iniciar la siguiente sesión
  bool _shouldAutoStart(PomodoroSessionType nextSessionType) {
    if (nextSessionType == PomodoroSessionType.work) {
      return state.config.autoStartWork;
    } else {
      return state.config.autoStartBreaks;
    }
  }

  /// Actualiza las estadísticas diarias
  Future<void> _updateDailyStats() async {
    final newTotalSessions = state.totalSessionsToday + 1;
    final newTotalMinutes = state.totalMinutesToday + state.config.workDuration;

    await _preferencesService.setInt(_totalSessionsTodayKey, newTotalSessions);
    await _preferencesService.setInt(_totalMinutesTodayKey, newTotalMinutes);

    emit(state.copyWith(
      totalSessionsToday: newTotalSessions,
      totalMinutesToday: newTotalMinutes,
    ));
  }

  /// Actualiza la configuración
  Future<void> updateConfig(PomodoroConfig newConfig) async {
    try {
      // Guardar configuración como JSON
      final configJson = json.encode(newConfig.toJson());
      await _preferencesService.setString(_configKey, configJson);

      // Actualizar estado
      final needsReset = state.timerStatus == TimerStatus.initial ||
          state.timerStatus == TimerStatus.completed;

      if (needsReset) {
        emit(state.copyWith(
          config: newConfig,
          remainingSeconds: _getDurationForSessionType(state.sessionType),
        ));
      } else {
        emit(state.copyWith(config: newConfig));
      }
    } catch (e) {
      print('Error guardando configuración de pomodoro: $e');
    }
  }

  /// Muestra u oculta la configuración
  void toggleSettings() {
    emit(state.copyWith(showingSettings: !state.showingSettings));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
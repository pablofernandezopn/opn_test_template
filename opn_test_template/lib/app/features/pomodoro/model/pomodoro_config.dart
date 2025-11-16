import 'package:json_annotation/json_annotation.dart';

part 'pomodoro_config.g.dart';

@JsonSerializable(explicitToJson: true)
class PomodoroConfig {
  /// Duración del intervalo de trabajo en minutos
  @JsonKey(name: 'work_duration')
  final int workDuration;

  /// Duración del descanso corto en minutos
  @JsonKey(name: 'short_break_duration')
  final int shortBreakDuration;

  /// Duración del descanso largo en minutos
  @JsonKey(name: 'long_break_duration')
  final int longBreakDuration;

  /// Número de sesiones de trabajo antes de un descanso largo
  @JsonKey(name: 'sessions_before_long_break')
  final int sessionsBeforeLongBreak;

  /// Si el sonido está activado
  @JsonKey(name: 'sound_enabled')
  final bool soundEnabled;

  /// Si las notificaciones están activadas
  @JsonKey(name: 'notifications_enabled')
  final bool notificationsEnabled;

  /// Si el timer continúa automáticamente
  @JsonKey(name: 'auto_start_breaks')
  final bool autoStartBreaks;

  @JsonKey(name: 'auto_start_work')
  final bool autoStartWork;

  const PomodoroConfig({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsBeforeLongBreak = 4,
    this.soundEnabled = true,
    this.notificationsEnabled = true,
    this.autoStartBreaks = false,
    this.autoStartWork = false,
  });

  /// Configuración por defecto
  static const defaultConfig = PomodoroConfig();

  /// Crea una instancia desde JSON
  factory PomodoroConfig.fromJson(Map<String, dynamic> json) => _$PomodoroConfigFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$PomodoroConfigToJson(this);

  /// Crea una copia con campos modificados
  PomodoroConfig copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsBeforeLongBreak,
    bool? soundEnabled,
    bool? notificationsEnabled,
    bool? autoStartBreaks,
    bool? autoStartWork,
  }) {
    return PomodoroConfig(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartWork: autoStartWork ?? this.autoStartWork,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PomodoroConfig &&
        other.workDuration == workDuration &&
        other.shortBreakDuration == shortBreakDuration &&
        other.longBreakDuration == longBreakDuration &&
        other.sessionsBeforeLongBreak == sessionsBeforeLongBreak &&
        other.soundEnabled == soundEnabled &&
        other.notificationsEnabled == notificationsEnabled &&
        other.autoStartBreaks == autoStartBreaks &&
        other.autoStartWork == autoStartWork;
  }

  @override
  int get hashCode =>
      workDuration.hashCode ^
      shortBreakDuration.hashCode ^
      longBreakDuration.hashCode ^
      sessionsBeforeLongBreak.hashCode ^
      soundEnabled.hashCode ^
      notificationsEnabled.hashCode ^
      autoStartBreaks.hashCode ^
      autoStartWork.hashCode;

  @override
  String toString() {
    return 'PomodoroConfig(workDuration: $workDuration, shortBreak: $shortBreakDuration, longBreak: $longBreakDuration)';
  }
}
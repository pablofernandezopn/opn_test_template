// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PomodoroConfig _$PomodoroConfigFromJson(Map<String, dynamic> json) =>
    PomodoroConfig(
      workDuration: (json['work_duration'] as num?)?.toInt() ?? 25,
      shortBreakDuration: (json['short_break_duration'] as num?)?.toInt() ?? 5,
      longBreakDuration: (json['long_break_duration'] as num?)?.toInt() ?? 15,
      sessionsBeforeLongBreak:
          (json['sessions_before_long_break'] as num?)?.toInt() ?? 4,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      autoStartBreaks: json['auto_start_breaks'] as bool? ?? false,
      autoStartWork: json['auto_start_work'] as bool? ?? false,
    );

Map<String, dynamic> _$PomodoroConfigToJson(PomodoroConfig instance) =>
    <String, dynamic>{
      'work_duration': instance.workDuration,
      'short_break_duration': instance.shortBreakDuration,
      'long_break_duration': instance.longBreakDuration,
      'sessions_before_long_break': instance.sessionsBeforeLongBreak,
      'sound_enabled': instance.soundEnabled,
      'notifications_enabled': instance.notificationsEnabled,
      'auto_start_breaks': instance.autoStartBreaks,
      'auto_start_work': instance.autoStartWork,
    };

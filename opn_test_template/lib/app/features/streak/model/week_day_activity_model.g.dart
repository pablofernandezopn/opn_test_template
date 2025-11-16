// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_day_activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeekDayActivity _$WeekDayActivityFromJson(Map<String, dynamic> json) =>
    WeekDayActivity(
      dayOfWeek: (json['day_of_week'] as num).toInt(),
      dayName: json['day_name'] as String,
      activityDate: DateTime.parse(json['activity_date'] as String),
      hasActivity: json['has_activity'] as bool,
      isToday: json['is_today'] as bool,
      testsCompleted: (json['tests_completed'] as num?)?.toInt() ?? 0,
      questionsAnswered: (json['questions_answered'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$WeekDayActivityToJson(WeekDayActivity instance) =>
    <String, dynamic>{
      'day_of_week': instance.dayOfWeek,
      'day_name': instance.dayName,
      'activity_date': instance.activityDate.toIso8601String(),
      'has_activity': instance.hasActivity,
      'is_today': instance.isToday,
      'tests_completed': instance.testsCompleted,
      'questions_answered': instance.questionsAnswered,
    };

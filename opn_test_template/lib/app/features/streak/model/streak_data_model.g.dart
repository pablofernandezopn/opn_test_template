// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreakData _$StreakDataFromJson(Map<String, dynamic> json) => StreakData(
      userId: (json['user_id'] as num).toInt(),
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      lastActivityDate: json['last_activity_date'] == null
          ? null
          : DateTime.parse(json['last_activity_date'] as String),
      streakUpdatedAt: json['streak_updated_at'] == null
          ? null
          : DateTime.parse(json['streak_updated_at'] as String),
      completedToday: json['completed_today'] as bool? ?? false,
      weekActivity: (json['week_activity'] as List<dynamic>?)
              ?.map((e) => WeekDayActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StreakDataToJson(StreakData instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'current_streak': instance.currentStreak,
      'longest_streak': instance.longestStreak,
      'last_activity_date': instance.lastActivityDate?.toIso8601String(),
      'streak_updated_at': instance.streakUpdatedAt?.toIso8601String(),
      'completed_today': instance.completedToday,
      'week_activity': instance.weekActivity.map((e) => e.toJson()).toList(),
    };

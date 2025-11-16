import 'package:json_annotation/json_annotation.dart';

part 'week_day_activity_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WeekDayActivity {
  @JsonKey(name: 'day_of_week')
  final int dayOfWeek; // 0=Domingo, 1=Lunes, ..., 6=Sábado

  @JsonKey(name: 'day_name')
  final String dayName; // L, M, M, J, V, S, D

  @JsonKey(name: 'activity_date')
  final DateTime activityDate;

  @JsonKey(name: 'has_activity')
  final bool hasActivity;

  @JsonKey(name: 'is_today')
  final bool isToday;

  @JsonKey(name: 'tests_completed')
  final int testsCompleted;

  @JsonKey(name: 'questions_answered')
  final int questionsAnswered;

  const WeekDayActivity({
    required this.dayOfWeek,
    required this.dayName,
    required this.activityDate,
    required this.hasActivity,
    required this.isToday,
    this.testsCompleted = 0,
    this.questionsAnswered = 0,
  });

  factory WeekDayActivity.fromJson(Map<String, dynamic> json) =>
      _$WeekDayActivityFromJson(json);

  Map<String, dynamic> toJson() => _$WeekDayActivityToJson(this);

  WeekDayActivity copyWith({
    int? dayOfWeek,
    String? dayName,
    DateTime? activityDate,
    bool? hasActivity,
    bool? isToday,
    int? testsCompleted,
    int? questionsAnswered,
  }) {
    return WeekDayActivity(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayName: dayName ?? this.dayName,
      activityDate: activityDate ?? this.activityDate,
      hasActivity: hasActivity ?? this.hasActivity,
      isToday: isToday ?? this.isToday,
      testsCompleted: testsCompleted ?? this.testsCompleted,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
    );
  }

  @override
  String toString() {
    return 'WeekDayActivity(dayName: $dayName, activityDate: $activityDate, hasActivity: $hasActivity, isToday: $isToday)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeekDayActivity &&
        other.dayOfWeek == dayOfWeek &&
        other.activityDate == activityDate;
  }

  @override
  int get hashCode => dayOfWeek.hashCode ^ activityDate.hashCode;

  /// Retorna el nombre completo del día en español
  String get fullDayName {
    switch (dayOfWeek) {
      case 0:
        return 'Domingo';
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      default:
        return '';
    }
  }
}

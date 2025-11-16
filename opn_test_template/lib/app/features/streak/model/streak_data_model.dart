import 'package:json_annotation/json_annotation.dart';
import 'week_day_activity_model.dart';

part 'streak_data_model.g.dart';

@JsonSerializable(explicitToJson: true)
class StreakData {
  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'current_streak')
  final int currentStreak;

  @JsonKey(name: 'longest_streak')
  final int longestStreak;

  @JsonKey(name: 'last_activity_date')
  final DateTime? lastActivityDate;

  @JsonKey(name: 'streak_updated_at')
  final DateTime? streakUpdatedAt;

  @JsonKey(name: 'completed_today')
  final bool completedToday;

  @JsonKey(name: 'week_activity')
  final List<WeekDayActivity> weekActivity;

  const StreakData({
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.streakUpdatedAt,
    this.completedToday = false,
    this.weekActivity = const [],
  });

  factory StreakData.fromJson(Map<String, dynamic> json) =>
      _$StreakDataFromJson(json);

  Map<String, dynamic> toJson() => _$StreakDataToJson(this);

  StreakData copyWith({
    int? userId,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    DateTime? streakUpdatedAt,
    bool? completedToday,
    List<WeekDayActivity>? weekActivity,
  }) {
    return StreakData(
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      streakUpdatedAt: streakUpdatedAt ?? this.streakUpdatedAt,
      completedToday: completedToday ?? this.completedToday,
      weekActivity: weekActivity ?? this.weekActivity,
    );
  }

  @override
  String toString() {
    return 'StreakData(userId: $userId, currentStreak: $currentStreak, longestStreak: $longestStreak, completedToday: $completedToday)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StreakData && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  /// Retorna el porcentaje de días completados esta semana
  double get weekCompletionRate {
    if (weekActivity.isEmpty) return 0;
    final completedDays =
        weekActivity.where((day) => day.hasActivity).length;
    return (completedDays / weekActivity.length) * 100;
  }

  /// Retorna el número de días completados esta semana
  int get weekCompletedDays {
    return weekActivity.where((day) => day.hasActivity).length;
  }

  /// Retorna true si el usuario está en riesgo de perder la racha
  bool get atRisk {
    return currentStreak > 0 && !completedToday;
  }

  /// Retorna el badge/nivel según la racha actual
  StreakBadge get badge {
    if (currentStreak >= 30) return StreakBadge.legend;
    if (currentStreak >= 14) return StreakBadge.champion;
    if (currentStreak >= 7) return StreakBadge.warrior;
    if (currentStreak >= 3) return StreakBadge.beginner;
    return StreakBadge.novice;
  }

  /// Retorna un mensaje motivacional basado en la racha
  String get motivationalMessage {
    if (atRisk && currentStreak >= 7) {
      return '¡No pierdas tu racha de $currentStreak días! Completa un test hoy.';
    }
    if (completedToday && currentStreak > longestStreak - 2) {
      return '¡Vas a superar tu récord! Solo ${longestStreak - currentStreak + 1} días más.';
    }
    if (completedToday && currentStreak >= 7) {
      return '¡Increíble! Llevas $currentStreak días consecutivos.';
    }
    if (currentStreak == 0) {
      return 'Comienza tu racha hoy. ¡Tú puedes!';
    }
    return '¡Sigue así! Llevas $currentStreak días.';
  }

  /// Crea una instancia vacía (sin datos)
  factory StreakData.empty(int userId) {
    return StreakData(
      userId: userId,
      currentStreak: 0,
      longestStreak: 0,
      completedToday: false,
      weekActivity: [],
    );
  }
}

/// Enum para los diferentes niveles de badges de racha
enum StreakBadge {
  novice('Principiante', 0),
  beginner('Iniciado', 3),
  warrior('Guerrero', 7),
  champion('Campeón', 14),
  legend('Leyenda', 30);

  final String name;
  final int daysRequired;

  const StreakBadge(this.name, this.daysRequired);

  /// Retorna el emoji asociado al badge
  String get emoji {
    switch (this) {
      case StreakBadge.novice:
        return '🌱';
      case StreakBadge.beginner:
        return '⭐';
      case StreakBadge.warrior:
        return '⚔️';
      case StreakBadge.champion:
        return '🏆';
      case StreakBadge.legend:
        return '👑';
    }
  }

  /// Retorna el color asociado al badge
  String get colorHex {
    switch (this) {
      case StreakBadge.novice:
        return '#9E9E9E'; // Gris
      case StreakBadge.beginner:
        return '#4CAF50'; // Verde
      case StreakBadge.warrior:
        return '#2196F3'; // Azul
      case StreakBadge.champion:
        return '#9C27B0'; // Púrpura
      case StreakBadge.legend:
        return '#FF9800'; // Dorado
    }
  }
}

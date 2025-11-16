import 'package:json_annotation/json_annotation.dart';

part 'group_ranking_entry_model.g.dart';

/// Modelo que representa una entrada en el ranking de un topic_group
///
/// Este modelo representa el ranking consolidado de un examen grupal,
/// donde se promedian los first_score de todos los topics del grupo.
@JsonSerializable(explicitToJson: true)
class GroupRankingEntry {
  @JsonKey(name: 'user_id')
  final int userId;

  final String username;

  @JsonKey(name: 'display_name')
  final String? displayName;

  @JsonKey(name: 'profile_image')
  final String? profileImage;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  /// Puntuación promedio de los first_score de todos los topics del grupo
  @JsonKey(name: 'average_first_score')
  final double averageFirstScore;

  /// Suma total de intentos en todos los topics del grupo
  @JsonKey(name: 'total_attempts')
  final int totalAttempts;

  /// Número de topics completados por el usuario en este grupo
  @JsonKey(name: 'topics_completed')
  final int topicsCompleted;

  /// Número total de topics en el grupo
  @JsonKey(name: 'total_topics_in_group')
  final int totalTopicsInGroup;

  /// Posición en el ranking (1 = mejor)
  @JsonKey(name: 'rank_position')
  final int rankPosition;

  /// Fecha del primer intento en cualquier topic del grupo
  @JsonKey(name: 'first_attempt_date')
  final DateTime firstAttemptDate;

  /// Fecha del último intento en cualquier topic del grupo
  @JsonKey(name: 'last_attempt_date')
  final DateTime lastAttemptDate;

  const GroupRankingEntry({
    required this.userId,
    required this.username,
    this.displayName,
    this.profileImage,
    this.firstName,
    this.lastName,
    required this.averageFirstScore,
    required this.totalAttempts,
    required this.topicsCompleted,
    required this.totalTopicsInGroup,
    required this.rankPosition,
    required this.firstAttemptDate,
    required this.lastAttemptDate,
  });

  /// Crea una instancia desde JSON
  factory GroupRankingEntry.fromJson(Map<String, dynamic> json) =>
      _$GroupRankingEntryFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$GroupRankingEntryToJson(this);

  /// Obtiene el nombre para mostrar del usuario
  String get displayNameOrUsername =>
      displayName?.isNotEmpty == true ? displayName! : username;

  /// Obtiene el nombre completo del usuario si está disponible
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayNameOrUsername;
  }

  /// Verifica si el usuario completó todos los topics del grupo
  bool get hasCompletedAllTopics => topicsCompleted == totalTopicsInGroup;

  /// Calcula el porcentaje de la puntuación promedio sobre el máximo
  double getAverageScorePercentage(double maxScore) {
    if (maxScore == 0) return 0;
    return (averageFirstScore / maxScore) * 100;
  }

  /// Calcula el promedio de intentos por topic
  double get averageAttemptsPerTopic {
    if (topicsCompleted == 0) return 0;
    return totalAttempts / topicsCompleted;
  }

  @override
  String toString() {
    return 'GroupRankingEntry(userId: $userId, username: $username, rankPosition: $rankPosition, averageFirstScore: $averageFirstScore, topicsCompleted: $topicsCompleted/$totalTopicsInGroup)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupRankingEntry && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
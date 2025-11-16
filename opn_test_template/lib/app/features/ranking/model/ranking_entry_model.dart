import 'package:json_annotation/json_annotation.dart';

part 'ranking_entry_model.g.dart';

/// Modelo que representa una entrada en el ranking de un topic tipo Mock
@JsonSerializable(explicitToJson: true)
class RankingEntry {
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: 'topic_id')
  final int topicId;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'topic_group_id')
  final int? topicGroupId;

  /// Primera puntuación obtenida (inmutable, define el ranking)
  @JsonKey(name: 'first_score')
  final double firstScore;

  /// Mejor puntuación obtenida
  @JsonKey(name: 'best_score')
  final double bestScore;

  /// Número total de intentos
  final int attempts;

  /// Posición en el ranking (1 = mejor)
  @JsonKey(name: 'rank_position')
  final int? rankPosition;

  @JsonKey(name: 'last_attempt_date')
  final DateTime lastAttemptDate;

  @JsonKey(name: 'first_attempt_date')
  final DateTime firstAttemptDate;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Información del usuario (JOIN con tabla users)
  final String username;

  @JsonKey(name: 'display_name')
  final String? displayName;

  @JsonKey(name: 'profile_image')
  final String? profileImage;

  @JsonKey(name: 'first_name')
  final String? firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  const RankingEntry({
    this.id,
    required this.topicId,
    required this.userId,
    this.topicGroupId,
    required this.firstScore,
    required this.bestScore,
    required this.attempts,
    this.rankPosition,
    required this.lastAttemptDate,
    required this.firstAttemptDate,
    this.createdAt,
    this.updatedAt,
    required this.username,
    this.displayName,
    this.profileImage,
    this.firstName,
    this.lastName,
  });

  /// Crea una instancia desde JSON
  factory RankingEntry.fromJson(Map<String, dynamic> json) =>
      _$RankingEntryFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$RankingEntryToJson(this);

  /// Crea una copia con campos modificados
  RankingEntry copyWith({
    int? id,
    int? topicId,
    int? userId,
    int? topicGroupId,
    double? firstScore,
    double? bestScore,
    int? attempts,
    int? rankPosition,
    DateTime? lastAttemptDate,
    DateTime? firstAttemptDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? username,
    String? displayName,
    String? profileImage,
    String? firstName,
    String? lastName,
  }) {
    return RankingEntry(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      userId: userId ?? this.userId,
      topicGroupId: topicGroupId ?? this.topicGroupId,
      firstScore: firstScore ?? this.firstScore,
      bestScore: bestScore ?? this.bestScore,
      attempts: attempts ?? this.attempts,
      rankPosition: rankPosition ?? this.rankPosition,
      lastAttemptDate: lastAttemptDate ?? this.lastAttemptDate,
      firstAttemptDate: firstAttemptDate ?? this.firstAttemptDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImage: profileImage ?? this.profileImage,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }

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

  /// Calcula el porcentaje de la primera puntuación sobre el máximo
  double getFirstScorePercentage(double maxScore) {
    if (maxScore == 0) return 0;
    return (firstScore / maxScore) * 100;
  }

  /// Calcula el porcentaje de la mejor puntuación sobre el máximo
  double getBestScorePercentage(double maxScore) {
    if (maxScore == 0) return 0;
    return (bestScore / maxScore) * 100;
  }

  /// Calcula cuánto mejoró desde el primer intento
  double get improvementPercentage {
    if (firstScore == 0) return 0;
    return ((bestScore - firstScore) / firstScore) * 100;
  }

  @override
  String toString() {
    return 'RankingEntry(id: $id, userId: $userId, username: $username, rankPosition: $rankPosition, firstScore: $firstScore, bestScore: $bestScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RankingEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
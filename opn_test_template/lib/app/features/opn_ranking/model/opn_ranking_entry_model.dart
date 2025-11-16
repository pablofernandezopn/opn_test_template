import 'package:json_annotation/json_annotation.dart';

part 'opn_ranking_entry_model.g.dart';

/// Modelo que representa una entrada en el ranking OPN
@JsonSerializable(explicitToJson: true)
class OpnRankingEntry {
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: 'user_id')
  final int userId;

  /// Índice OPN total (0-1000 puntos)
  @JsonKey(name: 'opn_index')
  final int opnIndex;

  /// Puntuación de tendencia de calidad (0-400 pts)
  @JsonKey(name: 'quality_trend_score')
  final double? qualityTrendScore;

  /// Puntuación de actividad reciente (0-300 pts)
  @JsonKey(name: 'recent_activity_score')
  final double? recentActivityScore;

  /// Puntuación competitiva (0-200 pts)
  @JsonKey(name: 'competitive_score')
  final double? competitiveScore;

  /// Puntuación de momentum (0-100 pts)
  @JsonKey(name: 'momentum_score')
  final double? momentumScore;

  /// Ranking global (1 = mejor)
  @JsonKey(name: 'global_rank')
  final int? globalRank;

  @JsonKey(name: 'calculated_at')
  final DateTime calculatedAt;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

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

  const OpnRankingEntry({
    this.id,
    required this.userId,
    required this.opnIndex,
    this.qualityTrendScore,
    this.recentActivityScore,
    this.competitiveScore,
    this.momentumScore,
    this.globalRank,
    required this.calculatedAt,
    this.createdAt,
    required this.username,
    this.displayName,
    this.profileImage,
    this.firstName,
    this.lastName,
  });

  /// Crea una instancia desde JSON
  factory OpnRankingEntry.fromJson(Map<String, dynamic> json) =>
      _$OpnRankingEntryFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$OpnRankingEntryToJson(this);

  /// Crea una copia con campos modificados
  OpnRankingEntry copyWith({
    int? id,
    int? userId,
    int? opnIndex,
    double? qualityTrendScore,
    double? recentActivityScore,
    double? competitiveScore,
    double? momentumScore,
    int? globalRank,
    DateTime? calculatedAt,
    DateTime? createdAt,
    String? username,
    String? displayName,
    String? profileImage,
    String? firstName,
    String? lastName,
  }) {
    return OpnRankingEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      opnIndex: opnIndex ?? this.opnIndex,
      qualityTrendScore: qualityTrendScore ?? this.qualityTrendScore,
      recentActivityScore: recentActivityScore ?? this.recentActivityScore,
      competitiveScore: competitiveScore ?? this.competitiveScore,
      momentumScore: momentumScore ?? this.momentumScore,
      globalRank: globalRank ?? this.globalRank,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      createdAt: createdAt ?? this.createdAt,
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

  /// Calcula el porcentaje del índice OPN sobre el máximo (1000)
  double get opnIndexPercentage => (opnIndex / 1000) * 100;

  @override
  String toString() {
    return 'OpnRankingEntry(id: $id, userId: $userId, username: $username, globalRank: $globalRank, opnIndex: $opnIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpnRankingEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
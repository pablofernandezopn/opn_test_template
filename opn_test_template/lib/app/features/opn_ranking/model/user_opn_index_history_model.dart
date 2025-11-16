import 'package:json_annotation/json_annotation.dart';

part 'user_opn_index_history_model.g.dart';

/// Modelo que representa el historial del índice OPN de un usuario
@JsonSerializable(explicitToJson: true)
class UserOpnIndexHistory {
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
  final DateTime? calculatedAt;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  const UserOpnIndexHistory({
    this.id,
    required this.userId,
    required this.opnIndex,
    this.qualityTrendScore,
    this.recentActivityScore,
    this.competitiveScore,
    this.momentumScore,
    this.globalRank,
    this.calculatedAt,
    this.createdAt,
  });

  /// Modelo vacío
  static const UserOpnIndexHistory empty = UserOpnIndexHistory(
    id: 0,
    userId: 0,
    opnIndex: 0,
    qualityTrendScore: 0,
    recentActivityScore: 0,
    competitiveScore: 0,
    momentumScore: 0,
    globalRank: null,
    calculatedAt: null,
    createdAt: null,
  );

  /// Crea una instancia desde JSON
  factory UserOpnIndexHistory.fromJson(Map<String, dynamic> json) =>
      _$UserOpnIndexHistoryFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$UserOpnIndexHistoryToJson(this);

  /// Crea una copia con campos modificados
  UserOpnIndexHistory copyWith({
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
  }) {
    return UserOpnIndexHistory(
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
    );
  }

  /// Calcula el porcentaje del índice OPN sobre el máximo (1000)
  double get opnIndexPercentage => (opnIndex / 1000) * 100;

  /// Verifica si el modelo está vacío
  bool get isEmpty => id == 0 && userId == 0 && opnIndex == 0;

  @override
  String toString() {
    return 'UserOpnIndexHistory(id: $id, userId: $userId, opnIndex: $opnIndex, globalRank: $globalRank, calculatedAt: $calculatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserOpnIndexHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
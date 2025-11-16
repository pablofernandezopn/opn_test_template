import 'package:json_annotation/json_annotation.dart';

part 'user_opn_index_current_model.g.dart';

/// Modelo que representa el índice OPN actual de un usuario desde la vista user_opn_index_current
/// Esta vista contiene el registro más reciente de cada usuario
@JsonSerializable(explicitToJson: true)
class UserOpnIndexCurrent {
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

  const UserOpnIndexCurrent({
    required this.userId,
    required this.opnIndex,
    this.qualityTrendScore,
    this.recentActivityScore,
    this.competitiveScore,
    this.momentumScore,
    this.globalRank,
    this.calculatedAt,
  });

  /// Modelo vacío
  static const UserOpnIndexCurrent empty = UserOpnIndexCurrent(
    userId: 0,
    opnIndex: 0,
    qualityTrendScore: 0,
    recentActivityScore: 0,
    competitiveScore: 0,
    momentumScore: 0,
    globalRank: null,
    calculatedAt: null,
  );

  /// Crea una instancia desde JSON
  factory UserOpnIndexCurrent.fromJson(Map<String, dynamic> json) =>
      _$UserOpnIndexCurrentFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$UserOpnIndexCurrentToJson(this);

  /// Crea una copia con campos modificados
  UserOpnIndexCurrent copyWith({
    int? userId,
    int? opnIndex,
    double? qualityTrendScore,
    double? recentActivityScore,
    double? competitiveScore,
    double? momentumScore,
    int? globalRank,
    DateTime? calculatedAt,
  }) {
    return UserOpnIndexCurrent(
      userId: userId ?? this.userId,
      opnIndex: opnIndex ?? this.opnIndex,
      qualityTrendScore: qualityTrendScore ?? this.qualityTrendScore,
      recentActivityScore: recentActivityScore ?? this.recentActivityScore,
      competitiveScore: competitiveScore ?? this.competitiveScore,
      momentumScore: momentumScore ?? this.momentumScore,
      globalRank: globalRank ?? this.globalRank,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  /// Calcula el porcentaje del índice OPN sobre el máximo (1000)
  double get opnIndexPercentage => (opnIndex / 1000) * 100;

  /// Verifica si el modelo está vacío
  bool get isEmpty => userId == 0 && opnIndex == 0;

  @override
  String toString() {
    return 'UserOpnIndexCurrent(userId: $userId, opnIndex: $opnIndex, globalRank: $globalRank, calculatedAt: $calculatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserOpnIndexCurrent && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

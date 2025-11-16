import 'package:json_annotation/json_annotation.dart';

part 'academy_kpis_model.g.dart';

/// Representa las estadísticas (KPIs) de una academia.
///
/// Esta tabla contiene datos precalculados para evitar consultas pesadas.
/// Se actualiza periódicamente mediante triggers o funciones programadas.
@JsonSerializable(explicitToJson: true)
class AcademyKpis {
  /// ID único del registro de KPIs
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  /// ID de la academia a la que pertenecen estos KPIs
  @JsonKey(name: 'academy_id')
  final int academyId;

  /// Total de usuarios registrados en la app
  @JsonKey(name: 'total_users', defaultValue: 0)
  final int totalUsers;

  /// Total de usuarios con membresía premium
  @JsonKey(name: 'total_premium_users', defaultValue: 0)
  final int totalPremiumUsers;

  /// Total de usuarios con membresía premium plus
  @JsonKey(name: 'premium_plus_users', defaultValue: 0)
  final int premiumPlusUsers;

  /// Total de preguntas disponibles
  @JsonKey(name: 'total_questions', defaultValue: 0)
  final int totalQuestions;

  /// Total de tests/challenges disponibles
  @JsonKey(name: 'total_tests', defaultValue: 0)
  final int totalTests;

  /// Total de usuarios activos hoy
  @JsonKey(name: 'total_users_today', defaultValue: 0)
  final int totalUsersToday;

  /// Nuevos usuarios registrados hoy
  @JsonKey(name: 'new_users_today', defaultValue: 0)
  final int newUsersToday;

  /// Total de respuestas dadas hoy
  @JsonKey(name: 'total_answers_today', defaultValue: 0)
  final int totalAnswersToday;

  /// Total de respuestas de flashcards hoy
  @JsonKey(name: 'total_flashcard_answers_today', defaultValue: 0)
  final int totalFlashcardAnswersToday;

  /// Fecha de creación del registro
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const AcademyKpis({
    this.id,
    required this.academyId,
    this.totalUsers = 0,
    this.totalPremiumUsers = 0,
    this.premiumPlusUsers = 0,
    this.totalQuestions = 0,
    this.totalTests = 0,
    this.totalUsersToday = 0,
    this.newUsersToday = 0,
    this.totalAnswersToday = 0,
    this.totalFlashcardAnswersToday = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Registro vacío para estados iniciales
  static const AcademyKpis empty = AcademyKpis(
    id: null,
    academyId: 0,
  );

  /// Crea una instancia desde JSON
  factory AcademyKpis.fromJson(Map<String, dynamic> json) =>
      _$AcademyKpisFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$AcademyKpisToJson(this);

  /// Crea una copia con campos modificados
  AcademyKpis copyWith({
    int? id,
    int? academyId,
    int? totalUsers,
    int? totalPremiumUsers,
    int? premiumPlusUsers,
    int? totalQuestions,
    int? totalTests,
    int? totalUsersToday,
    int? newUsersToday,
    int? totalAnswersToday,
    int? totalFlashcardAnswersToday,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AcademyKpis(
      id: id ?? this.id,
      academyId: academyId ?? this.academyId,
      totalUsers: totalUsers ?? this.totalUsers,
      totalPremiumUsers: totalPremiumUsers ?? this.totalPremiumUsers,
      premiumPlusUsers: premiumPlusUsers ?? this.premiumPlusUsers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalTests: totalTests ?? this.totalTests,
      totalUsersToday: totalUsersToday ?? this.totalUsersToday,
      newUsersToday: newUsersToday ?? this.newUsersToday,
      totalAnswersToday: totalAnswersToday ?? this.totalAnswersToday,
      totalFlashcardAnswersToday:
          totalFlashcardAnswersToday ?? this.totalFlashcardAnswersToday,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AcademyKpis(id: $id, academyId: $academyId, totalUsers: $totalUsers, totalQuestions: $totalQuestions)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AcademyKpis && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

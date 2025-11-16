// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academy_kpis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcademyKpis _$AcademyKpisFromJson(Map<String, dynamic> json) => AcademyKpis(
      id: (json['id'] as num?)?.toInt(),
      academyId: (json['academy_id'] as num).toInt(),
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      totalPremiumUsers: (json['total_premium_users'] as num?)?.toInt() ?? 0,
      premiumPlusUsers: (json['premium_plus_users'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      totalTests: (json['total_tests'] as num?)?.toInt() ?? 0,
      totalUsersToday: (json['total_users_today'] as num?)?.toInt() ?? 0,
      newUsersToday: (json['new_users_today'] as num?)?.toInt() ?? 0,
      totalAnswersToday: (json['total_answers_today'] as num?)?.toInt() ?? 0,
      totalFlashcardAnswersToday:
          (json['total_flashcard_answers_today'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AcademyKpisToJson(AcademyKpis instance) =>
    <String, dynamic>{
      'academy_id': instance.academyId,
      'total_users': instance.totalUsers,
      'total_premium_users': instance.totalPremiumUsers,
      'premium_plus_users': instance.premiumPlusUsers,
      'total_questions': instance.totalQuestions,
      'total_tests': instance.totalTests,
      'total_users_today': instance.totalUsersToday,
      'new_users_today': instance.newUsersToday,
      'total_answers_today': instance.totalAnswersToday,
      'total_flashcard_answers_today': instance.totalFlashcardAnswersToday,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialty_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Specialty _$SpecialtyFromJson(Map<String, dynamic> json) => Specialty(
      id: (json['id'] as num).toInt(),
      academyId: (json['academy_id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      isDefault: json['is_default'] as bool,
      isActive: json['is_active'] as bool,
      displayOrder: (json['display_order'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SpecialtyToJson(Specialty instance) => <String, dynamic>{
      'id': instance.id,
      'academy_id': instance.academyId,
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'is_default': instance.isDefault,
      'is_active': instance.isActive,
      'display_order': instance.displayOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

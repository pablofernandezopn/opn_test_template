// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialty.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Specialty _$SpecialtyFromJson(Map<String, dynamic> json) => Specialty(
      id: (json['id'] as num?)?.toInt(),
      academyId: (json['academy_id'] as num?)?.toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      colorHex: json['color_hex'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SpecialtyToJson(Specialty instance) => <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      if (instance.academyId case final value?) 'academy_id': value,
      'name': instance.name,
      'slug': instance.slug,
      if (instance.description case final value?) 'description': value,
      if (instance.iconUrl case final value?) 'icon_url': value,
      if (instance.colorHex case final value?) 'color_hex': value,
      'display_order': instance.displayOrder,
      'is_active': instance.isActive,
      'is_default': instance.isDefault,
    };

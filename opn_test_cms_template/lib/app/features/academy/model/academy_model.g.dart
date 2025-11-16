// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academy_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Academy _$AcademyFromJson(Map<String, dynamic> json) => Academy(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      website: json['website'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      address: json['address'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AcademyToJson(Academy instance) => <String, dynamic>{
      'name': instance.name,
      'slug': instance.slug,
      'description': instance.description,
      'logo_url': instance.logoUrl,
      'website': instance.website,
      'contact_email': instance.contactEmail,
      'contact_phone': instance.contactPhone,
      'address': instance.address,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

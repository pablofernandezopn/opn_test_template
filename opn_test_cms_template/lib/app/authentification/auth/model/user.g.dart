// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CmsUser _$CmsUserFromJson(Map<String, dynamic> json) => CmsUser(
      id: (json['id'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      userUuid: json['user_uuid'] as String?,
      academyId: (json['academy_id'] as num?)?.toInt() ?? 1,
      username: json['username'] as String,
      name: json['nombre'] as String,
      lastName: json['apellido'] as String,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      roleId: (json['role_id'] as num).toInt(),
      specialtyId: (json['specialty_id'] as num?)?.toInt(),
      specialty: json['specialty'] == null
          ? null
          : Specialty.fromJson(json['specialty'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CmsUserToJson(CmsUser instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'user_uuid': instance.userUuid,
      'academy_id': instance.academyId,
      'username': instance.username,
      'nombre': instance.name,
      'apellido': instance.lastName,
      'avatar_url': instance.avatarUrl,
      'email': instance.email,
      'phone': instance.phone,
      'address': instance.address,
      'role_id': instance.roleId,
      'specialty_id': instance.specialtyId,
      'specialty': instance.specialty,
    };

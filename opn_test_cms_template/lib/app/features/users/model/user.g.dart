// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      specialtyId: (json['specialty_id'] as num?)?.toInt(),
      specialty: json['specialty'] == null
          ? null
          : Specialty.fromJson(json['specialty'] as Map<String, dynamic>),
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      rightQuestions: (json['rightQuestions'] as num?)?.toInt() ?? 0,
      wrongQuestions: (json['wrongQuestions'] as num?)?.toInt() ?? 0,
      tester: json['tester'] as bool? ?? false,
      lastUsed: json['lastUsed'] == null
          ? null
          : DateTime.parse(json['lastUsed'] as String),
      fcmToken: json['fcm_token'] as String?,
      fidToken: json['fid_token'] as String?,
      profileImage: json['profile_image'] as String?,
      unlockedAt: json['unlocked_at'] == null
          ? null
          : DateTime.parse(json['unlocked_at'] as String),
      unlockDurationMinutes:
          (json['unlock_duration_minutes'] as num?)?.toInt() ?? 0,
      enabled: json['enabled'] as bool? ?? true,
      tutorial: json['tutorial'] as bool? ?? false,
      wordpressUserId: (json['wordpress_user_id'] as num?)?.toInt(),
      displayName: json['display_name'] as String?,
      academyId: (json['academy_id'] as num?)?.toInt() ?? 1,
      token: json['token'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      userMemberships: (json['user_memberships'] as List<dynamic>?)
              ?.map((e) => UserMembership.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      userOpnIndex: json['user_opn_index'] == null
          ? null
          : UserOpnIndexCurrent.fromJson(
              json['user_opn_index'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'specialty_id': instance.specialtyId,
      'specialty': instance.specialty?.toJson(),
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone': instance.phone,
      'totalQuestions': instance.totalQuestions,
      'rightQuestions': instance.rightQuestions,
      'wrongQuestions': instance.wrongQuestions,
      'tester': instance.tester,
      'lastUsed': instance.lastUsed?.toIso8601String(),
      'fcm_token': instance.fcmToken,
      'fid_token': instance.fidToken,
      'profile_image': instance.profileImage,
      'unlocked_at': instance.unlockedAt?.toIso8601String(),
      'unlock_duration_minutes': instance.unlockDurationMinutes,
      'enabled': instance.enabled,
      'tutorial': instance.tutorial,
      'wordpress_user_id': instance.wordpressUserId,
      'display_name': instance.displayName,
      'academy_id': instance.academyId,
      'token': instance.token,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'user_memberships':
          instance.userMemberships.map((e) => e.toJson()).toList(),
      'user_opn_index': instance.userOpnIndex?.toJson(),
    };

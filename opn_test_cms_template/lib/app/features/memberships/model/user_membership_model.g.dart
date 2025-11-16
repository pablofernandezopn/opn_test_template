// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserMembership _$UserMembershipFromJson(Map<String, dynamic> json) =>
    UserMembership(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['user_id'] as num).toInt(),
      membershipLevelId: (json['membership_level_id'] as num).toInt(),
      status: $enumDecodeNullable(_$MembershipStatusEnumMap, json['status']) ??
          MembershipStatus.active,
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      autoRenews: json['auto_renews'] as bool? ?? false,
      renewalGracePeriodDays:
          (json['renewal_grace_period_days'] as num?)?.toInt() ?? 3,
      lastSyncedAt: json['last_synced_at'] == null
          ? null
          : DateTime.parse(json['last_synced_at'] as String),
      syncSource: $enumDecodeNullable(_$SyncSourceEnumMap, json['sync_source']),
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['sync_status']) ??
              SyncStatus.synced,
      syncError: json['sync_error'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UserMembershipToJson(UserMembership instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'membership_level_id': instance.membershipLevelId,
      'status': _$MembershipStatusEnumMap[instance.status]!,
      'started_at': instance.startedAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'auto_renews': instance.autoRenews,
      'renewal_grace_period_days': instance.renewalGracePeriodDays,
      'last_synced_at': instance.lastSyncedAt?.toIso8601String(),
      'sync_source': _$SyncSourceEnumMap[instance.syncSource],
      'sync_status': _$SyncStatusEnumMap[instance.syncStatus]!,
      'sync_error': instance.syncError,
      'metadata': instance.metadata,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$MembershipStatusEnumMap = {
  MembershipStatus.active: 'active',
  MembershipStatus.inactive: 'inactive',
  MembershipStatus.cancelled: 'cancelled',
  MembershipStatus.expired: 'expired',
  MembershipStatus.pending: 'pending',
};

const _$SyncSourceEnumMap = {
  SyncSource.revenuecat: 'revenuecat',
  SyncSource.wordpress: 'wordpress',
  SyncSource.manual: 'manual',
  SyncSource.autoFreemium: 'auto_freemium',
};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
  SyncStatus.error: 'error',
};

import 'package:json_annotation/json_annotation.dart';
import 'memberships.dart';

part 'user_membership.g.dart';

@JsonSerializable()
class UserMembership {
  final int id;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'membership_level_id')
  final int membershipLevelId;

  final String? status;

  @JsonKey(name: 'started_at')
  final DateTime? startedAt;

  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;

  @JsonKey(name: 'auto_renews')
  final bool? autoRenews;

  @JsonKey(name: 'renewal_grace_period_days')
  final int? renewalGracePeriodDays;

  @JsonKey(name: 'last_synced_at')
  final DateTime? lastSyncedAt;

  @JsonKey(name: 'sync_source')
  final String? syncSource;

  @JsonKey(name: 'sync_status')
  final String? syncStatus;

  @JsonKey(name: 'sync_error')
  final String? syncError;

  final Map<String, dynamic>? metadata;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  // Relación con membership_level
  @JsonKey(name: 'membership_level')
  final MembershipLevel? membershipLevel;

  UserMembership({
    required this.id,
    required this.userId,
    required this.membershipLevelId,
    this.status = 'active',
    this.startedAt,
    this.expiresAt,
    this.cancelledAt,
    this.autoRenews = false,
    this.renewalGracePeriodDays = 3,
    this.lastSyncedAt,
    this.syncSource,
    this.syncStatus = 'synced',
    this.syncError,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.membershipLevel,
  });

  static UserMembership empty() {
    final now = DateTime.now();
    return UserMembership(
      id: 0,
      userId: 0,
      membershipLevelId: 0,
      status: 'active',
      startedAt: now,
      expiresAt: null,
      cancelledAt: null,
      autoRenews: false,
      renewalGracePeriodDays: 3,
      lastSyncedAt: now,
      syncSource: null,
      syncStatus: 'synced',
      syncError: null,
      metadata: null,
      createdAt: now,
      updatedAt: now,
      membershipLevel: null,
    );
  }

  factory UserMembership.fromJson(Map<String, dynamic> json) =>
      _$UserMembershipFromJson(json);

  Map<String, dynamic> toJson() => _$UserMembershipToJson(this);

  UserMembership copyWith({
    int? id,
    int? userId,
    int? membershipLevelId,
    String? status,
    DateTime? startedAt,
    DateTime? expiresAt,
    DateTime? cancelledAt,
    bool? autoRenews,
    int? renewalGracePeriodDays,
    DateTime? lastSyncedAt,
    String? syncSource,
    String? syncStatus,
    String? syncError,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    MembershipLevel? membershipLevel,
  }) {
    return UserMembership(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      membershipLevelId: membershipLevelId ?? this.membershipLevelId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      autoRenews: autoRenews ?? this.autoRenews,
      renewalGracePeriodDays:
      renewalGracePeriodDays ?? this.renewalGracePeriodDays,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncSource: syncSource ?? this.syncSource,
      syncStatus: syncStatus ?? this.syncStatus,
      syncError: syncError ?? this.syncError,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      membershipLevel: membershipLevel ?? this.membershipLevel,
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';
  bool get isPending => status == 'pending';
  bool get isInactive => status == 'inactive';

  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isInGracePeriod {
    if (expiresAt == null) return false;
    final gracePeriodEnd = expiresAt!.add(
      Duration(days: renewalGracePeriodDays ?? 3),
    );
    final now = DateTime.now();
    return now.isAfter(expiresAt!) && now.isBefore(gracePeriodEnd);
  }

  bool get isValidAndActive {
    return isActive && !hasExpired;
  }

  int? get daysUntilExpiration {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return 0;
    return expiresAt!.difference(now).inDays;
  }

  bool get isSynced => syncStatus == 'synced';
  bool get hasSyncError => syncStatus == 'error';

  String get sourceName {
    switch (syncSource) {
      case 'revenuecat':
        return 'RevenueCat';
      case 'wordpress':
        return 'WordPress';
      case 'manual':
        return 'Manual';
      default:
        return 'Unknown';
    }
  }
}
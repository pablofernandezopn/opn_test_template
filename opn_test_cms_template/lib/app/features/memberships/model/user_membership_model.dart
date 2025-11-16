import 'package:json_annotation/json_annotation.dart';

part 'user_membership_model.g.dart';

/// Estados posibles de una membresía de usuario
enum MembershipStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('expired')
  expired,
  @JsonValue('pending')
  pending,
}

/// Fuentes de sincronización de membresía
enum SyncSource {
  @JsonValue('revenuecat')
  revenuecat,
  @JsonValue('wordpress')
  wordpress,
  @JsonValue('manual')
  manual,
  @JsonValue('auto_freemium')
  autoFreemium,
}

/// Estados de sincronización
enum SyncStatus {
  @JsonValue('synced')
  synced,
  @JsonValue('pending')
  pending,
  @JsonValue('error')
  error,
}

/// Representa la membresía activa de un usuario a un nivel específico.
///
/// Gestiona:
/// - Relación usuario-nivel de membresía
/// - Estado y vigencia de la membresía
/// - Renovación automática
/// - Sincronización con sistemas externos (RevenueCat, WordPress)
/// - Metadatos personalizados
@JsonSerializable(explicitToJson: true)
class UserMembership {
  /// ID único de la membresía del usuario
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  /// ID del usuario propietario de la membresía
  @JsonKey(name: 'user_id')
  final int userId;

  /// ID del nivel de membresía asociado
  @JsonKey(name: 'membership_level_id')
  final int membershipLevelId;

  /// Estado actual de la membresía
  @JsonKey(defaultValue: MembershipStatus.active)
  final MembershipStatus status;

  /// Fecha de inicio de la membresía
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;

  /// Fecha de expiración (null = ilimitada)
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  /// Fecha de cancelación (si aplica)
  @JsonKey(name: 'cancelled_at')
  final DateTime? cancelledAt;

  /// Indica si la membresía se renueva automáticamente
  @JsonKey(name: 'auto_renews', defaultValue: false)
  final bool autoRenews;

  /// Días de gracia para renovación (default: 3)
  @JsonKey(name: 'renewal_grace_period_days', defaultValue: 3)
  final int renewalGracePeriodDays;

  /// Última fecha de sincronización con sistemas externos
  @JsonKey(name: 'last_synced_at')
  final DateTime? lastSyncedAt;

  /// Fuente de sincronización de esta membresía
  @JsonKey(name: 'sync_source')
  final SyncSource? syncSource;

  /// Estado de la última sincronización
  @JsonKey(name: 'sync_status', defaultValue: SyncStatus.synced)
  final SyncStatus syncStatus;

  /// Error de sincronización (si existe)
  @JsonKey(name: 'sync_error')
  final String? syncError;

  /// Metadatos personalizados en formato JSON
  final Map<String, dynamic>? metadata;

  /// Fecha de creación del registro
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const UserMembership({
    this.id,
    required this.userId,
    required this.membershipLevelId,
    this.status = MembershipStatus.active,
    this.startedAt,
    this.expiresAt,
    this.cancelledAt,
    this.autoRenews = false,
    this.renewalGracePeriodDays = 3,
    this.lastSyncedAt,
    this.syncSource,
    this.syncStatus = SyncStatus.synced,
    this.syncError,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  /// Membresía vacía para estados iniciales
  static const UserMembership empty = UserMembership(
    id: null,
    userId: 0,
    membershipLevelId: 0,
    status: MembershipStatus.pending,
    startedAt: null,
    expiresAt: null,
    cancelledAt: null,
    autoRenews: false,
    renewalGracePeriodDays: 3,
    lastSyncedAt: null,
    syncSource: null,
    syncStatus: SyncStatus.synced,
    syncError: null,
    metadata: null,
    createdAt: null,
    updatedAt: null,
  );

  /// Crea una instancia desde JSON
  factory UserMembership.fromJson(Map<String, dynamic> json) =>
      _$UserMembershipFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    final json = _$UserMembershipToJson(this);
    // Remover campos generados automáticamente por la BD en INSERT
    if (id == null) {
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');
    }
    return json;
  }

  /// Crea una copia con campos modificados
  UserMembership copyWith({
    int? id,
    int? userId,
    int? membershipLevelId,
    MembershipStatus? status,
    DateTime? startedAt,
    DateTime? expiresAt,
    DateTime? cancelledAt,
    bool? autoRenews,
    int? renewalGracePeriodDays,
    DateTime? lastSyncedAt,
    SyncSource? syncSource,
    SyncStatus? syncStatus,
    String? syncError,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
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
    );
  }

  // ========== Getters de validación ==========

  /// Valida que los IDs sean positivos
  bool get hasValidIds => userId > 0 && membershipLevelId > 0;

  /// Valida que el periodo de gracia sea no negativo
  bool get hasValidGracePeriod => renewalGracePeriodDays >= 0;

  /// Valida que las fechas sean lógicas
  bool get hasValidDates {
    if (startedAt != null && expiresAt != null) {
      if (expiresAt!.isBefore(startedAt!)) return false;
    }
    if (cancelledAt != null && startedAt != null) {
      if (cancelledAt!.isBefore(startedAt!)) return false;
    }
    return true;
  }

  /// Valida todos los campos requeridos
  bool get isValid => hasValidIds && hasValidGracePeriod && hasValidDates;

  // ========== Getters de estado ==========

  /// Indica si la membresía está vacía
  bool get isEmpty => id == null && userId == 0;

  /// Indica si la membresía está activa
  bool get isActive => status == MembershipStatus.active;

  /// Indica si la membresía está inactiva
  bool get isInactive => status == MembershipStatus.inactive;

  /// Indica si la membresía fue cancelada
  bool get isCancelled => status == MembershipStatus.cancelled;

  /// Indica si la membresía expiró
  bool get isExpired => status == MembershipStatus.expired;

  /// Indica si la membresía está pendiente
  bool get isPending => status == MembershipStatus.pending;

  /// Indica si la membresía tiene duración ilimitada
  bool get isUnlimited => expiresAt == null;

  /// Indica si la membresía ha expirado (comparando fechas)
  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Indica si la membresía está en periodo de gracia
  bool get isInGracePeriod {
    if (expiresAt == null || !hasExpired) return false;
    final gracePeriodEnd = expiresAt!.add(
      Duration(days: renewalGracePeriodDays),
    );
    return DateTime.now().isBefore(gracePeriodEnd);
  }

  /// Días restantes hasta expiración (negativo si ya expiró)
  int? get daysUntilExpiration {
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  /// Indica si la sincronización está completa
  bool get isSynced => syncStatus == SyncStatus.synced;

  /// Indica si hay un error de sincronización
  bool get hasSyncError => syncStatus == SyncStatus.error;

  /// Indica si la sincronización está pendiente
  bool get isSyncPending => syncStatus == SyncStatus.pending;

  // ========== Getters de información ==========

  /// Texto descriptivo del estado
  String get statusDescription {
    switch (status) {
      case MembershipStatus.active:
        return 'Activa';
      case MembershipStatus.inactive:
        return 'Inactiva';
      case MembershipStatus.cancelled:
        return 'Cancelada';
      case MembershipStatus.expired:
        return 'Expirada';
      case MembershipStatus.pending:
        return 'Pendiente';
    }
  }

  /// Texto descriptivo de la fuente de sincronización
  String get syncSourceDescription {
    if (syncSource == null) return 'N/A';
    switch (syncSource!) {
      case SyncSource.revenuecat:
        return 'RevenueCat';
      case SyncSource.wordpress:
        return 'WordPress';
      case SyncSource.manual:
        return 'Manual';
      case SyncSource.autoFreemium:
        return 'Auto Freemium';
    }
  }

  /// Descripción de tiempo hasta expiración
  String get expirationDescription {
    if (isUnlimited) return 'Sin expiración';
    if (expiresAt == null) return 'N/A';

    final days = daysUntilExpiration;
    if (days == null) return 'N/A';

    if (days < 0) {
      return 'Expiró hace ${-days} día${-days == 1 ? '' : 's'}';
    } else if (days == 0) {
      return 'Expira hoy';
    } else if (days == 1) {
      return 'Expira mañana';
    } else if (days <= 7) {
      return 'Expira en $days días';
    } else if (days <= 30) {
      return 'Expira en ${(days / 7).ceil()} semana${(days / 7).ceil() == 1 ? '' : 's'}';
    } else {
      return 'Expira en ${(days / 30).ceil()} mes${(days / 30).ceil() == 1 ? '' : 'es'}';
    }
  }

  @override
  String toString() {
    return 'UserMembership(id: $id, userId: $userId, '
        'membershipLevelId: $membershipLevelId, status: $status, '
        'expiresAt: $expiresAt, autoRenews: $autoRenews)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserMembership && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

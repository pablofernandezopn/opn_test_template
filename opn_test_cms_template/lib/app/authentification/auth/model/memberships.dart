import 'package:json_annotation/json_annotation.dart';
part 'memberships.g.dart';

@JsonSerializable()
class MembershipLevel {
  final int id;
  final String name;
  final String? description;

  @JsonKey(name: 'wordpress_rcp_id')
  final int? wordpressRcpId;

  @JsonKey(name: 'wordpress_level_name')
  final String? wordpressLevelName;

  @JsonKey(name: 'revenuecat_product_ids')
  final List<String> revenuecatProductIds;

  @JsonKey(name: 'revenuecat_entitlement_id')
  final String? revenuecatEntitlementId;

  @JsonKey(name: 'duration_days')
  final int? durationDays;

  @JsonKey(name: 'is_recurring')
  final bool? isRecurring;

  @JsonKey(name: 'trial_days')
  final int? trialDays;

  @JsonKey(name: 'max_content_access')
  final int? maxContentAccess;

  @JsonKey(name: 'features')
  final Map<String, dynamic>? features;

  @JsonKey(name: 'price_usd')
  final double? priceUsd;

  @JsonKey(name: 'price_eur')
  final double? priceEur;

  @JsonKey(name: 'currency_code')
  final String? currencyCode;

  @JsonKey(name: 'is_active')
  final bool? isActive;

  @JsonKey(name: 'display_order')
  final int? displayOrder;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @JsonKey(name: 'access_level')
  final int accessLevel;

  MembershipLevel({
    required this.id,
    required this.name,
    this.description,
    this.wordpressRcpId,
    this.wordpressLevelName,
    this.revenuecatProductIds = const [],
    this.revenuecatEntitlementId,
    this.durationDays,
    this.isRecurring = false,
    this.trialDays = 0,
    this.maxContentAccess,
    this.features,
    this.priceUsd,
    this.priceEur,
    this.currencyCode = 'EUR',
    this.isActive = true,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
    this.accessLevel = 1,
  });

  // Constructor para estado vacío
  static MembershipLevel empty() {
    final now = DateTime.now();
    return MembershipLevel(
      id: 0,
      name: '',
      description: null,
      wordpressRcpId: null,
      wordpressLevelName: null,
      revenuecatProductIds: const [],
      revenuecatEntitlementId: null,
      durationDays: null,
      isRecurring: false,
      trialDays: 0,
      maxContentAccess: null,
      features: null,
      priceUsd: null,
      priceEur: null,
      currencyCode: 'EUR',
      isActive: true,
      displayOrder: 0,
      createdAt: now,
      updatedAt: now,
      accessLevel: 1,
    );
  }

  factory MembershipLevel.fromJson(Map<String, dynamic> json) =>
      _$MembershipLevelFromJson(json);

  Map<String, dynamic> toJson() => _$MembershipLevelToJson(this);

  MembershipLevel copyWith({
    int? id,
    String? name,
    String? description,
    int? wordpressRcpId,
    String? wordpressLevelName,
    List<String>? revenuecatProductIds,
    String? revenuecatEntitlementId,
    int? durationDays,
    bool? isRecurring,
    int? trialDays,
    int? maxContentAccess,
    Map<String, dynamic>? features,
    double? priceUsd,
    double? priceEur,
    String? currencyCode,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? accessLevel,
  }) {
    return MembershipLevel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      wordpressRcpId: wordpressRcpId ?? this.wordpressRcpId,
      wordpressLevelName: wordpressLevelName ?? this.wordpressLevelName,
      revenuecatProductIds: revenuecatProductIds ?? this.revenuecatProductIds,
      revenuecatEntitlementId:
      revenuecatEntitlementId ?? this.revenuecatEntitlementId,
      durationDays: durationDays ?? this.durationDays,
      isRecurring: isRecurring ?? this.isRecurring,
      trialDays: trialDays ?? this.trialDays,
      maxContentAccess: maxContentAccess ?? this.maxContentAccess,
      features: features ?? this.features,
      priceUsd: priceUsd ?? this.priceUsd,
      priceEur: priceEur ?? this.priceEur,
      currencyCode: currencyCode ?? this.currencyCode,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accessLevel: accessLevel ?? this.accessLevel,
    );
  }

  // Helpers útiles
  bool get isPremiumPlus => accessLevel == 3;
  bool get isPremium => accessLevel == 2;
  bool get isFree => accessLevel == 1;

  bool get hasRevenuecatProducts => revenuecatProductIds.isNotEmpty;

  String get displayPrice {
    if (priceEur != null) {
      return '${priceEur!.toStringAsFixed(2)} €';
    } else if (priceUsd != null) {
      return '\$${priceUsd!.toStringAsFixed(2)}';
    }
    return 'Free';
  }

  bool get isTrial => trialDays != null && trialDays! > 0;
}
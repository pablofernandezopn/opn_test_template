// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memberships.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipLevel _$MembershipLevelFromJson(Map<String, dynamic> json) =>
    MembershipLevel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      wordpressRcpId: (json['wordpress_rcp_id'] as num?)?.toInt(),
      wordpressLevelName: json['wordpress_level_name'] as String?,
      revenuecatProductIds: (json['revenuecat_product_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      revenuecatEntitlementId: json['revenuecat_entitlement_id'] as String?,
      durationDays: (json['duration_days'] as num?)?.toInt(),
      isRecurring: json['is_recurring'] as bool? ?? false,
      trialDays: (json['trial_days'] as num?)?.toInt() ?? 0,
      maxContentAccess: (json['max_content_access'] as num?)?.toInt(),
      features: json['features'] as Map<String, dynamic>?,
      priceUsd: (json['price_usd'] as num?)?.toDouble(),
      priceEur: (json['price_eur'] as num?)?.toDouble(),
      currencyCode: json['currency_code'] as String? ?? 'EUR',
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      accessLevel: (json['access_level'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$MembershipLevelToJson(MembershipLevel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'wordpress_rcp_id': instance.wordpressRcpId,
      'wordpress_level_name': instance.wordpressLevelName,
      'revenuecat_product_ids': instance.revenuecatProductIds,
      'revenuecat_entitlement_id': instance.revenuecatEntitlementId,
      'duration_days': instance.durationDays,
      'is_recurring': instance.isRecurring,
      'trial_days': instance.trialDays,
      'max_content_access': instance.maxContentAccess,
      'features': instance.features,
      'price_usd': instance.priceUsd,
      'price_eur': instance.priceEur,
      'currency_code': instance.currencyCode,
      'is_active': instance.isActive,
      'display_order': instance.displayOrder,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'access_level': instance.accessLevel,
    };

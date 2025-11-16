import 'package:json_annotation/json_annotation.dart';

part 'membership_level_model.g.dart';

/// Representa un nivel de membresía disponible en una especialidad.
///
/// Cada nivel de membresía define:
/// - Información básica (nombre, descripción)
/// - Integración con WordPress RCP
/// - Integración con RevenueCat
/// - Configuración de duración y recurrencia
/// - Límites de acceso al contenido
/// - Características específicas (features)
/// - Información de precios
@JsonSerializable(explicitToJson: true)
class MembershipLevel {
  /// ID único del nivel de membresía
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  /// Nombre del nivel de membresía (requerido, máx 100 caracteres)
  final String name;

  /// Descripción del nivel de membresía
  final String? description;

  /// ID del nivel en WordPress RCP (para sincronización, único)
  @JsonKey(name: 'wordpress_rcp_id')
  final int? wordpressRcpId;

  /// Nombre del nivel en WordPress (máx 100 caracteres)
  @JsonKey(name: 'wordpress_level_name')
  final String? wordpressLevelName;

  /// IDs de productos en RevenueCat asociados a este nivel
  @JsonKey(name: 'revenuecat_product_ids', defaultValue: [])
  final List<String> revenuecatProductIds;

  /// ID del entitlement en RevenueCat (máx 100 caracteres)
  @JsonKey(name: 'revenuecat_entitlement_id')
  final String? revenuecatEntitlementId;

  /// Duración en días del nivel de membresía (null = ilimitado)
  @JsonKey(name: 'duration_days')
  final int? durationDays;

  /// Indica si la membresía es recurrente (suscripción)
  @JsonKey(name: 'is_recurring', defaultValue: false)
  final bool isRecurring;

  /// Días de prueba gratis
  @JsonKey(name: 'trial_days', defaultValue: 0)
  final int trialDays;

  /// Máximo de contenido al que puede acceder (null = ilimitado)
  @JsonKey(name: 'max_content_access')
  final int? maxContentAccess;

  /// Características específicas del nivel (JSON flexible)
  final Map<String, dynamic>? features;

  /// Precio en dólares estadounidenses (numeric 10,2)
  @JsonKey(name: 'price_usd')
  final double? priceUsd;

  /// Precio en euros (numeric 10,2)
  @JsonKey(name: 'price_eur')
  final double? priceEur;

  /// Código de moneda (máx 3 caracteres, default: EUR)
  @JsonKey(name: 'currency_code', defaultValue: 'EUR')
  final String currencyCode;

  /// Indica si el nivel está activo y disponible
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;

  /// Orden de visualización (para ordenar en UI)
  @JsonKey(name: 'display_order', defaultValue: 0)
  final int displayOrder;

  /// Fecha de creación
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// ID de la especialidad a la que pertenece (requerido)
  @JsonKey(name: 'specialty_id')
  final int specialtyId;

  /// Nivel de acceso (1 = básico, mayor = más acceso, debe ser > 0)
  @JsonKey(name: 'access_level', defaultValue: 1)
  final int accessLevel;

  const MembershipLevel({
    this.id,
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
    required this.specialtyId,
    this.accessLevel = 1,
  });

  /// Nivel de membresía vacío para estados iniciales
  static const MembershipLevel empty = MembershipLevel(
    id: null,
    name: '',
    description: null,
    wordpressRcpId: null,
    wordpressLevelName: null,
    revenuecatProductIds: [],
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
    createdAt: null,
    updatedAt: null,
    specialtyId: 1,
    accessLevel: 1,
  );

  /// Crea una instancia desde JSON
  factory MembershipLevel.fromJson(Map<String, dynamic> json) =>
      _$MembershipLevelFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    final json = _$MembershipLevelToJson(this);
    // Remover campos generados automáticamente por la BD en INSERT
    if (id == null) {
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');
    }
    return json;
  }

  /// Crea una copia con campos modificados
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
    int? specialtyId,
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
      specialtyId: specialtyId ?? this.specialtyId,
      accessLevel: accessLevel ?? this.accessLevel,
    );
  }

  /// Valida que el nombre no esté vacío y no exceda 100 caracteres
  bool get hasValidName => name.trim().isNotEmpty && name.length <= 100;

  /// Valida que el nivel de acceso sea positivo
  bool get hasValidAccessLevel => accessLevel > 0;

  /// Valida que el precio EUR sea válido (si existe)
  bool get hasValidPrice {
    if (priceEur == null) return true;
    return priceEur! >= 0;
  }

  /// Valida que la duración sea positiva (si existe)
  bool get hasValidDuration {
    if (durationDays == null) return true;
    return durationDays! > 0;
  }

  /// Valida que el código de moneda no exceda 3 caracteres
  bool get hasValidCurrencyCode => currencyCode.length <= 3;

  /// Valida todos los campos requeridos
  bool get isValid =>
      hasValidName &&
      hasValidAccessLevel &&
      hasValidPrice &&
      hasValidDuration &&
      hasValidCurrencyCode;

  /// Indica si la membresía está vacía
  bool get isEmpty => id == null && name.isEmpty;

  /// Indica si la membresía es gratuita
  bool get isFree =>
      (priceEur == null || priceEur == 0) &&
      (priceUsd == null || priceUsd == 0);

  /// Indica si tiene duración ilimitada
  bool get isUnlimited => durationDays == null;

  /// Indica si tiene trial
  bool get hasTrial => trialDays > 0;

  /// Indica si tiene acceso ilimitado al contenido
  bool get hasUnlimitedContentAccess => maxContentAccess == null;

  /// Obtiene el precio formateado con moneda
  String get formattedPrice {
    if (isFree) return 'Gratis';

    if (currencyCode == 'EUR' && priceEur != null) {
      return '€${priceEur!.toStringAsFixed(2)}';
    } else if (currencyCode == 'USD' && priceUsd != null) {
      return '\$${priceUsd!.toStringAsFixed(2)}';
    }

    return 'N/A';
  }

  /// Obtiene la descripción de duración
  String get durationDescription {
    if (isUnlimited) return 'Ilimitado';
    if (durationDays == null) return 'N/A';

    if (durationDays! >= 365) {
      final years = (durationDays! / 365).floor();
      return years == 1 ? '1 año' : '$years años';
    } else if (durationDays! >= 30) {
      final months = (durationDays! / 30).floor();
      return months == 1 ? '1 mes' : '$months meses';
    } else {
      return durationDays == 1 ? '1 día' : '$durationDays días';
    }
  }

  @override
  String toString() {
    return 'MembershipLevel(id: $id, name: $name, specialtyId: $specialtyId, '
        'accessLevel: $accessLevel, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MembershipLevel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

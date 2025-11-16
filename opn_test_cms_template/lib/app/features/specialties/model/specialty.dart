import 'package:json_annotation/json_annotation.dart';

part 'specialty.g.dart';

@JsonSerializable(includeIfNull: false)
class Specialty {
  final int? id;

  @JsonKey(name: 'academy_id')
  final int? academyId;

  final String name;

  final String slug;

  final String? description;

  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  @JsonKey(name: 'color_hex')
  final String? colorHex;

  @JsonKey(name: 'display_order')
  final int displayOrder;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'is_default')
  final bool isDefault;

  @JsonKey(name: 'created_at', includeToJson: false)
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at', includeToJson: false)
  final DateTime? updatedAt;

  const Specialty({
    this.id,
    this.academyId,
    required this.name,
    required this.slug,
    this.description,
    this.iconUrl,
    this.colorHex,
    this.displayOrder = 0,
    this.isActive = true,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  static const Specialty empty = Specialty(
    id: 0,
    academyId: 0,
    name: 'General',
    slug: 'general',
    displayOrder: 0,
    isActive: true,
    isDefault: true,
  );

  factory Specialty.fromJson(Map<String, dynamic> json) =>
      _$SpecialtyFromJson(json);

  Map<String, dynamic> toJson() => _$SpecialtyToJson(this);

  /// Convierte a JSON para crear/actualizar en Supabase
  /// Excluye id (para CREATE), created_at y updated_at
  Map<String, dynamic> toJsonForCreate() {
    final json = <String, dynamic>{
      'name': name,
      'slug': slug,
      'display_order': displayOrder,
      'is_active': isActive,
      'is_default': isDefault,
    };

    // Incluir academy_id si existe
    if (academyId != null) json['academy_id'] = academyId;

    // Solo incluir campos opcionales si tienen valor
    if (description != null && description!.isNotEmpty) {
      json['description'] = description;
    }
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      json['icon_url'] = iconUrl;
    }
    if (colorHex != null && colorHex!.isNotEmpty) {
      json['color_hex'] = colorHex;
    }

    return json;
  }

  /// Convierte a JSON para actualizar en Supabase
  /// Incluye solo los campos que se pueden actualizar
  Map<String, dynamic> toJsonForUpdate() {
    final json = <String, dynamic>{
      'name': name,
      'slug': slug,
      'display_order': displayOrder,
      'is_active': isActive,
      'is_default': isDefault,
    };

    // Solo incluir campos opcionales si tienen valor
    if (description != null && description!.isNotEmpty) {
      json['description'] = description;
    }
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      json['icon_url'] = iconUrl;
    }
    if (colorHex != null && colorHex!.isNotEmpty) {
      json['color_hex'] = colorHex;
    }

    return json;
  }

  Specialty copyWith({
    int? id,
    int? academyId,
    String? name,
    String? slug,
    String? description,
    String? iconUrl,
    String? colorHex,
    int? displayOrder,
    bool? isActive,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Specialty(
      id: id ?? this.id,
      academyId: academyId ?? this.academyId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      colorHex: colorHex ?? this.colorHex,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verifica si la especialidad está vacía
  bool get isEmpty => id == null || id == 0;

  /// Verifica si es una especialidad nueva (sin ID)
  bool get isNew => id == null;

  @override
  String toString() => 'Specialty(id: $id, name: $name, slug: $slug)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Specialty &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          slug == other.slug;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ slug.hashCode;
}

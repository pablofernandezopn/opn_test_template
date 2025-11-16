import 'package:json_annotation/json_annotation.dart';

part 'academy_model.g.dart';

/// Representa una academia o centro de formación.
///
/// Cada academia agrupa:
/// - Usuarios editores/tutores (cms_users)
/// - Usuarios finales/estudiantes (users)
/// - Contenido educativo (topics, questions)
/// - Desafíos/reportes (challenges)
@JsonSerializable(explicitToJson: true)
class Academy {
  /// ID único de la academia
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  /// Nombre de la academia (único, requerido)
  final String name;

  /// Identificador URL-friendly (único, requerido)
  /// Formato: solo lowercase, números, guiones y guiones bajos
  final String slug;

  /// Descripción de la academia
  final String? description;

  /// URL del logo de la academia
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  /// Sitio web de la academia
  final String? website;

  /// Email de contacto de la academia
  @JsonKey(name: 'contact_email')
  final String? contactEmail;

  /// Teléfono de contacto de la academia
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;

  /// Dirección física de la academia
  final String? address;

  /// Indica si la academia está activa y puede operar
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;

  /// Fecha de creación
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const Academy({
    this.id,
    required this.name,
    required this.slug,
    this.description,
    this.logoUrl,
    this.website,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Academia vacía para estados iniciales
  static const Academy empty = Academy(
    id: null,
    name: '',
    slug: '',
    description: null,
    logoUrl: null,
    website: null,
    contactEmail: null,
    contactPhone: null,
    address: null,
    isActive: true,
    createdAt: null,
    updatedAt: null,
  );

  /// Academia OPN por defecto (ID: 1)
  static const Academy opn = Academy(
    id: 1,
    name: 'OPN',
    slug: 'opn',
    description: 'Academia por defecto del sistema OPN Test Guardia Civil',
    isActive: true,
  );

  /// Crea una instancia desde JSON
  factory Academy.fromJson(Map<String, dynamic> json) =>
      _$AcademyFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    final json = _$AcademyToJson(this);
    // Remover campos generados automáticamente por la BD en INSERT
    if (id == null) {
      json.remove('id');
      json.remove('created_at');
      json.remove('updated_at');
    }
    return json;
  }

  /// Crea una copia con campos modificados
  Academy copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? logoUrl,
    String? website,
    String? contactEmail,
    String? contactPhone,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Academy(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Valida que el nombre no esté vacío
  bool get hasValidName => name.trim().isNotEmpty;

  /// Valida que el slug tenga formato correcto
  /// Solo lowercase, números, guiones y guiones bajos
  bool get hasValidSlug {
    final slugPattern = RegExp(r'^[a-z0-9_-]+$');
    return slug.isNotEmpty && slugPattern.hasMatch(slug);
  }

  /// Valida que el email tenga formato correcto (si existe)
  bool get hasValidEmail {
    if (contactEmail == null || contactEmail!.isEmpty) return true;
    final emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );
    return emailPattern.hasMatch(contactEmail!);
  }

  /// Valida todos los campos requeridos
  bool get isValid => hasValidName && hasValidSlug && hasValidEmail;

  /// Indica si la academia está vacía
  bool get isEmpty => id == null && name.isEmpty && slug.isEmpty;

  @override
  String toString() {
    return 'Academy(id: $id, name: $name, slug: $slug, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Academy && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

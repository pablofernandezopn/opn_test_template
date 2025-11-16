import 'package:json_annotation/json_annotation.dart';

part 'academy.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Academy {
  const Academy({
    required this.id,
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

  final int id;
  final String name;
  final String slug;
  final String? description;

  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  final String? website;

  @JsonKey(name: 'contact_email')
  final String? contactEmail;

  @JsonKey(name: 'contact_phone')
  final String? contactPhone;

  final String? address;

  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  factory Academy.fromJson(Map<String, dynamic> json) => _$AcademyFromJson(json);

  Map<String, dynamic> toJson() => _$AcademyToJson(this);

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

  static const empty = Academy(
    id: 0,
    name: '',
    slug: '',
    description: null,
    logoUrl: null,
    website: null,
    contactEmail: null,
    contactPhone: null,
    address: null,
    isActive: false,
    createdAt: null,
    updatedAt: null,
  );
}

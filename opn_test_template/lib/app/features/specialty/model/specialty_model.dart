import 'package:json_annotation/json_annotation.dart';

part 'specialty_model.g.dart';

@JsonSerializable()
class Specialty {
  final int id;

  @JsonKey(name: 'academy_id')
  final int academyId;

  final String name;
  final String slug;
  final String? description;

  @JsonKey(name: 'is_default')
  final bool isDefault;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: 'display_order')
  final int displayOrder;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Specialty({
    required this.id,
    required this.academyId,
    required this.name,
    required this.slug,
    this.description,
    required this.isDefault,
    required this.isActive,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) =>
      _$SpecialtyFromJson(json);

  Map<String, dynamic> toJson() => _$SpecialtyToJson(this);

  Specialty copyWith({
    int? id,
    int? academyId,
    String? name,
    String? slug,
    String? description,
    bool? isDefault,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Specialty(
      id: id ?? this.id,
      academyId: academyId ?? this.academyId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
import 'package:json_annotation/json_annotation.dart';

part 'topic_group_model.g.dart';

/// Modelo para grupos de topics (exámenes secuenciales)
///
/// Un TopicGroup agrupa varios topics que se deben realizar en orden secuencial,
/// como un examen real con varias partes: Conocimientos → Psicotécnicos → Ortografía
@JsonSerializable(explicitToJson: true)
class TopicGroup {
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  final String name;

  final String? description;

  @JsonKey(name: 'academy_id', defaultValue: 1)
  final int academyId;

  final bool enabled;

  @JsonKey(name: 'is_premium')
  final bool isPremium;

  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const TopicGroup({
    this.id,
    required this.name,
    this.description,
    this.academyId = 1,
    this.enabled = true,
    this.isPremium = false,
    this.publishedAt,
    this.imageUrl,
    this.durationSeconds,
    this.createdAt,
    this.updatedAt,
  });

  /// Crea una instancia desde JSON
  factory TopicGroup.fromJson(Map<String, dynamic> json) => _$TopicGroupFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$TopicGroupToJson(this);

  /// Crea una copia con campos modificados
  TopicGroup copyWith({
    int? id,
    String? name,
    String? description,
    int? academyId,
    bool? enabled,
    bool? isPremium,
    DateTime? publishedAt,
    String? imageUrl,
    int? durationSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TopicGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      academyId: academyId ?? this.academyId,
      enabled: enabled ?? this.enabled,
      isPremium: isPremium ?? this.isPremium,
      publishedAt: publishedAt ?? this.publishedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TopicGroup(id: $id, name: $name, enabled: $enabled, isPremium: $isPremium)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopicGroup && other.id == id;
  }


  int get durationMinutes {
    if (durationSeconds == null) return 0;
    return (durationSeconds! / 60).ceil();
  }

  @override
  int get hashCode => id.hashCode;
}

import 'package:json_annotation/json_annotation.dart';

part 'topic_group_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TopicGroup {
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  final String name;

  final String? description;

  @JsonKey(name: 'academy_id')
  final int academyId;

  final bool enabled;

  @JsonKey(name: 'is_premium')
  final bool isPremium;

  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  static const empty = TopicGroup(
    name: '',
    academyId: 1,
    createdAt: null,
    updatedAt: null,
  );

  const TopicGroup({
    this.id,
    required this.name,
    this.description,
    this.academyId = 1,
    this.enabled = true,
    this.isPremium = false,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una instancia desde JSON
  factory TopicGroup.fromJson(Map<String, dynamic> json) =>
      _$TopicGroupFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    final json = _$TopicGroupToJson(this);
    // Asegurar que los campos int no se conviertan a double
    if (json['academy_id'] != null) {
      json['academy_id'] = (json['academy_id'] as num).toInt();
    }
    return json;
  }

  /// Crea una copia con campos modificados
  TopicGroup copyWith({
    int? id,
    String? name,
    String? description,
    int? academyId,
    bool? enabled,
    bool? isPremium,
    Object? publishedAt = const _Undefined(),
    Object? createdAt = const _Undefined(),
    Object? updatedAt = const _Undefined(),
  }) {
    return TopicGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      academyId: academyId ?? this.academyId,
      enabled: enabled ?? this.enabled,
      isPremium: isPremium ?? this.isPremium,
      publishedAt: publishedAt is _Undefined
          ? this.publishedAt
          : publishedAt as DateTime?,
      createdAt:
          createdAt is _Undefined ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          updatedAt is _Undefined ? this.updatedAt : updatedAt as DateTime?,
    );
  }

  @override
  String toString() {
    return 'TopicGroup(id: $id, name: $name, academyId: $academyId, enabled: $enabled, isPremium: $isPremium)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopicGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class _Undefined {
  const _Undefined();
}

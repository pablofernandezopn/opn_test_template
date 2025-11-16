import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Category {
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  final String? name;

  @JsonKey(name: 'topic_type')
  final int? topicType;

  const Category({
    this.id,
    this.createdAt,
    this.name,
    this.topicType,
  });

  /// Crea una instancia desde JSON
  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  /// Crea una copia con campos modificados
  Category copyWith({
    int? id,
    DateTime? createdAt,
    String? name,
    int? topicType,
  }) {
    return Category(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      topicType: topicType ?? this.topicType,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, topicType: $topicType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
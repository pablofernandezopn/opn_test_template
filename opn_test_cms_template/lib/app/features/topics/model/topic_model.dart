import 'package:json_annotation/json_annotation.dart';

part 'topic_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Topic {
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: 'topic_type_id')
  final int topicTypeId;

  @JsonKey(name: 'category_id')
  final int? categoryId;

  @JsonKey(name: 'order')
  final int? order;

  @JsonKey(name: 'topic_name')
  final String topicName;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  final String? description;

  final bool enabled;

  @JsonKey(name: 'duration_seconds')
  final int? durationSeconds;

  @JsonKey(name: 'is_premium')
  final bool isPremium;

  @JsonKey(name: 'is_hidden_but_premium')
  final bool isHiddenButPremium;

  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;

  @JsonKey(name: 'total_participants', includeToJson: false)
  final int totalParticipants;

  @JsonKey(name: 'total_questions', includeToJson: false)
  final int totalQuestions;

  @JsonKey(name: 'total_score', includeToJson: false)
  final int totalScore;

  @JsonKey(name: 'average_score', includeToJson: false)
  final double? averageScore;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  final int options;

  @JsonKey(name: 'max_score', includeToJson: false)
  final int? maxScore;

  @JsonKey(name: 'min_score', includeToJson: false)
  final int? minScore;

  /// ID de la academia a la que pertenece este topic
  @JsonKey(name: 'academy_id', defaultValue: 1)
  final int academyId;

  @JsonKey(name: 'topic_group_id')
  final int? topicGroupId;

  /// Orden del topic dentro de su grupo
  @JsonKey(name: 'group_order')
  final int? groupOrder;

  /// ID de la especialidad a la que pertenece este topic (NULL = contenido compartido)
  @JsonKey(name: 'specialty_id')
  final int? specialtyId;

  static const empty = Topic(
      topicTypeId: 0,
      topicName: '',
      createdAt: null,
      updatedAt: null,
      durationSeconds: 0);

  const Topic({
    this.id,
    this.categoryId,
    this.order,
    this.imageUrl,
    this.durationSeconds = 55 * 60,
    required this.topicTypeId,
    required this.topicName,
    this.description,
    this.enabled = true,
    this.isPremium = false,
    this.isHiddenButPremium = false,
    this.publishedAt,
    this.totalParticipants = 0,
    this.totalQuestions = 0,
    this.totalScore = 0,
    this.averageScore,
    required this.createdAt,
    required this.updatedAt,
    this.options = 3,
    this.maxScore = 0,
    this.minScore = 0,
    this.academyId = 1,
    this.specialtyId,
    this.topicGroupId,
    this.groupOrder,
  });

  /// Crea una instancia desde JSON
  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    final json = _$TopicToJson(this);
    // Asegurar que los campos int no se conviertan a double
    if (json['options'] != null)
      json['options'] = (json['options'] as num).toInt();
    if (json['academy_id'] != null)
      json['academy_id'] = (json['academy_id'] as num).toInt();
    if (json['order'] != null) json['order'] = (json['order'] as num).toInt();
    if (json['group_order'] != null)
      json['group_order'] = (json['group_order'] as num).toInt();
    if (json['topic_type_id'] != null)
      json['topic_type_id'] = (json['topic_type_id'] as num).toInt();
    if (json['duration_seconds'] != null)
      json['duration_seconds'] = (json['duration_seconds'] as num).toInt();
    return json;
  }

  /// Crea una copia con campos modificados
  Topic copyWith(
      {int? id,
      int? order,
      int? topicTypeId,
      String? topicName,
      String? description,
      String? imageUrl,
      bool? enabled,
      bool? isPremium,
      bool? isHiddenButPremium,
      Object? publishedAt = const _Undefined(), // Cambiado
      int? totalParticipants,
      int? totalQuestions,
      int? totalScore,
      double? averageScore,
      Object? createdAt = const _Undefined(), // Cambiado
      Object? updatedAt = const _Undefined(), // Cambiado
      int? options,
      int? maxScore,
      int? minScore,
      int? academyId,
      int? specialtyId,
      int? durationSeconds,
      int? category,
      Object? topicGroupId = const _Undefined(),
      Object? groupOrder = const _Undefined()}) {
    return Topic(
      id: id ?? this.id,
      order: order ?? this.order,
      topicTypeId: topicTypeId ?? this.topicTypeId,
      topicName: topicName ?? this.topicName,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      enabled: enabled ?? this.enabled,
      isPremium: isPremium ?? this.isPremium,
      isHiddenButPremium: isHiddenButPremium ?? this.isHiddenButPremium,
      publishedAt: publishedAt is _Undefined
          ? this.publishedAt
          : publishedAt as DateTime?,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalScore: totalScore ?? this.totalScore,
      averageScore: averageScore ?? this.averageScore,
      createdAt:
          createdAt is _Undefined ? this.createdAt : createdAt as DateTime?,
      updatedAt:
          updatedAt is _Undefined ? this.updatedAt : updatedAt as DateTime?,
      options: options ?? this.options,
      maxScore: maxScore ?? this.maxScore,
      minScore: minScore ?? this.minScore,
      academyId: academyId ?? this.academyId,
      specialtyId: specialtyId ?? this.specialtyId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      categoryId: category ?? this.categoryId,
      topicGroupId:
          topicGroupId is _Undefined ? this.topicGroupId : topicGroupId as int?,
      groupOrder:
          groupOrder is _Undefined ? this.groupOrder : groupOrder as int?,
    );
  }

  @override
  String toString() {
    return 'Topic(id: $id, topicName: $topicName, topicTypeId: $topicTypeId, enabled: $enabled, isPremium: $isPremium)';
  }

  int get durationMinutes =>
      (durationSeconds != null) ? (durationSeconds! / 60).round() : 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Topic && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class _Undefined {
  const _Undefined();
}



import 'package:json_annotation/json_annotation.dart';

part 'topic_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Topic {
  @JsonKey(includeToJson: false, includeIfNull: false)
  final int? id;

  @JsonKey(name: 'topic_type_id')
  final int topicTypeId;

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

  @JsonKey(name: 'category_id')
  final int? categoryId;

  /// ID de la academia a la que pertenece este topic
  @JsonKey(name: 'academy_id', defaultValue: 1)
  final int academyId;

  /// ID del grupo al que pertenece este topic (NULL si va solo)
  @JsonKey(name: 'topic_group_id')
  final int? topicGroupId;

  /// Orden dentro del grupo (1, 2, 3...). NULL si no pertenece a ningún grupo
  @JsonKey(name: 'group_order')
  final int? groupOrder;

  /// ID de la especialidad a la que pertenece este topic (NULL si es general)
  @JsonKey(name: 'specialty_id')
  final int? specialtyId;



  static const empty = Topic(
    topicTypeId: 0,
    topicName: '',
    createdAt: null,
    updatedAt: null,
    durationSeconds: 0
  );

  const Topic({
    this.id,
    this.order,
    this.imageUrl,
    this.durationSeconds = 55*60,
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
    this.categoryId,
    this.topicGroupId,
    this.groupOrder,
    this.specialtyId,
  });

  /// Crea una instancia desde JSON
  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$TopicToJson(this);

  /// Crea una copia con campos modificados
  Topic copyWith({
    int? id,
    int? order,
    int? topicTypeId,
    String? topicName,
    String? description,
    bool? enabled,
    bool? isPremium,
    bool? isHiddenButPremium,
    DateTime? publishedAt,
    int? totalParticipants,
    int? totalQuestions,
    int? totalScore,
    double? averageScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? options,
    int? maxScore,
    int? minScore,
    int? academyId,
    int? durationSeconds,
    String? imageUrl,
    int? categoryId,
    int? topicGroupId,
    int? groupOrder,
    int? specialtyId,
  }) {
    return Topic(
      id: id ?? this.id,
      order: order ?? this.order,
      topicTypeId: topicTypeId ?? this.topicTypeId,
      topicName: topicName ?? this.topicName,
      description: description ?? this.description,
      enabled: enabled ?? this.enabled,
      isPremium: isPremium ?? this.isPremium,
      isHiddenButPremium: isHiddenButPremium ?? this.isHiddenButPremium,
      publishedAt: publishedAt ?? this.publishedAt,
      totalParticipants: totalParticipants ?? this.totalParticipants,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      totalScore: totalScore ?? this.totalScore,
      averageScore: averageScore ?? this.averageScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      options: options ?? this.options,
      maxScore: maxScore ?? this.maxScore,
      minScore: minScore ?? this.minScore,
      academyId: academyId ?? this.academyId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      topicGroupId: topicGroupId ?? this.topicGroupId,
      groupOrder: groupOrder ?? this.groupOrder,
      specialtyId: specialtyId ?? this.specialtyId,
    );
  }

  @override
  String toString() {
    return 'Topic(id: $id, topicName: $topicName, topicTypeId: $topicTypeId, enabled: $enabled, isPremium: $isPremium)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Topic && other.id == id;
  }

  //durationMinutes
  int get durationMinutes => (durationSeconds != null) ? (durationSeconds! / 60).round() : 0;

  @override
  int get hashCode => id.hashCode;
}
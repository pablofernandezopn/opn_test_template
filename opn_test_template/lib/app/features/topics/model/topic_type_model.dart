import 'package:json_annotation/json_annotation.dart';

import 'topic_level.dart';

part 'topic_type_model.g.dart';

/// Representa el tipo de un tema o categoría de preguntas.
@JsonSerializable(explicitToJson: true)
class TopicType {
  @JsonKey(includeIfNull: false)
  final int? id;

  @JsonKey(name: 'topic_type_name')
  final String topicTypeName;

  @JsonKey(name: 'default_number_options')
  final int defaultNumberOptions;

  final String? description;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  final double penalty;

  @JsonKey(name: 'level', defaultValue: TopicLevel.Mock)
  final TopicLevel? level;

  @JsonKey(name: 'order_of_appearance', defaultValue: 0)
  final int? orderOfAppearance;

  const TopicType({
    this.id,
    required this.topicTypeName,
    this.defaultNumberOptions = 4,
    this.description,
    required this.createdAt,
    this.penalty = 0.5,
    this.level = TopicLevel.Mock,
    this.orderOfAppearance = 0,
  });

  factory TopicType.fromJson(Map<String, dynamic> json) =>
      _$TopicTypeFromJson(json);

  Map<String, dynamic> toJson() => _$TopicTypeToJson(this);


  // topic empty copyWith
  static const TopicType empty = TopicType(
    id: null,
    topicTypeName: '',
    defaultNumberOptions: 4,
    description: null,
    createdAt: null,
    penalty: 0.5,
    level: TopicLevel.Mock,
    orderOfAppearance: 0,
  );

  TopicType copyWith({
    int? id,
    String? topicTypeName,
    int? defaultNumberOptions,
    String? description,
    DateTime? createdAt,
    double? penalty,
    TopicLevel? level,
    int? orderOfAppearance,
  }) {
    return TopicType(
      id: id ?? this.id,
      topicTypeName: topicTypeName ?? this.topicTypeName,
      defaultNumberOptions: defaultNumberOptions ?? this.defaultNumberOptions,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      penalty: penalty ?? this.penalty,
      level: level ?? this.level,
      orderOfAppearance: orderOfAppearance ?? this.orderOfAppearance,
    );
  }

  @override
  String toString() {
    return 'TopicType(id: $id, topicTypeName: $topicTypeName, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopicType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;


  bool get isFlashcards => level == TopicLevel.Flashcard;
  bool get isMock => level == TopicLevel.Mock;
  bool get isStudy => level == TopicLevel.Study;
  bool get isTest => isMock||isStudy;
}
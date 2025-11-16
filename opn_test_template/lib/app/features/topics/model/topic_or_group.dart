import 'package:opn_test_template/app/features/topics/model/topic_model.dart';
import 'package:opn_test_template/app/features/topics/model/topic_group_model.dart';

/// Clase wrapper para poder manejar Topics y TopicGroups en la misma lista
/// Permite ordenarlos juntos por published_at
class TopicOrGroup {
  final Topic? topic;
  final TopicGroup? topicGroup;
  final int? topicCount; // Solo para groups: cuántos topics tiene

  TopicOrGroup.topic(this.topic)
      : topicGroup = null,
        topicCount = null;

  TopicOrGroup.group(this.topicGroup, this.topicCount) : topic = null;

  bool get isGroup => topicGroup != null;
  bool get isTopic => topic != null;

  DateTime? get publishedAt => isGroup ? topicGroup!.publishedAt : topic!.publishedAt;

  String get name => isGroup ? topicGroup!.name : topic!.topicName;

  int? get id => isGroup ? topicGroup!.id : topic!.id;
}

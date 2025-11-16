import 'package:freezed_annotation/freezed_annotation.dart';
import '../model/topic_model.dart';
import '../model/topic_type_model.dart';
import '../model/category_model.dart';
import '../model/topic_group_model.dart';
import '../model/user_completed_topic_model.dart';
import '../model/user_completed_topic_group_model.dart';

part 'topic_state.freezed.dart';

enum StatusNames { loading, done, error }

class Status {
  final StatusNames status;
  final String message;

  Status({
    required this.status,
    String? message,
  }) : message = message ?? '';

  // Factory methods
  factory Status.loading([String? message]) =>
      Status(status: StatusNames.loading, message: message);

  factory Status.done([String? message]) =>
      Status(status: StatusNames.done, message: message);

  factory Status.error([String? message]) =>
      Status(status: StatusNames.error, message: message);

  // Getters de conveniencia
  bool get isLoading => status == StatusNames.loading;
  bool get isDone => status == StatusNames.done;
  bool get isError => status == StatusNames.error;

  // Necesario para Freezed
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Status &&
              runtimeType == other.runtimeType &&
              status == other.status &&
              message == other.message;

  @override
  int get hashCode => status.hashCode ^ message.hashCode;

  @override
  String toString() => 'Status(status: $status, message: $message)';
}

@freezed
class TopicState with _$TopicState {
  const factory TopicState({
    @Default([]) List<Topic> topics,
    @Default([]) List<TopicType> topicTypes,
    @Default([]) List<Category> categories,
    @Default([]) List<TopicGroup> topicGroups,
    // Mapa: topic_group_id -> topic_type_id (para filtrar grupos por tipo)
    @Default({}) Map<int, int> topicGroupTypeMap,
    // Mapa: topic_group_id -> cantidad de topics en el grupo
    @Default({}) Map<int, int> topicGroupCountMap,
    // Set de IDs de topics completados por el usuario
    @Default({}) Set<int> completedTopicIds,
    // Lista completa de topics completados con ranking
    @Default([]) List<UserCompletedTopic> completedTopics,
    // Lista de topic groups completados con ranking
    @Default([]) List<UserCompletedTopicGroup> completedTopicGroups,
    int? selectedTopicTypeId,
    int? selectedTopicId,
    required Status fetchTopicTypesStatus,
    required Status fetchTopicsStatus,
    required Status fetchTopicsByTypeStatus,
    required Status fetchCategoriesStatus,
    required Status fetchTopicGroupsStatus,
    required Status fetchCompletedTopicsStatus,
    String? error,
  }) = _TopicState;

  const TopicState._();

  // Helper para crear estado inicial
  factory TopicState.initial() => TopicState(
    fetchTopicTypesStatus: Status.done(),
    fetchTopicsStatus: Status.done(),
    fetchTopicsByTypeStatus: Status.done(),
    fetchCategoriesStatus: Status.done(),
    fetchTopicGroupsStatus: Status.done(),
    fetchCompletedTopicsStatus: Status.done(),
    error: null,
  );
}
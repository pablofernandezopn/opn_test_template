import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_group_model.dart';
import '../model/topic_model.dart';
import '../model/topic_type_model.dart';

part 'state.freezed.dart';

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
    @Default([]) List<TopicGroup> topicGroups, // AÑADIR
    int? selectedTopicTypeId,
    int? selectedTopicId,
    int? selectedTopicGroupId, // AÑADIR
    TopicGroup? selectedTopicGroup, // AÑADIR (opcional, para fetchById)
    required Status fetchStatus,
    required Status fetchTopicsStatus,
    required Status createTopicTypeStatus,
    required Status updateTopicTypeStatus,
    required Status deleteTopicTypeStatus,
    required Status createTopicStatus,
    required Status updateTopicStatus,
    required Status deleteTopicStatus,
    required Status fetchTopicsByTypeStatus,
    required Status fetchTopicGroupsStatus, // AÑADIR
    required Status fetchTopicGroupByIdStatus, // AÑADIR
    required Status createTopicGroupStatus, // AÑADIR
    required Status updateTopicGroupStatus, // AÑADIR
    required Status deleteTopicGroupStatus, // AÑADIR
    String? error,
  }) = _TopicState;

  const TopicState._();

  factory TopicState.initial() => TopicState(
        fetchStatus: Status.done(),
        fetchTopicsStatus: Status.done(),
        createTopicTypeStatus: Status.done(),
        updateTopicTypeStatus: Status.done(),
        deleteTopicTypeStatus: Status.done(),
        createTopicStatus: Status.done(),
        updateTopicStatus: Status.done(),
        deleteTopicStatus: Status.done(),
        fetchTopicsByTypeStatus: Status.done(),
        fetchTopicGroupsStatus: Status.done(), // AÑADIR
        fetchTopicGroupByIdStatus: Status.done(), // AÑADIR
        createTopicGroupStatus: Status.done(), // AÑADIR
        updateTopicGroupStatus: Status.done(), // AÑADIR
        deleteTopicGroupStatus: Status.done(), // AÑADIR
        error: null,
      );
}

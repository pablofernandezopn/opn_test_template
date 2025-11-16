import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/cubit/state.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_group_model.dart';
import '../../../../bootstrap.dart';
import '../../../authentification/auth/cubit/auth_cubit.dart';
import '../model/topic_level.dart';
import '../model/topic_model.dart';
import '../model/topic_type_model.dart';
import '../repository/respository.dart';

class TopicCubit extends Cubit<TopicState> {
  final TopicRepository _topicRepository;
  final AuthCubit _authCubit;

  TopicCubit(this._topicRepository, this._authCubit)
      : super(TopicState.initial()) {
    initialFetch();
  }

  /// Obtiene el academy_id del usuario autenticado
  int? get _currentAcademyId => _authCubit.state.user.academyId;

  /// Obtiene el specialty_id del usuario autenticado
  int? get _currentSpecialtyId => _authCubit.state.user.specialtyId;

  Future<void> initialFetch() async {
    try {
      // logger.info('curr: $_currentAcademyId');
      emit(state.copyWith(fetchStatus: Status.loading()));
      final topicTypes = await _topicRepository.fetchTopicTypes();

      logger.debug('Fetched topic types: $topicTypes');
      emit(state.copyWith(
        topicTypes: topicTypes,
        fetchStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching topic types: $e');
    }
  }

  Future<void> createTopicType(
      {required String name,
      String? description,
      required double penalty,
      required int defaultNumberOptions,
      required TopicLevel level}) async {
    try {
      emit(state.copyWith(createTopicTypeStatus: Status.loading()));
      final newTopicType = TopicType(
        topicTypeName: name,
        description: description,
        penalty: penalty,
        defaultNumberOptions: defaultNumberOptions,
        level: level,
        createdAt: DateTime.now(),
      );
      await _topicRepository.createTopicType(newTopicType);
      await initialFetch(); // Recargar para obtener el nuevo estado
    } catch (e) {
      emit(state.copyWith(
        createTopicTypeStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error creating topic type: $e');
    }
  }

  Future<void> updateTopicType(int id, TopicType topicType) async {
    try {
      emit(state.copyWith(updateTopicTypeStatus: Status.loading()));
      final updatedTopicType =
          await _topicRepository.updateTopicType(id, topicType);
      final updatedTopicTypes = state.topicTypes
          .map((t) => t.id == id ? updatedTopicType : t)
          .toList();
      emit(state.copyWith(
        topicTypes: updatedTopicTypes,
        updateTopicTypeStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        updateTopicTypeStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error updating topic type: $e');
    }
  }

  Future<void> updateTopicTypeOrder({
    required List<TopicType> topicTypes,
    required TopicLevel level,
    required int oldIndex,
    required int newIndex,
  }) async {
    // Reorder the list locally
    final item = topicTypes.removeAt(oldIndex);
    topicTypes.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);

    // Update the orderOfAppearance property
    final updatedOrder = topicTypes.asMap().entries.map((entry) {
      return entry.value.copyWith(orderOfAppearance: entry.key);
    }).toList();

    // Update the state with the new order
    final allTopicTypes = state.topicTypes
        .where((t) => t.level != level)
        .toList()
      ..addAll(updatedOrder);

    emit(state.copyWith(topicTypes: allTopicTypes));

    // Persist the changes to the database
    try {
      await _topicRepository.updateTopicTypeOrder(updatedOrder);
    } catch (e) {
      logger.error('Error updating topic type order: $e');
      // Optionally, revert the state if the update fails
      emit(state.copyWith(topicTypes: state.topicTypes));
    }
  }

  Future<void> deleteTopicType(int id) async {
    try {
      emit(state.copyWith(deleteTopicTypeStatus: Status.loading()));
      await _topicRepository.deleteTopicType(id);
      final updatedTopicTypes =
          state.topicTypes.where((t) => t.id != id).toList();
      emit(state.copyWith(
        topicTypes: updatedTopicTypes,
        deleteTopicTypeStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        deleteTopicTypeStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error deleting topic type: $e');
    }
  }

  Future<void> fetchTopics() async {
    try {
      emit(state.copyWith(fetchTopicsStatus: Status.loading()));
      // Filtrar topics por academy_id del usuario autenticado
      logger.info('ccurr : $_currentAcademyId');
      final topics = await _topicRepository.fetchTopics(
          academyId: _currentAcademyId, specialtyId: _currentSpecialtyId);
      emit(state.copyWith(
        topics: topics,
        fetchTopicsStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchTopicsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching topics: $e');
    }
  }

  Future<void> fetchUnassignedTopics() async {
    try {
      emit(state.copyWith(fetchTopicsStatus: Status.loading()));
      // Filtrar topics por academy_id del usuario autenticado
      final topics = await _topicRepository.fetchUnassignedTopics(
          academyId: _currentAcademyId, specialtyId: _currentSpecialtyId);
      emit(state.copyWith(
        topics: topics,
        fetchTopicsStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchTopicsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching topics: $e');
    }
  }

  Future<void> createTopic(Topic topic) async {
    try {
      emit(state.copyWith(createTopicStatus: Status.loading()));

      // Obtener todos los topics del mismo tipo
      final topicsOfSameType = state.topics
          .where((t) => t.topicTypeId == topic.topicTypeId)
          .toList();

      // Incrementar el orden de todos los topics existentes
      final updatedExistingTopics = topicsOfSameType.map((t) {
        return t.copyWith(order: (t.order ?? 0) + 1);
      }).toList();

      // Actualizar el orden en la base de datos primero
      if (updatedExistingTopics.isNotEmpty) {
        await _topicRepository.updateTopicOrder(updatedExistingTopics);
      }

      // Crear el nuevo topic con order = 0
      final topicWithOrder = topic.copyWith(order: 0);
      final newTopic = await _topicRepository.createTopic(topicWithOrder);

      // Actualizar el estado con todos los topics
      final otherTopics = state.topics
          .where((t) => t.topicTypeId != topic.topicTypeId)
          .toList();

      final updatedTopics = [
        ...otherTopics,
        newTopic,
        ...updatedExistingTopics,
      ];

      emit(state.copyWith(
        topics: updatedTopics,
        createTopicStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        createTopicStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error creating topic: $e');
    }
  }

  Future<void> updateTopic(int id, Topic topic) async {
    try {
      emit(state.copyWith(updateTopicStatus: Status.loading()));
      final updatedTopic = await _topicRepository.updateTopic(id, topic);
      // logger.info('Updated topic: $topic');
      final updatedTopics =
          state.topics.map((t) => t.id == id ? updatedTopic : t).toList();
      emit(state.copyWith(
        topics: updatedTopics,
        updateTopicStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        updateTopicStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error updating topic: $e');
    }
  }

  Future<void> deleteTopic(int id) async {
    try {
      emit(state.copyWith(deleteTopicStatus: Status.loading()));
      await _topicRepository.deleteTopic(id);
      final updatedTopics = state.topics.where((t) => t.id != id).toList();
      emit(state.copyWith(
        topics: updatedTopics,
        deleteTopicStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        deleteTopicStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error deleting topic: $e');
    }
  }

  Future<void> fetchTopicsByType(int topicTypeId) async {
    try {
      emit(state.copyWith(fetchTopicsByTypeStatus: Status.loading()));
      // Filtrar topics por academy_id del usuario autenticado
      final topics = await _topicRepository.fetchTopicsByType(topicTypeId,
          academyId: _currentAcademyId, specialtyId: _currentSpecialtyId);
      emit(state.copyWith(
        topics: topics,
        fetchTopicsByTypeStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchTopicsByTypeStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching topics by type: $e');
    }
  }

  void selectTopic(int? id) {
    emit(state.copyWith(selectedTopicId: id));
  }

  Future<void> reorderTopics({
    required int topicTypeId,
    required int oldIndex,
    required int newIndex,
  }) async {
    try {
      // Obtener los topics del tipo específico
      final topicsForType = state.topics
          .where((topic) => topic.topicTypeId == topicTypeId)
          .toList();

      // Reordenar localmente
      final item = topicsForType.removeAt(oldIndex);
      topicsForType.insert(newIndex, item);

      // Actualizar el campo order de cada topic
      final updatedTopics = topicsForType.asMap().entries.map((entry) {
        return entry.value.copyWith(order: entry.key);
      }).toList();

      // Actualizar el estado con el nuevo orden
      final allTopics = state.topics
          .where((t) => t.topicTypeId != topicTypeId)
          .toList()
        ..addAll(updatedTopics);

      emit(state.copyWith(topics: allTopics));

      // Persistir los cambios en la base de datos
      await _topicRepository.updateTopicOrder(updatedTopics);
    } catch (e) {
      logger.error('Error reordering topics: $e');
      // Revertir el estado si falla la actualización
      await fetchTopicsByType(topicTypeId);
    }
  }

  // Agregar al TopicCubit

// Fetch all topic groups
  Future<void> fetchTopicGroups() async {
    try {
      emit(state.copyWith(fetchTopicGroupsStatus: Status.loading()));
      // Filtrar por academy_id del usuario autenticado
      final topicGroups = await _topicRepository.fetchTopicGroups(
        academyId: _currentAcademyId,
      );
      emit(state.copyWith(
        topicGroups: topicGroups,
        fetchTopicGroupsStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchTopicGroupsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching topic groups: $e');
    }
  }

// Fetch a single topic group by id
  Future<void> fetchTopicGroupById(int id) async {
    try {
      emit(state.copyWith(fetchTopicGroupByIdStatus: Status.loading()));
      final topicGroup = await _topicRepository.fetchTopicGroupById(id);
      emit(state.copyWith(
        selectedTopicGroup: topicGroup,
        fetchTopicGroupByIdStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchTopicGroupByIdStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching topic group by id: $e');
    }
  }

// Create a new topic group
  Future<void> createTopicGroup(TopicGroup topicGroup) async {
    try {
      emit(state.copyWith(createTopicGroupStatus: Status.loading()));
      final newTopicGroup = await _topicRepository.createTopicGroup(topicGroup);
      final updatedTopicGroups = [...state.topicGroups, newTopicGroup];
      emit(state.copyWith(
        topicGroups: updatedTopicGroups,
        createTopicGroupStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        createTopicGroupStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error creating topic group: $e');
    }
  }

// Update an existing topic group
  Future<void> updateTopicGroup(int id, TopicGroup topicGroup) async {
    try {
      emit(state.copyWith(updateTopicGroupStatus: Status.loading()));
      final updatedTopicGroup =
          await _topicRepository.updateTopicGroup(id, topicGroup);
      final updatedTopicGroups = state.topicGroups
          .map((t) => t.id == id ? updatedTopicGroup : t)
          .toList();
      emit(state.copyWith(
        topicGroups: updatedTopicGroups,
        updateTopicGroupStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        updateTopicGroupStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error updating topic group: $e');
    }
  }

// Delete a topic group
  Future<void> deleteTopicGroup(int id) async {
    try {
      emit(state.copyWith(deleteTopicGroupStatus: Status.loading()));
      await _topicRepository.deleteTopicGroup(id);
      final updatedTopicGroups =
          state.topicGroups.where((t) => t.id != id).toList();
      emit(state.copyWith(
        topicGroups: updatedTopicGroups,
        deleteTopicGroupStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        deleteTopicGroupStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error deleting topic group: $e');
    }
  }

// Select a topic group
  void selectTopicGroup(int? id) {
    emit(state.copyWith(selectedTopicGroupId: id));
  }

// Fetch enabled topic groups (útil para filtros)
  Future<void> fetchEnabledTopicGroups() async {
    try {
      emit(state.copyWith(fetchTopicGroupsStatus: Status.loading()));
      final topicGroups = await _topicRepository.fetchEnabledTopicGroups(
        academyId: _currentAcademyId,
      );
      emit(state.copyWith(
        topicGroups: topicGroups,
        fetchTopicGroupsStatus: Status.done(),
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        fetchTopicGroupsStatus: Status.error('Error: ${e.toString()}'),
        error: e.toString(),
      ));
      logger.error('Error fetching enabled topic groups: $e');
    }
  }
}

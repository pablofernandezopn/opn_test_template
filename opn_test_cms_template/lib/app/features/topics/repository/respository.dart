import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_group_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_type_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TopicRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<TopicType>> fetchTopicTypes() async {
    final response = await _supabaseClient
        .from('topic_type')
        .select()
        .order('order_of_appearance', ascending: true);

    return response.map((json) => TopicType.fromJson(json)).toList();
  }

  Future<TopicType> createTopicType(TopicType topicType) async {
    final response = await _supabaseClient
        .from('topic_type')
        .insert(topicType.toJson())
        .select();

    return TopicType.fromJson(response.first);
  }

  Future<TopicType> updateTopicType(int id, TopicType topicType) async {
    final response = await _supabaseClient
        .from('topic_type')
        .update(topicType.toJson())
        .eq('id', id)
        .select();

    return TopicType.fromJson(response.first);
  }

  Future<void> updateTopicTypeOrder(List<TopicType> topicTypes) async {
    final updates = topicTypes.map((topicType) {
      return _supabaseClient
          .from('topic_type')
          .update({'order_of_appearance': topicType.orderOfAppearance}).eq(
              'id', topicType.id!);
    }).toList();

    await Future.wait(updates);
  }

  Future<void> deleteTopicType(int id) async {
    await _supabaseClient.from('topic_type').delete().eq('id', id);
  }

  Future<List<Topic>> fetchTopics({int? academyId, int? specialtyId}) async {
    var query = _supabaseClient.from('topic').select();

    // Filtrar por academy_id si se proporciona
    if (academyId != null) {
      query = query.eq('academy_id', academyId);
    }

    // Filtrar por specialty_id si se proporciona
    // Si specialtyId es null, mostrar solo contenido compartido (specialty_id IS NULL)
    // Si specialtyId tiene valor, mostrar contenido de esa especialidad O contenido compartido
    if (specialtyId != null) {
      query = query.or('specialty_id.eq.$specialtyId,specialty_id.is.null');
    }

    final response = await query;
    return response.map((json) => Topic.fromJson(json)).toList();
  }

  Future<List<Topic>> fetchUnassignedTopics(
      {int? academyId, int? specialtyId}) async {
    var query = _supabaseClient
        .from('topic')
        .select()
        .eq('topic_type_id', 3)
        .isFilter('topic_group_id', null);

    // Filtrar por academy_id si se proporciona
    if (academyId != null) {
      query = query.eq('academy_id', academyId);
    }

    // Filtrar por specialty_id si se proporciona
    // Si specialtyId es null, mostrar solo contenido compartido (specialty_id IS NULL)
    // Si specialtyId tiene valor, mostrar contenido de esa especialidad O contenido compartido
    if (specialtyId != null) {
      query = query.or('specialty_id.eq.$specialtyId,specialty_id.is.null');
    }

    final response = await query;
    return response.map((json) => Topic.fromJson(json)).toList();
  }

  Future<List<Topic>> fetchTopicsByType(int topicTypeId,
      {int? academyId, int? specialtyId}) async {
    var query =
        _supabaseClient.from('topic').select().eq('topic_type_id', topicTypeId);

    // Filtrar por academy_id si se proporciona
    if (academyId != null) {
      query = query.eq('academy_id', academyId);
    }

    // Filtrar por specialty_id si se proporciona
    // Si specialtyId es null, mostrar solo contenido compartido (specialty_id IS NULL)
    // Si specialtyId tiene valor, mostrar contenido de esa especialidad O contenido compartido
    if (specialtyId != null) {
      query = query.or('specialty_id.eq.$specialtyId,specialty_id.is.null');
    }

    final response = await query.order('order', ascending: true);
    return response.map((json) => Topic.fromJson(json)).toList();
  }

  Future<Topic> createTopic(Topic topic) async {
    final response =
        await _supabaseClient.from('topic').insert(topic.toJson()).select();
    return Topic.fromJson(response.first);
  }

  Future<Topic> updateTopic(int id, Topic topic) async {
    final response = await _supabaseClient
        .from('topic')
        .update(topic.toJson())
        .eq('id', id)
        .select();
    return Topic.fromJson(response.first);
  }

  Future<void> deleteTopic(int id) async {
    await _supabaseClient.from('topic').delete().eq('id', id);
  }

  Future<void> updateTopicOrder(List<Topic> topics) async {
    final updates = topics.map((topic) {
      return _supabaseClient
          .from('topic')
          .update({'order': topic.order}).eq('id', topic.id!);
    }).toList();

    await Future.wait(updates);
  }

  // Fetch all topic groups
  Future<List<TopicGroup>> fetchTopicGroups({int? academyId}) async {
    var query = _supabaseClient.from('topic_groups').select();

    // Filtrar por academy_id si se proporciona
    if (academyId != null) {
      query = query.eq('academy_id', academyId);
    }

    final response = await query.order('created_at', ascending: false);
    return response.map((json) => TopicGroup.fromJson(json)).toList();
  }

// Fetch a single topic group by id
  Future<TopicGroup> fetchTopicGroupById(int id) async {
    final response = await _supabaseClient
        .from('topic_groups')
        .select()
        .eq('id', id)
        .single();

    return TopicGroup.fromJson(response);
  }

// Create a new topic group
  Future<TopicGroup> createTopicGroup(TopicGroup topicGroup) async {
    final response = await _supabaseClient
        .from('topic_groups')
        .insert(topicGroup.toJson())
        .select();

    return TopicGroup.fromJson(response.first);
  }

// Update an existing topic group
  Future<TopicGroup> updateTopicGroup(int id, TopicGroup topicGroup) async {
    final response = await _supabaseClient
        .from('topic_groups')
        .update(topicGroup.toJson())
        .eq('id', id)
        .select();

    return TopicGroup.fromJson(response.first);
  }

// Delete a topic group
  Future<void> deleteTopicGroup(int id) async {
    await _supabaseClient.from('topic_groups').delete().eq('id', id);
  }

// Fetch enabled topic groups (útil para la app móvil)
  Future<List<TopicGroup>> fetchEnabledTopicGroups({int? academyId}) async {
    var query =
        _supabaseClient.from('topic_groups').select().eq('enabled', true);

    if (academyId != null) {
      query = query.eq('academy_id', academyId);
    }

    final response = await query.order('created_at', ascending: false);
    return response.map((json) => TopicGroup.fromJson(json)).toList();
  }

// Fetch published topic groups (con publishedAt no nulo)
  Future<List<TopicGroup>> fetchPublishedTopicGroups({int? academyId}) async {
    var query = _supabaseClient
        .from('topic_groups')
        .select()
        .not('published_at', 'is', null);

    if (academyId != null) {
      query = query.eq('academy_id', academyId);
    }

    final response = await query.order('published_at', ascending: false);
    return response.map((json) => TopicGroup.fromJson(json)).toList();
  }
}

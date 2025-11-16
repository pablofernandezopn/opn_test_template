import 'package:opn_test_template/app/authentification/auth/model/user.dart' as main_user;
import 'package:opn_test_template/app/features/topics/model/topic_model.dart';
import 'package:opn_test_template/app/features/topics/model/topic_type_model.dart';
import 'package:opn_test_template/app/features/topics/model/category_model.dart';
import 'package:opn_test_template/app/features/topics/model/topic_group_model.dart';
import 'package:opn_test_template/app/features/topics/model/user_special_topic_model.dart';
import 'package:opn_test_template/app/features/topics/model/user_completed_topic_model.dart';
import 'package:opn_test_template/app/features/topics/model/user_completed_topic_group_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../bootstrap.dart';


class TopicRepository {
  SupabaseClient get _supabaseClient => Supabase.instance.client;

  /// Obtiene todos los tipos de topic ordenados por order_of_appearance
  Future<List<TopicType>> fetchTopicTypes() async {
    final response = await _supabaseClient
        .from('topic_type')
        .select()
        .order('order_of_appearance', ascending: true);

    return response.map((json) => TopicType.fromJson(json)).toList();
  }

  /// Obtiene un tipo de topic específico por su identificador.
  Future<TopicType?> fetchTopicTypeById(int id) async {
    final response = await _supabaseClient
        .from('topic_type')
        .select()
        .eq('id', id)
        .limit(1);

    if (response.isEmpty) return null;
    return TopicType.fromJson(response.first);
  }

  /// Obtiene todos los topics, con filtro opcional por academy_id y specialty_id
  /// Si specialty_id es null, solo muestra topics generales (specialty_id = null)
  /// Si specialty_id tiene valor, muestra topics de esa especialidad + topics generales
  Future<List<Topic>> fetchTopics({int? academyId, int? specialtyId}) async {
    print('🔍 [TOPIC_REPO] fetchTopics INICIADO');
    print('🔍 [TOPIC_REPO] ├─ academyId: $academyId');
    print('🔍 [TOPIC_REPO] └─ specialtyId: $specialtyId');

    var query = _supabaseClient.from('topic').select();

    // Filtrar por academy_id si se proporciona
    if (academyId != null) {
      print('🔍 [TOPIC_REPO] Aplicando filtro: academy_id = $academyId');
      query = query.eq('academy_id', academyId);
    }

    // Filtrar por specialty_id
    if (specialtyId != null) {
      // Mostrar topics de la especialidad específica O topics generales (specialty_id = null)
      print('🔍 [TOPIC_REPO] Aplicando filtro: specialty_id = $specialtyId O specialty_id IS NULL');
      query = query.or('specialty_id.eq.$specialtyId,specialty_id.is.null');
    } else {
      // Si el usuario no tiene especialidad, solo mostrar topics generales
      print('🔍 [TOPIC_REPO] Aplicando filtro: solo topics generales (specialty_id IS NULL)');
      query = query.isFilter('specialty_id', null);
    }

    final response = await query;
    final topics = response.map((json) => Topic.fromJson(json)).toList();

    print('✅ [TOPIC_REPO] fetchTopics COMPLETADO: ${topics.length} topics');
    if (topics.isNotEmpty) {
      print('📋 [TOPIC_REPO] Primeros 5 topics:');
      for (final topic in topics.take(5)) {
        print('   - ID: ${topic.id}, Name: ${topic.topicName}, specialty_id: ${topic.specialtyId}');
      }
    }

    return topics;
  }

  /// Obtiene topics filtrados por tipo, con filtro opcional por academy_id y specialty_id
  /// Si specialty_id es null, solo muestra topics generales (specialty_id = null)
  /// Si specialty_id tiene valor, muestra topics de esa especialidad + topics generales
  Future<List<Topic>> fetchTopicsByType(int topicTypeId, {int? academyId, int? specialtyId, required main_user.User user}) async {
    print('🔍 [TOPIC_REPO] fetchTopicsByType INICIADO');
    print('🔍 [TOPIC_REPO] ├─ topicTypeId: $topicTypeId');
    print('🔍 [TOPIC_REPO] ├─ academyId: $academyId');
    print('🔍 [TOPIC_REPO] ├─ specialtyId: $specialtyId');
    print('🔍 [TOPIC_REPO] └─ isBetaTester: ${user.isBetaTester}');

    var query = _supabaseClient
        .from('topic')
        .select()
        .eq('topic_type_id', topicTypeId);

    // Filtrar por academy_id si se proporciona
    if (academyId != null) {
      print('🔍 [TOPIC_REPO] Filtrando por academy_id = $academyId');
      query = query.eq('academy_id', academyId);
    }

    // 🆕 Filtrar por specialty_id
    if (specialtyId != null) {
      // Mostrar topics de la especialidad específica O topics generales (specialty_id = null)
      print('🔍 [TOPIC_REPO] Filtrando por specialty_id = $specialtyId O specialty_id = null');
      query = query.or('specialty_id.eq.$specialtyId,specialty_id.is.null');
    } else {
      // Si el usuario no tiene especialidad, solo mostrar topics generales
      print('🔍 [TOPIC_REPO] Usuario sin especialidad, solo topics generales (specialty_id = null)');
      query = query.isFilter('specialty_id', null);
    }

    // filtrar por fecha de publicación
    if(!user.isBetaTester) {
      final now = DateTime.now().toUtc().toIso8601String();
      print('🔍 [TOPIC_REPO] Filtrando por published_at <= $now (no es beta tester)');
      query = query.lte('published_at', now);
    } else {
      print('🔍 [TOPIC_REPO] NO filtrando por published_at (es beta tester)');
    }

    final response = await query;

    final topics = response.map((json) => Topic.fromJson(json)).toList();

    print('✅ [TOPIC_REPO] fetchTopicsByType COMPLETADO: ${topics.length} topics encontrados');
    if (topics.isNotEmpty) {
      print('📋 [TOPIC_REPO] Topics encontrados:');
      for (final topic in topics) {
        print('   - ID: ${topic.id}, Name: ${topic.topicName}, specialty_id: ${topic.specialtyId}');
      }
    } else {
      print('⚠️ [TOPIC_REPO] No se encontraron topics con los filtros aplicados');
    }

    return topics;
  }

  /// Busca topics por texto libre en el nombre del topic
  /// Filtra por academy_id, specialty_id y topicTypeId
  /// Si specialty_id es null, solo muestra topics generales (specialty_id = null)
  /// Si specialty_id tiene valor, muestra topics de esa especialidad + topics generales
  Future<List<Topic>> searchTopics(
    String term, {
    int? academyId,
    int? specialtyId,
    int? topicTypeId,
  }) async {
    print('🔍 [TOPIC_REPO] searchTopics INICIADO');
    print('🔍 [TOPIC_REPO] ├─ term: "$term"');
    print('🔍 [TOPIC_REPO] ├─ academyId: $academyId');
    print('🔍 [TOPIC_REPO] ├─ specialtyId: $specialtyId');
    print('🔍 [TOPIC_REPO] └─ topicTypeId: $topicTypeId');

    var query = _supabaseClient.from('topic').select();

    // Filtrar por academy_id
    if (academyId != null) {
      query = query.eq('academy_id', academyId);
      print('🔍 [TOPIC_REPO] Aplicando filtro: academy_id = $academyId');
    }

    // Filtrar por topic_type_id
    if (topicTypeId != null) {
      query = query.eq('topic_type_id', topicTypeId);
      print('🔍 [TOPIC_REPO] Aplicando filtro: topic_type_id = $topicTypeId');
    }

    // 🆕 Filtrar por specialty_id (igual que fetchTopics y fetchTopicsByType)
    if (specialtyId != null) {
      // Mostrar topics de la especialidad específica O topics generales (specialty_id = null)
      query = query.or('specialty_id.eq.$specialtyId,specialty_id.is.null');
      print('🔍 [TOPIC_REPO] Aplicando filtro: specialty_id = $specialtyId O specialty_id IS NULL');
    } else {
      // Si el usuario no tiene especialidad, solo mostrar topics generales
      query = query.isFilter('specialty_id', null);
      print('🔍 [TOPIC_REPO] Aplicando filtro: solo topics generales (specialty_id IS NULL)');
    }

    // Filtrar por término de búsqueda
    final sanitized = term.trim();
    if (sanitized.isNotEmpty) {
      query = query.ilike('topic_name', '%$sanitized%');
      print('🔍 [TOPIC_REPO] Aplicando filtro: topic_name ILIKE "%$sanitized%"');
    }

    final response = await query;
    final topics = response.map((json) => Topic.fromJson(json)).toList();

    print('✅ [TOPIC_REPO] searchTopics COMPLETADO: ${topics.length} topics');
    if (topics.isNotEmpty && topics.length <= 5) {
      print('📋 [TOPIC_REPO] Topics encontrados:');
      for (final topic in topics) {
        print('   - ID: ${topic.id}, Name: ${topic.topicName}, specialty_id: ${topic.specialtyId}');
      }
    }

    return topics;
  }

  Future<Topic?> fetchTopicById(int id) async {
    final response = await _supabaseClient
        .from('topic')
        .select()
        .eq('id', id)
        .limit(1);
    if (response.isEmpty) return null;
    return Topic.fromJson(response.first);
  }

  /// Obtiene todas las categorías
  Future<List<Category>> fetchCategories() async {
    final response = await _supabaseClient
        .from('categories')
        .select();

    return response.map((json) => Category.fromJson(json)).toList();
  }

  // ============================================================================
  // TOPIC GROUPS - Grupos de examen secuenciales
  // ============================================================================

  /// Obtiene todos los topic_groups habilitados y publicados
  /// Ordenados por published_at descendente (más recientes primero)
  Future<List<TopicGroup>> fetchTopicGroups({int? academyId}) async {
    var query = _supabaseClient
        .from('topic_groups')
        .select()
        .eq('enabled', true)
        .not('published_at', 'is', null);

    // Filtrar por academy_id si se proporciona
    if (academyId != null) {
      query = query.eq('academy_id', academyId);
    }

    final response = await query.order('published_at', ascending: false);
    return response.map((json) => TopicGroup.fromJson(json)).toList();
  }

  /// Obtiene un topic_group por ID
  Future<TopicGroup?> fetchTopicGroupById(int id) async {
    final response = await _supabaseClient
        .from('topic_groups')
        .select()
        .eq('id', id)
        .limit(1);

    if (response.isEmpty) return null;
    return TopicGroup.fromJson(response.first);
  }

  /// Obtiene los topics de un grupo en orden secuencial
  Future<List<Topic>> fetchTopicsInGroup(int topicGroupId) async {
    final response = await _supabaseClient
        .from('topic')
        .select()
        .eq('topic_group_id', topicGroupId)
        .order('group_order', ascending: true);

    return response.map((json) => Topic.fromJson(json)).toList();
  }

  /// Obtiene un topic_group con sus topics incluidos (útil para mostrar la estructura completa)
  Future<Map<String, dynamic>?> fetchTopicGroupWithTopics(int groupId) async {
    // Obtener el grupo
    final group = await fetchTopicGroupById(groupId);
    if (group == null) return null;

    // Obtener los topics del grupo
    final topics = await fetchTopicsInGroup(groupId);

    return {
      'group': group,
      'topics': topics,
    };
  }

  // ============================================================================
  // USER SPECIAL TOPICS - Topics especiales completados por el usuario
  // ============================================================================

  /// Obtiene los topics especiales completados por un usuario con paginación
  ///
  /// - [userId]: ID del usuario
  /// - [limit]: Número de resultados a devolver (default: 20)
  /// - [offset]: Número de resultados a saltar para paginación (default: 0)
  ///
  /// Usa la función optimizada de base de datos `get_user_special_topics`
  /// para obtener topics especiales con estadísticas agregadas.
  ///
  /// Ideal para implementar scroll infinito en la UI.
  Future<List<UserSpecialTopic>> fetchUserSpecialTopics({
    required int userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseClient.rpc(
        'get_user_special_topics',
        params: {
          'p_user_id': userId,
          'p_limit': limit,
          'p_offset': offset,
        },
      );

      if (response == null) return [];

      final data = response as List<dynamic>;
      return data
          .map((json) => UserSpecialTopic.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.error('Error fetching user special topics: $e');
      return [];
    }
  }

  /// Obtiene los IDs de todos los topics completados por un usuario
  ///
  /// - [userId]: ID del usuario
  ///
  /// Usa la función optimizada `get_user_completed_topic_ids` que combina
  /// datos de user_tests y topic_mock_rankings para una vista completa.
  ///
  /// Útil para mostrar indicadores de progreso en la UI (ej: checkmarks).
  Future<List<UserCompletedTopic>> fetchUserCompletedTopics({
    required int userId,
  }) async {
    try {
      final response = await _supabaseClient.rpc(
        'get_user_completed_topic_ids',
        params: {
          'p_user_id': userId,
        },
      );

      if (response == null) return [];

      final data = response as List<dynamic>;
      return data
          .map((json) => UserCompletedTopic.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.error('Error fetching user completed topics: $e');
      return [];
    }
  }

  /// Verifica si un usuario ha completado un topic específico
  ///
  /// - [userId]: ID del usuario
  /// - [topicId]: ID del topic a verificar
  ///
  /// Retorna un mapa con información del topic si está completado, o null si no.
  Future<UserCompletedTopic?> hasUserCompletedTopic({
    required int userId,
    required int topicId,
  }) async {
    try {
      final completedTopics = await fetchUserCompletedTopics(userId: userId);
      return completedTopics.firstWhere(
        (topic) => topic.topicId == topicId,
        orElse: () => throw Exception('Topic not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene un set de IDs de topics completados (optimizado para verificaciones rápidas)
  ///
  /// - [userId]: ID del usuario
  ///
  /// Útil cuando necesitas verificar múltiples topics de forma eficiente.
  Future<Set<int>> fetchUserCompletedTopicIds({
    required int userId,
  }) async {
    try {
      final completedTopics = await fetchUserCompletedTopics(userId: userId);
      return completedTopics.map((topic) => topic.topicId).toSet();
    } catch (e) {
      logger.error('Error fetching user completed topic IDs: $e');
      return {};
    }
  }

  /// Obtiene la lista de topic groups completados con su ranking
  ///
  /// - [userId]: ID del usuario
  /// - [topicGroupIds]: Lista de IDs de topic groups para consultar
  ///
  /// Retorna una lista de [UserCompletedTopicGroup] con información de completado y ranking
  Future<List<UserCompletedTopicGroup>> fetchUserCompletedTopicGroups({
    required int userId,
    required List<int> topicGroupIds,
  }) async {
    if (topicGroupIds.isEmpty) return [];

    try {
      final List<UserCompletedTopicGroup> completedGroups = [];

      // Consultar cada grupo individualmente
      for (final groupId in topicGroupIds) {
        try {
          final response = await _supabaseClient.rpc(
            'get_user_topic_group_ranking_entry',
            params: {
              'p_topic_group_id': groupId,
              'p_user_id': userId,
            },
          );

          if (response != null && response is List && response.isNotEmpty) {
            try {
              final groupData = response.first as Map<String, dynamic>;
              completedGroups.add(
                UserCompletedTopicGroup.fromJson({
                  'topic_group_id': groupId,
                  ...groupData,
                }),
              );
            } catch (e) {
              logger.warning('⚠️ Error parsing group $groupId data (skipping): $e');
              // Continuar sin este grupo
              continue;
            }
          }
        } catch (e) {
          // Error común de Supabase con tipos de datos incompatibles
          if (e.toString().contains('structure of query does not match') ||
              e.toString().contains('does not match expected type')) {
            logger.warning('⚠️ Database schema issue for group $groupId (skipping): Type mismatch in get_user_topic_group_ranking_entry function');
          } else {
            logger.error('❌ Error fetching group $groupId ranking: $e');
          }
          // Continuar con el siguiente grupo sin bloquear
          continue;
        }
      }

      return completedGroups;
    } catch (e) {
      logger.error('Error fetching user completed topic groups: $e');
      return [];
    }
  }
}

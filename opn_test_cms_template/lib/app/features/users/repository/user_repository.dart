import 'package:opn_test_guardia_civil_cms/app/features/topics/model/topic_model.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/model/user.dart';
import 'package:opn_test_guardia_civil_cms/app/features/users/model/user_test.dart';
import 'package:opn_test_guardia_civil_cms/bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class UserRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  /// Obtiene usuarios con paginación
  Future<List<User>> fetchUsers({
    int? academyId,
    int? roleId,
    int? specialtyId,
    int page = 0,
    int pageSize = 20,
  }) async {
    var query = _supabaseClient.from('users').select('''
    *,
    specialties!specialty_id(*),
    user_opn_index_current!user_id(
      user_id,
      opn_index,
      quality_trend_score,
      recent_activity_score,
      competitive_score,
      momentum_score,
      global_rank,
      calculated_at
    )
  ''');

    // Filtrar por academia si se proporciona
    if (academyId != null) {
      query = query.eq('academy_id', academyId);
    }

    // Filtrar por rol si se proporciona
    if (roleId != null) {
      query = query.eq('role_id', roleId);
    }

    // Filtrar por especialidad si se proporciona
    if (specialtyId != null) {
      query = query.eq('specialty_id', specialtyId);
    }

    // Aplicar paginación
    final from = page * pageSize;
    final to = from + pageSize - 1;

    final response =
        await query.order('createdAt', ascending: false).range(from, to);

    // Mapear los datos de la tabla 'users' al modelo User
    return response.map((json) {
      final userDataWithRelations = Map<String, dynamic>.from(json);

      // Mover el objeto specialties a specialty para que coincida con el modelo
      if (json['specialties'] != null) {
        userDataWithRelations['specialty'] = json['specialties'];
      }
      userDataWithRelations.remove('specialties');

      // Mover el objeto user_opn_index_current completo a user_opn_index
      if (json['user_opn_index_current'] != null &&
          json['user_opn_index_current'].isNotEmpty) {
        final opnData = json['user_opn_index_current'][0];
        userDataWithRelations['user_opn_index'] = opnData;
      }
      userDataWithRelations.remove('user_opn_index_current');

      return User.fromJson(userDataWithRelations);
    }).toList();
  }

  /// Obtiene un usuario por ID con su índice OPN
  Future<User> fetchUserById(int id) async {
    final response = await _supabaseClient.from('users').select('''
          *,
          specialties!specialty_id(*),
          user_opn_index_current!user_id(
            user_id,
            opn_index,
            quality_trend_score,
            recent_activity_score,
            competitive_score,
            momentum_score,
            global_rank,
            calculated_at
          )
        ''').eq('id', id).single();

    final userDataWithSpecialty = Map<String, dynamic>.from(response);

    // Mover el objeto specialties a specialty para que coincida con el modelo
    if (response['specialties'] != null) {
      userDataWithSpecialty['specialty'] = response['specialties'];
    }
    userDataWithSpecialty.remove('specialties');

    // Mover el objeto user_opn_index_current completo a user_opn_index
    if (response['user_opn_index_current'] != null &&
        response['user_opn_index_current'].isNotEmpty) {
      final opnData = response['user_opn_index_current'][0];
      userDataWithSpecialty['user_opn_index'] = opnData;
    }
    userDataWithSpecialty.remove('user_opn_index_current');

    // logger.info('User OPn index ${userDataWithSpecialty}');

    return User.fromJson(userDataWithSpecialty);
  }

  /// Crea un nuevo usuario (alumno) en la tabla 'users'
  Future<User> createUser(User user) async {
    final userData = user.toJson();
    // Remover el objeto specialty del JSON, solo guardar specialty_id
    userData.remove('specialty');
    // Remover user_opn_index ya que es de solo lectura (viene de una vista)
    userData.remove('user_opn_index');

    final response = await _supabaseClient
        .from('users')
        .insert(userData)
        .select('*, specialties!specialty_id(*)');

    final json = response.first;
    final userDataWithSpecialty = Map<String, dynamic>.from(json);

    // Mover el objeto specialties a specialty para que coincida con el modelo
    if (json['specialties'] != null) {
      userDataWithSpecialty['specialty'] = json['specialties'];
    }
    userDataWithSpecialty.remove('specialties');

    return User.fromJson(userDataWithSpecialty);
  }

  /// Actualiza un usuario existente
  Future<User> updateUser(int id, User user) async {
    final userData = user.toJson();
    // Remover el objeto specialty del JSON, solo guardar specialty_id
    userData.remove('specialty');
    // Remover user_opn_index ya que es de solo lectura (viene de una vista)
    userData.remove('user_opn_index');

    final response = await _supabaseClient
        .from('users')
        .update(userData)
        .eq('id', id)
        .select('*, specialties!specialty_id(*)');

    final json = response.first;
    final userDataWithSpecialty = Map<String, dynamic>.from(json);

    // Mover el objeto specialties a specialty para que coincida con el modelo
    if (json['specialties'] != null) {
      userDataWithSpecialty['specialty'] = json['specialties'];
    }
    userDataWithSpecialty.remove('specialties');

    return User.fromJson(userDataWithSpecialty);
  }

  /// Elimina un usuario
  Future<void> deleteUser(int id) async {
    await _supabaseClient.from('users').delete().eq('id', id);
  }

  /// Busca usuarios por nombre, apellido, email o username con paginación
  Future<List<User>> searchUsers({
    required String query,
    int? academyId,
    int page = 0,
    int pageSize = 20,
  }) async {
    var supabaseQuery =
        _supabaseClient.from('users').select('*, specialties!specialty_id(*)');

    // Filtrar por academia si se proporciona
    if (academyId != null) {
      supabaseQuery = supabaseQuery.eq('academy_id', academyId);
    }

    // Búsqueda por texto (nombre, apellido, email, username o display_name)
    supabaseQuery = supabaseQuery.or(
      'first_name.ilike.%$query%,last_name.ilike.%$query%,email.ilike.%$query%,username.ilike.%$query%,display_name.ilike.%$query%',
    );

    // Aplicar paginación
    final from = page * pageSize;
    final to = from + pageSize - 1;

    final response = await supabaseQuery
        .order('createdAt', ascending: false)
        .range(from, to);

    return response.map((json) {
      final userDataWithSpecialty = Map<String, dynamic>.from(json);

      // Mover el objeto specialties a specialty para que coincida con el modelo
      if (json['specialties'] != null) {
        userDataWithSpecialty['specialty'] = json['specialties'];
      }
      userDataWithSpecialty.remove('specialties');

      return User.fromJson(userDataWithSpecialty);
    }).toList();
  }

  /// Obtiene los tests finalizados de un usuario para un topic_type específico
  Future<List<UserTest>> fetchUserTestsByTopicType({
    required int userId,
    required int topicTypeId,
  }) async {
    try {
      // Primero obtenemos los topic IDs que pertenecen a ese topic_type
      final topicsResponse = await _supabaseClient
          .from('topic')
          .select('id')
          .eq('topic_type_id', topicTypeId);

      if (topicsResponse.isEmpty) {
        logger.info(
          'No topics found for topic_type_id: $topicTypeId',
        );
        return [];
      }

      final topicIds =
          topicsResponse.map((topic) => topic['id'] as int).toList();

      logger.info(
        'Found ${topicIds.length} topics for topic_type_id: $topicTypeId',
      );

      // Usamos el operador && de PostgreSQL para verificar si hay intersección
      // entre el array topic_ids del test y el array de topicIds que buscamos
      final testsResponse = await _supabaseClient
          .from('user_tests')
          .select('*')
          .eq('user_id', userId)
          .eq('finalized', true)
          .overlaps('topic_ids', topicIds)
          .order('created_at', ascending: true);

      logger.info(
        'Found ${testsResponse.length} tests for user_id: $userId and topic_type_id: $topicTypeId',
      );

      // Convertir la respuesta a lista de UserTest
      final tests =
          testsResponse.map((json) => UserTest.fromJson(json)).toList();

      // Si no hay tests, retornar lista vacía
      if (tests.isEmpty) {
        return tests;
      }

      // Recolectar todos los topic_ids únicos de todos los tests
      final allTopicIds = <int>{};
      for (final test in tests) {
        allTopicIds.addAll(test.topicIds);
      }

      // Obtener todos los topics correspondientes a esos IDs
      final allTopicsResponse = await _supabaseClient
          .from('topic')
          .select('*')
          .inFilter('id', allTopicIds.toList());

      // Convertir la respuesta a mapa de Topic por ID para acceso rápido
      final topicsMap = <int, Map<String, dynamic>>{};
      for (final topicJson in allTopicsResponse) {
        topicsMap[topicJson['id'] as int] = topicJson;
      }

      // Crear nuevos UserTest con los topics asignados
      return tests.map((test) {
        final testTopics = test.topicIds
            .where((id) => topicsMap.containsKey(id))
            .map((id) => Topic.fromJson(topicsMap[id]!))
            .toList();

        // Crear un nuevo UserTest con los topics
        return UserTest(
          id: test.id,
          userId: test.userId,
          topicIds: test.topicIds,
          rightQuestions: test.rightQuestions,
          wrongQuestions: test.wrongQuestions,
          questionCount: test.questionCount,
          score: test.score,
          finalized: test.finalized,
          timeSpentMillis: test.timeSpentMillis,
          createdAt: test.createdAt,
          updatedAt: test.updatedAt,
          topics: testTopics,
        );
      }).toList();
    } catch (e, stackTrace) {
      logger.error(
        'Error fetching user tests by topic type',
        // error: e,
        // stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

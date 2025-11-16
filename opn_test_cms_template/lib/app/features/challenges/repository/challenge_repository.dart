import 'package:opn_test_guardia_civil_cms/app/features/users/model/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../bootstrap.dart';
import '../model/challenge_model.dart';
import '../../topics/model/topic_model.dart';
import '../../questions/model/question_model.dart';
import '../../../authentification/auth/model/user.dart';

/// Repositorio para gestionar impugnaciones (challenges) en Supabase.
///
/// Provee operaciones CRUD completas para la tabla `challenge`.
/// Las impugnaciones permiten reportar problemas en preguntas del sistema.
class ChallengeRepository {
  ChallengeRepository();

  static const String _tableName = 'challenge';
  static const String _schema = 'public';

  /// Obtiene el cliente de Supabase
  supa.SupabaseClient get _client => supa.Supabase.instance.client;

  // ============================================
  // CREATE
  // ============================================

  /// Crea una nueva impugnación.
  ///
  /// Retorna la impugnación creada con su ID asignado.
  /// Lanza excepción si:
  /// - El questionId no existe (FK constraint)
  /// - Faltan campos requeridos
  Future<Challenge> createChallenge(Challenge challenge) async {
    try {
      logger.info('Creating challenge for question: ${challenge.questionId}');

      // Validar antes de enviar
      if (!challenge.isValid) {
        throw Exception(
          'Impugnación inválida: verifica questionId y razón (mínimo 10 caracteres)',
        );
      }

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .insert(challenge.toJson())
          .select(
        '''
            *,
            questions(*),
            topic(*),
            user:users!challenge_user_id_fkey(*),
            editor:cms_users!challenge_editor_id_fkey(*)
          ''',
      ).single();

      final createdChallenge = _parseChallengeWithRelations(response);
      logger.info('Challenge created successfully: ${createdChallenge.id}');
      return createdChallenge;
    } on supa.PostgrestException catch (e) {
      logger.error('PostgreSQL error creating challenge: ${e.message}');
      if (e.code == '23503') {
        // Foreign key violation
        if (e.message.contains('question_id')) {
          throw Exception('La pregunta especificada no existe');
        }
      }
      throw Exception('Error al crear impugnación: ${e.message}');
    } catch (e, st) {
      logger.error('Unexpected error creating challenge: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error de conexión al crear impugnación');
    }
  }

  // ============================================
  // READ
  // ============================================

  /// Obtiene todas las impugnaciones con filtros opcionales y paginación.
  ///
  /// [status] - Filtra por estado (pending, approved, rejected, in_review)
  /// [academyId] - Filtra por academia
  /// [specialtyId] - Filtra por especialidad (incluye contenido compartido)
  /// [pendingOnly] - Si es true, solo retorna pendientes
  /// [orderBy] - Campo por el que ordenar (default: 'created_at')
  /// [ascending] - Orden ascendente o descendente (default: false - más recientes primero)
  /// [page] - Número de página (0-indexed)
  /// [pageSize] - Tamaño de página
  Future<List<Challenge>> getChallenges({
    ChallengeStatus? status,
    int? academyId,
    int? specialtyId,
    bool pendingOnly = false,
    String orderBy = 'created_at',
    bool ascending = false,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      logger.info(
          'Fetching challenges (status: $status, academyId: $academyId, specialtyId: $specialtyId, page: $page, pageSize: $pageSize)');

      var query = _client.schema(_schema).from(_tableName).select('''
            *,
            questions(*),
            topic(*),
            user:users!challenge_user_id_fkey(*),
            editor:cms_users!challenge_editor_id_fkey(*)
          ''');

      if (pendingOnly) {
        query = query.eq('state', ChallengeStatus.pending.value);
      } else if (status != null) {
        query = query.eq('state', status.value);
      }

      if (academyId != null) {
        query = query.eq('academy_id', academyId);
      }

      // Filtrar por specialty_id si se proporciona
      // Si specialtyId tiene valor, mostrar challenges de esa especialidad O sin especialidad (compartidos)
      if (specialtyId != null) {
        query = query.or('specialty_id.eq.$specialtyId,specialty_id.is.null');
      }

      // Aplicar paginación
      final from = page * pageSize;
      final to = from + pageSize - 1;

      final response =
          await query.order(orderBy, ascending: ascending).range(from, to);

      final challenges = (response as List)
          .map((json) => _parseChallengeWithRelations(json))
          .toList();

      logger.info('Fetched ${challenges.length} challenges for page $page');
      return challenges;
    } catch (e, st) {
      logger.error('Error fetching challenges: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener impugnaciones');
    }
  }

  /// Obtiene una impugnación por su ID.
  ///
  /// Retorna null si no existe.
  Future<Challenge?> getChallengeById(int id) async {
    try {
      logger.info('Fetching challenge by ID: $id');

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .select(
            '''
            *,
            questions(*),
            topic(*),
            user:users!challenge_user_id_fkey(*),
            editor:cms_users!challenge_editor_id_fkey(*)
          ''',
          )
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        logger.warning('Challenge not found: $id');
        return null;
      }

      final challenge = _parseChallengeWithRelations(response);
      logger.info('Challenge fetched: ${challenge.id}');
      return challenge;
    } catch (e, st) {
      logger.error('Error fetching challenge by ID: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener impugnación');
    }
  }

  /// Obtiene impugnaciones por ID de pregunta.
  Future<List<Challenge>> getChallengesByQuestionId(int questionId) async {
    try {
      logger.info('Fetching challenges for question: $questionId');

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .select('''
            *,
            questions(*),
            topic(*),
            user:users!challenge_user_id_fkey(*),
            editor:cms_users!challenge_editor_id_fkey(*)
          ''')
          .eq('question_id', questionId)
          .order('created_at', ascending: false);

      final challenges = (response as List)
          .map((json) => _parseChallengeWithRelations(json))
          .toList();

      logger.info(
          'Found ${challenges.length} challenges for question $questionId');
      return challenges;
    } catch (e, st) {
      logger.error('Error fetching challenges by question: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener impugnaciones de la pregunta');
    }
  }

  /// Obtiene solo las impugnaciones pendientes con paginación.
  Future<List<Challenge>> getPendingChallenges({
    int? academyId,
    int? specialtyId,
    int page = 0,
    int pageSize = 20,
  }) async {
    return getChallenges(
      pendingOnly: true,
      academyId: academyId,
      specialtyId: specialtyId,
      orderBy: 'created_at',
      ascending: false,
      page: page,
      pageSize: pageSize,
    );
  }

  // ============================================
  // UPDATE
  // ============================================

  /// Actualiza una impugnación existente.
  ///
  /// Solo actualiza los campos no nulos del objeto [challenge].
  /// [editorId] - ID del editor CMS que realiza la actualización (opcional)
  /// Retorna la impugnación actualizada.
  Future<Challenge> updateChallenge(Challenge challenge,
      {int? editorId}) async {
    try {
      if (challenge.id == null) {
        throw Exception('No se puede actualizar una impugnación sin ID');
      }

      logger.info('Updating challenge: ${challenge.id}');

      // Preparar datos para actualizar
      final updateData = challenge.toJson();
      updateData.remove('id');
      updateData.remove('created_at');
      updateData.remove('updated_at');
      updateData.remove('reviewed_at');

      // Establecer el editor si se proporciona
      if (editorId != null) {
        updateData['editor_id'] = editorId;
      }

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .update(updateData)
          .eq('id', challenge.id!)
          .select(
        '''
            *,
            questions(*),
            topic(*),
            user:users!challenge_user_id_fkey(*),
            editor:cms_users!challenge_editor_id_fkey(*)
          ''',
      ).single();

      final updatedChallenge = _parseChallengeWithRelations(response);
      logger.info('Challenge updated successfully: ${updatedChallenge.id}');
      return updatedChallenge;
    } catch (e, st) {
      logger.error('Unexpected error updating challenge: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al actualizar impugnación');
    }
  }

  /// Cambia el estado de una impugnación.
  ///
  /// [id] - ID de la impugnación
  /// [status] - Nuevo estado
  /// [reviewedBy] - UUID del revisor (opcional)
  /// [editorId] - ID del editor CMS que realiza el cambio (opcional)
  /// [reviewComments] - Comentarios de revisión (opcional)
  Future<Challenge> updateChallengeStatus({
    required int id,
    required ChallengeStatus status,
    String? reviewedBy,
    int? editorId,
    String? reviewComments,
  }) async {
    try {
      logger.info('Updating challenge status: $id to ${status.value}');

      final updateData = <String, dynamic>{
        'state': status.value,
      };

      logger.info('esq  ure :$updateData');

      // Si se está aprobando o rechazando, marcar fecha de revisión
      if (status.isApproved || status.isRejected) {
        updateData['updated_at'] = DateTime.now().toIso8601String();
      }

      if (reviewedBy != null) {
        updateData['tutor_uuid'] = reviewedBy;
      }

      if (editorId != null) {
        updateData['editor_id'] = editorId;
      }

      if (reviewComments != null) {
        updateData['reply'] = reviewComments;
      }

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select('''
            *,
            questions(*),
            topic(*),
            user:users!challenge_user_id_fkey(*),
            editor:cms_users!challenge_editor_id_fkey(*)
          ''').single();

      final updatedChallenge = _parseChallengeWithRelations(response);
      logger.info('Challenge status updated: ${updatedChallenge.id}');
      return updatedChallenge;
    } catch (e, st) {
      logger.error('Error updating challenge status: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al cambiar estado de impugnación');
    }
  }

  // ============================================
  // DELETE
  // ============================================

  /// Elimina una impugnación.
  ///
  /// [id] - ID de la impugnación a eliminar
  Future<void> deleteChallenge(int id) async {
    try {
      logger.info('Deleting challenge: $id');

      await _client.schema(_schema).from(_tableName).delete().eq('id', id);

      logger.info('Challenge deleted successfully: $id');
    } catch (e, st) {
      logger.error('Unexpected error deleting challenge: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al eliminar impugnación');
    }
  }

  // ============================================
  // STATISTICS
  // ============================================

  /// Obtiene el conteo de impugnaciones por estado.
  Future<Map<String, int>> getChallengeStatsByStatus(
      {int? academyId, int? specialtyId}) async {
    try {
      logger.info('Fetching challenge stats by status');

      var query = _client.schema(_schema).from(_tableName).select('state');

      if (academyId != null) {
        query = query.eq('academy_id', academyId);
      }

      // Filtrar por specialty_id si se proporciona
      if (specialtyId != null) {
        query = query.eq('specialty_id', specialtyId);
      }

      final response = await query;
      final challenges = response as List;

      final stats = <String, int>{
        'pendiente': 0,
        'resuelta': 0,
        'rechazada': 0,
        'total': challenges.length,
      };

      for (final challenge in challenges) {
        final status = challenge['state'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      logger.info('Challenge stats: $stats');
      return stats;
    } catch (e, st) {
      logger.error('Error fetching challenge stats: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener estadísticas de impugnaciones');
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Parsea un JSON con relaciones anidadas a un objeto Challenge.
  Challenge _parseChallengeWithRelations(Map<String, dynamic> json) {
    // Extraer datos de relaciones
    String? questionText;
    int? topicId;
    String? topicName;
    String? createdByName;
    String? createdByEmail;
    String? reviewedByName;
    String? academyName;
    Question? questionObj;
    Topic? topicObj;
    Topic? questionTopicObj;
    User? userObj;
    CmsUser? editorObj;

    // Pregunta (questions)
    if (json['questions'] != null && json['questions'] is Map) {
      final questionData = json['questions'] as Map<String, dynamic>;
      // logger.info('question', questionData);
      questionText = questionData['question'] as String?;

      // Parsear objeto Question completo
      try {
        questionObj = Question.fromJson(questionData);
      } catch (e) {
        logger.warning('Error parsing Question object: $e');
      }

      // Topic dentro de question - puede ser un int (ID) o un Map (objeto completo)
      if (questionData['topic'] != null) {
        if (questionData['topic'] is Map) {
          // Caso retrocompatible: topic como objeto completo
          final topicData = questionData['topic'] as Map<String, dynamic>;
          topicId = topicData['id'] as int?;
          topicName = topicData['topic_name'] as String?;

          // Parsear objeto Topic completo desde question
          try {
            questionTopicObj = Topic.fromJson(topicData);
          } catch (e) {
            logger.warning('Error parsing Topic object from question: $e');
          }
        } else if (questionData['topic'] is int) {
          // Caso normal: topic como ID numérico
          topicId = questionData['topic'] as int?;
        }
      }
    }

    // Topic directo (desde challenge.topic_id)
    if (json['topic'] != null && json['topic'] is Map) {
      final topicData = json['topic'] as Map<String, dynamic>;

      // Parsear objeto Topic completo
      try {
        topicObj = Topic.fromJson(topicData);
        // Si no tenemos topicId/topicName de question.topic, usar estos
        if (topicId == null) {
          topicId = topicData['id'] as int?;
          topicName = topicData['topic_name'] as String?;
        }
      } catch (e) {
        logger.warning('Error parsing Topic object: $e');
      }
    }

    // Usuario creador (user)
    if (json['user'] != null && json['user'] is Map) {
      final userData = json['user'] as Map<String, dynamic>;
      try {
        userObj = User.fromJson(userData);
        createdByName = userObj.fullName;
        createdByEmail = userObj.email;
      } catch (e) {
        logger.warning('Error parsing User object: $e');
        // Fallback a campos individuales si falla el parseo
        createdByName = userData['name'] as String?;
        createdByEmail = userData['email'] as String?;
      }
    }

    // Editor (editor)
    if (json['editor'] != null && json['editor'] is Map) {
      final editorData = json['editor'] as Map<String, dynamic>;
      try {
        editorObj = CmsUser.fromJson(editorData);
        reviewedByName = editorObj.fullName;
      } catch (e) {
        logger.warning('Error parsing Editor object: $e');
        // Fallback a campos individuales si falla el parseo
        reviewedByName = editorData['name'] as String?;
      }
    }

    // Retrocompatibilidad: Usuario creador (created_by_user - antiguo)
    if (json['created_by_user'] != null && json['created_by_user'] is Map) {
      final user = json['created_by_user'] as Map<String, dynamic>;
      createdByName = user['name'] as String?;
      createdByEmail = user['email'] as String?;
    }

    // Retrocompatibilidad: Usuario revisor (reviewed_by_user - antiguo)
    if (json['reviewed_by_user'] != null && json['reviewed_by_user'] is Map) {
      final user = json['reviewed_by_user'] as Map<String, dynamic>;
      reviewedByName = user['name'] as String?;
    }

    // Academia
    if (json['academy'] != null && json['academy'] is Map) {
      final academy = json['academy'] as Map<String, dynamic>;
      academyName = academy['name'] as String?;
    }

    // Crear copia del JSON limpia
    final cleanJson = Map<String, dynamic>.from(json);
    cleanJson.remove('questions');
    cleanJson.remove('topic');
    cleanJson.remove('user');
    cleanJson.remove('editor');
    cleanJson.remove('created_by_user');
    cleanJson.remove('reviewed_by_user');
    cleanJson.remove('academy');

    // Agregar campos denormalizados
    cleanJson['question_text'] = questionText;
    cleanJson['topic_id'] = topicId;
    cleanJson['topic_name'] = topicName;
    cleanJson['user_name'] = createdByName;
    cleanJson['user_email'] = createdByEmail;
    cleanJson['editor_name'] = reviewedByName;
    cleanJson['academy_name'] = academyName;

    // Crear el Challenge con fromJson
    final challenge = Challenge.fromJson(cleanJson);

    // Añadir objetos completos usando copyWith
    // Priorizar topicObj directo, pero si no existe, usar questionTopicObj
    return challenge.copyWith(
      question: questionObj,
      topic: topicObj ?? questionTopicObj,
      user: userObj,
      editor: editorObj,
    );
  }
}

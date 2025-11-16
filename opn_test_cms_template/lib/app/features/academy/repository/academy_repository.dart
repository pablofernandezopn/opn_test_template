import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../bootstrap.dart';
import '../model/academy_model.dart';
import '../model/academy_kpis_model.dart';
import '../../../authentification/auth/model/user.dart';
import '../../specialties/model/specialty.dart';

/// Repositorio para gestionar academias y tutores en Supabase.
///
/// Provee operaciones CRUD completas para las tablas `academies` y `cms_users`.
/// Solo usuarios con rol SuperAdmin pueden crear, editar o eliminar academias.
class AcademyRepository {
  AcademyRepository();

  static const String _tableName = 'academies';
  static const String _cmsUsersTable = 'cms_users';
  static const String _schema = 'public';

  /// Obtiene el cliente de Supabase
  supa.SupabaseClient get _client => supa.Supabase.instance.client;

  // ============================================
  // CREATE
  // ============================================

  /// Crea una nueva academia.
  ///
  /// Retorna la academia creada con su ID asignado.
  /// Lanza excepción si:
  /// - El nombre ya existe (UNIQUE constraint)
  /// - El slug ya existe (UNIQUE constraint)
  /// - Faltan campos requeridos
  Future<Academy> createAcademy(Academy academy) async {
    try {
      logger.info('Creating academy: ${academy.name}');

      // Validar antes de enviar
      if (!academy.isValid) {
        throw Exception('Academia inválida: verifica nombre, slug y email');
      }

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .insert(academy.toJson())
          .select()
          .single();

      final createdAcademy = Academy.fromJson(response);
      logger.info('Academy created successfully: ${createdAcademy.id}');
      return createdAcademy;
    } on supa.PostgrestException catch (e) {
      logger.error('PostgreSQL error creating academy: ${e.message}');
      if (e.code == '23505') {
        // Unique violation
        if (e.message.contains('academies_name_key')) {
          throw Exception('Ya existe una academia con ese nombre');
        } else if (e.message.contains('academies_slug_key')) {
          throw Exception('Ya existe una academia con ese slug');
        }
      }
      throw Exception('Error al crear academia: ${e.message}');
    } catch (e, st) {
      logger.error('Unexpected error creating academy: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error de conexión al crear academia');
    }
  }

  // ============================================
  // READ
  // ============================================

  /// Obtiene todas las academias.
  ///
  /// [activeOnly] - Si es true, solo retorna academias activas (is_active = true)
  /// [orderBy] - Campo por el que ordenar (default: 'name')
  /// [ascending] - Orden ascendente o descendente (default: true)
  Future<List<Academy>> getAcademies({
    bool activeOnly = false,
    String orderBy = 'name',
    bool ascending = true,
  }) async {
    try {
      logger.info('Fetching academies (activeOnly: $activeOnly)');

      var query = _client.schema(_schema).from(_tableName).select();

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final response = await query.order(orderBy, ascending: ascending);

      final academies =
          (response as List).map((json) => Academy.fromJson(json)).toList();

      logger.info('Fetched ${academies.length} academies');
      return academies;
    } catch (e, st) {
      logger.error('Error fetching academies: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener academias');
    }
  }

  /// Obtiene una academia por su ID.
  ///
  /// Retorna null si no existe.
  Future<Academy?> getAcademyById(int id) async {
    try {
      logger.info('Fetching academy by ID: $id');

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        logger.warning('Academy not found: $id');
        return null;
      }

      final academy = Academy.fromJson(response);
      logger.info('Academy fetched: ${academy.name}');
      return academy;
    } catch (e, st) {
      logger.error('Error fetching academy by ID: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener academia');
    }
  }

  /// Obtiene una academia por su slug.
  ///
  /// Retorna null si no existe.
  Future<Academy?> getAcademyBySlug(String slug) async {
    try {
      logger.info('Fetching academy by slug: $slug');

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .select()
          .eq('slug', slug)
          .maybeSingle();

      if (response == null) {
        logger.warning('Academy not found: $slug');
        return null;
      }

      final academy = Academy.fromJson(response);
      logger.info('Academy fetched: ${academy.name}');
      return academy;
    } catch (e, st) {
      logger.error('Error fetching academy by slug: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener academia');
    }
  }

  /// Busca academias por nombre (búsqueda parcial, case-insensitive).
  Future<List<Academy>> searchAcademiesByName(String searchTerm) async {
    try {
      logger.info('Searching academies by name: $searchTerm');

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .select()
          .ilike('name', '%$searchTerm%')
          .order('name', ascending: true);

      final academies =
          (response as List).map((json) => Academy.fromJson(json)).toList();

      logger.info('Found ${academies.length} academies matching "$searchTerm"');
      return academies;
    } catch (e, st) {
      logger.error('Error searching academies: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al buscar academias');
    }
  }

  // ============================================
  // UPDATE
  // ============================================

  /// Actualiza una academia existente.
  ///
  /// Solo actualiza los campos no nulos del objeto [academy].
  /// Retorna la academia actualizada.
  /// Lanza excepción si:
  /// - La academia no existe
  /// - El nuevo nombre/slug ya existe (UNIQUE constraint)
  Future<Academy> updateAcademy(Academy academy) async {
    try {
      if (academy.id == null) {
        throw Exception('No se puede actualizar una academia sin ID');
      }

      logger.info('Updating academy: ${academy.id}');

      // Validar antes de enviar
      if (!academy.isValid) {
        throw Exception('Academia inválida: verifica nombre, slug y email');
      }

      // Preparar datos para actualizar (excluir ID, created_at, updated_at)
      final updateData = academy.toJson();
      updateData.remove('id');
      updateData.remove('created_at');
      updateData.remove('updated_at');

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .update(updateData)
          .eq('id', academy.id!)
          .select()
          .single();

      final updatedAcademy = Academy.fromJson(response);
      logger.info('Academy updated successfully: ${updatedAcademy.id}');
      return updatedAcademy;
    } on supa.PostgrestException catch (e) {
      logger.error('PostgreSQL error updating academy: ${e.message}');
      if (e.code == '23505') {
        // Unique violation
        if (e.message.contains('academies_name_key')) {
          throw Exception('Ya existe una academia con ese nombre');
        } else if (e.message.contains('academies_slug_key')) {
          throw Exception('Ya existe una academia con ese slug');
        }
      }
      throw Exception('Error al actualizar academia: ${e.message}');
    } catch (e, st) {
      logger.error('Unexpected error updating academy: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error de conexión al actualizar academia');
    }
  }

  /// Activa o desactiva una academia.
  ///
  /// [id] - ID de la academia
  /// [isActive] - true para activar, false para desactivar
  Future<Academy> toggleAcademyStatus(int id, bool isActive) async {
    try {
      logger.info('Toggling academy status: $id to $isActive');

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .update({'is_active': isActive})
          .eq('id', id)
          .select()
          .single();

      final updatedAcademy = Academy.fromJson(response);
      logger.info('Academy status updated: ${updatedAcademy.id}');
      return updatedAcademy;
    } catch (e, st) {
      logger.error('Error toggling academy status: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al cambiar estado de academia');
    }
  }

  // ============================================
  // DELETE
  // ============================================

  /// Elimina una academia.
  ///
  /// IMPORTANTE: Esto fallará si existen registros asociados debido a
  /// la política RESTRICT en las foreign keys (users, topics, questions, etc).
  ///
  /// Para eliminar una academia, primero debes:
  /// 1. Mover o eliminar todos los usuarios (cms_users, users)
  /// 2. Mover o eliminar todos los topics
  /// 3. Mover o eliminar todas las questions
  /// 4. Mover o eliminar todos los challenges
  ///
  /// [id] - ID de la academia a eliminar
  /// [force] - Si es true, intenta eliminar en cascada (NO IMPLEMENTADO aún)
  Future<void> deleteAcademy(int id, {bool force = false}) async {
    try {
      logger.info('Deleting academy: $id (force: $force)');

      // Academia OPN (ID: 1) no se puede eliminar
      if (id == 1) {
        throw Exception(
            'No se puede eliminar la academia OPN (predeterminada)');
      }

      await _client.schema(_schema).from(_tableName).delete().eq('id', id);

      logger.info('Academy deleted successfully: $id');
    } on supa.PostgrestException catch (e) {
      logger.error('PostgreSQL error deleting academy: ${e.message}');

      // Foreign key constraint violation
      if (e.code == '23503') {
        throw Exception(
          'No se puede eliminar la academia porque tiene datos asociados '
          '(usuarios, topics, preguntas, etc). '
          'Primero migra o elimina esos datos.',
        );
      }

      throw Exception('Error al eliminar academia: ${e.message}');
    } catch (e, st) {
      logger.error('Unexpected error deleting academy: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error de conexión al eliminar academia');
    }
  }

  // ============================================
  // STATISTICS
  // ============================================

  /// Obtiene estadísticas de una academia desde la tabla academy_kpis.
  ///
  /// Esta tabla contiene KPIs precalculados para evitar consultas pesadas.
  /// Una sola consulta a la tabla academy_kpis.
  ///
  /// Retorna un mapa con:
  /// - total_users: Número de usuarios finales
  /// - total_questions: Número de preguntas
  /// - total_tests: Número de tests/challenges
  /// - total_premium_users: Número de usuarios premium
  /// - premium_plus_users: Número de usuarios premium plus
  /// - total_users_today: Usuarios activos hoy
  /// - new_users_today: Nuevos usuarios hoy
  /// - total_answers_today: Respuestas totales hoy
  /// - total_flashcard_answers_today: Respuestas de flashcards hoy
  Future<Map<String, int>> getAcademyStats(int academyId) async {
    try {
      logger.info('Fetching stats for academy: $academyId from academy_kpis');

      // Obtener KPIs precalculados de la tabla academy_kpis
      final kpisResponse = await _client
          .schema(_schema)
          .from('academy_kpis')
          .select()
          .eq('academy_id', academyId)
          .maybeSingle();

      AcademyKpis kpis;
      if (kpisResponse != null) {
        kpis = AcademyKpis.fromJson(kpisResponse);
      } else {
        logger.warning(
            'No KPIs found for academy $academyId, using empty values');
        kpis = AcademyKpis.empty.copyWith(academyId: academyId);
      }

      final stats = {
        'total_users': kpis.totalUsers,
        'total_questions': kpis.totalQuestions,
        'total_tests': kpis.totalTests,
        'total_premium_users': kpis.totalPremiumUsers,
        'premium_plus_users': kpis.premiumPlusUsers,
        'total_users_today': kpis.totalUsersToday,
        'new_users_today': kpis.newUsersToday,
        'total_answers_today': kpis.totalAnswersToday,
        'total_flashcard_answers_today': kpis.totalFlashcardAnswersToday,
      };

      // logger.info('Stats fetched for academy $academyId: $stats');
      return stats;
    } catch (e, st) {
      logger.error('Error fetching academy stats: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener estadísticas de academia');
    }
  }

  // ============================================
  // TUTORS - READ
  // ============================================

  /// Obtiene todos los tutores (usuarios CMS) de una academia específica.
  ///
  /// [academyId] - ID de la academia
  /// [orderBy] - Campo por el que ordenar (default: 'nombre')
  /// [ascending] - Orden ascendente o descendente (default: true)
  Future<List<CmsUser>> fetchTutorsByAcademy(
    int academyId, {
    String orderBy = 'nombre',
    bool ascending = true,
  }) async {
    try {
      logger.debug('Fetching tutors for academy $academyId...');

      final response = await _client
          .schema(_schema)
          .from(_cmsUsersTable)
          .select('*, specialties!specialty_id(*)')
          .eq('academy_id', academyId)
          .order(orderBy, ascending: ascending);

      final tutors = (response as List).map((json) {
        final data = Map<String, dynamic>.from(json as Map<String, dynamic>);

        // Mover el objeto specialties a specialty
        if (data['specialties'] != null) {
          data['specialty'] = data['specialties'];
        }
        data.remove('specialties');

        return CmsUser.fromJson(data);
      }).toList();

      logger.debug('Fetched ${tutors.length} tutors for academy $academyId');
      return tutors;
    } catch (e, stackTrace) {
      logger.error('Error fetching tutors for academy $academyId: $e');
      logger.error('Stack trace: $stackTrace');
      throw Exception('Error al obtener tutores de la academia');
    }
  }

  /// Obtiene todos los tutores de todas las academias (solo para Admin).
  ///
  /// [orderBy] - Campo por el que ordenar (default: 'nombre')
  /// [ascending] - Orden ascendente o descendente (default: true)
  Future<List<CmsUser>> fetchAllTutors({
    String orderBy = 'nombre',
    bool ascending = true,
  }) async {
    try {
      logger.debug('Fetching all tutors...');

      final response = await _client
          .schema(_schema)
          .from(_cmsUsersTable)
          .select('*, specialties!specialty_id(*)')
          .order(orderBy, ascending: ascending);

      final tutors = (response as List).map((json) {
        final data = Map<String, dynamic>.from(json as Map<String, dynamic>);

        // Mover el objeto specialties a specialty
        if (data['specialties'] != null) {
          data['specialty'] = data['specialties'];
        }
        data.remove('specialties');

        return CmsUser.fromJson(data);
      }).toList();

      logger.debug('Fetched ${tutors.length} total tutors');
      return tutors;
    } catch (e, stackTrace) {
      logger.error('Error fetching all tutors: $e');
      logger.error('Stack trace: $stackTrace');
      throw Exception('Error al obtener todos los tutores');
    }
  }

  // ============================================
  // TUTORS - SEARCH
  // ============================================

  /// Busca tutores por nombre, apellido, email o username en una academia específica.
  ///
  /// [academyId] - ID de la academia
  /// [query] - Término de búsqueda (busca en nombre, apellido, email y username)
  /// [orderBy] - Campo por el que ordenar (default: 'nombre')
  /// [ascending] - Orden ascendente o descendente (default: true)
  Future<List<CmsUser>> searchTutorsByAcademy({
    required int academyId,
    required String query,
    String orderBy = 'nombre',
    bool ascending = true,
  }) async {
    try {
      logger.debug('Searching tutors in academy $academyId with query: $query');

      final searchTerm = '%$query%';

      final response = await _client
          .schema(_schema)
          .from(_cmsUsersTable)
          .select('*, specialties!specialty_id(*)')
          .eq('academy_id', academyId)
          .or('nombre.ilike.$searchTerm,apellido.ilike.$searchTerm,email.ilike.$searchTerm,username.ilike.$searchTerm')
          .order(orderBy, ascending: ascending);

      final tutors = (response as List).map((json) {
        final data = Map<String, dynamic>.from(json as Map<String, dynamic>);

        // Mover el objeto specialties a specialty
        if (data['specialties'] != null) {
          data['specialty'] = data['specialties'];
        }
        data.remove('specialties');

        return CmsUser.fromJson(data);
      }).toList();

      logger.debug(
          'Found ${tutors.length} tutors matching query in academy $academyId');
      return tutors;
    } catch (e, stackTrace) {
      logger.error('Error searching tutors in academy $academyId: $e');
      logger.error('Stack trace: $stackTrace');
      throw Exception('Error al buscar tutores en la academia');
    }
  }

  /// Busca tutores por nombre, apellido, email o username en todas las academias (solo para Admin).
  ///
  /// [query] - Término de búsqueda (busca en nombre, apellido, email y username)
  /// [orderBy] - Campo por el que ordenar (default: 'nombre')
  /// [ascending] - Orden ascendente o descendente (default: true)
  Future<List<CmsUser>> searchAllTutors({
    required String query,
    String orderBy = 'nombre',
    bool ascending = true,
  }) async {
    try {
      logger.debug('Searching all tutors with query: $query');

      final searchTerm = '%$query%';

      final response = await _client
          .schema(_schema)
          .from(_cmsUsersTable)
          .select('*, specialties!specialty_id(*)')
          .or('nombre.ilike.$searchTerm,apellido.ilike.$searchTerm,email.ilike.$searchTerm,username.ilike.$searchTerm')
          .order(orderBy, ascending: ascending);

      final tutors = (response as List).map((json) {
        final data = Map<String, dynamic>.from(json as Map<String, dynamic>);

        // Mover el objeto specialties a specialty
        if (data['specialties'] != null) {
          data['specialty'] = data['specialties'];
        }
        data.remove('specialties');

        return CmsUser.fromJson(data);
      }).toList();

      logger.debug('Found ${tutors.length} tutors matching query');
      return tutors;
    } catch (e, stackTrace) {
      logger.error('Error searching all tutors: $e');
      logger.error('Stack trace: $stackTrace');
      throw Exception('Error al buscar tutores');
    }
  }

  // ============================================
  // TUTORS - CREATE
  // ============================================

  /// Crea un nuevo tutor (usuario CMS).
  ///
  /// [username] - Nombre de usuario único
  /// [name] - Nombre del tutor
  /// [lastName] - Apellido del tutor
  /// [email] - Email del tutor
  /// [password] - Contraseña para el usuario
  /// [academyId] - ID de la academia a la que pertenece
  /// [roleId] - ID del rol (default: 4 = User)
  /// [phone] - Teléfono opcional
  /// [address] - Dirección opcional
  /// [specialtyId] - ID de la especialidad opcional
  /// [avatarUrl] - URL del avatar opcional
  Future<CmsUser> createTutor({
    required String username,
    required String name,
    required String lastName,
    required String email,
    required String password,
    required int academyId,
    int roleId = 4,
    String? phone,
    String? address,
    int? specialtyId,
    String? avatarUrl,
  }) async {
    try {
      logger.debug('Creating new tutor: $username');

      // 1. Crear usuario en Supabase Auth
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Error al crear usuario en Auth');
      }

      final userUuid = authResponse.user!.id;

      // 2. Crear registro en cms_users
      final userData = {
        'user_uuid': userUuid,
        'username': username,
        'nombre': name,
        'apellido': lastName,
        'email': email,
        'academy_id': academyId,
        'role_id': 3,
        'phone': phone,
        'address': address,
        'specialty_id': specialtyId,
        'avatar_url': avatarUrl,
      };

      final response = await _client
          .schema(_schema)
          .from(_cmsUsersTable)
          .update(userData)
          .eq('user_uuid', userUuid)
          .select('*, specialties!specialty_id(*)')
          .single();

      final data = Map<String, dynamic>.from(response as Map<String, dynamic>);

      // Mover el objeto specialties a specialty
      if (data['specialties'] != null) {
        data['specialty'] = data['specialties'];
      }
      data.remove('specialties');

      final newTutor = CmsUser.fromJson(data);
      logger.debug('Tutor created successfully: ${newTutor.id}');
      return newTutor;
    } catch (e, stackTrace) {
      logger.error('Error creating tutor: $e');
      logger.error('Stack trace: $stackTrace');
      throw Exception('Error al crear tutor: ${e.toString()}');
    }
  }

  // ============================================
  // TUTORS - UPDATE
  // ============================================

  /// Actualiza un tutor existente.
  ///
  /// [tutorId] - ID del tutor a actualizar
  /// [username] - Nuevo nombre de usuario (opcional)
  /// [name] - Nuevo nombre (opcional)
  /// [lastName] - Nuevo apellido (opcional)
  /// [email] - Nuevo email (opcional)
  /// [phone] - Nuevo teléfono (opcional)
  /// [address] - Nueva dirección (opcional)
  /// [roleId] - Nuevo rol (opcional)
  /// [specialtyId] - Nueva especialidad (opcional)
  /// [avatarUrl] - Nueva URL de avatar (opcional)
  /// [academyId] - Nueva academia (opcional, solo para Admin)
  Future<CmsUser> updateTutor({
    required int tutorId,
    String? username,
    String? name,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    int? roleId,
    int? specialtyId,
    String? avatarUrl,
    int? academyId,
  }) async {
    try {
      logger.debug('Updating tutor: $tutorId');

      // Construir el mapa de actualización solo con campos no nulos
      final updateData = <String, dynamic>{};

      if (username != null) updateData['username'] = username;
      if (name != null) updateData['nombre'] = name;
      if (lastName != null) updateData['apellido'] = lastName;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (roleId != null) updateData['role_id'] = roleId;
      if (specialtyId != null) updateData['specialty_id'] = specialtyId;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (academyId != null) updateData['academy_id'] = academyId;

      if (updateData.isEmpty) {
        throw Exception('No hay datos para actualizar');
      }

      // Actualizar updated_at automáticamente
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .schema(_schema)
          .from(_cmsUsersTable)
          .update(updateData)
          .eq('id', tutorId)
          .select('*, specialties!specialty_id(*)')
          .single();

      final data = Map<String, dynamic>.from(response as Map<String, dynamic>);

      // Mover el objeto specialties a specialty
      if (data['specialties'] != null) {
        data['specialty'] = data['specialties'];
      }
      data.remove('specialties');

      final updatedTutor = CmsUser.fromJson(data);
      logger.debug('Tutor updated successfully: ${updatedTutor.id}');
      return updatedTutor;
    } catch (e, stackTrace) {
      logger.error('Error updating tutor $tutorId: $e');
      logger.error('Stack trace: $stackTrace');
      throw Exception('Error al actualizar tutor: ${e.toString()}');
    }
  }

  // ============================================
  // TUTORS - DELETE
  // ============================================

  /// Elimina un tutor (soft delete).
  ///
  /// En lugar de eliminar físicamente el registro, se puede marcar como inactivo
  /// o se puede eliminar completamente según la lógica de negocio.
  ///
  /// [tutorId] - ID del tutor a eliminar
  /// [hardDelete] - Si es true, elimina permanentemente. Si es false, marca como inactivo
  Future<void> deleteTutor({
    required int tutorId,
    bool hardDelete = false,
  }) async {
    try {
      logger.debug('Deleting tutor: $tutorId (hard: $hardDelete)');

      if (hardDelete) {
        // Eliminar permanentemente
        await _client
            .schema(_schema)
            .from(_cmsUsersTable)
            .delete()
            .eq('id', tutorId);

        logger.debug('Tutor deleted permanently: $tutorId');
      } else {
        // Soft delete - marcar como inactivo o agregar deleted_at
        final updateData = {
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _client
            .schema(_schema)
            .from(_cmsUsersTable)
            .update(updateData)
            .eq('id', tutorId);

        logger.debug('Tutor marked as deleted: $tutorId');
      }
    } catch (e, stackTrace) {
      logger.error('Error deleting tutor $tutorId: $e');
      logger.error('Stack trace: $stackTrace');
      throw Exception('Error al eliminar tutor: ${e.toString()}');
    }
  }

  /// Elimina múltiples tutores.
  ///
  /// [tutorIds] - Lista de IDs de tutores a eliminar
  /// [hardDelete] - Si es true, elimina permanentemente
  Future<void> deleteTutors({
    required List<int> tutorIds,
    bool hardDelete = false,
  }) async {
    try {
      logger.debug('Deleting multiple tutors: ${tutorIds.length}');

      if (hardDelete) {
        await _client
            .schema(_schema)
            .from(_cmsUsersTable)
            .delete()
            .eq('id', tutorIds);

        logger.debug('Tutors deleted permanently: ${tutorIds.length}');
      } else {
        final updateData = {
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _client
            .schema(_schema)
            .from(_cmsUsersTable)
            .update(updateData)
            .eq('id', tutorIds);

        logger.debug('Tutors marked as deleted: ${tutorIds.length}');
      }
    } catch (e, stackTrace) {
      logger.error('Error deleting multiple tutors: $e');
      logger.error('Stack trace: $stackTrace');
      throw Exception('Error al eliminar tutores: ${e.toString()}');
    }
  }

  /// Reactiva un tutor (si se usó soft delete).
  ///
  /// [tutorId] - ID del tutor a reactivar
  Future<CmsUser> reactivateTutor(int tutorId) async {
    try {
      logger.debug('Reactivating tutor: $tutorId');

      final updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .schema(_schema)
          .from(_cmsUsersTable)
          .update(updateData)
          .eq('id', tutorId)
          .select('*, specialties!specialty_id(*)')
          .single();

      final data = Map<String, dynamic>.from(response as Map<String, dynamic>);

      // Mover el objeto specialties a specialty
      if (data['specialties'] != null) {
        data['specialty'] = data['specialties'];
      }
      data.remove('specialties');

      final tutor = CmsUser.fromJson(data);
      logger.debug('Tutor reactivated successfully: $tutorId');
      return tutor;
    } catch (e, stackTrace) {
      logger.error('Error reactivating tutor $tutorId: $e');
      logger.error('Stack trace: $stackTrace');
      throw Exception('Error al reactivar tutor: ${e.toString()}');
    }
  }
}

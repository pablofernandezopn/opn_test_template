import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../bootstrap.dart';
import '../model/membership_level_model.dart';

/// Repositorio para gestionar niveles de membresía en Supabase.
///
/// Provee operaciones CRUD completas para la tabla `membership_levels`.
/// Los niveles de membresía definen los diferentes planes disponibles en la academia.
class MembershipRepository {
  MembershipRepository();

  static const String _tableName = 'membership_levels';
  static const String _schema = 'public';

  /// Obtiene el cliente de Supabase
  supa.SupabaseClient get _client => supa.Supabase.instance.client;

  // ============================================
  // CREATE
  // ============================================

  /// Crea un nuevo nivel de membresía.
  ///
  /// Retorna el nivel de membresía creado con su ID asignado.
  /// Lanza excepción si:
  /// - El nombre ya existe en la academia (UNIQUE constraint)
  /// - El wordpress_rcp_id ya existe (UNIQUE constraint)
  /// - Faltan campos requeridos
  Future<MembershipLevel> createMembershipLevel(
      MembershipLevel membershipLevel) async {
    try {
      logger.info('Creating membership level: ${membershipLevel.name}');

      // Validar antes de enviar
      if (!membershipLevel.isValid) {
        throw Exception(
            'Nivel de membresía inválido: verifica nombre, nivel de acceso y precios');
      }

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .insert(membershipLevel.toJson())
          .select()
          .single();

      final createdLevel = MembershipLevel.fromJson(response);
      logger.info('Membership level created successfully: ${createdLevel.id}');
      return createdLevel;
    } on supa.PostgrestException catch (e) {
      logger.error('PostgreSQL error creating membership level: ${e.message}');
      if (e.code == '23505') {
        // Unique violation
        if (e.message.contains('membership_levels_wordpress_rcp_id_key')) {
          throw Exception(
              'Ya existe un nivel de membresía con ese WordPress RCP ID');
        }
        throw Exception('Ya existe un nivel de membresía con esos datos');
      }
      throw Exception('Error al crear nivel de membresía: ${e.message}');
    } catch (e, st) {
      logger.error('Unexpected error creating membership level: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error de conexión al crear nivel de membresía');
    }
  }

  // ============================================
  // READ
  // ============================================

  /// Obtiene todos los niveles de membresía de una especialidad.
  ///
  /// [specialtyId] - ID de la especialidad
  /// [activeOnly] - Si es true, solo retorna niveles activos
  /// [orderBy] - Campo por el que ordenar (default: 'display_order')
  /// [ascending] - Orden ascendente o descendente (default: true)
  Future<List<MembershipLevel>> getMembershipLevels({
    required int specialtyId,
    bool activeOnly = false,
    String orderBy = 'display_order',
    bool ascending = true,
  }) async {
    try {
      logger.info(
          'Fetching membership levels for specialty $specialtyId (activeOnly: $activeOnly)');

      var query = _client
          .schema(_schema)
          .from(_tableName)
          .select()
          .eq('specialty_id', specialtyId);

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final response = await query.order(orderBy, ascending: ascending);

      final levels = (response as List)
          .map((json) => MembershipLevel.fromJson(json))
          .toList();

      logger.info('Fetched ${levels.length} membership levels');
      return levels;
    } catch (e, st) {
      logger.error('Error fetching membership levels: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener niveles de membresía');
    }
  }

  /// Obtiene todos los niveles de membresía (todas las especialidades).
  ///
  /// Solo para administradores.
  /// [activeOnly] - Si es true, solo retorna niveles activos
  /// [orderBy] - Campo por el que ordenar (default: 'specialty_id, display_order')
  Future<List<MembershipLevel>> getAllMembershipLevels({
    bool activeOnly = false,
    String orderBy = 'specialty_id',
  }) async {
    try {
      logger.info('Fetching all membership levels (activeOnly: $activeOnly)');

      var query = _client.schema(_schema).from(_tableName).select();

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final response = await query.order(orderBy).order('display_order');

      final levels = (response as List)
          .map((json) => MembershipLevel.fromJson(json))
          .toList();

      logger.info('Fetched ${levels.length} membership levels');
      return levels;
    } catch (e, st) {
      logger.error('Error fetching all membership levels: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener niveles de membresía');
    }
  }

  /// Obtiene un nivel de membresía por su ID.
  ///
  /// Retorna null si no existe.
  Future<MembershipLevel?> getMembershipLevelById(int id) async {
    try {
      logger.info('Fetching membership level by ID: $id');

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        logger.warning('Membership level not found: $id');
        return null;
      }

      final level = MembershipLevel.fromJson(response);
      logger.info('Membership level fetched: ${level.name}');
      return level;
    } catch (e, st) {
      logger.error('Error fetching membership level by ID: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener nivel de membresía');
    }
  }

  /// Obtiene un nivel de membresía por su WordPress RCP ID.
  ///
  /// Retorna null si no existe.
  Future<MembershipLevel?> getMembershipLevelByWordpressId(
      int wordpressRcpId) async {
    try {
      logger.info(
          'Fetching membership level by WordPress RCP ID: $wordpressRcpId');

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .select()
          .eq('wordpress_rcp_id', wordpressRcpId)
          .maybeSingle();

      if (response == null) {
        logger.warning(
            'Membership level not found for WordPress RCP ID: $wordpressRcpId');
        return null;
      }

      final level = MembershipLevel.fromJson(response);
      logger.info('Membership level fetched: ${level.name}');
      return level;
    } catch (e, st) {
      logger.error('Error fetching membership level by WordPress RCP ID: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al obtener nivel de membresía');
    }
  }

  /// Busca niveles de membresía por nombre.
  ///
  /// [specialtyId] - ID de la especialidad
  /// [searchTerm] - Término de búsqueda (parcial, case-insensitive)
  Future<List<MembershipLevel>> searchMembershipLevels({
    required int specialtyId,
    required String searchTerm,
  }) async {
    try {
      logger.info(
          'Searching membership levels in specialty $specialtyId: $searchTerm');

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .select()
          .eq('specialty_id', specialtyId)
          .ilike('name', '%$searchTerm%')
          .order('display_order', ascending: true);

      final levels = (response as List)
          .map((json) => MembershipLevel.fromJson(json))
          .toList();

      logger.info(
          'Found ${levels.length} membership levels matching "$searchTerm"');
      return levels;
    } catch (e, st) {
      logger.error('Error searching membership levels: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al buscar niveles de membresía');
    }
  }

  // ============================================
  // UPDATE
  // ============================================

  /// Actualiza un nivel de membresía existente.
  ///
  /// Retorna el nivel de membresía actualizado.
  /// Lanza excepción si:
  /// - El nivel no existe
  /// - El nuevo nombre ya existe (UNIQUE constraint)
  /// - El nuevo wordpress_rcp_id ya existe (UNIQUE constraint)
  Future<MembershipLevel> updateMembershipLevel(
      MembershipLevel membershipLevel) async {
    try {
      if (membershipLevel.id == null) {
        throw Exception('No se puede actualizar un nivel de membresía sin ID');
      }

      logger.info('Updating membership level: ${membershipLevel.id}');

      // Validar antes de enviar
      if (!membershipLevel.isValid) {
        throw Exception(
            'Nivel de membresía inválido: verifica nombre, nivel de acceso y precios');
      }

      // Preparar datos para actualizar (excluir ID, created_at)
      final updateData = membershipLevel.toJson();
      updateData.remove('id');
      updateData.remove('created_at');
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .update(updateData)
          .eq('id', membershipLevel.id!)
          .select()
          .single();

      final updatedLevel = MembershipLevel.fromJson(response);
      logger.info('Membership level updated successfully: ${updatedLevel.id}');
      return updatedLevel;
    } on supa.PostgrestException catch (e) {
      logger.error('PostgreSQL error updating membership level: ${e.message}');
      if (e.code == '23505') {
        // Unique violation
        if (e.message.contains('membership_levels_wordpress_rcp_id_key')) {
          throw Exception(
              'Ya existe un nivel de membresía con ese WordPress RCP ID');
        }
        throw Exception('Ya existe un nivel de membresía con esos datos');
      }
      throw Exception('Error al actualizar nivel de membresía: ${e.message}');
    } catch (e, st) {
      logger.error('Unexpected error updating membership level: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error de conexión al actualizar nivel de membresía');
    }
  }

  /// Activa o desactiva un nivel de membresía.
  ///
  /// [id] - ID del nivel de membresía
  /// [isActive] - true para activar, false para desactivar
  Future<MembershipLevel> toggleMembershipLevelStatus(
      int id, bool isActive) async {
    try {
      logger.info('Toggling membership level status: $id to $isActive');

      final response = await _client
          .schema(_schema)
          .from(_tableName)
          .update({
            'is_active': isActive,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      final updatedLevel = MembershipLevel.fromJson(response);
      logger.info('Membership level status updated: ${updatedLevel.id}');
      return updatedLevel;
    } catch (e, st) {
      logger.error('Error toggling membership level status: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al cambiar estado del nivel de membresía');
    }
  }

  // ============================================
  // DELETE
  // ============================================

  /// Elimina un nivel de membresía.
  ///
  /// IMPORTANTE: Esto puede fallar si existen user_memberships asociadas
  /// debido a las foreign keys.
  ///
  /// [id] - ID del nivel de membresía a eliminar
  Future<void> deleteMembershipLevel(int id) async {
    try {
      logger.info('Deleting membership level: $id');

      await _client.schema(_schema).from(_tableName).delete().eq('id', id);

      logger.info('Membership level deleted successfully: $id');
    } on supa.PostgrestException catch (e) {
      logger.error('PostgreSQL error deleting membership level: ${e.message}');

      // Foreign key constraint violation
      if (e.code == '23503') {
        throw Exception(
          'No se puede eliminar el nivel de membresía porque tiene usuarios asociados. '
          'Primero desactívalo o migra los usuarios a otro nivel.',
        );
      }

      throw Exception('Error al eliminar nivel de membresía: ${e.message}');
    } catch (e, st) {
      logger.error('Unexpected error deleting membership level: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error de conexión al eliminar nivel de membresía');
    }
  }

  // ============================================
  // STATISTICS
  // ============================================

  /// Cuenta cuántos usuarios tienen un nivel de membresía específico.
  ///
  /// [membershipLevelId] - ID del nivel de membresía
  // Future<int> countUsersWithMembershipLevel(int membershipLevelId) async {
  //   try {
  //     logger.info('Counting users with membership level: $membershipLevelId');

  //     final response = await _client
  //         .schema(_schema)
  //         .from('user_memberships')
  //         .select('id', const supa.count(count: supa.CountOption.exact))
  //         .eq('membership_level_id', membershipLevelId)
  //         .eq('is_active', true);

  //     final count = response.count ?? 0;
  //     logger
  //         .info('Found $count users with membership level $membershipLevelId');
  //     return count;
  //   } catch (e, st) {
  //     logger.error('Error counting users with membership level: $e');
  //     logger.error('Stack trace: $st');
  //     throw Exception('Error al contar usuarios con nivel de membresía');
  //   }
  // }
}

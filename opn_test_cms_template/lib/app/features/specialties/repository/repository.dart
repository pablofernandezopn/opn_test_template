import 'package:opn_test_guardia_civil_cms/app/features/specialties/model/specialty.dart';
import 'package:opn_test_guardia_civil_cms/bootstrap.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Para el logger

class SpecialtyRepository {
  final supabase = Supabase.instance.client;

  /// Obtiene todas las especialidades
  Future<List<Specialty>> fetchSpecialties() async {
    try {
      var query = supabase.from('specialties').select();

      final response = await query;
      final specialties =
          (response as List).map((json) => Specialty.fromJson(json)).toList();

      // Ordenar por display_order ascendente
      specialties.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

      return specialties;
    } catch (e) {
      throw Exception('Error fetching specialties: $e');
    }
  }

  /// Obtiene una especialidad por ID
  Future<Specialty> fetchSpecialtyById(int id) async {
    try {
      final response =
          await supabase.from('specialties').select().eq('id', id).single();
      return Specialty.fromJson(response);
    } catch (e) {
      throw Exception('Error fetching specialty: $e');
    }
  }

  /// Crea una nueva especialidad
  Future<Specialty> createSpecialty(Specialty specialty) async {
    try {
      final response = await supabase
          .from('specialties')
          .insert(specialty.toJsonForCreate())
          .select()
          .single();
      return Specialty.fromJson(response);
    } catch (e) {
      throw Exception('Error creating specialty: $e');
    }
  }

  /// Actualiza una especialidad existente
  Future<Specialty> updateSpecialty(int id, Specialty specialty) async {
    try {
      final response = await supabase
          .from('specialties')
          .update(specialty.toJsonForUpdate())
          .eq('id', id)
          .select()
          .single();
      return Specialty.fromJson(response);
    } catch (e) {
      throw Exception('Error updating specialty: $e');
    }
  }

  /// Elimina una especialidad
  Future<void> deleteSpecialty(int id) async {
    try {
      await supabase.from('specialties').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error deleting specialty: $e');
    }
  }

  /// Actualiza el estado activo de una especialidad
  Future<Specialty> updateSpecialtyActive(int id, bool isActive) async {
    try {
      final response = await supabase
          .from('specialties')
          .update({'is_active': isActive})
          .eq('id', id)
          .select()
          .single();
      return Specialty.fromJson(response);
    } catch (e) {
      throw Exception('Error updating specialty active status: $e');
    }
  }

  /// Actualiza el orden de visualización de una especialidad específica
  Future<Specialty> updateSpecialtyOrder(int id, int newOrder) async {
    try {
      final response = await supabase
          .from('specialties')
          .update({'display_order': newOrder})
          .eq('id', id)
          .select()
          .single();
      return Specialty.fromJson(response);
    } catch (e) {
      throw Exception('Error updating specialty order: $e');
    }
  }

  /// Actualiza el orden de múltiples especialidades en batch
  Future<void> updateSpecialtiesOrder(
      List<Map<String, dynamic>> updates) async {
    try {
      // Realizar múltiples updates en paralelo
      final futures = updates.map((update) {
        return supabase.from('specialties').update(
            {'display_order': update['display_order']}).eq('id', update['id']);
      });

      await Future.wait(futures);
    } catch (e) {
      throw Exception('Error updating specialties order: $e');
    }
  }

  /// Obtiene especialidades activas por academia
  Future<List<Specialty>> getSpecialtiesByAcademy(int academyId) async {
    try {
      final response = await supabase
          .from('specialties')
          .select()
          .eq('academy_id', academyId)
          .eq('is_active', true)
          .order('display_order', ascending: true);

      if (response.isEmpty) {
        logger.warning('No specialties found for academy $academyId');
        return [];
      }

      return (response as List)
          .map((json) => Specialty.fromJson(json))
          .toList();
    } catch (e, st) {
      logger.error('Error fetching specialties for academy $academyId: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al cargar especialidades. Intenta más tarde.');
    }
  }

  /// Cambia la especialidad de un usuario
  Future<void> updateUserSpecialty({
    required int userId,
    required int specialtyId,
  }) async {
    try {
      // Actualizar en cms_users
      await supabase
          .from('cms_users')
          .update({'specialty_id': specialtyId}).eq('id', userId);

      logger.info('User $userId specialty updated to $specialtyId');
    } catch (e, st) {
      logger.error('Error updating user specialty: $e');
      logger.error('Stack trace: $st');
      throw Exception('Error al cambiar especialidad. Intenta más tarde.');
    }
  }

  /// Obtiene una especialidad por ID (alternativa)
  Future<Specialty?> getSpecialtyById(int specialtyId) async {
    try {
      final response = await supabase
          .from('specialties')
          .select()
          .eq('id', specialtyId)
          .single();

      return Specialty.fromJson(response);
    } catch (e, st) {
      logger.error('Error fetching specialty $specialtyId: $e');
      logger.error('Stack trace: $st');
      return null;
    }
  }
}

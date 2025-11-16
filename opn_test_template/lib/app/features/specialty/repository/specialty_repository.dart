import 'package:opn_test_template/app/features/specialty/model/specialty_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SpecialtyRepository {
  SupabaseClient get _supabaseClient => Supabase.instance.client;

  /// Obtiene todas las especialidades activas de una academia
  Future<List<Specialty>> fetchSpecialtiesByAcademy(int academyId) async {
    final response = await _supabaseClient
        .from('specialties')
        .select()
        .eq('academy_id', academyId)
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return response.map((json) => Specialty.fromJson(json)).toList();
  }

  /// Obtiene todas las especialidades activas (sin filtro de academia)
  Future<List<Specialty>> fetchAllActiveSpecialties() async {
    final response = await _supabaseClient
        .from('specialties')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);

    return response.map((json) => Specialty.fromJson(json)).toList();
  }

  /// Obtiene una especialidad por ID
  Future<Specialty?> fetchSpecialtyById(int id) async {
    final response = await _supabaseClient
        .from('specialties')
        .select()
        .eq('id', id)
        .limit(1);

    if (response.isEmpty) return null;
    return Specialty.fromJson(response.first);
  }

  /// Obtiene la especialidad por defecto de una academia
  Future<Specialty?> fetchDefaultSpecialty(int academyId) async {
    final response = await _supabaseClient
        .from('specialties')
        .select()
        .eq('academy_id', academyId)
        .eq('is_default', true)
        .eq('is_active', true)
        .limit(1);

    if (response.isEmpty) return null;
    return Specialty.fromJson(response.first);
  }

  /// Actualiza la especialidad del usuario
  Future<void> updateUserSpecialty(int userId, int specialtyId) async {
    await _supabaseClient
        .from('users')
        .update({'specialty_id': specialtyId})
        .eq('id', userId);
  }

  /// Obtiene la especialidad actual del usuario
  Future<int?> fetchUserSpecialtyId(int userId) async {
    final response = await _supabaseClient
        .from('users')
        .select('specialty_id')
        .eq('id', userId)
        .limit(1);

    if (response.isEmpty) return null;
    return response.first['specialty_id'] as int?;
  }
}
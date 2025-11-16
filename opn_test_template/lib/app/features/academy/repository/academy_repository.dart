import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../../bootstrap.dart';
import '../../../authentification/auth/model/academy.dart';

class AcademyRepository {
  const AcademyRepository();

  Future<Academy?> fetchAcademyById(int academyId) async {
    try {
      final response = await supa.Supabase.instance.client
          .from('academies')
          .select('*')
          .eq('id', academyId)
          .maybeSingle();

      if (response == null) return null;
      return Academy.fromJson(response as Map<String, dynamic>);
    } catch (error, stackTrace) {
      logger.error('Error fetching academy $academyId: $error');
      logger.debug('StackTrace: $stackTrace');
      return null;
    }
  }
}

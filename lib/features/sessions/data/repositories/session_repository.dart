// =============================================================================
//  features/sessions/data/repositories/session_repository.dart
// =============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/session_model.dart';

class SessionRepository {
  final SupabaseClient _client;

  SessionRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const String _table = 'sessions';

  Future<List<LaserSession>> fetchForPatient(String patientId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('patient_id', patientId)
        .order('session_date', ascending: false);

    return response.map((json) => LaserSession.fromJson(json)).toList();
  }

  Future<LaserSession> insert({
    required String patientId,
    required DateTime sessionDate,
    required String laserArea,
    required double price,
    required String laserPower,
    required String notes,
  }) async {
    final newSession = LaserSession(
      id: '',
      patientId: patientId,
      sessionDate: sessionDate,
      laserArea: laserArea,
      price: price,
      laserPower: laserPower,
      notes: notes,
    );

    final response = await _client
        .from(_table)
        .insert(newSession.toInsertJson())
        .select()
        .single();

    return LaserSession.fromJson(response);
  }

  Future<void> delete(String sessionId) async {
    await _client.from(_table).delete().eq('id', sessionId);
  }
}

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
    // Join with doctors table to get doctor name
    final response = await _client
        .from(_table)
        .select('*, doctors(name)')
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
    required String? doctorId,
    required int pulses,
  }) async {
    final newSession = LaserSession(
      id: '',
      patientId: patientId,
      sessionDate: sessionDate,
      laserArea: laserArea,
      price: price,
      laserPower: laserPower,
      notes: notes,
      doctorId: doctorId,
      pulses: pulses,
    );

    final response = await _client
        .from(_table)
        .insert(newSession.toInsertJson())
        .select('*, doctors(name)')
        .single();

    return LaserSession.fromJson(response);
  }

  Future<void> delete(String sessionId) async {
    await _client.from(_table).delete().eq('id', sessionId);
  }

  // ---------------------------------------------------------------------------
  //  Doctor Report: Fetch sessions for a specific doctor within a date range.
  // ---------------------------------------------------------------------------
  Future<List<LaserSession>> fetchForDoctorReport({
    required String doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _client
        .from(_table)
        .select('*, doctors(name)')
        .eq('doctor_id', doctorId)
        .gte('session_date', startDate.toIso8601String())
        .lte('session_date', endDate.toIso8601String())
        .order('session_date', ascending: false);

    return response.map((json) => LaserSession.fromJson(json)).toList();
  }
}

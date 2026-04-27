// =============================================================================
//  features/patients/data/repositories/patient_repository.dart
//  All Supabase CRUD operations for the `patients` table.
//  The UI layer never touches Supabase directly — it only calls this class.
// =============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient_model.dart';

class PatientRepository {
  final SupabaseClient _client;

  PatientRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const String _table = 'patients';

  // ---------------------------------------------------------------------------
  //  Fetch all patients, newest first.
  // ---------------------------------------------------------------------------
  Future<List<Patient>> fetchAll() async {
    final response = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => Patient.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  //  Search patients by name or phone number (case-insensitive).
  // ---------------------------------------------------------------------------
  Future<List<Patient>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return fetchAll();

    final response = await _client
        .from(_table)
        .select()
        .or('name.ilike.%$q%,phone_number.ilike.%$q%')
        .order('created_at', ascending: false);

    return response
        .map((json) => Patient.fromJson(json))
        .toList();
  }

  // ---------------------------------------------------------------------------
  //  Insert a new patient and return the created record.
  // ---------------------------------------------------------------------------
  Future<Patient> insert({
    required String name,
    required String phoneNumber,
  }) async {
    final newPatient = Patient(
      id: '',          // Will be assigned by Supabase
      name: name,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(), // Placeholder; Supabase sets the real value
    );

    final response = await _client
        .from(_table)
        .insert(newPatient.toInsertJson())
        .select()
        .single();

    return Patient.fromJson(response);
  }

  // ---------------------------------------------------------------------------
  //  Delete a patient by id (cascades to sessions if FK cascade is set in DB).
  // ---------------------------------------------------------------------------
  Future<void> delete(String patientId) async {
    await _client.from(_table).delete().eq('id', patientId);
  }
}

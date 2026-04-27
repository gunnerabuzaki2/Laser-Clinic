// =============================================================================
//  features/doctors/data/repositories/doctor_repository.dart
//  Read-only repository — doctors are managed via Supabase dashboard.
// =============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/doctor_model.dart';

class DoctorRepository {
  final SupabaseClient _client;

  DoctorRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const String _table = 'doctors';

  /// Fetch all doctors, ordered by name.
  Future<List<Doctor>> fetchAll() async {
    final response = await _client
        .from(_table)
        .select()
        .order('name', ascending: true);

    return (response as List<dynamic>)
        .map((json) => Doctor.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

// =============================================================================
//  features/doctors/presentation/providers/doctor_providers.dart
//  Riverpod providers for doctor data.
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/doctor_model.dart';
import '../../data/repositories/doctor_repository.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository();
});

/// Fetches all doctors for dropdown lists and reports.
final doctorListProvider =
    FutureProvider.autoDispose<List<Doctor>>((ref) async {
  final repo = ref.watch(doctorRepositoryProvider);
  return repo.fetchAll();
});

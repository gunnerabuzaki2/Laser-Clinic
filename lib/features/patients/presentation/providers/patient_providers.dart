// =============================================================================
//  features/patients/presentation/providers/patient_providers.dart
//
//  Riverpod providers that manage patient state.
//  The UI consumes these providers — it never directly calls the repository.
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/patient_model.dart';
import '../../data/repositories/patient_repository.dart';

// ---------------------------------------------------------------------------
//  Repository provider (singleton)
// ---------------------------------------------------------------------------
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepository();
});

// ---------------------------------------------------------------------------
//  Search query state — drives which patients are shown.
// ---------------------------------------------------------------------------
final patientSearchQueryProvider = StateProvider<String>((ref) => '');

// ---------------------------------------------------------------------------
//  Async patient list — fetches/searches based on the current query.
//  Automatically refreshes when the query changes.
// ---------------------------------------------------------------------------
final patientListProvider =
    FutureProvider.autoDispose<List<Patient>>((ref) async {
  final repo = ref.watch(patientRepositoryProvider);
  final query = ref.watch(patientSearchQueryProvider);
  return query.isEmpty ? repo.fetchAll() : repo.search(query);
});

// ---------------------------------------------------------------------------
//  State notifier that performs mutations (insert / delete) and then
//  invalidates the list provider so the UI auto-refreshes.
// ---------------------------------------------------------------------------
class PatientNotifier extends StateNotifier<AsyncValue<void>> {
  PatientNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  final PatientRepository _repo;
  final Ref _ref;

  /// Add a new patient and refresh the list.
  Future<void> addPatient({
    required String name,
    required String phoneNumber,
    String address = '',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.insert(name: name, phoneNumber: phoneNumber, address: address),
    );
    // Invalidate the list so FutureProvider re-fetches automatically.
    _ref.invalidate(patientListProvider);
  }

  /// Delete a patient by id and refresh the list.
  Future<void> deletePatient(String patientId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.delete(patientId));
    _ref.invalidate(patientListProvider);
  }
}

final patientNotifierProvider =
    StateNotifierProvider<PatientNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(patientRepositoryProvider);
  return PatientNotifier(repo, ref);
});

// =============================================================================
//  features/sessions/presentation/providers/session_providers.dart
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});

final selectedPatientIdProvider = StateProvider<String?>((ref) => null);

final sessionListProvider =
    FutureProvider.autoDispose<List<LaserSession>>((ref) async {
  final patientId = ref.watch(selectedPatientIdProvider);
  if (patientId == null) return [];
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.fetchForPatient(patientId);
});

class SessionNotifier extends StateNotifier<AsyncValue<void>> {
  SessionNotifier(this._repo, this._ref) : super(const AsyncValue.data(null));

  final SessionRepository _repo;
  final Ref _ref;

  Future<void> addSession({
    required String patientId,
    required DateTime sessionDate,
    required String laserArea,
    required double price,
    required String laserPower,
    required String notes,
    required String? doctorId,
    required int pulses,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.insert(
        patientId: patientId,
        sessionDate: sessionDate,
        laserArea: laserArea,
        price: price,
        laserPower: laserPower,
        notes: notes,
        doctorId: doctorId,
        pulses: pulses,
      ),
    );
    _ref.invalidate(sessionListProvider);
  }

  Future<void> deleteSession(String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.delete(sessionId));
    _ref.invalidate(sessionListProvider);
  }
}

final sessionNotifierProvider =
    StateNotifierProvider<SessionNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return SessionNotifier(repo, ref);
});

// =============================================================================
//  Doctor Report Providers
// =============================================================================

/// State for the doctor report parameters
class DoctorReportParams {
  final String? doctorId;
  final DateTime? startDate;
  final DateTime? endDate;

  const DoctorReportParams({this.doctorId, this.startDate, this.endDate});
}

final doctorReportParamsProvider =
    StateProvider<DoctorReportParams>((ref) => const DoctorReportParams());

/// Fetches sessions for doctor report when params are set.
final doctorReportProvider =
    FutureProvider.autoDispose<List<LaserSession>?>((ref) async {
  final params = ref.watch(doctorReportParamsProvider);
  if (params.doctorId == null ||
      params.startDate == null ||
      params.endDate == null) {
    return null; // No search performed yet
  }
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.fetchForDoctorReport(
    doctorId: params.doctorId!,
    startDate: params.startDate!,
    endDate: params.endDate!,
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/candidate_model.dart';
import '../services/candidate_service.dart';

// Service provider
final candidateServiceProvider = Provider<CandidateService>((ref) {
  return CandidateService();
});

// All candidates provider
final candidatesProvider = FutureProvider<List<Candidate>>((ref) async {
  final service = ref.read(candidateServiceProvider);
  return await service.getAllCandidates();
});

// Only pre-boarding (not onboarded) candidates for letter generation
final candidatesForLettersProvider = FutureProvider<List<Candidate>>((
  ref,
) async {
  final service = ref.read(candidateServiceProvider);
  return await service.getCandidatesForLetters();
});

// Candidates by status provider
final candidatesByStatusProvider =
    FutureProvider.family<List<Candidate>, String>((ref, status) async {
      final service = ref.read(candidateServiceProvider);
      return await service.getCandidatesByStatus(status);
    });

// Candidates by stage provider
final candidatesByStageProvider =
    FutureProvider.family<List<Candidate>, String>((ref, stage) async {
      final service = ref.read(candidateServiceProvider);
      return await service.getCandidatesByStage(stage);
    });

// Candidate by ID provider
final candidateByIdProvider = FutureProvider.family<Candidate?, String>((
  ref,
  id,
) async {
  final service = ref.read(candidateServiceProvider);
  return await service.getCandidateById(id);
});

// Search candidates provider
final searchCandidatesProvider = FutureProvider.family<List<Candidate>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    final service = ref.read(candidateServiceProvider);
    return await service.searchCandidates(query);
  },
);

// Candidate notifier for CRUD operations
class CandidateNotifier extends StateNotifier<AsyncValue<List<Candidate>>> {
  final CandidateService _service;

  CandidateNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    state = const AsyncValue.loading();
    try {
      final candidates = await _service.getAllCandidates();
      state = AsyncValue.data(candidates);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createCandidate(Candidate candidate) async {
    try {
      final createdCandidate = await _service.createCandidate(candidate);
      state.whenData((candidates) {
        state = AsyncValue.data([...candidates, createdCandidate]);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCandidate(Candidate candidate) async {
    try {
      await _service.updateCandidate(candidate);
      state.whenData((candidates) {
        final updatedCandidates =
            candidates.map((c) {
              return c.id == candidate.id ? candidate : c;
            }).toList();
        state = AsyncValue.data(updatedCandidates);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteCandidate(String id) async {
    try {
      await _service.deleteCandidate(id);
      state.whenData((candidates) {
        final filteredCandidates = candidates.where((c) => c.id != id).toList();
        state = AsyncValue.data(filteredCandidates);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCandidateStatus(
    String id,
    String newStatus, {
    String? updatedBy,
  }) async {
    try {
      await _service.updateCandidateStatus(id, newStatus, updatedBy: updatedBy);
      state.whenData((candidates) {
        final updatedCandidates =
            candidates.map((c) {
              if (c.id == id) {
                return c.updateStatus(newStatus, updatedBy: updatedBy);
              }
              return c;
            }).toList();
        state = AsyncValue.data(updatedCandidates);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> assignEmployeeId(
    String candidateId,
    String employeeId,
    String userId,
  ) async {
    try {
      await _service.assignEmployeeId(candidateId, employeeId, userId);
      state.whenData((candidates) {
        final updatedCandidates =
            candidates.map((c) {
              if (c.id == candidateId) {
                return c.assignEmployeeId(employeeId, userId);
              }
              return c;
            }).toList();
        state = AsyncValue.data(updatedCandidates);
      });
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadCandidates();
  }
}

// Candidate notifier provider
final candidateNotifierProvider =
    StateNotifierProvider<CandidateNotifier, AsyncValue<List<Candidate>>>((
      ref,
    ) {
      final service = ref.read(candidateServiceProvider);
      return CandidateNotifier(service);
    });

// Next candidate ID provider
final nextCandidateIdProvider = FutureProvider<String>((ref) async {
  final service = ref.read(candidateServiceProvider);
  return await service.generateNextCandidateId();
});

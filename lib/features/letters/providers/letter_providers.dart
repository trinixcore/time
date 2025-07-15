import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/letter_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/letter_service.dart';
import '../../../shared/providers/auth_providers.dart';

// Letter Service Provider
final letterServiceProvider = Provider<LetterService>((ref) {
  return LetterService();
});

// Current User Provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUserModel();
});

// All Letters Provider
final allLettersProvider = FutureProvider<List<Letter>>((ref) async {
  final letterService = ref.watch(letterServiceProvider);
  return await letterService.getLetters();
});

// Draft Letters Provider
final draftLettersProvider = FutureProvider<List<Letter>>((ref) async {
  final letterService = ref.watch(letterServiceProvider);
  final letters = await letterService.getLetters();
  return letters.where((letter) => letter.isDraft).toList();
});

// Pending Approval Letters Provider
final pendingApprovalLettersProvider = FutureProvider<List<Letter>>((
  ref,
) async {
  final letterService = ref.watch(letterServiceProvider);
  final letters = await letterService.getLetters();
  return letters.where((letter) => letter.isPendingApproval).toList();
});

// Letters Pending Current User Approval Provider
final lettersPendingUserApprovalProvider = FutureProvider<List<Letter>>((
  ref,
) async {
  final letterService = ref.watch(letterServiceProvider);
  final currentUser = await ref.watch(currentUserProvider.future);

  if (currentUser == null) return [];

  return await letterService.getLettersPendingUserApproval(currentUser.uid);
});

// Approved Letters Provider
final approvedLettersProvider = FutureProvider<List<Letter>>((ref) async {
  final letterService = ref.watch(letterServiceProvider);
  final letters = await letterService.getLetters();
  return letters.where((letter) => letter.isApproved).toList();
});

// Sent Letters Provider
final sentLettersProvider = FutureProvider<List<Letter>>((ref) async {
  final letterService = ref.watch(letterServiceProvider);
  final letters = await letterService.getLetters();
  return letters.where((letter) => letter.isSent).toList();
});

// Accepted Letters Provider
final acceptedLettersProvider = FutureProvider<List<Letter>>((ref) async {
  final letterService = ref.watch(letterServiceProvider);
  final letters = await letterService.getLetters();
  return letters.where((letter) => letter.isAccepted).toList();
});

// Rejected Letters Provider
final rejectedLettersProvider = FutureProvider<List<Letter>>((ref) async {
  final letterService = ref.watch(letterServiceProvider);
  final letters = await letterService.getLetters();
  return letters.where((letter) => letter.isRejected).toList();
});

// Single Letter Provider
final letterProvider = FutureProvider.family<Letter?, String>((
  ref,
  letterId,
) async {
  final letterService = ref.watch(letterServiceProvider);
  return await letterService.getLetter(letterId);
});

// User Approval Status Provider
final userApprovalStatusProvider =
    FutureProvider.family<SignatureApproval?, Map<String, String>>((
      ref,
      params,
    ) async {
      final letterService = ref.watch(letterServiceProvider);
      final letterId = params['letterId']!;
      final userId = params['userId']!;

      return await letterService.getUserApprovalStatus(letterId, userId);
    });

// Letter Creation Provider
final letterCreationProvider =
    StateNotifierProvider<LetterCreationNotifier, AsyncValue<Letter?>>((ref) {
      return LetterCreationNotifier(ref.read(letterServiceProvider));
    });

class LetterCreationNotifier extends StateNotifier<AsyncValue<Letter?>> {
  final LetterService _letterService;

  LetterCreationNotifier(this._letterService)
    : super(const AsyncValue.data(null));

  Future<void> createLetter({
    required String type,
    required String employeeName,
    required String employeeEmail,
    required List<String> signatureAuthorityUids,
    String? content,
    Map<String, dynamic>? additionalContext,
  }) async {
    state = const AsyncValue.loading();

    try {
      final letter = await _letterService.createLetter(
        type: type,
        employeeName: employeeName,
        employeeEmail: employeeEmail,
        signatureAuthorityUids: signatureAuthorityUids,
        content: content,
        additionalContext: additionalContext,
      );
      state = AsyncValue.data(letter);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Letter Actions Provider
final letterActionsProvider = Provider<LetterActionsNotifier>((ref) {
  return LetterActionsNotifier(ref.read(letterServiceProvider));
});

class LetterActionsNotifier {
  final LetterService _letterService;

  LetterActionsNotifier(this._letterService);

  Future<void> submitForApproval(String letterId) async {
    await _letterService.submitForApproval(letterId);
  }

  Future<void> approveIndividualSignature(
    String letterId,
    String signatureId,
    String approvedBy,
    String approvedByName,
  ) async {
    await _letterService.approveIndividualSignature(
      letterId,
      signatureId,
      approvedBy,
      approvedByName,
    );
  }

  Future<void> rejectIndividualSignature(
    String letterId,
    String signatureId,
    String rejectedBy,
    String rejectedByName,
    String reason,
  ) async {
    await _letterService.rejectIndividualSignature(
      letterId,
      signatureId,
      rejectedBy,
      rejectedByName,
      reason,
    );
  }

  Future<void> markAsSent(
    String letterId, {
    String? sentVia,
    String? sentTo,
  }) async {
    await _letterService.markAsSent(letterId, sentVia: sentVia, sentTo: sentTo);
  }

  Future<void> markAsAccepted(String letterId) async {
    await _letterService.markAsAccepted(letterId);
  }

  Future<void> deleteLetter(String letterId) async {
    await _letterService.deleteLetter(letterId);
  }

  Future<void> moveToDraft(String letterId) async {
    await _letterService.moveToDraft(letterId);
  }
}

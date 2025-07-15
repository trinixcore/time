import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/signature_model.dart';
import '../services/signature_service.dart';

// Signature Service Provider
final signatureServiceProvider = Provider<SignatureService>((ref) {
  return SignatureService();
});

// All Signatures Provider
final allSignaturesProvider = FutureProvider<List<Signature>>((ref) async {
  final service = ref.read(signatureServiceProvider);
  return await service.getAllSignatures();
});

// Signatures for Letter Type Provider
final signaturesForLetterTypeProvider =
    FutureProvider.family<List<Signature>, String>((ref, letterType) async {
      final service = ref.read(signatureServiceProvider);
      return await service.getSignaturesForLetterType(letterType);
    });

// Refreshed Signatures for Letter Type Provider (for refresh functionality)
final refreshedSignaturesForLetterTypeProvider =
    FutureProvider.family<List<Signature>, String>((ref, letterType) async {
      final service = ref.read(signatureServiceProvider);
      return await service.getSignaturesForLetterType(letterType);
    });

// Signature by ID Provider
final signatureByIdProvider = FutureProvider.family<Signature?, String>((
  ref,
  signatureId,
) async {
  final service = ref.read(signatureServiceProvider);
  return await service.getSignatureById(signatureId);
});

// Signature Refresh Provider (for triggering refreshes)
final signatureRefreshProvider = StateProvider<int>((ref) => 0);

// Active Signatures Provider
final activeSignaturesProvider = FutureProvider<List<Signature>>((ref) async {
  final service = ref.read(signatureServiceProvider);
  final allSignatures = await service.getAllSignatures();
  return allSignatures.where((sig) => sig.isActive == true).toList();
});

// Signatures by Owner Provider
final signaturesByOwnerProvider =
    FutureProvider.family<List<Signature>, String>((ref, ownerUid) async {
      final service = ref.read(signatureServiceProvider);
      final allSignatures = await service.getAllSignatures();
      return allSignatures.where((sig) => sig.ownerUid == ownerUid).toList();
    });

// Signature Creation Provider
final signatureCreationProvider =
    StateNotifierProvider<SignatureCreationNotifier, AsyncValue<Signature?>>((
      ref,
    ) {
      return SignatureCreationNotifier(ref.read(signatureServiceProvider));
    });

class SignatureCreationNotifier extends StateNotifier<AsyncValue<Signature?>> {
  final SignatureService _signatureService;

  SignatureCreationNotifier(this._signatureService)
    : super(const AsyncValue.data(null));

  Future<void> createSignature({
    required String ownerUid,
    required String ownerName,
    required Uint8List imageBytes,
    required String imageFileName,
    required List<String> allowedLetterTypes,
    String? title,
    String? department,
    String? email,
    String? phoneNumber,
    bool requiresApproval = false,
    bool isActive = true,
    String? notes,
  }) async {
    state = const AsyncValue.loading();

    try {
      final signature = await _signatureService.addSignatureAuthority(
        ownerUid: ownerUid,
        ownerName: ownerName,
        imageBytes: imageBytes,
        imageFileName: imageFileName,
        allowedLetterTypes: allowedLetterTypes,
        title: title,
        department: department,
        email: email,
        phoneNumber: phoneNumber,
        requiresApproval: requiresApproval,
        isActive: isActive,
        notes: notes,
      );
      state = AsyncValue.data(signature);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// Signature Actions Provider
final signatureActionsProvider = Provider<SignatureActionsNotifier>((ref) {
  return SignatureActionsNotifier(ref.read(signatureServiceProvider));
});

class SignatureActionsNotifier {
  final SignatureService _signatureService;

  SignatureActionsNotifier(this._signatureService);

  Future<void> updateSignature({
    required String signatureId,
    required String ownerUid,
    required String ownerName,
    required List<String> allowedLetterTypes,
    String? title,
    String? department,
    String? email,
    String? phoneNumber,
    bool requiresApproval = false,
    bool isActive = true,
    String? notes,
    Uint8List? newImageBytes,
    String? newImageFileName,
  }) async {
    await _signatureService.updateSignatureAuthority(
      signatureId: signatureId,
      ownerUid: ownerUid,
      ownerName: ownerName,
      allowedLetterTypes: allowedLetterTypes,
      title: title,
      department: department,
      email: email,
      phoneNumber: phoneNumber,
      requiresApproval: requiresApproval,
      isActive: isActive,
      notes: notes,
      newImageBytes: newImageBytes,
      newImageFileName: newImageFileName,
    );
  }

  Future<void> deleteSignature(String signatureId) async {
    await _signatureService.deleteSignature(signatureId);
  }

  Future<void> toggleSignatureStatus(String signatureId, bool isActive) async {
    await _signatureService.setSignatureActive(signatureId, isActive);
  }
}

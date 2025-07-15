import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/signature_model.dart';
import '../../../core/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class SignatureService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'signatures';
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = const Uuid();

  /// Get all signatures
  Future<List<Signature>> getAllSignatures() async {
    final querySnapshot = await _firestore.collection(_collection).get();
    return querySnapshot.docs
        .map((doc) => Signature.fromJson({...doc.data()!, 'id': doc.id}))
        .toList();
  }

  /// Get signatures for a specific letter type
  Future<List<Signature>> getSignaturesForLetterType(String letterType) async {
    final querySnapshot =
        await _firestore
            .collection(_collection)
            .where('allowedLetterTypes', arrayContains: letterType)
            .where('isActive', isEqualTo: true)
            .get();
    return querySnapshot.docs
        .map((doc) => Signature.fromJson({...doc.data()!, 'id': doc.id}))
        .toList();
  }

  /// Get a specific signature by ID
  Future<Signature?> getSignatureById(String signatureId) async {
    final doc = await _firestore.collection(_collection).doc(signatureId).get();
    if (doc.exists) {
      return Signature.fromJson({...doc.data()!, 'id': doc.id});
    }
    return null;
  }

  /// Add a new signature authority (with image upload)
  Future<Signature> addSignatureAuthority({
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
    final now = DateTime.now();
    final signatureId = _uuid.v4();
    final storagePath = 'process/sig/$signatureId';
    final uploadedPath = await _supabaseService.uploadBytesWithServiceRole(
      filePath: storagePath,
      bytes: imageBytes,
      fileName: imageFileName,
      contentType: 'image/png',
    );

    final signature = Signature(
      id: signatureId,
      ownerUid: ownerUid,
      ownerName: ownerName,
      imagePath: uploadedPath,
      requiresApproval: requiresApproval,
      allowedLetterTypes: allowedLetterTypes,
      createdAt: now,
      updatedAt: now,
      title: title,
      department: department,
      email: email,
      phoneNumber: phoneNumber,
      isActive: isActive,
      notes: notes,
      metadata: {},
    );
    await _firestore
        .collection(_collection)
        .doc(signatureId)
        .set(signature.toJson());
    return signature;
  }

  /// Update signature authority with full data
  Future<void> updateSignatureAuthority({
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
    String? newImagePath;
    if (newImageBytes != null && newImageFileName != null) {
      // Delete the old image first if it exists
      try {
        final existingSignature = await getSignatureById(signatureId);
        if (existingSignature != null &&
            existingSignature.imagePath.isNotEmpty) {
          await _supabaseService.deleteFile(existingSignature.imagePath);
        }
      } catch (e) {
        print('⚠️ Failed to delete old signature image: $e');
      }

      // Upload the new image
      final storagePath = 'process/sig/$signatureId';
      newImagePath = await _supabaseService.uploadBytesWithServiceRole(
        filePath: storagePath,
        bytes: newImageBytes,
        fileName: newImageFileName,
        contentType: 'image/png',
      );
    }

    final updateData = {
      'ownerUid': ownerUid,
      'ownerName': ownerName,
      'allowedLetterTypes': allowedLetterTypes,
      'title': title,
      'department': department,
      'email': email,
      'phoneNumber': phoneNumber,
      'requiresApproval': requiresApproval,
      'isActive': isActive,
      'notes': notes,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (newImagePath != null) {
      updateData['imagePath'] = newImagePath;
    }

    await _firestore
        .collection(_collection)
        .doc(signatureId)
        .update(updateData);
  }

  /// Update signature authority (optionally with new image)
  Future<void> updateSignatureAuthorityLegacy({
    required Signature signature,
    Uint8List? newImageBytes,
    String? newImageFileName,
  }) async {
    String? newImagePath;
    if (newImageBytes != null && newImageFileName != null) {
      final storagePath = 'process/sig/${signature.id}';
      newImagePath = await _supabaseService.uploadBytesWithServiceRole(
        filePath: storagePath,
        bytes: newImageBytes,
        fileName: newImageFileName,
        contentType: 'image/png',
      );
    }
    final updated = signature.copyWith(
      imagePath: newImagePath ?? signature.imagePath,
      updatedAt: DateTime.now(),
    );
    await _firestore
        .collection(_collection)
        .doc(signature.id)
        .update(updated.toJson());
  }

  /// Deactivate or remove signature authority
  Future<void> setSignatureActive(String signatureId, bool isActive) async {
    await _firestore.collection(_collection).doc(signatureId).update({
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Delete signature with proper cleanup
  Future<void> deleteSignature(String signatureId) async {
    try {
      // First, get the signature to get the image path
      final signature = await getSignatureById(signatureId);
      if (signature != null) {
        // Try to delete the image from Supabase storage
        try {
          await _supabaseService.deleteFile(signature.imagePath);
        } catch (e) {
          // Log but don't fail if image deletion fails
          print('⚠️ Failed to delete signature image: $e');
        }
      }

      // Delete the document from Firestore
      await _firestore.collection(_collection).doc(signatureId).delete();
    } catch (e) {
      throw Exception('Failed to delete signature: $e');
    }
  }

  /// Refresh signature cache (call this after CRUD operations)
  Future<void> refreshSignatureCache() async {
    // This method can be called to trigger cache invalidation
    // The actual refresh is handled by the provider watching this method
  }

  /// Delete multiple signatures
  Future<void> deleteMultipleSignatures(List<String> signatureIds) async {
    final batch = _firestore.batch();

    for (final signatureId in signatureIds) {
      final docRef = _firestore.collection(_collection).doc(signatureId);
      batch.delete(docRef);

      // Also try to delete associated images
      try {
        final signature = await getSignatureById(signatureId);
        if (signature != null) {
          await _supabaseService.deleteFile(signature.imagePath);
        }
      } catch (e) {
        print('⚠️ Failed to delete signature image for $signatureId: $e');
      }
    }

    await batch.commit();
  }
}

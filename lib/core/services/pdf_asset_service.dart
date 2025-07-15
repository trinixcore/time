import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/pdf_asset_model.dart';
import 'supabase_service.dart';

class PdfAssetService {
  static final _firestore = FirebaseFirestore.instance;
  static final _collection = _firestore.collection('pdf_assets');
  static final _uuid = Uuid();

  /// Uploads a new PDF asset (header/footer/logo)
  static Future<PdfAsset> uploadAsset({
    required String type, // 'header', 'footer', 'logo'
    required String label,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final storagePath = 'process/pdf/$type/$id/$fileName';
    // Upload to Supabase
    final supabaseService = SupabaseService();
    final uploadedPath = await supabaseService.uploadBytesWithServiceRole(
      filePath: 'process/pdf/$type/$id',
      bytes: bytes,
      fileName: fileName,
      contentType: 'image/png',
    );
    // Get signed URL for viewing
    final imageUrl = await supabaseService.getSignedUrl(uploadedPath);
    // Store metadata in Firestore
    final asset = PdfAsset(
      id: id,
      type: type,
      label: label,
      imageUrl: imageUrl,
      createdAt: now,
      updatedAt: now,
    );
    await _collection.doc(id).set(asset.toMap());
    return asset;
  }

  /// Updates an existing asset (optionally replacing the image)
  static Future<void> updateAsset({
    required PdfAsset asset,
    String? newLabel,
    Uint8List? newBytes,
    String? newFileName,
  }) async {
    String imageUrl = asset.imageUrl;
    if (newBytes != null && newFileName != null) {
      // Delete old image from Supabase
      final supabaseService = SupabaseService();
      await supabaseService.deleteFile(asset.imageUrl);
      // Upload new image
      final uploadedPath = await supabaseService.uploadBytesWithServiceRole(
        filePath: 'process/pdf/${asset.type}/${asset.id}',
        bytes: newBytes,
        fileName: newFileName,
        contentType: 'image/png',
      );
      imageUrl = await supabaseService.getSignedUrl(uploadedPath);
    }
    await _collection.doc(asset.id).update({
      if (newLabel != null) 'label': newLabel,
      'imageUrl': imageUrl,
      'updatedAt': DateTime.now(),
    });
  }

  /// Deletes an asset and its image
  static Future<void> deleteAsset(PdfAsset asset) async {
    final supabaseService = SupabaseService();
    await supabaseService.deleteFile(asset.imageUrl);
    await _collection.doc(asset.id).delete();
  }

  /// Fetch all assets
  static Stream<List<PdfAsset>> getAssets() {
    return _collection.snapshots().map(
      (snap) => snap.docs.map((doc) => PdfAsset.fromFirestore(doc)).toList(),
    );
  }

  static Future<PdfAsset?> getAssetById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return PdfAsset.fromFirestore(doc);
  }
}

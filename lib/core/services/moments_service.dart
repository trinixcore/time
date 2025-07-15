import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import '../models/moment_media_model.dart';
import '../models/announcement_model.dart';
import '../config/supabase_config.dart';

class MomentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger();

  // Service role client for storage operations (bypasses RLS)
  SupabaseClient? _serviceClient;

  // Collections
  CollectionReference get _momentMediaCollection =>
      _firestore.collection('moment_media');
  CollectionReference get _announcementsCollection =>
      _firestore.collection('announcements');

  // Supabase bucket
  static const String _bucketName = 'moments';

  // Initialize service client
  Future<void> _initializeServiceClient() async {
    if (_serviceClient == null) {
      try {
        final url = await SupabaseConfig.url;
        final serviceRoleKey = await SupabaseConfig.serviceRoleKey;

        _serviceClient = SupabaseClient(url, serviceRoleKey);
        print(
          '✅ MomentsService: Service client initialized with dynamic config',
        );
      } catch (e) {
        print('❌ MomentsService: Failed to initialize service client: $e');
        throw Exception('Failed to initialize service client: $e');
      }
    }
  }

  /// Upload moment media (image/video) to Supabase and save metadata to Firestore
  Future<MomentMedia?> uploadMomentMedia({
    required String fileName,
    required Uint8List fileBytes,
    required MediaType mediaType,
    required String uploadedBy,
    String? title,
    String? description,
  }) async {
    try {
      _logger.i('📤 Uploading moment media: $fileName');

      // Initialize service client
      await _initializeServiceClient();

      // Generate unique ID
      final mediaId = _momentMediaCollection.doc().id;
      final filePath = '$mediaId/$fileName';

      _logger.i('📁 File path: $filePath');
      _logger.i('📊 File size: ${fileBytes.length} bytes');

      // Upload to Supabase using service role client
      await _serviceClient!.storage
          .from(_bucketName)
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      _logger.i('✅ File uploaded to Supabase successfully');

      // Get public URL
      final fileUrl = _serviceClient!.storage
          .from(_bucketName)
          .getPublicUrl(filePath);

      _logger.i('🔗 Public URL generated: $fileUrl');

      // Get current max order
      final maxOrderQuery =
          await _momentMediaCollection
              .orderBy('displayOrder', descending: true)
              .limit(1)
              .get();

      final nextOrder =
          maxOrderQuery.docs.isEmpty
              ? 1
              : (maxOrderQuery.docs.first.data()
                      as Map<String, dynamic>)['displayOrder'] +
                  1;

      // Create moment media object
      final momentMedia = MomentMedia(
        id: mediaId,
        fileName: fileName,
        fileUrl: fileUrl,
        mediaType: mediaType,
        displayOrder: nextOrder,
        uploadedBy: uploadedBy,
        uploadedAt: DateTime.now(),
        title: title,
        description: description,
        isActive: true,
      );

      // Save to Firestore
      await _momentMediaCollection.doc(mediaId).set(momentMedia.toJson());

      _logger.i('✅ Moment media uploaded successfully: $mediaId');
      return momentMedia;
    } catch (e) {
      _logger.e('❌ Failed to upload moment media: $e');
      return null;
    }
  }

  /// Get all active moment media ordered by display order
  Future<List<MomentMedia>> getActiveMomentMedia() async {
    try {
      final querySnapshot =
          await _momentMediaCollection
              .where('isActive', isEqualTo: true)
              .orderBy('displayOrder')
              .get();

      // Initialize service client
      await _initializeServiceClient();

      final List<MomentMedia> mediaList = [];
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final fileName = data['fileName'] as String;
        final mediaId = data['id'] as String? ?? doc.id;
        final filePath = '$mediaId/$fileName';
        String? signedUrl;
        try {
          final res = await _serviceClient!.storage
              .from(_bucketName)
              .createSignedUrl(
                filePath,
                await SupabaseConfig.momentsMediaExpiry, // Dynamic expiry
              );
          signedUrl = res;
        } catch (e) {
          _logger.w('Could not generate signed URL for $filePath: $e');
        }
        final media = MomentMedia.fromJson(data).copyWith(signedUrl: signedUrl);
        mediaList.add(media);
      }
      return mediaList;
    } catch (e) {
      _logger.e('❌ Failed to get moment media: $e');
      return [];
    }
  }

  /// Delete moment media from both Supabase and Firestore
  Future<bool> deleteMomentMedia(String mediaId) async {
    try {
      _logger.i('🗑️ Deleting moment media: $mediaId');

      // Initialize service client
      await _initializeServiceClient();

      // Get media info from Firestore
      final doc = await _momentMediaCollection.doc(mediaId).get();
      if (!doc.exists) {
        _logger.w('⚠️ Media document not found: $mediaId');
        return false;
      }

      final mediaData = doc.data() as Map<String, dynamic>;
      final fileName = mediaData['fileName'] as String;
      final filePath = '$mediaId/$fileName';

      _logger.i('📁 Deleting file from Supabase: $filePath');

      // Delete from Supabase using service role client
      await _serviceClient!.storage.from(_bucketName).remove([filePath]);

      _logger.i('✅ File deleted from Supabase successfully');

      // Delete from Firestore
      await _momentMediaCollection.doc(mediaId).delete();

      _logger.i('✅ Moment media deleted successfully: $mediaId');
      return true;
    } catch (e) {
      _logger.e('❌ Failed to delete moment media: $e');
      return false;
    }
  }

  /// Update display order of moment media
  Future<bool> updateMomentMediaOrder(String mediaId, int newOrder) async {
    try {
      await _momentMediaCollection.doc(mediaId).update({
        'displayOrder': newOrder,
      });
      return true;
    } catch (e) {
      _logger.e('❌ Failed to update moment media order: $e');
      return false;
    }
  }

  /// Create new announcement
  Future<Announcement?> createAnnouncement({
    required String title,
    required String content,
    required String createdBy,
    DateTime? expiresAt,
    String? priority,
    String? category,
    List<String>? tags,
    String? richContent,
    List<String>? attachments,
    List<String>? targetDepartments,
    List<String>? targetRoles,
    bool? isGlobal,
    bool? requiresAcknowledgment,
    int? maxViews,
    String? createdByName,
  }) async {
    try {
      _logger.i('📢 Creating announcement: $title');

      final announcementId = _announcementsCollection.doc().id;

      final announcement = Announcement(
        id: announcementId,
        title: title,
        content: content,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        isActive: true,
        priority: priority ?? 'medium',
        category: category,
        tags: tags ?? [],
        richContent: richContent,
        attachments: attachments ?? [],
        targetDepartments: targetDepartments ?? [],
        targetRoles: targetRoles ?? [],
        isGlobal: isGlobal ?? true,
        requiresAcknowledgment: requiresAcknowledgment ?? false,
        acknowledgedBy: [],
        maxViews: maxViews,
        viewCount: 0,
        createdByName: createdByName,
      );

      await _announcementsCollection
          .doc(announcementId)
          .set(announcement.toJson());

      _logger.i('✅ Announcement created successfully: $announcementId');
      return announcement;
    } catch (e) {
      _logger.e('❌ Failed to create announcement: $e');
      return null;
    }
  }

  /// Get all active announcements
  Future<List<Announcement>> getActiveAnnouncements() async {
    try {
      final now = DateTime.now();
      final querySnapshot =
          await _announcementsCollection
              .where('isActive', isEqualTo: true)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => Announcement.fromJson(doc.data() as Map<String, dynamic>),
          )
          .where((announcement) {
            // Filter out expired announcements
            if (announcement.expiresAt != null) {
              return announcement.expiresAt!.isAfter(now);
            }
            return true;
          })
          .toList();
    } catch (e) {
      _logger.e('❌ Failed to get announcements: $e');
      return [];
    }
  }

  /// Update announcement
  Future<bool> updateAnnouncement({
    required String announcementId,
    String? title,
    String? content,
    DateTime? expiresAt,
    String? priority,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (expiresAt != null)
        updates['expiresAt'] = Timestamp.fromDate(expiresAt);
      if (priority != null) updates['priority'] = priority;
      if (isActive != null) updates['isActive'] = isActive;

      await _announcementsCollection.doc(announcementId).update(updates);
      return true;
    } catch (e) {
      _logger.e('❌ Failed to update announcement: $e');
      return false;
    }
  }

  /// Delete announcement
  Future<bool> deleteAnnouncement(String announcementId) async {
    try {
      await _announcementsCollection.doc(announcementId).delete();
      return true;
    } catch (e) {
      _logger.e('❌ Failed to delete announcement: $e');
      return false;
    }
  }
}

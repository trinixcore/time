import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/moments_service.dart';
import '../../../core/models/moment_media_model.dart';
import '../../../core/models/announcement_model.dart';
import 'dart:typed_data';

part 'moments_providers.g.dart';

// Service provider
@riverpod
MomentsService momentsService(MomentsServiceRef ref) {
  return MomentsService();
}

// Moment Media Providers
@riverpod
Future<List<MomentMedia>> activeMomentMedia(ActiveMomentMediaRef ref) async {
  final service = ref.watch(momentsServiceProvider);
  return await service.getActiveMomentMedia();
}

@riverpod
class MomentMediaUpload extends _$MomentMediaUpload {
  @override
  FutureOr<void> build() {}

  Future<MomentMedia?> uploadMedia({
    required String fileName,
    required List<int> fileBytes,
    required MediaType mediaType,
    required String uploadedBy,
    String? title,
    String? description,
  }) async {
    state = AsyncValue.loading();

    try {
      final service = ref.read(momentsServiceProvider);
      final media = await service.uploadMomentMedia(
        fileName: fileName,
        fileBytes: Uint8List.fromList(fileBytes),
        mediaType: mediaType,
        uploadedBy: uploadedBy,
        title: title,
        description: description,
      );

      if (media != null) {
        // Invalidate the list provider
        ref.invalidate(activeMomentMediaProvider);
        state = AsyncValue.data(null);
        return media;
      } else {
        state = AsyncValue.error('Failed to upload media', StackTrace.current);
        return null;
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
}

@riverpod
class MomentMediaDelete extends _$MomentMediaDelete {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteMedia(String mediaId) async {
    state = AsyncValue.loading();

    try {
      final service = ref.read(momentsServiceProvider);
      final success = await service.deleteMomentMedia(mediaId);

      if (success) {
        // Invalidate the list provider
        ref.invalidate(activeMomentMediaProvider);
        state = AsyncValue.data(null);
        return true;
      } else {
        state = AsyncValue.error('Failed to delete media', StackTrace.current);
        return false;
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

// Announcement Providers
@riverpod
Future<List<Announcement>> activeAnnouncements(
  ActiveAnnouncementsRef ref,
) async {
  final service = ref.watch(momentsServiceProvider);
  return await service.getActiveAnnouncements();
}

@riverpod
class AnnouncementCreate extends _$AnnouncementCreate {
  @override
  FutureOr<void> build() {}

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
    state = AsyncValue.loading();

    try {
      final service = ref.read(momentsServiceProvider);
      final announcement = await service.createAnnouncement(
        title: title,
        content: content,
        createdBy: createdBy,
        expiresAt: expiresAt,
        priority: priority,
        category: category,
        tags: tags,
        richContent: richContent,
        attachments: attachments,
        targetDepartments: targetDepartments,
        targetRoles: targetRoles,
        isGlobal: isGlobal,
        requiresAcknowledgment: requiresAcknowledgment,
        maxViews: maxViews,
        createdByName: createdByName,
      );

      if (announcement != null) {
        // Invalidate the list provider
        ref.invalidate(activeAnnouncementsProvider);
        state = AsyncValue.data(null);
        return announcement;
      } else {
        state = AsyncValue.error(
          'Failed to create announcement',
          StackTrace.current,
        );
        return null;
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
}

@riverpod
class AnnouncementUpdate extends _$AnnouncementUpdate {
  @override
  FutureOr<void> build() {}

  Future<bool> updateAnnouncement({
    required String announcementId,
    String? title,
    String? content,
    DateTime? expiresAt,
    String? priority,
    bool? isActive,
  }) async {
    state = AsyncValue.loading();

    try {
      final service = ref.read(momentsServiceProvider);
      final success = await service.updateAnnouncement(
        announcementId: announcementId,
        title: title,
        content: content,
        expiresAt: expiresAt,
        priority: priority,
        isActive: isActive,
      );

      if (success) {
        // Invalidate the list provider
        ref.invalidate(activeAnnouncementsProvider);
        state = AsyncValue.data(null);
        return true;
      } else {
        state = AsyncValue.error(
          'Failed to update announcement',
          StackTrace.current,
        );
        return false;
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

@riverpod
class AnnouncementDelete extends _$AnnouncementDelete {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteAnnouncement(String announcementId) async {
    state = AsyncValue.loading();

    try {
      final service = ref.read(momentsServiceProvider);
      final success = await service.deleteAnnouncement(announcementId);

      if (success) {
        // Invalidate the list provider
        ref.invalidate(activeAnnouncementsProvider);
        state = AsyncValue.data(null);
        return true;
      } else {
        state = AsyncValue.error(
          'Failed to delete announcement',
          StackTrace.current,
        );
        return false;
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

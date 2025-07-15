import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/task_document_service.dart';
import '../../../core/models/task_document_model.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../core/services/audit_log_service.dart';

// Service provider
final taskDocumentServiceProvider = Provider<TaskDocumentService>((ref) {
  return TaskDocumentService();
});

// Task documents provider
final taskDocumentsProvider =
    StreamProvider.family<List<TaskDocumentModel>, String>((ref, taskId) {
      final service = ref.watch(taskDocumentServiceProvider);
      return Stream.fromFuture(service.getTaskDocuments(taskId));
    });

// Upload task document provider
final uploadTaskDocumentProvider = StateNotifierProvider<
  UploadTaskDocumentNotifier,
  AsyncValue<TaskDocumentModel?>
>((ref) {
  final service = ref.watch(taskDocumentServiceProvider);
  return UploadTaskDocumentNotifier(service, ref);
});

// Delete task document provider
final deleteTaskDocumentProvider =
    StateNotifierProvider<DeleteTaskDocumentNotifier, AsyncValue<void>>((ref) {
      final service = ref.watch(taskDocumentServiceProvider);
      return DeleteTaskDocumentNotifier(service, ref);
    });

// Task document URL provider
final taskDocumentUrlProvider = FutureProvider.family<String, String>((
  ref,
  documentId,
) {
  final service = ref.watch(taskDocumentServiceProvider);
  return service.getTaskDocumentUrl(documentId);
});

class UploadTaskDocumentNotifier
    extends StateNotifier<AsyncValue<TaskDocumentModel?>> {
  final TaskDocumentService _service;
  final Ref _ref;

  UploadTaskDocumentNotifier(this._service, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> uploadDocument({
    required String taskId,
    required String fileName,
    required Uint8List bytes,
    String? description,
    List<String>? tags,
    Function(double progress, String status)? onProgress,
  }) async {
    state = const AsyncValue.loading();

    try {
      final currentUser = await _ref.read(currentUserProvider.future);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final document = await _service.uploadTaskDocument(
        bytes: bytes,
        fileName: fileName,
        taskId: taskId,
        uploadedBy: currentUser.uid,
        uploadedByName:
            currentUser.displayName ?? currentUser.email ?? 'Unknown',
        description: description,
        tags: tags,
        onProgress: onProgress,
      );

      // Audit log for task document upload
      await AuditLogService().logEvent(
        action: 'TASK_DOCUMENT_UPLOAD',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
        userEmail: currentUser.email,
        status: 'success',
        targetType: 'task',
        targetId: taskId,
        details: {
          'documentId': document.id,
          'documentFileName': document.fileName,
          'documentSizeBytes': document.fileSizeBytes,
          'documentDescription': description,
          'documentTags': tags,
        },
      );

      state = AsyncValue.data(document);

      // Invalidate the task documents stream to refresh the list
      _ref.invalidate(taskDocumentsProvider(taskId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

class DeleteTaskDocumentNotifier extends StateNotifier<AsyncValue<void>> {
  final TaskDocumentService _service;
  final Ref _ref;

  DeleteTaskDocumentNotifier(this._service, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> deleteDocument(String documentId, String taskId) async {
    state = const AsyncValue.loading();

    try {
      await _service.deleteTaskDocument(documentId);
      state = const AsyncValue.data(null);

      // Invalidate the task documents stream to refresh the list
      _ref.invalidate(taskDocumentsProvider(taskId));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

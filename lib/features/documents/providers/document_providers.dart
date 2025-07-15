import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/document_model.dart';
import '../../../core/models/folder_model.dart';
import '../../../core/enums/document_enums.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/services/document_management_service.dart';
import '../../../core/services/firebase_document_service.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../core/services/permission_management_service.dart';
import '../../../core/services/audit_log_service.dart';
import '../../../core/utils/logger.dart';

part 'document_providers.g.dart';

// Query classes for parameters
class DocumentQuery {
  final String? folderId;
  final DocumentCategory? category;
  final String? searchTerm;
  final int? limit;

  const DocumentQuery({
    this.folderId,
    this.category,
    this.searchTerm,
    this.limit,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentQuery &&
          runtimeType == other.runtimeType &&
          folderId == other.folderId &&
          category == other.category &&
          searchTerm == other.searchTerm &&
          limit == other.limit;

  @override
  int get hashCode =>
      folderId.hashCode ^
      category.hashCode ^
      searchTerm.hashCode ^
      limit.hashCode;
}

class FolderQuery {
  final String? parentId;
  final DocumentCategory? category;
  final int? limit;

  const FolderQuery({this.parentId, this.category, this.limit});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FolderQuery &&
          runtimeType == other.runtimeType &&
          parentId == other.parentId &&
          category == other.category &&
          limit == other.limit;

  @override
  int get hashCode => parentId.hashCode ^ category.hashCode ^ limit.hashCode;
}

// Document Management Service Provider
@riverpod
DocumentManagementService documentManagementService(
  DocumentManagementServiceRef ref,
) {
  return DocumentManagementService();
}

// Firebase Document Service Provider
@riverpod
FirebaseDocumentService firebaseDocumentService(
  FirebaseDocumentServiceRef ref,
) {
  return FirebaseDocumentService();
}

// Documents Provider
@riverpod
Stream<List<DocumentModel>> documents(DocumentsRef ref, DocumentQuery query) {
  final service = ref.watch(documentManagementServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  return currentUser.when(
    data: (user) {
      if (user == null) return Stream.value([]);

      if (query.searchTerm != null && query.searchTerm!.isNotEmpty) {
        // Search documents
        return Stream.fromFuture(
          service.searchDocuments(
            searchTerm: query.searchTerm!,
            userId: user.uid,
            userRole: user.role,
            category: query.category,
            limit: query.limit,
          ),
        );
      } else {
        // Stream documents
        return service.streamDocuments(
          userRole: user.role,
          userId: user.uid,
          category: query.category,
          folderId: query.folderId,
          limit: query.limit,
        );
      }
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
}

// Folders Provider
@riverpod
Stream<List<FolderModel>> folders(FoldersRef ref, FolderQuery query) {
  final service = ref.watch(documentManagementServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  return currentUser.when(
    data: (user) {
      if (user == null) return Stream.value([]);

      return service.streamFolders(
        userRole: user.role,
        parentId: query.parentId,
        category: query.category,
        limit: query.limit,
      );
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
}

// Single Document Provider
@riverpod
Future<DocumentModel?> document(DocumentRef ref, String documentId) {
  final firebaseService = ref.watch(firebaseDocumentServiceProvider);
  return firebaseService.getDocument(documentId);
}

// Single Folder Provider
@riverpod
Future<FolderModel?> folder(FolderRef ref, String folderId) {
  final firebaseService = ref.watch(firebaseDocumentServiceProvider);
  return firebaseService.getFolder(folderId);
}

// Document Statistics Provider
@riverpod
Future<Map<String, dynamic>> documentStatistics(
  DocumentStatisticsRef ref, {
  DocumentCategory? category,
}) {
  final service = ref.watch(documentManagementServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  return currentUser.when(
    data: (user) async {
      if (user == null) return <String, dynamic>{};

      return service.getDocumentStatistics(
        userRole: user.role,
        userId: user.uid,
        category: category,
      );
    },
    loading: () async => <String, dynamic>{},
    error: (_, __) async => <String, dynamic>{},
  );
}

// Upload Document Provider
@riverpod
class UploadDocument extends _$UploadDocument {
  @override
  AsyncValue<DocumentModel?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> uploadFile({
    required File file,
    required DocumentCategory category,
    required DocumentAccessLevel accessLevel,
    String? description,
    String? folderId,
    List<String>? tags,
    bool requiresApproval = false,
  }) async {
    AppLogger.upload('Starting upload process...');
    AppLogger.upload('File: ${file.path}');
    AppLogger.upload('Category: ${category.displayName}');
    AppLogger.upload('Access level: ${accessLevel.displayName}');

    final service = ref.read(documentManagementServiceProvider);
    final currentUser = await ref.read(currentUserProvider.future);

    AppLogger.upload('Current user: ${currentUser?.displayName ?? 'null'}');

    if (currentUser == null) {
      AppLogger.uploadError('User not authenticated');
      state = const AsyncValue.error(
        'User not authenticated',
        StackTrace.empty,
      );
      return;
    }

    AppLogger.uploadSuccess('User authenticated, proceeding with upload...');
    state = const AsyncValue.loading();

    try {
      AppLogger.upload('Calling document management service...');

      final document = await service.uploadDocument(
        file: file,
        uploadedBy: currentUser.uid,
        uploadedByName: currentUser.displayName ?? 'Unknown',
        uploaderRole: currentUser.role ?? UserRole.employee,
        category: category,
        accessLevel: accessLevel,
        description: description,
        folderId: folderId,
        tags: tags,
        requiresApproval: requiresApproval,
      );

      AppLogger.uploadSuccess('Document uploaded successfully: ${document.id}');
      state = AsyncValue.data(document);

      // Audit log for document upload
      await AuditLogService().logEvent(
        action: 'DOCUMENT_UPLOAD',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Unknown',
        userEmail: currentUser.email,
        status: 'success',
        targetType: 'document',
        targetId: document.id,
        details: {
          'documentFileName': document.fileName,
          'documentCategory': category.value,
          'documentAccessLevel': accessLevel.value,
          'documentSizeBytes': document.fileSizeBytes,
          'documentFileType': document.fileType.extension,
          'documentDescription': description,
          'documentFolderId': folderId,
          'documentTags': tags,
          'requiresApproval': requiresApproval,
          'uploadMethod': 'file',
        },
      );

      // Invalidate related providers
      AppLogger.upload('Invalidating related providers...');
      ref.invalidate(documentsProvider);
      ref.invalidate(documentStatisticsProvider);
      AppLogger.uploadSuccess('Providers invalidated');
    } catch (error, stackTrace) {
      AppLogger.uploadError('Upload provider error: $error');
      AppLogger.uploadError('Stack trace: $stackTrace');

      // Convert to user-friendly error message
      final userFriendlyMessage = service.getUserFriendlyErrorMessage(error);
      AppLogger.upload('User-friendly error message: $userFriendlyMessage');

      state = AsyncValue.error(userFriendlyMessage, stackTrace);
    }
  }

  Future<void> uploadFromBytes({
    required Uint8List bytes,
    required String fileName,
    required DocumentCategory category,
    required DocumentAccessLevel accessLevel,
    String? description,
    String? folderId,
    List<String>? tags,
    bool requiresApproval = false,
  }) async {
    AppLogger.upload('Starting upload from bytes...');
    AppLogger.upload('File: $fileName');
    AppLogger.upload('Category: ${category.displayName}');
    AppLogger.upload('Access level: ${accessLevel.displayName}');
    AppLogger.upload('File size: ${bytes.length} bytes');

    final service = ref.read(documentManagementServiceProvider);
    final currentUser = await ref.read(currentUserProvider.future);

    AppLogger.upload('Current user: ${currentUser?.displayName ?? 'null'}');

    if (currentUser == null) {
      AppLogger.uploadError('User not authenticated');
      state = const AsyncValue.error(
        'User not authenticated',
        StackTrace.empty,
      );
      return;
    }

    AppLogger.uploadSuccess('User authenticated, proceeding with upload...');
    state = const AsyncValue.loading();

    try {
      AppLogger.upload('Calling document management service...');

      final document = await service.uploadDocumentFromBytes(
        bytes: bytes,
        fileName: fileName,
        uploadedBy: currentUser.uid,
        uploadedByName: currentUser.displayName ?? 'Unknown',
        uploaderRole: currentUser.role ?? UserRole.employee,
        category: category,
        accessLevel: accessLevel,
        description: description,
        folderId: folderId,
        tags: tags,
        requiresApproval: requiresApproval,
      );

      AppLogger.uploadSuccess('Document uploaded successfully: ${document.id}');
      state = AsyncValue.data(document);

      // Audit log for document upload
      await AuditLogService().logEvent(
        action: 'DOCUMENT_UPLOAD',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Unknown',
        userEmail: currentUser.email,
        status: 'success',
        targetType: 'document',
        targetId: document.id,
        details: {
          'documentFileName': document.fileName,
          'documentCategory': category.value,
          'documentAccessLevel': accessLevel.value,
          'documentSizeBytes': document.fileSizeBytes,
          'documentFileType': document.fileType.extension,
          'documentDescription': description,
          'documentFolderId': folderId,
          'documentTags': tags,
          'requiresApproval': requiresApproval,
          'uploadMethod': 'bytes',
        },
      );

      // Invalidate related providers
      AppLogger.upload('Invalidating related providers...');
      ref.invalidate(documentsProvider);
      ref.invalidate(documentStatisticsProvider);
      AppLogger.uploadSuccess('Providers invalidated');
    } catch (error, stackTrace) {
      AppLogger.uploadError('Upload provider error: $error');
      AppLogger.uploadError('Stack trace: $stackTrace');

      // Convert to user-friendly error message
      final userFriendlyMessage = service.getUserFriendlyErrorMessage(error);
      AppLogger.upload('User-friendly error message: $userFriendlyMessage');

      state = AsyncValue.error(userFriendlyMessage, stackTrace);
    }
  }
}

// Create Folder Provider
@riverpod
class CreateFolder extends _$CreateFolder {
  @override
  AsyncValue<FolderModel?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> create({
    required String name,
    required DocumentCategory category,
    required DocumentAccessLevel accessLevel,
    String? parentId,
    String? description,
    List<String>? tags,
  }) async {
    final service = ref.read(documentManagementServiceProvider);
    final currentUser = await ref.read(currentUserProvider.future);

    if (currentUser == null) {
      state = const AsyncValue.error(
        'User not authenticated',
        StackTrace.empty,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      final folder = await service.createFolder(
        name: name,
        createdBy: currentUser.uid,
        createdByName: currentUser.displayName ?? 'Unknown',
        creatorRole: currentUser.role ?? UserRole.employee,
        category: category,
        accessLevel: accessLevel,
        parentId: parentId,
        description: description,
        tags: tags,
      );

      state = AsyncValue.data(folder);

      // Invalidate related providers
      ref.invalidate(foldersProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Document Actions Provider
@riverpod
class DocumentActions extends _$DocumentActions {
  @override
  AsyncValue<String?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> downloadDocument(String documentId) async {
    final service = ref.read(documentManagementServiceProvider);
    final currentUser = await ref.read(currentUserProvider.future);

    if (currentUser == null) {
      state = const AsyncValue.error(
        'User not authenticated',
        StackTrace.empty,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      final bytes = await service.downloadDocument(
        documentId: documentId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Unknown',
        userRole: currentUser.role ?? UserRole.employee,
      );

      // Audit log for document download
      await AuditLogService().logEvent(
        action: 'DOCUMENT_DOWNLOAD',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Unknown',
        userEmail: currentUser.email,
        status: 'success',
        targetType: 'document',
        targetId: documentId,
        details: {'downloadMethod': 'bytes', 'downloadSizeBytes': bytes.length},
      );

      // Here you would typically save the file or trigger a download
      // For now, we'll just indicate success
      state = const AsyncValue.data('Downloaded successfully');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteDocument(String documentId) async {
    final service = ref.read(documentManagementServiceProvider);
    final currentUser = await ref.read(currentUserProvider.future);

    if (currentUser == null) {
      state = const AsyncValue.error(
        'User not authenticated',
        StackTrace.empty,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      await service.deleteDocument(
        documentId: documentId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Unknown',
        userRole: currentUser.role ?? UserRole.employee,
      );

      // Audit log for document deletion
      await AuditLogService().logEvent(
        action: 'DOCUMENT_DELETE',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Unknown',
        userEmail: currentUser.email,
        status: 'success',
        targetType: 'document',
        targetId: documentId,
        details: {'deletionMethod': 'permanent'},
      );

      state = const AsyncValue.data('Deleted successfully');

      // Invalidate related providers
      ref.invalidate(documentsProvider);
      ref.invalidate(documentStatisticsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> approveDocument(String documentId) async {
    final service = ref.read(documentManagementServiceProvider);
    final currentUser = await ref.read(currentUserProvider.future);

    if (currentUser == null) {
      state = const AsyncValue.error(
        'User not authenticated',
        StackTrace.empty,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      await service.approveDocument(
        documentId: documentId,
        approvedBy: currentUser.uid,
        approvedByName: currentUser.displayName ?? 'Unknown',
        approverRole: currentUser.role ?? UserRole.employee,
      );

      // Audit log for document approval
      await AuditLogService().logEvent(
        action: 'DOCUMENT_APPROVE',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Unknown',
        userEmail: currentUser.email,
        status: 'success',
        targetType: 'document',
        targetId: documentId,
        details: {'approvalMethod': 'manual'},
      );

      state = const AsyncValue.data('Approved successfully');

      // Invalidate related providers
      ref.invalidate(documentsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> rejectDocument(String documentId, String reason) async {
    final service = ref.read(documentManagementServiceProvider);
    final currentUser = await ref.read(currentUserProvider.future);

    if (currentUser == null) {
      state = const AsyncValue.error(
        'User not authenticated',
        StackTrace.empty,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      await service.rejectDocument(
        documentId: documentId,
        rejectedBy: currentUser.uid,
        rejectedByName: currentUser.displayName ?? 'Unknown',
        rejecterRole: currentUser.role ?? UserRole.employee,
        reason: reason,
      );

      // Audit log for document rejection
      await AuditLogService().logEvent(
        action: 'DOCUMENT_REJECT',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Unknown',
        userEmail: currentUser.email,
        status: 'success',
        targetType: 'document',
        targetId: documentId,
        details: {'rejectionMethod': 'manual', 'rejectionReason': reason},
      );

      state = const AsyncValue.data('Rejected successfully');

      // Invalidate related providers
      ref.invalidate(documentsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<String> getDocumentSignedUrl(String documentId) async {
    // print('🎬 [PROVIDER DEBUG] Starting getDocumentSignedUrl in provider');
    // print('🎬 [PROVIDER DEBUG] Document ID: $documentId');

    final service = ref.read(documentManagementServiceProvider);
    // print('🎬 [PROVIDER DEBUG] Document management service obtained');

    final currentUser = await ref.read(currentUserProvider.future);
    // print('🎬 [PROVIDER DEBUG] Current user: ${currentUser?.email ?? 'null'}');
    // print(
    //   '🎬 [PROVIDER DEBUG] User role: ${currentUser?.role?.value ?? 'null'}',
    // );

    if (currentUser == null) {
      // print('❌ [PROVIDER DEBUG] User not authenticated');
      throw Exception('User not authenticated');
    }

    try {
      // print('🎬 [PROVIDER DEBUG] Calling service.getDocumentSignedUrl...');
      final result = await service.getDocumentSignedUrl(
        documentId: documentId,
        userId: currentUser.uid,
        userRole: currentUser.role ?? UserRole.employee,
      );

      // Audit log for document access/view
      await AuditLogService().logEvent(
        action: 'DOCUMENT_ACCESS',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Unknown',
        userEmail: currentUser.email,
        status: 'success',
        targetType: 'document',
        targetId: documentId,
        details: {
          'accessMethod': 'signed_url',
          'signedUrlLength': result.length,
        },
      );

      // print('✅ [PROVIDER DEBUG] Service call successful');
      // print('🎬 [PROVIDER DEBUG] Returned URL length: ${result.length}');
      return result;
    } catch (error, stackTrace) {
      // print('💥 [PROVIDER DEBUG] Service call failed: $error');
      // print('📚 [PROVIDER DEBUG] Stack trace: $stackTrace');
      throw Exception('Failed to get document URL: $error');
    }
  }

  Future<void> downloadDocumentWithUrl(String documentId) async {
    final service = ref.read(documentManagementServiceProvider);
    final currentUser = await ref.read(currentUserProvider.future);

    if (currentUser == null) {
      state = const AsyncValue.error(
        'User not authenticated',
        StackTrace.empty,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      final signedUrl = await service.getDocumentSignedUrl(
        documentId: documentId,
        userId: currentUser.uid,
        userRole: currentUser.role ?? UserRole.employee,
      );

      // For web, we can open the URL directly
      state = AsyncValue.data(signedUrl);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Permission Providers for Employee Folders
@riverpod
Future<bool> canUploadToEmployeeFolder(
  CanUploadToEmployeeFolderRef ref,
  UserRole role,
  String folderCode,
  String folderName,
) async {
  final permissionService = ref.watch(permissionManagementServiceProvider);
  return await permissionService.canUploadToEmployeeFolder(
    role,
    folderCode,
    folderName,
  );
}

@riverpod
Future<bool> canViewEmployeeFolder(
  CanViewEmployeeFolderRef ref,
  UserRole role,
  String folderCode,
  String folderName, {
  String? currentUserEmployeeId,
  String? targetEmployeeId,
}) async {
  final permissionService = ref.watch(permissionManagementServiceProvider);
  return await permissionService.canViewEmployeeFolder(
    role,
    folderCode,
    folderName,
    currentUserEmployeeId: currentUserEmployeeId,
    targetEmployeeId: targetEmployeeId,
  );
}

@riverpod
Future<bool> canDeleteFromEmployeeFolder(
  CanDeleteFromEmployeeFolderRef ref,
  UserRole role,
  String folderCode,
  String folderName,
) async {
  final permissionService = ref.watch(permissionManagementServiceProvider);
  return await permissionService.canDeleteFromEmployeeFolder(
    role,
    folderCode,
    folderName,
  );
}

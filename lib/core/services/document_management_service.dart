import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document_model.dart';
import '../models/folder_model.dart';
import '../enums/user_role.dart';
import '../enums/document_enums.dart';
import '../utils/document_permissions.dart';
import '../services/permission_management_service.dart';
import 'firebase_document_service.dart';
import 'supabase_service.dart';
import '../config/supabase_config.dart';

class DocumentManagementService {
  static final DocumentManagementService _instance =
      DocumentManagementService._internal();

  factory DocumentManagementService() {
    return _instance;
  }

  DocumentManagementService._internal();

  final FirebaseDocumentService _firebaseService = FirebaseDocumentService();
  final SupabaseService _supabaseService = SupabaseService();
  final PermissionManagementService _permissionService =
      PermissionManagementService();
  final Uuid _uuid = const Uuid();

  // Permission cache with expiry
  static final Map<String, Map<String, dynamic>> _permissionCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 15);

  /// Check if user has permission with caching
  Future<bool> _hasPermissionCached(String userId, String permission) async {
    final cacheKey = '${userId}_$permission';
    final now = DateTime.now();

    // Check if cache is valid
    if (_permissionCache.containsKey(cacheKey) &&
        _cacheTimestamps.containsKey(cacheKey) &&
        now.difference(_cacheTimestamps[cacheKey]!) < _cacheExpiry) {
      print('📋 Using cached permission for $permission');
      return _permissionCache[cacheKey]![permission] ?? false;
    }

    // Fetch fresh permissions
    final hasPermission = await _checkUserPermission(userId, permission);

    // Update cache
    _permissionCache[cacheKey] = {permission: hasPermission};
    _cacheTimestamps[cacheKey] = now;

    print('🔄 Cached permission for $permission: $hasPermission');
    return hasPermission;
  }

  /// Clear permission cache for a user
  static void clearUserPermissionCache(String userId) {
    _permissionCache.removeWhere((key, value) => key.startsWith(userId));
    _cacheTimestamps.removeWhere((key, value) => key.startsWith(userId));
    print('🗑️ Cleared permission cache for user: $userId');
  }

  /// Check user permission (placeholder implementation)
  Future<bool> _checkUserPermission(String userId, String permission) async {
    // This would typically check against your user permissions system
    // For now, return true for super_admin and admin roles
    try {
      // You can implement actual permission checking logic here
      // This is a simplified version
      return true; // Placeholder - implement actual permission logic
    } catch (e) {
      print('⚠️ Error checking permission: $e');
      return false;
    }
  }

  /// Batch upload multiple documents
  Future<List<DocumentModel>> batchUploadDocuments({
    required List<Map<String, dynamic>> uploadRequests,
    required String uploadedBy,
    required String uploaderName,
    required UserRole uploaderRole,
  }) async {
    print('📦 Starting batch upload of ${uploadRequests.length} documents');

    final results = <DocumentModel>[];
    final errors = <String>[];

    // Process uploads in parallel (max 3 concurrent)
    const maxConcurrent = 3;
    for (int i = 0; i < uploadRequests.length; i += maxConcurrent) {
      final batch = uploadRequests.skip(i).take(maxConcurrent);
      final futures = batch.map((request) async {
        try {
          return await uploadDocumentFromBytes(
            bytes: request['bytes'],
            fileName: request['fileName'],
            category: request['category'],
            accessLevel: request['accessLevel'],
            uploadedBy: uploadedBy,
            uploadedByName: uploaderName,
            uploaderRole: uploaderRole,
          );
        } catch (e) {
          errors.add('${request['fileName']}: $e');
          return null;
        }
      });

      final batchResults = await Future.wait(futures);
      results.addAll(batchResults.whereType<DocumentModel>());
    }

    print(
      '✅ Batch upload completed: ${results.length} successful, ${errors.length} failed',
    );
    if (errors.isNotEmpty) {
      print('❌ Batch upload errors: ${errors.join(', ')}');
    }

    return results;
  }

  /// Upload a document with metadata
  Future<DocumentModel> uploadDocument({
    required File file,
    required String uploadedBy,
    required String uploadedByName,
    required UserRole uploaderRole,
    required DocumentCategory category,
    required DocumentAccessLevel accessLevel,
    String? description,
    String? folderId,
    List<String>? tags,
    List<String>? additionalAccessRoles,
    List<String>? additionalAccessUserIds,
    bool requiresApproval = false,
  }) async {
    try {
      //print('🏗️ DocumentManagementService: Starting upload process...');
      //print('📁 File: ${file.path}');
      //print('👤 Uploaded by: $uploadedByName ($uploadedBy)');
      //print('🎭 Role: ${uploaderRole.value}');
      //print('📂 Category: ${category.displayName}');

      // Check permissions
      print('🔐 Checking permissions...');
      final permissions = await _permissionService.getEffectivePermissionsAsync(
        uploaderRole,
      );

      // Check if user can upload to this specific category
      bool canUpload = permissions.canUploadToCategory(category);

      // Special handling for employee category with folder-specific permissions
      if (!canUpload &&
          category == DocumentCategory.employee &&
          folderId != null) {
        print(
          '🔍 [PERMISSION CHECK] Checking folder-specific employee permissions...',
        );

        // Extract folder info from folderId (which should be the folder path for employee documents)
        final folderInfo = _permissionService.extractFolderInfo(folderId);
        if (folderInfo != null) {
          print(
            '🔍 [PERMISSION CHECK] Checking upload permission for folder: ${folderInfo['code']}_${folderInfo['name']}',
          );
          canUpload = await _permissionService.canUploadToEmployeeFolder(
            uploaderRole,
            folderInfo['code']!,
            folderInfo['name']!,
          );
          print(
            '📋 [PERMISSION CHECK] Folder-specific upload permission: $canUpload',
          );
        }
      }

      if (!canUpload) {
        print(
          '❌ Upload permission denied - user cannot upload to category: ${category.value}',
        );
        if (category == DocumentCategory.employee) {
          print(
            '❌ User does not have upload permission for employee documents',
          );
          final config = await _permissionService.getPermissionConfig(
            uploaderRole,
          );
          if (config != null) {
            final uploadableCategories = config
                .documentConfig
                .uploadableCategories
                .map((c) => c.value)
                .join(', ');
            print('📋 User uploadable categories: $uploadableCategories');
          }
        }

        if (permissions.canUploadToAll) {
          throw Exception(
            'You do not have access to upload to the "${category.displayName}" category. Please contact your administrator.',
          );
        } else {
          throw Exception(
            'You do not have permission to upload documents to the "${category.displayName}" category. Please contact your administrator.',
          );
        }
      }

      print('✅ Upload permission granted for category: ${category.value}');

      // Read file
      print('📖 Reading file...');
      final fileBytes = await file.readAsBytes();
      final fileName = path.basename(file.path);
      print('📄 File name: $fileName');
      print('📊 File size: ${fileBytes.length} bytes');

      // Enhanced file validation with content scanning
      print('🔍 Enhanced file validation...');

      // Check file signature/magic bytes for PDF
      if (fileName.toLowerCase().endsWith('.pdf')) {
        if (fileBytes.length < 4 ||
            !(fileBytes[0] == 0x25 &&
                fileBytes[1] == 0x50 &&
                fileBytes[2] == 0x44 &&
                fileBytes[3] == 0x46)) {
          throw Exception('Invalid PDF file: File signature mismatch');
        }
        print('✅ PDF signature validated');
      }

      // Check for suspicious file patterns
      final suspiciousPatterns = [
        'javascript:',
        'vbscript:',
        '<script',
        'eval(',
        'document.cookie',
      ];

      final fileContent = String.fromCharCodes(
        fileBytes.take(1024),
      ); // Check first 1KB
      for (final pattern in suspiciousPatterns) {
        if (fileContent.toLowerCase().contains(pattern.toLowerCase())) {
          throw Exception('File contains potentially malicious content');
        }
      }

      // Validate file size against dynamic permissions
      if (fileBytes.length > permissions.maxFileSizeMB * 1024 * 1024) {
        throw Exception(
          'File size (${(fileBytes.length / 1024 / 1024).toStringAsFixed(2)} MB) '
          'exceeds limit for role ${uploaderRole.displayName} '
          '(${permissions.maxFileSizeMB} MB)',
        );
      }

      // Validate file
      final fileExtension = path.extension(fileName).toLowerCase();
      final fileType = DocumentFileType.fromExtension(fileExtension);

      if (!permissions.isFileTypeAllowed(fileType)) {
        throw Exception('File type not allowed for this user role');
      }

      // Validate file size (using dynamic permissions)
      if (!permissions.isFileSizeAllowed(fileBytes.length)) {
        throw Exception(
          'File size exceeds maximum allowed size of ${permissions.maxFileSizeMB}MB',
        );
      }

      // Generate unique document ID
      final documentId = _uuid.v4();
      print('🆔 Generated document ID: $documentId');

      // Generate storage path
      print('🗂️ Generating storage path...');
      final storagePath = _supabaseService.generateDocumentPath(
        category: category.value,
        userId: uploadedBy,
        folderId: folderId,
      );
      print('📍 Storage path: $storagePath');

      // Upload to Supabase
      print('☁️ Uploading to Supabase...');
      final supabasePath = await _supabaseService.uploadFile(
        filePath: storagePath,
        file: file,
        contentType: _supabaseService.getMimeType(fileName),
      );
      print('✅ Supabase upload completed: $supabasePath');

      // Calculate checksum
      print('🔐 Calculating checksum...');
      final checksum = _supabaseService.calculateChecksum(fileBytes);
      print('✅ Checksum: $checksum');

      // Determine access roles and users
      final accessRoles = <String>[uploaderRole.value];
      if (additionalAccessRoles != null) {
        accessRoles.addAll(additionalAccessRoles);
      }

      final accessUserIds = <String>[uploadedBy];
      if (additionalAccessUserIds != null) {
        accessUserIds.addAll(additionalAccessUserIds);
      }

      print('👥 Access roles: $accessRoles');
      print('👤 Access user IDs: $accessUserIds');

      // Create document model
      print('📋 Creating document model...');
      final document = DocumentModel(
        id: documentId,
        fileName: fileName,
        originalFileName: fileName,
        supabasePath: supabasePath,
        firebasePath: 'documents/$documentId',
        category: category,
        fileType: fileType,
        status:
            requiresApproval ? DocumentStatus.pending : DocumentStatus.approved,
        accessLevel: accessLevel,
        uploadedBy: uploadedBy,
        uploadedByName: uploadedByName,
        uploadedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        fileSizeBytes: fileBytes.length,
        accessRoles: accessRoles,
        accessUserIds: accessUserIds,
        description: description,
        folderId: folderId,
        mimeType: _supabaseService.getMimeType(fileName),
        checksum: checksum,
        tags: tags,
        requiresApproval: requiresApproval,
        isConfidential:
            accessLevel == DocumentAccessLevel.confidential ||
            accessLevel == DocumentAccessLevel.private,
      );

      // Save metadata to Firebase
      print('🔥 Saving metadata to Firebase...');
      final firebaseDocId = await _firebaseService.createDocument(document);
      print('✅ Firebase document created: $firebaseDocId');

      // Update document with Firebase ID
      print('🔄 Updating document with Firebase ID...');
      final updatedDocument = document.copyWith(id: firebaseDocId);
      await _firebaseService.updateDocument(firebaseDocId, updatedDocument);
      print('✅ Document updated in Firebase');

      // Log the upload
      print('📝 Logging document access...');
      await _firebaseService.logDocumentAccess(
        documentId: firebaseDocId,
        userId: uploadedBy,
        userName: uploadedByName,
        action: 'upload',
      );
      print('✅ Access logged');

      // Enhanced audit logging with performance metrics
      final uploadStartTime = DateTime.now();
      print('⏱️ Upload started at: ${uploadStartTime.toIso8601String()}');

      // Log security event
      await _logSecurityEvent(
        userId: uploadedBy,
        userName: uploadedByName,
        action: 'DOCUMENT_UPLOAD_ATTEMPT',
        details: {
          'fileName': fileName,
          'fileSize': fileBytes.length,
          'category': category.value,
          'accessLevel': accessLevel.value,
          'userRole': uploaderRole.value,
          'ipAddress': 'web_client', // Could be enhanced with actual IP
          'userAgent':
              'flutter_web', // Could be enhanced with actual user agent
        },
      );

      // Log successful upload with performance metrics
      final uploadEndTime = DateTime.now();
      final uploadDuration = uploadEndTime.difference(uploadStartTime);

      print('⏱️ Upload completed at: ${uploadEndTime.toIso8601String()}');
      print('⚡ Upload duration: ${uploadDuration.inMilliseconds}ms');
      print(
        '📈 Upload speed: ${(fileBytes.length / uploadDuration.inSeconds / 1024 / 1024).toStringAsFixed(2)} MB/s',
      );

      await _logSecurityEvent(
        userId: uploadedBy,
        userName: uploadedByName,
        action: 'DOCUMENT_UPLOAD_SUCCESS',
        details: {
          'documentId': document.id,
          'fileName': fileName,
          'fileSize': fileBytes.length,
          'uploadDurationMs': uploadDuration.inMilliseconds,
          'uploadSpeedMBps':
              fileBytes.length / uploadDuration.inSeconds / 1024 / 1024,
          'checksum': checksum,
          'supabasePath': supabasePath,
        },
      );

      print('🎉 Document upload completed successfully!');
      return updatedDocument;
    } catch (e, stackTrace) {
      print('💥 DocumentManagementService upload error: $e');
      print('📚 Stack trace: $stackTrace');
      throw Exception('Failed to upload document: $e');
    }
  }

  /// Upload document from bytes
  Future<DocumentModel> uploadDocumentFromBytes({
    required Uint8List bytes,
    required String fileName,
    required String uploadedBy,
    required String uploadedByName,
    required UserRole uploaderRole,
    required DocumentCategory category,
    required DocumentAccessLevel accessLevel,
    String? description,
    String? folderId,
    List<String>? tags,
    List<String>? additionalAccessRoles,
    List<String>? additionalAccessUserIds,
    bool requiresApproval = false,
  }) async {
    try {
      print('🏗️ DocumentManagementService: Starting upload from bytes...');
      print('📁 File: $fileName');
      print('👤 Uploaded by: $uploadedByName ($uploadedBy)');
      print('🎭 Role: ${uploaderRole.value}');
      print('📂 Category: ${category.displayName}');
      print('📊 File size: ${bytes.length} bytes');

      // Initialize storage first
      print('🔧 Initializing storage...');
      try {
        await _supabaseService.initializeStorage();
      } catch (e) {
        print('⚠️ Storage initialization warning: $e');
        // Continue anyway, the upload might still work
      }

      // Check permissions
      print('🔐 Checking permissions...');
      final permissions = await _permissionService.getEffectivePermissionsAsync(
        uploaderRole,
      );

      // Check if user can upload to this specific category
      bool canUpload = permissions.canUploadToCategory(category);

      // Special handling for employee category with folder-specific permissions
      if (!canUpload &&
          category == DocumentCategory.employee &&
          folderId != null) {
        print(
          '🔍 [PERMISSION CHECK] Checking folder-specific employee permissions...',
        );

        // Extract folder info from folderId (which should be the folder path for employee documents)
        final folderInfo = _permissionService.extractFolderInfo(folderId);
        if (folderInfo != null) {
          print(
            '🔍 [PERMISSION CHECK] Checking upload permission for folder: ${folderInfo['code']}_${folderInfo['name']}',
          );
          canUpload = await _permissionService.canUploadToEmployeeFolder(
            uploaderRole,
            folderInfo['code']!,
            folderInfo['name']!,
          );
          print(
            '📋 [PERMISSION CHECK] Folder-specific upload permission: $canUpload',
          );
        }
      }

      if (!canUpload) {
        print(
          '❌ Upload permission denied - user cannot upload to category: ${category.value}',
        );
        if (category == DocumentCategory.employee) {
          print(
            '❌ User does not have upload permission for employee documents',
          );
          final config = await _permissionService.getPermissionConfig(
            uploaderRole,
          );
          if (config != null) {
            final uploadableCategories = config
                .documentConfig
                .uploadableCategories
                .map((c) => c.value)
                .join(', ');
            print('📋 User uploadable categories: $uploadableCategories');
          }
        }

        if (permissions.canUploadToAll) {
          throw Exception(
            'You do not have access to upload to the "${category.displayName}" category. Please contact your administrator.',
          );
        } else {
          throw Exception(
            'You do not have permission to upload documents to the "${category.displayName}" category. Please contact your administrator.',
          );
        }
      }

      print(
        '✅ Upload permission granted for category: ${category.displayName}',
      );

      // Enhanced file validation with content scanning
      print('🔍 Enhanced file validation...');

      // Check file signature/magic bytes for PDF
      if (fileName.toLowerCase().endsWith('.pdf')) {
        if (bytes.length < 4 ||
            !(bytes[0] == 0x25 &&
                bytes[1] == 0x50 &&
                bytes[2] == 0x44 &&
                bytes[3] == 0x46)) {
          throw Exception('Invalid PDF file: File signature mismatch');
        }
        print('✅ PDF signature validated');
      }

      // Check for suspicious file patterns
      final suspiciousPatterns = [
        'javascript:',
        'vbscript:',
        '<script',
        'eval(',
        'document.cookie',
      ];

      final fileContent = String.fromCharCodes(
        bytes.take(1024),
      ); // Check first 1KB
      for (final pattern in suspiciousPatterns) {
        if (fileContent.toLowerCase().contains(pattern.toLowerCase())) {
          throw Exception('File contains potentially malicious content');
        }
      }

      // Validate file size against dynamic permissions
      if (bytes.length > permissions.maxFileSizeMB * 1024 * 1024) {
        throw Exception(
          'File size (${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB) '
          'exceeds limit for role ${uploaderRole.displayName} '
          '(${permissions.maxFileSizeMB} MB)',
        );
      }

      // Validate file
      final fileExtension = path.extension(fileName).toLowerCase();
      final fileType = DocumentFileType.fromExtension(fileExtension);

      if (!permissions.isFileTypeAllowed(fileType)) {
        throw Exception('File type not allowed for this user role');
      }

      // Validate file size (using dynamic permissions)
      if (!permissions.isFileSizeAllowed(bytes.length)) {
        throw Exception(
          'File size exceeds maximum allowed size of ${permissions.maxFileSizeMB}MB',
        );
      }

      // Generate unique document ID
      final documentId = _uuid.v4();
      print('🆔 Generated document ID: $documentId');

      // Generate storage path
      print('🗂️ Generating storage path...');
      final storagePath = _supabaseService.generateDocumentPath(
        category: category.value,
        userId: uploadedBy,
        folderId: folderId,
      );
      print('📍 Storage path: $storagePath');

      // Upload to Supabase
      print('☁️ Uploading to Supabase...');
      final supabasePath = await _supabaseService.uploadBytesWithSignedUrl(
        filePath: storagePath,
        bytes: bytes,
        fileName: fileName,
        contentType: _supabaseService.getMimeType(fileName),
      );

      // Calculate checksum
      final checksum = _supabaseService.calculateChecksum(bytes);

      // Determine access roles and users
      final accessRoles = <String>[uploaderRole.value];
      if (additionalAccessRoles != null) {
        accessRoles.addAll(additionalAccessRoles);
      }

      final accessUserIds = <String>[uploadedBy];
      if (additionalAccessUserIds != null) {
        accessUserIds.addAll(additionalAccessUserIds);
      }

      print('👥 Access roles: $accessRoles');
      print('👤 Access user IDs: $accessUserIds');

      // Create document model
      print('📋 Creating document model...');
      final document = DocumentModel(
        id: documentId,
        fileName: fileName,
        originalFileName: fileName,
        supabasePath: supabasePath,
        firebasePath: 'documents/$documentId',
        category: category,
        fileType: fileType,
        status:
            requiresApproval ? DocumentStatus.pending : DocumentStatus.approved,
        accessLevel: accessLevel,
        uploadedBy: uploadedBy,
        uploadedByName: uploadedByName,
        uploadedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        fileSizeBytes: bytes.length,
        accessRoles: accessRoles,
        accessUserIds: accessUserIds,
        description: description,
        folderId: folderId,
        mimeType: _supabaseService.getMimeType(fileName),
        checksum: checksum,
        tags: tags,
        requiresApproval: requiresApproval,
        isConfidential:
            accessLevel == DocumentAccessLevel.confidential ||
            accessLevel == DocumentAccessLevel.private,
      );

      // Save metadata to Firebase
      print('🔥 Saving metadata to Firebase...');
      final firebaseDocId = await _firebaseService.createDocument(document);
      print('✅ Firebase document created: $firebaseDocId');

      // Update document with Firebase ID
      print('🔄 Updating document with Firebase ID...');
      final updatedDocument = document.copyWith(id: firebaseDocId);
      await _firebaseService.updateDocument(firebaseDocId, updatedDocument);
      print('✅ Document updated in Firebase');

      // Log the upload
      print('📝 Logging document access...');
      await _firebaseService.logDocumentAccess(
        documentId: firebaseDocId,
        userId: uploadedBy,
        userName: uploadedByName,
        action: 'upload',
      );
      print('✅ Access logged');

      // Enhanced audit logging with performance metrics
      final uploadStartTime = DateTime.now();
      print('⏱️ Upload started at: ${uploadStartTime.toIso8601String()}');

      // Log security event
      await _logSecurityEvent(
        userId: uploadedBy,
        userName: uploadedByName,
        action: 'DOCUMENT_UPLOAD_ATTEMPT',
        details: {
          'fileName': fileName,
          'fileSize': bytes.length,
          'category': category.value,
          'accessLevel': accessLevel.value,
          'userRole': uploaderRole.value,
          'ipAddress': 'web_client', // Could be enhanced with actual IP
          'userAgent':
              'flutter_web', // Could be enhanced with actual user agent
        },
      );

      // Log successful upload with performance metrics
      final uploadEndTime = DateTime.now();
      final uploadDuration = uploadEndTime.difference(uploadStartTime);

      print('⏱️ Upload completed at: ${uploadEndTime.toIso8601String()}');
      print('⚡ Upload duration: ${uploadDuration.inMilliseconds}ms');
      print(
        '📈 Upload speed: ${(bytes.length / uploadDuration.inSeconds / 1024 / 1024).toStringAsFixed(2)} MB/s',
      );

      await _logSecurityEvent(
        userId: uploadedBy,
        userName: uploadedByName,
        action: 'DOCUMENT_UPLOAD_SUCCESS',
        details: {
          'documentId': document.id,
          'fileName': fileName,
          'fileSize': bytes.length,
          'uploadDurationMs': uploadDuration.inMilliseconds,
          'uploadSpeedMBps':
              bytes.length / uploadDuration.inSeconds / 1024 / 1024,
          'checksum': checksum,
          'supabasePath': supabasePath,
        },
      );

      print('🎉 Document upload from bytes completed successfully!');
      return updatedDocument;
    } catch (e, stackTrace) {
      print('💥 DocumentManagementService upload from bytes error: $e');
      print('📚 Stack trace: $stackTrace');

      // Provide more user-friendly error messages
      if (e.toString().contains('Storage access denied') ||
          e.toString().contains('row-level security policy')) {
        throw Exception(
          'Storage access denied. Please ensure the Supabase storage bucket is properly configured with RLS policies.',
        );
      }

      throw Exception('Failed to upload document from bytes: $e');
    }
  }

  /// Download a document
  Future<Uint8List> downloadDocument({
    required String documentId,
    required String userId,
    required String userName,
    required UserRole userRole,
  }) async {
    try {
      // Get document metadata
      final document = await _firebaseService.getDocument(documentId);
      if (document == null) {
        throw Exception('Document not found');
      }

      // Check access permissions
      if (!_hasDocumentAccess(document, userRole, userId)) {
        throw Exception('Access denied');
      }

      // Download from Supabase
      final bytes = await _supabaseService.downloadFile(document.supabasePath);

      // Log the download
      await _firebaseService.logDocumentAccess(
        documentId: documentId,
        userId: userId,
        userName: userName,
        action: 'download',
      );

      // Update document access tracking
      final updatedDocument = document.recordAccess(userId);
      await _firebaseService.updateDocument(documentId, updatedDocument);

      return bytes;
    } catch (e) {
      throw Exception('Failed to download document: $e');
    }
  }

  /// Get signed URL for document access
  Future<String> getDocumentSignedUrl({
    required String documentId,
    required String userId,
    required UserRole userRole,
  }) async {
    try {
      // print('🔗 [DEBUG] Starting getDocumentSignedUrl process');
      // print('🔗 [DEBUG] Document ID: $documentId');
      // print('🔗 [DEBUG] User ID: $userId');
      // print('🔗 [DEBUG] User Role: ${userRole.value}');

      // Get document metadata first
      // print('🔗 [DEBUG] Fetching document metadata from Firebase...');
      final document = await _firebaseService.getDocument(documentId);
      if (document == null) {
        // print('❌ [DEBUG] Document not found in Firebase');
        throw Exception('Document not found');
      }

      // print('✅ [DEBUG] Document found: ${document.fileName}');
      // print('🔗 [DEBUG] Document Supabase path: ${document.supabasePath}');
      // print('🔗 [DEBUG] Document category: ${document.category.displayName}');
      // print(
      //   '🔗 [DEBUG] Document access level: ${document.accessLevel.displayName}',
      // );

      // Check permissions
      // print('🔗 [DEBUG] Checking document access permissions...');
      final hasAccess = _hasDocumentAccess(document, userRole, userId);
      // print('🔗 [DEBUG] Access check result: $hasAccess');

      if (!hasAccess) {
        // print('❌ [DEBUG] Access denied to document');
        // print('🔗 [DEBUG] Document access roles: ${document.accessRoles}');
        // print('🔗 [DEBUG] Document access user IDs: ${document.accessUserIds}');
        // print('🔗 [DEBUG] User role level: ${userRole.level}');
        throw Exception('Access denied to document');
      }

      // print('✅ [DEBUG] Document access granted');

      // Get signed URL from Supabase
      // print('�� [DEBUG] Requesting signed URL from Supabase...');
      // print('🔗 [DEBUG] Supabase path: ${document.supabasePath}');

      final signedUrl = await _supabaseService.getSignedUrl(
        document.supabasePath,
        expiresIn: await SupabaseConfig.documentPreviewExpiry, // Dynamic expiry
      );

      // print('✅ [DEBUG] Signed URL generated successfully');
      // print('🔗 [DEBUG] Signed URL length: ${signedUrl.length} characters');
      // print(
      //   '🔗 [DEBUG] Signed URL starts with: ${signedUrl.substring(0, 50)}...',
      // );

      // Log document access
      // print('🔗 [DEBUG] Logging document access...');
      await _firebaseService.logDocumentAccess(
        documentId: documentId,
        userId: userId,
        userName: 'User', // We'll get this from the user context
        action: 'preview',
      );
      // print('✅ [DEBUG] Document access logged');

      // print('🎉 [DEBUG] getDocumentSignedUrl completed successfully');
      return signedUrl;
    } catch (e, stackTrace) {
      // print('💥 [DEBUG] Failed to get signed URL: $e');
      // print('📚 [DEBUG] Stack trace: $stackTrace');
      throw Exception('Failed to get document URL: $e');
    }
  }

  /// Download document with proper access logging
  Future<String> downloadDocumentWithUrl({
    required String documentId,
    required String userId,
    required String userName,
    required UserRole userRole,
  }) async {
    try {
      print('📥 Starting document download: $documentId');

      // Get document metadata first
      final document = await _firebaseService.getDocument(documentId);
      if (document == null) {
        throw Exception('Document not found');
      }

      // Check permissions
      if (!_hasDocumentAccess(document, userRole, userId)) {
        throw Exception('Access denied to document');
      }

      // Get signed URL from Supabase
      final signedUrl = await _supabaseService.getSignedUrl(
        document.supabasePath,
        expiresIn:
            await SupabaseConfig.documentDownloadExpiry, // Dynamic expiry
      );

      // Update document access count and log
      final updatedDocument = document.recordAccess(userId);
      await _firebaseService.updateDocument(documentId, updatedDocument);

      // Log document access
      await _firebaseService.logDocumentAccess(
        documentId: documentId,
        userId: userId,
        userName: userName,
        action: 'download',
      );

      print('✅ Document download URL generated successfully');
      return signedUrl;
    } catch (e) {
      print('💥 Failed to download document: $e');
      throw Exception('Failed to download document: $e');
    }
  }

  /// Create a new folder
  Future<FolderModel> createFolder({
    required String name,
    required String createdBy,
    required String createdByName,
    required UserRole creatorRole,
    required DocumentCategory category,
    required DocumentAccessLevel accessLevel,
    String? parentId,
    String? description,
    List<String>? tags,
    List<String>? additionalAccessRoles,
    List<String>? additionalAccessUserIds,
  }) async {
    try {
      print('🏗️ DocumentManagementService: Starting folder creation...');
      print('📁 Folder name: $name');
      print('👤 Created by: $createdByName ($createdBy)');
      print('🎭 Role: ${creatorRole.value}');
      print('📂 Category: ${category.displayName}');
      print('🔒 Access level: ${accessLevel.displayName}');
      print('📍 Parent ID: ${parentId ?? 'root'}');

      // Check permissions
      print('🔐 Checking folder creation permissions...');
      final permissions = await _permissionService.getEffectivePermissionsAsync(
        creatorRole,
      );
      if (!permissions.canCreateFolders) {
        print('❌ User does not have folder creation permissions');
        throw Exception('User does not have permission to create folders');
      }
      print('✅ Folder creation permission granted');

      // Check if user can access this category
      if (!permissions.accessibleCategories.contains(category)) {
        print(
          '❌ Category access denied - user cannot access category: ${category.value}',
        );
        throw Exception(
          'User does not have access to create folders in category: ${category.displayName}',
        );
      }
      print('✅ Category access granted for folder creation');

      // Generate unique folder ID
      final folderId = _uuid.v4();
      print('🆔 Generated folder ID: $folderId');

      // Determine access roles and users
      final accessRoles = <String>[creatorRole.value];
      if (additionalAccessRoles != null) {
        accessRoles.addAll(additionalAccessRoles);
      }

      final accessUserIds = <String>[createdBy];
      if (additionalAccessUserIds != null) {
        accessUserIds.addAll(additionalAccessUserIds);
      }

      print('👥 Access roles: $accessRoles');
      print('👤 Access user IDs: $accessUserIds');

      // Construct folder paths
      print('🛤️ Constructing folder paths...');
      String folderPath;
      String? parentPath;

      if (parentId != null) {
        // Get parent folder to construct path
        final parentFolder = await _firebaseService.getFolder(parentId);
        if (parentFolder != null) {
          parentPath = parentFolder.path;
          folderPath = '${parentFolder.path}/$name';
        } else {
          parentPath = null;
          folderPath = name;
        }
      } else {
        parentPath = null;
        folderPath = name;
      }

      print('📍 Folder path: $folderPath');
      print('📍 Parent path: ${parentPath ?? 'none'}');

      // Create folder model
      print('📋 Creating folder model...');
      final folder = FolderModel(
        id: folderId,
        name: name,
        path: folderPath,
        category: category,
        accessLevel: accessLevel,
        createdBy: createdBy,
        createdByName: createdByName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        accessRoles: accessRoles,
        accessUserIds: accessUserIds,
        parentId: parentId,
        parentPath: parentPath,
        description: description,
        tags: tags,
        isArchived: false,
      );

      // Save metadata to Firebase
      print('🔥 Saving folder metadata to Firebase...');
      final firebaseFolderId = await _firebaseService.createFolder(folder);
      print('✅ Firebase folder created: $firebaseFolderId');

      // Update folder with Firebase ID
      print('🔄 Updating folder with Firebase ID...');
      final updatedFolder = folder.copyWith(id: firebaseFolderId);
      await _firebaseService.updateFolder(firebaseFolderId, updatedFolder);
      print('✅ Folder updated in Firebase');

      // Create folder structure in Supabase
      print('🗂️ Creating folder structure in Supabase...');
      try {
        final supabaseFolderPath = _supabaseService.generateDocumentPath(
          category: category.value,
          userId: createdBy,
          folderId: firebaseFolderId,
        );
        print('📍 Supabase folder path: $supabaseFolderPath');

        await _supabaseService.createFolderStructure(supabaseFolderPath);
        print('✅ Supabase folder structure created');
      } catch (e) {
        print('⚠️ Supabase folder structure creation warning: $e');
        // Continue anyway, the folder metadata is saved in Firebase
      }

      print('🎉 Folder creation completed successfully!');
      return updatedFolder;
    } catch (e, stackTrace) {
      print('💥 DocumentManagementService folder creation error: $e');
      print('📚 Stack trace: $stackTrace');
      throw Exception('Failed to create folder: $e');
    }
  }

  /// Delete a document (Super Admin only with dynamic permissions)
  Future<void> deleteDocument({
    required String documentId,
    required String userId,
    required String userName,
    required UserRole userRole,
  }) async {
    try {
      print('🗑️ [DELETE] Starting document deletion process');
      print('🗑️ [DELETE] Document ID: $documentId');
      print('🗑️ [DELETE] User: $userName (${userRole.value})');

      // Get document metadata first to check category
      final document = await _firebaseService.getDocument(documentId);
      if (document == null) {
        print('❌ [DELETE] Document not found: $documentId');
        throw Exception('Document not found');
      }

      print('📄 [DELETE] Document found: ${document.fileName}');
      print('📂 [DELETE] Document category: ${document.category.value}');
      print('📁 [DELETE] Supabase path: ${document.supabasePath}');

      // Check dynamic permissions for deletion
      final permissions = await _permissionService.getEffectivePermissionsAsync(
        userRole,
      );

      // Check if user can delete from this specific category
      if (!permissions.canDeleteFromCategory(document.category)) {
        print(
          '❌ [DELETE] Permission denied - user cannot delete from category: ${document.category.value}',
        );
        if (permissions.canDeleteAny) {
          print(
            '❌ [DELETE] User has canDeleteAny but category ${document.category.value} is not accessible',
          );
          throw Exception(
            'You do not have access to delete documents from the "${document.category.displayName}" category. Please contact your administrator.',
          );
        } else {
          print(
            '❌ [DELETE] User does not have delete permission for category: ${document.category.value}',
          );
          print(
            '📋 [DELETE] User deletable categories: ${permissions.deletableCategories.map((c) => c.value).join(', ')}',
          );
          throw Exception(
            'You do not have permission to delete documents from the "${document.category.displayName}" category. Please contact your administrator.',
          );
        }
      }
      print(
        '✅ [DELETE] Delete permission granted for category: ${document.category.displayName}',
      );

      // Additional check: users can only delete their own documents unless they have canDeleteAny permission
      if (!permissions.canDeleteAny && document.uploadedBy != userId) {
        print('❌ [DELETE] Permission denied - can only delete own documents');
        throw Exception('You can only delete documents you uploaded');
      }

      // Delete from Supabase first
      print('🗑️ [DELETE] Deleting file from Supabase...');
      await _supabaseService.deleteFile(document.supabasePath);
      print('✅ [DELETE] File deleted from Supabase successfully');

      // Delete metadata from Firebase
      print('🗑️ [DELETE] Deleting document metadata from Firebase...');
      await _firebaseService.deleteDocument(documentId);
      print('✅ [DELETE] Document metadata deleted from Firebase successfully');

      // Log the deletion
      print('📝 [DELETE] Logging deletion action...');
      await _firebaseService.logDocumentAccess(
        documentId: documentId,
        userId: userId,
        userName: userName,
        action: 'delete',
      );
      print('✅ [DELETE] Deletion logged successfully');

      print('🎉 [DELETE] Document deletion completed successfully');
    } catch (e) {
      print('💥 [DELETE] Failed to delete document: $e');
      throw Exception('Failed to delete document: $e');
    }
  }

  /// Delete a folder and all its contents
  Future<void> deleteFolder({
    required String folderId,
    required String userId,
    required String userName,
    required UserRole userRole,
  }) async {
    try {
      // Get folder metadata
      final folder = await _firebaseService.getFolder(folderId);
      if (folder == null) {
        throw Exception('Folder not found');
      }

      // Check permissions
      if (!folder.canDelete(userRole)) {
        throw Exception('Permission denied');
      }

      // Get all documents in folder
      final documents = await _firebaseService.getDocumentsInFolder(folderId);

      // Delete all documents
      for (final document in documents) {
        await _supabaseService.deleteFile(document.supabasePath);
        await _firebaseService.deleteDocument(document.id);
      }

      // Get all subfolders and delete recursively
      final subfolders = await _firebaseService.getFoldersByParent(folderId);
      for (final subfolder in subfolders) {
        await deleteFolder(
          folderId: subfolder.id,
          userId: userId,
          userName: userName,
          userRole: userRole,
        );
      }

      // Delete folder from Firebase
      await _firebaseService.deleteFolder(folderId);
    } catch (e) {
      throw Exception('Failed to delete folder: $e');
    }
  }

  /// Get documents accessible by user
  Future<List<DocumentModel>> getUserDocuments({
    required String userId,
    required UserRole userRole,
    DocumentCategory? category,
    String? folderId,
    int? limit,
  }) async {
    try {
      if (userRole.level >= 80) {
        // Admin users can see all documents
        return await _firebaseService
            .streamDocuments(
              category: category,
              folderId: folderId,
              limit: limit,
            )
            .first;
      } else {
        // Regular users see documents they have access to
        return await _firebaseService
            .streamDocuments(
              userRole: userRole,
              userId: userId,
              category: category,
              folderId: folderId,
              limit: limit,
            )
            .first;
      }
    } catch (e) {
      throw Exception('Failed to get user documents: $e');
    }
  }

  /// Get folders accessible by user
  Future<List<FolderModel>> getUserFolders({
    required String userId,
    required UserRole userRole,
    String? parentId,
    DocumentCategory? category,
    int? limit,
  }) async {
    try {
      if (userRole.level >= 80) {
        // Admin users can see all folders
        return await _firebaseService
            .streamFolders(parentId: parentId, category: category, limit: limit)
            .first;
      } else {
        // Regular users see folders they have access to
        return await _firebaseService
            .streamFolders(
              parentId: parentId,
              userRole: userRole,
              category: category,
              limit: limit,
            )
            .first;
      }
    } catch (e) {
      throw Exception('Failed to get user folders: $e');
    }
  }

  /// Search documents
  Future<List<DocumentModel>> searchDocuments({
    required String searchTerm,
    required String userId,
    required UserRole userRole,
    DocumentCategory? category,
    int? limit,
  }) async {
    try {
      print(
        '🔍 [DOCUMENT SEARCH] Starting document search for role: ${userRole.value}',
      );
      print('🔍 [DOCUMENT SEARCH] Search term: $searchTerm');
      print('📁 [DOCUMENT SEARCH] Category: ${category?.value ?? 'all'}');

      // Get dynamic permissions
      final permissions = await _permissionService.getEffectivePermissionsAsync(
        userRole,
      );

      print(
        '📋 [DOCUMENT SEARCH] User permissions: canViewAll=${permissions.canViewAll}',
      );
      print(
        '📋 [DOCUMENT SEARCH] Accessible categories: ${permissions.accessibleCategories.map((c) => c.value).join(', ')}',
      );

      // If user has canViewAll permission, search all documents but still apply restrictions
      if (permissions.canViewAll) {
        print(
          '✅ [DOCUMENT SEARCH] User has canViewAll - searching all documents with restrictions',
        );
        print(
          '🔒 [DOCUMENT SEARCH] Applying accessible categories: ${permissions.accessibleCategories.map((c) => c.value).join(', ')}',
        );
        print(
          '🔒 [DOCUMENT SEARCH] Applying file type restrictions: ${permissions.allowedFileTypes.map((f) => f.extension).join(', ')}',
        );

        final documents = await _firebaseService.searchDocuments(
          searchTerm,
          userRole: null, // Don't filter by role since they can view all
          userId: null, // Don't filter by user since they can view all
          category: category,
          limit: limit,
        );

        // Apply client-side filtering for accessible categories and file types
        return documents.where((doc) {
          // Check if document category is accessible
          if (!permissions.accessibleCategories.contains(doc.category)) {
            print(
              '🚫 [DOCUMENT SEARCH] Document ${doc.fileName} filtered out - category ${doc.category.value} not accessible',
            );
            return false;
          }

          // Check file type restrictions
          if (!permissions.allowedFileTypes.contains(doc.fileType)) {
            print(
              '🚫 [DOCUMENT SEARCH] Document ${doc.fileName} filtered out - file type ${doc.fileType.extension} not allowed',
            );
            return false;
          }

          print(
            '✅ [DOCUMENT SEARCH] Document ${doc.fileName} passed all filters',
          );
          return true;
        }).toList();
      } else {
        print(
          '🔒 [DOCUMENT SEARCH] User has limited access - applying filters',
        );

        // Filter by accessible categories if category is specified
        if (category != null &&
            !permissions.accessibleCategories.contains(category)) {
          print(
            '❌ [DOCUMENT SEARCH] User cannot access category: ${category.value}',
          );
          return <DocumentModel>[];
        }

        // Search with role and user filtering, then apply additional client-side filtering
        final documents = await _firebaseService.searchDocuments(
          searchTerm,
          userRole: userRole,
          userId: userId,
          category: category,
          limit: limit,
        );

        // Additional client-side filtering based on dynamic permissions
        return documents.where((doc) {
          // Check if document category is accessible
          if (!permissions.accessibleCategories.contains(doc.category)) {
            return false;
          }

          // Check file type restrictions
          if (!permissions.allowedFileTypes.contains(doc.fileType)) {
            return false;
          }

          // Additional access checks for documents without canViewAll
          return _hasDocumentAccess(doc, userRole, userId);
        }).toList();
      }
    } catch (e) {
      print('❌ [DOCUMENT SEARCH] Error searching documents: $e');
      throw Exception('Failed to search documents: $e');
    }
  }

  /// Approve a document
  Future<DocumentModel> approveDocument({
    required String documentId,
    required String approvedBy,
    required String approvedByName,
    required UserRole approverRole,
  }) async {
    try {
      // Check permissions
      final permissions = await _permissionService.getEffectivePermissionsAsync(
        approverRole,
      );
      if (!permissions.canManagePermissions) {
        throw Exception('User does not have permission to approve documents');
      }

      // Get document
      final document = await _firebaseService.getDocument(documentId);
      if (document == null) {
        throw Exception('Document not found');
      }

      // Approve document
      final approvedDocument = document.approve(approvedBy, approvedByName);
      await _firebaseService.updateDocument(documentId, approvedDocument);

      // Log the approval
      await _firebaseService.logDocumentAccess(
        documentId: documentId,
        userId: approvedBy,
        userName: approvedByName,
        action: 'approve',
      );

      return approvedDocument;
    } catch (e) {
      throw Exception('Failed to approve document: $e');
    }
  }

  /// Reject a document
  Future<DocumentModel> rejectDocument({
    required String documentId,
    required String rejectedBy,
    required String rejectedByName,
    required UserRole rejecterRole,
    required String reason,
  }) async {
    try {
      // Check permissions
      final permissions = await _permissionService.getEffectivePermissionsAsync(
        rejecterRole,
      );
      if (!permissions.canManagePermissions) {
        throw Exception('User does not have permission to reject documents');
      }

      // Get document
      final document = await _firebaseService.getDocument(documentId);
      if (document == null) {
        throw Exception('Document not found');
      }

      // Reject document
      final rejectedDocument = document.reject(
        rejectedBy,
        rejectedByName,
        reason,
      );
      await _firebaseService.updateDocument(documentId, rejectedDocument);

      // Log the rejection
      await _firebaseService.logDocumentAccess(
        documentId: documentId,
        userId: rejectedBy,
        userName: rejectedByName,
        action: 'reject',
      );

      return rejectedDocument;
    } catch (e) {
      throw Exception('Failed to reject document: $e');
    }
  }

  /// Check if user has access to document
  Future<bool> _hasDocumentAccessAsync(
    DocumentModel document,
    UserRole userRole,
    String userId,
  ) async {
    try {
      // Get dynamic permissions
      final permissions = await _permissionService.getEffectivePermissionsAsync(
        userRole,
      );

      // Users with canViewAll permission have access to everything
      if (permissions.canViewAll) return true;

      // Check if user is in access list
      if (document.isAccessibleByUser(userId)) return true;

      // Check if user role has access
      if (document.isAccessibleByRole(userRole)) return true;

      return false;
    } catch (e) {
      print('❌ [ACCESS CHECK] Error checking document access: $e');
      // Fallback to false for security
      return false;
    }
  }

  /// Check if user has access to document (synchronous version for backwards compatibility)
  bool _hasDocumentAccess(
    DocumentModel document,
    UserRole userRole,
    String userId,
  ) {
    // This is a synchronous fallback that uses static role checking
    // It's used in stream transformations where async calls are not possible

    // Check if user is in access list
    if (document.isAccessibleByUser(userId)) return true;

    // Check if user role has access
    if (document.isAccessibleByRole(userRole)) return true;

    return false;
  }

  /// Get document statistics
  Future<Map<String, dynamic>> getDocumentStatistics({
    required UserRole userRole,
    String? userId,
    DocumentCategory? category,
  }) async {
    try {
      return await _firebaseService.getDocumentStatistics(
        userRole: userRole,
        userId: userId,
        category: category,
      );
    } catch (e) {
      throw Exception('Failed to get document statistics: $e');
    }
  }

  /// Stream documents for real-time updates
  Stream<List<DocumentModel>> streamDocuments({
    required UserRole userRole,
    String? userId,
    DocumentCategory? category,
    String? folderId,
    int? limit,
  }) {
    try {
      print(
        '🔍 [DOCUMENT STREAM] Starting document stream for role: ${userRole.value}',
      );
      print('📁 [DOCUMENT STREAM] Category: ${category?.value ?? 'all'}');
      print('🗂️ [DOCUMENT STREAM] Folder ID: ${folderId ?? 'none'}');

      // Get dynamic permissions asynchronously and transform the stream
      return Stream.fromFuture(
        _permissionService.getEffectivePermissionsAsync(userRole),
      ).asyncExpand((permissions) {
        print(
          '📋 [DOCUMENT STREAM] User permissions: canViewAll=${permissions.canViewAll}',
        );
        print(
          '📋 [DOCUMENT STREAM] Accessible categories: ${permissions.accessibleCategories.map((c) => c.value).join(', ')}',
        );

        // If user has canViewAll permission, stream all documents but still apply restrictions
        if (permissions.canViewAll) {
          print(
            '✅ [DOCUMENT STREAM] User has canViewAll - streaming all documents with restrictions',
          );
          print(
            '🔒 [DOCUMENT STREAM] Applying accessible categories: ${permissions.accessibleCategories.map((c) => c.value).join(', ')}',
          );
          print(
            '🔒 [DOCUMENT STREAM] Applying file type restrictions: ${permissions.allowedFileTypes.map((f) => f.extension).join(', ')}',
          );

          return _firebaseService
              .streamDocuments(
                userRole: null, // Don't filter by role since they can view all
                userId: null, // Don't filter by user since they can view all
                category: category,
                folderId: folderId,
                limit: limit,
              )
              .map((documents) {
                // Apply client-side filtering for accessible categories and file types
                return documents.where((doc) {
                  // Check if document category is accessible
                  if (!permissions.accessibleCategories.contains(
                    doc.category,
                  )) {
                    print(
                      '🚫 [DOCUMENT STREAM] Document ${doc.fileName} filtered out - category ${doc.category.value} not accessible',
                    );
                    return false;
                  }

                  // Check file type restrictions
                  if (!permissions.allowedFileTypes.contains(doc.fileType)) {
                    print(
                      '🚫 [DOCUMENT STREAM] Document ${doc.fileName} filtered out - file type ${doc.fileType.extension} not allowed',
                    );
                    return false;
                  }

                  print(
                    '✅ [DOCUMENT STREAM] Document ${doc.fileName} passed all filters',
                  );
                  return true;
                }).toList();
              });
        } else {
          print(
            '🔒 [DOCUMENT STREAM] User has limited access - applying filters',
          );

          // Filter by accessible categories if category is specified
          if (category != null &&
              !permissions.accessibleCategories.contains(category)) {
            print(
              '❌ [DOCUMENT STREAM] User cannot access category: ${category.value}',
            );
            return Stream.value(<DocumentModel>[]);
          }

          // Use the old Firebase service method but with additional client-side filtering
          return _firebaseService
              .streamDocuments(
                userRole: userRole,
                userId: userId,
                category: category,
                folderId: folderId,
                limit: limit,
              )
              .map((documents) {
                // Additional client-side filtering based on dynamic permissions
                return documents.where((doc) {
                  // Check if document category is accessible
                  if (!permissions.accessibleCategories.contains(
                    doc.category,
                  )) {
                    return false;
                  }

                  // Check file type restrictions
                  if (!permissions.allowedFileTypes.contains(doc.fileType)) {
                    return false;
                  }

                  // Additional access checks for documents without canViewAll
                  return _hasDocumentAccess(doc, userRole, userId ?? '');
                }).toList();
              });
        }
      });
    } catch (e) {
      print('❌ [DOCUMENT STREAM] Error streaming documents: $e');
      throw Exception('Failed to stream documents: $e');
    }
  }

  /// Stream folders for real-time updates
  Stream<List<FolderModel>> streamFolders({
    required UserRole userRole,
    String? parentId,
    DocumentCategory? category,
    int? limit,
  }) {
    try {
      print(
        '🔍 [FOLDER STREAM] Starting folder stream for role: ${userRole.value}',
      );
      print('📁 [FOLDER STREAM] Category: ${category?.value ?? 'all'}');
      print('🗂️ [FOLDER STREAM] Parent ID: ${parentId ?? 'root'}');

      // Get dynamic permissions asynchronously and transform the stream
      return Stream.fromFuture(
        _permissionService.getEffectivePermissionsAsync(userRole),
      ).asyncExpand((permissions) {
        print(
          '📋 [FOLDER STREAM] User permissions: canViewAll=${permissions.canViewAll}',
        );
        print(
          '📋 [FOLDER STREAM] Accessible categories: ${permissions.accessibleCategories.map((c) => c.value).join(', ')}',
        );

        // If user has canViewAll permission, stream all folders but still apply restrictions
        if (permissions.canViewAll) {
          print(
            '✅ [FOLDER STREAM] User has canViewAll - streaming all folders with restrictions',
          );
          print(
            '🔒 [FOLDER STREAM] Applying accessible categories: ${permissions.accessibleCategories.map((c) => c.value).join(', ')}',
          );

          return _firebaseService
              .streamFolders(
                parentId: parentId,
                userRole: null, // Don't filter by role since they can view all
                category: category,
                limit: limit,
              )
              .map((folders) {
                // Apply client-side filtering for accessible categories
                return folders.where((folder) {
                  // Check if folder category is accessible
                  if (folder.category != null &&
                      !permissions.accessibleCategories.contains(
                        folder.category!,
                      )) {
                    print(
                      '🚫 [FOLDER STREAM] Folder ${folder.name} filtered out - category ${folder.category!.value} not accessible',
                    );
                    return false;
                  }

                  print(
                    '✅ [FOLDER STREAM] Folder ${folder.name} passed category filter',
                  );
                  return true; // Folder is accessible
                }).toList();
              });
        } else {
          print(
            '🔒 [FOLDER STREAM] User has limited access - applying filters',
          );

          // Filter by accessible categories if category is specified
          if (category != null &&
              !permissions.accessibleCategories.contains(category)) {
            print(
              '❌ [FOLDER STREAM] User cannot access category: ${category.value}',
            );
            return Stream.value(<FolderModel>[]);
          }

          // Use the old Firebase service method but with additional client-side filtering
          return _firebaseService
              .streamFolders(
                parentId: parentId,
                userRole: userRole,
                category: category,
                limit: limit,
              )
              .map((folders) {
                // Additional client-side filtering based on dynamic permissions
                return folders.where((folder) {
                  // Check if folder category is accessible
                  if (folder.category != null &&
                      !permissions.accessibleCategories.contains(
                        folder.category!,
                      )) {
                    return false;
                  }

                  return true; // Folder is accessible
                }).toList();
              });
        }
      });
    } catch (e) {
      print('❌ [FOLDER STREAM] Error streaming folders: $e');
      throw Exception('Failed to stream folders: $e');
    }
  }

  /// Get maximum file size allowed for a user role (in bytes)
  int _getMaxFileSizeForRole(UserRole role) {
    switch (role) {
      case UserRole.sa:
      case UserRole.admin:
        return 100 * 1024 * 1024; // 100 MB
      case UserRole.tl:
      case UserRole.manager:
        return 50 * 1024 * 1024; // 50 MB
      case UserRole.se:
        return 25 * 1024 * 1024; // 25 MB
      case UserRole.employee:
        return 10 * 1024 * 1024; // 10 MB
      case UserRole.intern:
        return 5 * 1024 * 1024; // 5 MB
      default:
        return 10 * 1024 * 1024; // 10 MB default
    }
  }

  /// Log a security event
  Future<void> _logSecurityEvent({
    required String userId,
    required String userName,
    required String action,
    required Map<String, dynamic> details,
  }) async {
    try {
      final securityLog = {
        'userId': userId,
        'userName': userName,
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
        'sessionId': 'web_session_${DateTime.now().millisecondsSinceEpoch}',
        'severity': _getActionSeverity(action),
      };

      await FirebaseFirestore.instance
          .collection('security_logs')
          .add(securityLog);

      print('🔒 Security event logged: $action');
    } catch (e) {
      print('⚠️ Failed to log security event: $e');
      // Don't throw - logging failures shouldn't break the main flow
    }
  }

  /// Get severity level for security actions
  String _getActionSeverity(String action) {
    switch (action) {
      case 'DOCUMENT_UPLOAD_ATTEMPT':
      case 'DOCUMENT_UPLOAD_SUCCESS':
      case 'DOCUMENT_ACCESS':
        return 'INFO';
      case 'DOCUMENT_UPLOAD_FAILED':
      case 'PERMISSION_DENIED':
        return 'WARNING';
      case 'SECURITY_VIOLATION':
      case 'SUSPICIOUS_ACTIVITY':
        return 'CRITICAL';
      default:
        return 'INFO';
    }
  }

  /// Upload with retry mechanism
  Future<DocumentModel> uploadDocumentWithRetry({
    required Uint8List bytes,
    required String fileName,
    required String uploadedBy,
    required String uploadedByName,
    required UserRole uploaderRole,
    required DocumentCategory category,
    required DocumentAccessLevel accessLevel,
    String? description,
    String? folderId,
    List<String>? tags,
    List<String>? additionalAccessRoles,
    List<String>? additionalAccessUserIds,
    bool requiresApproval = false,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      attempts++;
      print('🔄 Upload attempt $attempts of $maxRetries for $fileName');

      try {
        return await uploadDocumentFromBytes(
          bytes: bytes,
          fileName: fileName,
          uploadedBy: uploadedBy,
          uploadedByName: uploadedByName,
          uploaderRole: uploaderRole,
          category: category,
          accessLevel: accessLevel,
          description: description,
          folderId: folderId,
          tags: tags,
          additionalAccessRoles: additionalAccessRoles,
          additionalAccessUserIds: additionalAccessUserIds,
          requiresApproval: requiresApproval,
        );
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        print('❌ Upload attempt $attempts failed: $e');

        // Don't retry for certain types of errors
        if (_isNonRetryableError(e)) {
          print('🚫 Non-retryable error detected, stopping retries');
          break;
        }

        // Wait before retry (exponential backoff)
        if (attempts < maxRetries) {
          final waitTime = Duration(seconds: attempts * 2);
          print('⏳ Waiting ${waitTime.inSeconds}s before retry...');
          await Future.delayed(waitTime);
        }
      }
    }

    // Log final failure
    await _logSecurityEvent(
      userId: uploadedBy,
      userName: uploadedByName,
      action: 'DOCUMENT_UPLOAD_FAILED',
      details: {
        'fileName': fileName,
        'attempts': attempts,
        'error': lastException.toString(),
      },
    );

    throw lastException ??
        Exception('Upload failed after $maxRetries attempts');
  }

  /// Check if error should not be retried
  bool _isNonRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('permission') ||
        errorString.contains('unauthorized') ||
        errorString.contains('invalid') ||
        errorString.contains('malicious') ||
        errorString.contains('file type') ||
        errorString.contains('file size');
  }

  /// Health check for the document management service
  Future<Map<String, dynamic>> healthCheck() async {
    final healthStatus = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'services': <String, dynamic>{},
    };

    // Check Supabase connectivity
    try {
      await _supabaseService.initializeStorage();
      healthStatus['services']['supabase'] = {
        'status': 'healthy',
        'message': 'Storage accessible',
      };
    } catch (e) {
      healthStatus['services']['supabase'] = {
        'status': 'unhealthy',
        'message': e.toString(),
      };
    }

    // Check Firebase connectivity
    try {
      await FirebaseFirestore.instance
          .collection('health_check')
          .limit(1)
          .get();
      healthStatus['services']['firebase'] = {
        'status': 'healthy',
        'message': 'Firestore accessible',
      };
    } catch (e) {
      healthStatus['services']['firebase'] = {
        'status': 'unhealthy',
        'message': e.toString(),
      };
    }

    // Overall health
    final allHealthy = healthStatus['services'].values.every(
      (service) => service['status'] == 'healthy',
    );
    healthStatus['overall'] = allHealthy ? 'healthy' : 'degraded';

    print('🏥 Health check completed: ${healthStatus['overall']}');
    return healthStatus;
  }

  /// Get user-friendly error message
  String getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission') ||
        errorString.contains('unauthorized')) {
      return 'You don\'t have permission to perform this action. Please contact your administrator.';
    } else if (errorString.contains('file size')) {
      return 'The file is too large. Please choose a smaller file or contact your administrator for higher limits.';
    } else if (errorString.contains('file type') ||
        errorString.contains('invalid')) {
      return 'This file type is not supported. Please choose a different file format.';
    } else if (errorString.contains('malicious') ||
        errorString.contains('suspicious')) {
      return 'The file contains content that may be unsafe. Please check the file and try again.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network connection issue. Please check your internet connection and try again.';
    } else if (errorString.contains('storage') ||
        errorString.contains('bucket')) {
      return 'Storage service is temporarily unavailable. Please try again in a few minutes.';
    } else if (errorString.contains('quota') || errorString.contains('limit')) {
      return 'Storage quota exceeded. Please contact your administrator.';
    } else {
      return 'An unexpected error occurred. Please try again or contact support if the problem persists.';
    }
  }

  /// Upload with progress callback
  Future<DocumentModel> uploadDocumentWithProgress({
    required Uint8List bytes,
    required String fileName,
    required String uploadedBy,
    required String uploadedByName,
    required UserRole uploaderRole,
    required DocumentCategory category,
    required DocumentAccessLevel accessLevel,
    Function(double progress, String status)? onProgress,
    String? description,
    String? folderId,
    List<String>? tags,
    List<String>? additionalAccessRoles,
    List<String>? additionalAccessUserIds,
    bool requiresApproval = false,
  }) async {
    try {
      onProgress?.call(0.1, 'Validating file...');

      // File validation
      final fileExtension = path.extension(fileName).toLowerCase();
      final fileType = DocumentFileType.fromExtension(fileExtension);
      final permissions = await _permissionService.getEffectivePermissionsAsync(
        uploaderRole,
      );

      if (!permissions.isFileTypeAllowed(fileType)) {
        throw Exception('File type not allowed for this user role');
      }

      if (!permissions.isFileSizeAllowed(bytes.length)) {
        throw Exception('File size exceeds maximum allowed size');
      }

      onProgress?.call(0.2, 'Checking permissions...');

      // Permission checks - check if user can upload to this specific category
      if (!permissions.canUploadToCategory(category)) {
        if (permissions.canUploadToAll) {
          throw Exception(
            'You do not have access to upload to the "${category.displayName}" category. Please contact your administrator.',
          );
        } else {
          throw Exception(
            'You do not have permission to upload documents to the "${category.displayName}" category. Please contact your administrator.',
          );
        }
      }

      onProgress?.call(0.3, 'Preparing upload...');

      // Generate IDs and paths
      final documentId = _uuid.v4();
      final storagePath = _supabaseService.generateDocumentPath(
        category: category.value,
        userId: uploadedBy,
        folderId: folderId,
      );

      onProgress?.call(0.4, 'Uploading file...');

      // Upload to Supabase with progress
      final supabasePath = await _supabaseService
          .uploadBytesWithProgressAndChunking(
            filePath: storagePath,
            bytes: bytes,
            fileName: fileName,
            contentType: _supabaseService.getMimeType(fileName),
            onProgress: (uploadProgress) {
              // Map upload progress to overall progress (40% to 80%)
              final overallProgress = 0.4 + (uploadProgress * 0.4);
              onProgress?.call(
                overallProgress,
                'Uploading... ${(uploadProgress * 100).toInt()}%',
              );
            },
          );

      onProgress?.call(0.8, 'Processing metadata...');

      // Calculate checksum and create document
      final checksum = _supabaseService.calculateChecksum(bytes);

      final document = DocumentModel(
        id: documentId,
        fileName: fileName,
        originalFileName: fileName,
        supabasePath: supabasePath,
        firebasePath: 'documents/$documentId',
        category: category,
        fileType: fileType,
        status:
            requiresApproval ? DocumentStatus.pending : DocumentStatus.approved,
        accessLevel: accessLevel,
        uploadedBy: uploadedBy,
        uploadedByName: uploadedByName,
        uploadedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        fileSizeBytes: bytes.length,
        accessRoles: [uploaderRole.value, ...(additionalAccessRoles ?? [])],
        accessUserIds: [uploadedBy, ...(additionalAccessUserIds ?? [])],
        description: description,
        folderId: folderId,
        mimeType: _supabaseService.getMimeType(fileName),
        checksum: checksum,
        tags: tags,
        requiresApproval: requiresApproval,
        isConfidential:
            accessLevel == DocumentAccessLevel.confidential ||
            accessLevel == DocumentAccessLevel.private,
      );

      onProgress?.call(0.9, 'Saving metadata...');

      // Save to Firebase
      final firebaseDocId = await _firebaseService.createDocument(document);
      final updatedDocument = document.copyWith(id: firebaseDocId);
      await _firebaseService.updateDocument(firebaseDocId, updatedDocument);

      onProgress?.call(1.0, 'Upload completed successfully!');

      return updatedDocument;
    } catch (e) {
      onProgress?.call(0.0, getUserFriendlyErrorMessage(e));
      rethrow;
    }
  }

  /// Validate file before upload
  Future<void> _validateFileUpload({
    required File file,
    required UserRole uploaderRole,
    required DocumentCategory category,
    required String fileName,
  }) async {
    print('🔍 Validating file...');

    // Get dynamic permissions
    final permissions = await _permissionService.getEffectivePermissionsAsync(
      uploaderRole,
    );

    // Check file extension
    final extension = path.extension(fileName).toLowerCase();
    print('📎 File extension: $extension');

    // Get file type
    final fileType = DocumentFileType.fromExtension(extension);
    print('🗂️ File type: ${fileType.extension}');

    // Check if file type is allowed
    if (!permissions.allowedFileTypes.contains(fileType)) {
      print('❌ File type not allowed: ${fileType.extension}');
      throw Exception('File type ${fileType.extension} is not allowed');
    }
    print('✅ File type allowed');

    // Check file size
    final fileSize = await file.length();
    final maxSizeBytes = permissions.maxFileSizeMB * 1024 * 1024;
    if (fileSize > maxSizeBytes) {
      print('❌ File size too large: $fileSize bytes');
      throw Exception(
        'File size (${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB) exceeds limit (${permissions.maxFileSizeMB} MB)',
      );
    }
    print('✅ File size within limits');
  }
}

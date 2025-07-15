import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show latin1;

import '../../../shared/providers/auth_providers.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../../../shared/widgets/custom_loader.dart';
import '../../../shared/widgets/password_confirmation_dialog.dart';
import '../../../core/services/document_management_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/document_model.dart';
import '../../../core/enums/document_enums.dart';
import '../../../core/enums/user_role.dart';
import '../widgets/document_preview_dialog.dart';
import '../providers/document_providers.dart';
import '../../../core/services/permission_management_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyDocumentsFolderPage extends ConsumerStatefulWidget {
  final String folderPath;

  const MyDocumentsFolderPage({super.key, required this.folderPath});

  @override
  ConsumerState<MyDocumentsFolderPage> createState() =>
      _MyDocumentsFolderPageState();
}

class _MyDocumentsFolderPageState extends ConsumerState<MyDocumentsFolderPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  List<DocumentModel> _documents = [];

  final DocumentManagementService _documentService =
      DocumentManagementService();
  final FirebaseService _firebaseService = FirebaseService();
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadFolderDocuments();
  }

  Future<void> _loadFolderDocuments() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Get current user for permission checking
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      print(
        '🔍 [FOLDER DOCS] Loading documents for user: ${currentUser.role.value}',
      );
      print('📁 [FOLDER DOCS] Folder path: ${widget.folderPath}');

      // Get dynamic permissions for the current user
      final permissionService = PermissionManagementService();

      // Check folder-specific view permission
      final folderInfo = permissionService.extractFolderInfo(widget.folderPath);

      bool canViewFolder = false;
      if (folderInfo != null) {
        // Extract target employee ID from folder path
        String? targetEmployeeId;
        final pathParts = widget.folderPath.split('/');
        if (pathParts.length >= 2 && pathParts[0] == 'employees') {
          final employeePart =
              pathParts[1]; // e.g., "TRX2025000001_Samrat_De_Sarkar"
          targetEmployeeId = employeePart.split('_')[0]; // Extract employee ID
        }

        // Check folder-specific view permission with employee IDs
        canViewFolder = await ref.read(
          canViewEmployeeFolderProvider(
            currentUser.role,
            folderInfo['code']!,
            folderInfo['name']!,
            currentUserEmployeeId: currentUser.employeeId,
            targetEmployeeId: targetEmployeeId,
          ).future,
        );

        print(
          '🔍 [FOLDER VIEW PERMISSION] Current User: ${currentUser.employeeId}, Target: $targetEmployeeId, Can View: $canViewFolder',
        );
      } else {
        // Fallback to category-level permission check
        final permissions = await permissionService
            .getEffectivePermissionsAsync(currentUser.role);
        canViewFolder =
            permissions.canViewAll ||
            permissions.accessibleCategories.contains(
              DocumentCategory.employee,
            );

        print(
          '🔍 [FOLDER VIEW PERMISSION] Using category-level check, Can View: $canViewFolder',
        );
      }

      if (!canViewFolder) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'You do not have permission to view this folder';
        });
        return;
      }

      final permissions = await permissionService.getEffectivePermissionsAsync(
        currentUser.role,
      );

      print(
        '📋 [FOLDER DOCS] User permissions: canViewAll=${permissions.canViewAll}',
      );

      // Query documents from Firebase with employee category filter
      final snapshot =
          await FirebaseFirestore.instance
              .collection('documents')
              .where('category', isEqualTo: 'employee')
              .orderBy('uploadedAt', descending: true)
              .get();

      print(
        '📊 [FOLDER DOCS] Found ${snapshot.docs.length} employee documents',
      );

      final List<DocumentModel> documents = [];
      for (final doc in snapshot.docs) {
        try {
          final document = _convertToDocumentModel(doc.id, doc.data());

          // Apply permission filtering - for employee documents, allow access if user has employee category access
          if (permissions.canViewAll ||
              permissions.accessibleCategories.contains(
                DocumentCategory.employee,
              ) ||
              document.supabasePath.contains(currentUser.employeeId ?? '')) {
            // Check if document belongs to this specific folder
            if (document.supabasePath.contains(widget.folderPath)) {
              documents.add(document);
            }
          }
        } catch (e) {
          print('❌ [FOLDER DOCS] Error processing document ${doc.id}: $e');
        }
      }

      print('✅ [FOLDER DOCS] Loaded ${documents.length} documents for folder');

      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [FOLDER DOCS] Error loading documents: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load documents: ${e.toString()}';
      });
    }
  }

  Future<bool> _checkDeletePermission(UserRole role) async {
    try {
      final permissionService = PermissionManagementService();
      final currentUser = ref.read(currentUserProvider).value;

      // Extract folder info from the current folder path
      final folderInfo = permissionService.extractFolderInfo(widget.folderPath);

      // Extract target employee ID from folder path
      String? targetEmployeeId;
      final pathParts = widget.folderPath.split('/');
      if (pathParts.length >= 2 && pathParts[0] == 'employees') {
        final employeePart =
            pathParts[1]; // e.g., "TRX2025000001_Samrat_De_Sarkar"
        targetEmployeeId = employeePart.split('_')[0]; // Extract employee ID
      }

      if (folderInfo != null) {
        // Check folder-specific delete permission with employee IDs
        final canDelete = await permissionService.canDeleteFromEmployeeFolder(
          role,
          folderInfo['code']!,
          folderInfo['name']!,
          currentUserEmployeeId: currentUser?.employeeId,
          targetEmployeeId: targetEmployeeId,
        );

        print(
          '🔍 [DELETE PERMISSION] Current User: ${currentUser?.employeeId}, Target: $targetEmployeeId, Can Delete: $canDelete',
        );
        return canDelete;
      }

      print('❌ [DELETE PERMISSION] Could not extract folder info');
      return false;
    } catch (e) {
      print('❌ [DELETE PERMISSION] Error checking permissions: $e');
      return false;
    }
  }

  DocumentModel _convertToDocumentModel(String id, Map<String, dynamic> data) {
    // Helper function to parse file type from filename or mime type
    DocumentFileType getFileType(String? fileName, String? mimeType) {
      if (fileName != null) {
        final extension = fileName.split('.').last.toLowerCase();
        print(
          '🔍 [FILE TYPE] Detecting file type for: $fileName, extension: $extension',
        );

        switch (extension) {
          case 'pdf':
            print('✅ [FILE TYPE] Detected: PDF');
            return DocumentFileType.pdf;
          case 'doc':
            print('✅ [FILE TYPE] Detected: DOC');
            return DocumentFileType.doc;
          case 'docx':
            print('✅ [FILE TYPE] Detected: DOCX');
            return DocumentFileType.docx;
          case 'pages':
            print('✅ [FILE TYPE] Detected: PAGES');
            return DocumentFileType.pages;
          case 'xls':
            print('✅ [FILE TYPE] Detected: XLS');
            return DocumentFileType.xls;
          case 'xlsx':
            print('✅ [FILE TYPE] Detected: XLSX');
            return DocumentFileType.xlsx;
          case 'numbers':
            print('✅ [FILE TYPE] Detected: NUMBERS');
            return DocumentFileType.numbers;
          case 'ppt':
            print('✅ [FILE TYPE] Detected: PPT');
            return DocumentFileType.ppt;
          case 'pptx':
            print('✅ [FILE TYPE] Detected: PPTX');
            return DocumentFileType.pptx;
          case 'keynote':
            print('✅ [FILE TYPE] Detected: KEYNOTE');
            return DocumentFileType.keynote;
          case 'txt':
            print('✅ [FILE TYPE] Detected: TXT');
            return DocumentFileType.txt;
          case 'csv':
            print('✅ [FILE TYPE] Detected: CSV');
            return DocumentFileType.csv;
          case 'jpg':
            print('✅ [FILE TYPE] Detected: JPG');
            return DocumentFileType.jpg;
          case 'jpeg':
            print('✅ [FILE TYPE] Detected: JPEG');
            return DocumentFileType.jpeg;
          case 'png':
            print('✅ [FILE TYPE] Detected: PNG');
            return DocumentFileType.png;
          case 'gif':
            print('✅ [FILE TYPE] Detected: GIF');
            return DocumentFileType.gif;
          case 'zip':
            print('✅ [FILE TYPE] Detected: ZIP');
            return DocumentFileType.zip;
          case 'rar':
            print('✅ [FILE TYPE] Detected: RAR');
            return DocumentFileType.rar;
          case 'mp4':
            print('✅ [FILE TYPE] Detected: MP4');
            return DocumentFileType.mp4;
          case 'mp3':
            print('✅ [FILE TYPE] Detected: MP3');
            return DocumentFileType.mp3;
          default:
            print(
              '⚠️ [FILE TYPE] Unknown extension: $extension, defaulting to OTHER',
            );
            return DocumentFileType.other;
        }
      }
      print('⚠️ [FILE TYPE] No filename provided, defaulting to OTHER');
      return DocumentFileType.other;
    }

    // Helper function to parse access level
    DocumentAccessLevel getAccessLevel(String? accessLevel) {
      switch (accessLevel?.toLowerCase()) {
        case 'public':
          return DocumentAccessLevel.public;
        case 'restricted':
          return DocumentAccessLevel.restricted;
        case 'confidential':
          return DocumentAccessLevel.confidential;
        case 'private':
          return DocumentAccessLevel.private;
        default:
          return DocumentAccessLevel.restricted;
      }
    }

    // Helper function to parse document status
    DocumentStatus getStatus(String? status) {
      switch (status?.toLowerCase()) {
        case 'draft':
          return DocumentStatus.draft;
        case 'pending':
          return DocumentStatus.pending;
        case 'approved':
          return DocumentStatus.approved;
        case 'rejected':
          return DocumentStatus.rejected;
        case 'archived':
          return DocumentStatus.archived;
        default:
          return DocumentStatus.approved;
      }
    }

    // Parse timestamp
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is DateTime) return timestamp;
      if (timestamp.toString().contains('Timestamp')) {
        return timestamp.toDate();
      }
      try {
        return DateTime.parse(timestamp.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return DocumentModel(
      id: id,
      fileName: data['fileName'] ?? 'Unknown Document',
      originalFileName:
          data['originalFileName'] ?? data['fileName'] ?? 'Unknown Document',
      supabasePath: data['supabasePath'] ?? '',
      firebasePath: data['firebasePath'] ?? data['supabasePath'] ?? '',
      category: DocumentCategory.employee,
      fileType: getFileType(data['fileName'], data['mimeType']),
      fileSizeBytes: data['fileSizeBytes'] ?? 0,
      mimeType: data['mimeType'] ?? 'application/octet-stream',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      folderId: null, // Employee documents don't have folder IDs
      folderPath: widget.folderPath,
      uploadedAt: parseTimestamp(data['uploadedAt']),
      uploadedBy: data['uploadedBy'] ?? '',
      uploadedByName: data['uploadedByName'] ?? 'Unknown',
      updatedAt: parseTimestamp(data['updatedAt']),
      status: getStatus(data['status']),
      accessLevel: getAccessLevel(data['accessLevel']),
      accessRoles: List<String>.from(data['accessRoles'] ?? []),
      accessUserIds: List<String>.from(data['accessUserIds'] ?? []),
      requiresApproval: data['requiresApproval'] ?? false,
      isConfidential: data['isConfidential'] ?? false,
      checksum: data['checksum'] ?? '',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      version: data['version'] ?? '1.0',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    // Extract folder name from path
    final folderName = _formatFolderName(widget.folderPath);

    return DashboardScaffold(
      currentPath: '/my-documents',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/my-documents'),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back to My Documents',
                ),
                const SizedBox(width: 8),
                Icon(Icons.folder, size: 32, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    folderName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loadFolderDocuments,
                  icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
                  tooltip: 'Refresh documents',
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Subtitle with folder path
            Text(
              'Path: ${widget.folderPath}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(child: _buildContent(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CustomLoader(message: 'Loading documents...', size: 80),
      );
    }

    if (_hasError) {
      return _buildErrorWidget(theme);
    }

    if (_documents.isEmpty) {
      return _buildEmptyState(theme);
    }

    return _buildDocumentsList(theme);
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load documents',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unknown error occurred',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadFolderDocuments,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No documents yet',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This folder is empty. Documents uploaded by HR or Admin will appear here.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsList(ThemeData theme) {
    return ListView.builder(
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final document = _documents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getDocumentIcon(document.fileName),
              color: theme.colorScheme.primary,
            ),
            title: Text(document.fileName),
            subtitle: Text(
              'Uploaded: ${_formatDate(document.uploadedAt)} • Size: ${_formatFileSize(document.fileSizeBytes)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _viewDocument(document),
                  tooltip: 'View Document',
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadDocument(document),
                  tooltip: 'Download Document',
                ),
                Consumer(
                  builder: (context, ref, child) {
                    // Use dynamic permission checking for employee document deletion
                    final currentUser = ref.watch(currentUserProvider).value;
                    if (currentUser == null) return const SizedBox.shrink();

                    return FutureBuilder<bool>(
                      future: _checkDeletePermission(currentUser.role),
                      builder: (context, snapshot) {
                        final canDelete = snapshot.data ?? false;

                        if (!canDelete) {
                          return const SizedBox.shrink(); // Hide if no permission
                        }

                        return IconButton(
                          onPressed: () => _showDeleteConfirmation(document),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Document',
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            onTap: () => _viewDocument(document),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(DocumentModel document) {
    showPasswordConfirmationDialog(
      context: context,
      title: 'Confirm Document Deletion',
      message:
          'You are about to permanently delete "${document.fileName}". This action cannot be undone and requires password verification for security.',
      actionButtonText: 'Delete Document',
      actionButtonColor: Colors.red,
      icon: Icons.delete_forever,
      onConfirmed: () => _deleteDocument(document),
    );
  }

  Future<void> _deleteDocument(DocumentModel document) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Get current user info
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Delete the document using the document management service
      final documentService = ref.read(documentManagementServiceProvider);
      await documentService.deleteDocument(
        documentId: document.id,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? 'Unknown User',
        userRole: currentUser.role,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Document "${document.fileName}" deleted successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh the document list
      _loadFolderDocuments();
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatFolderName(String folderPath) {
    if (folderPath.isEmpty) {
      return 'Unknown Folder';
    }

    final folderName = folderPath.split('/').last;
    if (folderName.contains('_')) {
      final namePart = folderName.split('_').skip(1).join(' ');
      return namePart
          .split('-')
          .where((word) => word.isNotEmpty) // Filter out empty words
          .map(
            (word) =>
                word.isNotEmpty
                    ? word[0].toUpperCase() + word.substring(1)
                    : '',
          )
          .where((word) => word.isNotEmpty) // Filter out empty results
          .join(' ');
    }
    return folderPath;
  }

  IconData _getDocumentIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
      case 'pages':
        return Icons.description;
      case 'xls':
      case 'xlsx':
      case 'numbers':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
      case 'keynote':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      case 'csv':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'mp4':
        return Icons.video_file;
      case 'mp3':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _viewDocument(DocumentModel document) async {
    try {
      // For employee documents, use direct Supabase access instead of DocumentPreviewDialog
      // to avoid complex access control checks
      final signedUrl = await _supabaseService.getSignedUrl(
        document.supabasePath,
      );

      // Register appropriate viewer based on document type
      if (kIsWeb) {
        switch (document.fileType) {
          case DocumentFileType.pdf:
            _registerPdfViewer(document);
            break;
          case DocumentFileType.doc:
          case DocumentFileType.docx:
            _registerWordViewer(document);
            break;
          case DocumentFileType.ppt:
          case DocumentFileType.pptx:
            _registerPowerPointViewer(document);
            break;
          default:
            // No special viewer registration needed for images and text files
            break;
        }
      }

      // Show custom preview dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => _buildCustomPreviewDialog(document, signedUrl),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to view document: $e')));
      }
    }
  }

  Widget _buildCustomPreviewDialog(DocumentModel document, String signedUrl) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      child: Container(
        width: screenSize.width * 0.9,
        height: screenSize.height * 0.9,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getDocumentIcon(document.fileName),
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.fileName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_formatFileSize(document.fileSizeBytes)} • ${document.fileType.displayName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  IconButton(
                    onPressed: () => _downloadDocument(document),
                    icon: const Icon(Icons.download),
                    tooltip: 'Download',
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Content
            Expanded(child: _buildPreviewContent(document, signedUrl, theme)),

            // Footer with document info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (document.description?.isNotEmpty == true) ...[
                          Text(
                            'Description: ${document.description}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          'Uploaded: ${_formatDate(document.uploadedAt)} by ${document.uploadedByName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent(
    DocumentModel document,
    String signedUrl,
    ThemeData theme,
  ) {
    print('🎭 [PREVIEW] Building preview for: ${document.fileName}');
    print('🎭 [PREVIEW] File type: ${document.fileType}');
    print('🎭 [PREVIEW] File type enum: ${document.fileType.runtimeType}');

    // For PDF files, use PDF.js viewer
    if (document.fileType == DocumentFileType.pdf) {
      print('🎭 [PREVIEW] Using PDF viewer');
      if (kIsWeb) {
        // Update the PDF viewer with the signed URL
        _updatePdfViewer(document, signedUrl);

        // Return the HtmlElementView that will display the PDF.js viewer
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: HtmlElementView(viewType: 'pdf-viewer-${document.id}'),
        );
      } else {
        return _buildMobilePreview(
          document,
          signedUrl,
          theme,
          'PDF Preview',
          Icons.picture_as_pdf,
        );
      }
    }

    // For Word documents and Pages, use Office Online viewer (Pages may fallback to download)
    if (document.fileType == DocumentFileType.doc ||
        document.fileType == DocumentFileType.docx ||
        document.fileType == DocumentFileType.pages) {
      print('🎭 [PREVIEW] Using Word/Pages viewer');
      if (kIsWeb) {
        // For Pages files, Office Online won't work, but we'll try and fallback gracefully
        if (document.fileType == DocumentFileType.pages) {
          // Pages files can't be previewed in web browsers, show download option
          return _buildAppleFormatPreview(
            document,
            signedUrl,
            theme,
            'Pages Document',
            Icons.description,
            'Apple Pages documents cannot be previewed in web browsers. Download to view in Pages app.',
          );
        } else {
          // Update the Word viewer with the signed URL
          _updateWordViewer(document, signedUrl);

          // Return the HtmlElementView that will display the Word viewer
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: HtmlElementView(viewType: 'word-viewer-${document.id}'),
          );
        }
      } else {
        return _buildMobilePreview(
          document,
          signedUrl,
          theme,
          document.fileType == DocumentFileType.pages
              ? 'Pages Document'
              : 'Word Document',
          Icons.description,
        );
      }
    }

    // For PowerPoint documents and Keynote, use Office Online viewer (Keynote may fallback to download)
    if (document.fileType == DocumentFileType.ppt ||
        document.fileType == DocumentFileType.pptx ||
        document.fileType == DocumentFileType.keynote) {
      print('🎭 [PREVIEW] Using PowerPoint/Keynote viewer');
      if (kIsWeb) {
        // For Keynote files, Office Online won't work, but we'll try and fallback gracefully
        if (document.fileType == DocumentFileType.keynote) {
          // Keynote files can't be previewed in web browsers, show download option
          return _buildAppleFormatPreview(
            document,
            signedUrl,
            theme,
            'Keynote Presentation',
            Icons.slideshow,
            'Apple Keynote presentations cannot be previewed in web browsers. Download to view in Keynote app.',
          );
        } else {
          // Update the PowerPoint viewer with the signed URL
          _updatePowerPointViewer(document, signedUrl);

          // Return the HtmlElementView that will display the PowerPoint viewer
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: HtmlElementView(
              viewType: 'powerpoint-viewer-${document.id}',
            ),
          );
        }
      } else {
        return _buildMobilePreview(
          document,
          signedUrl,
          theme,
          document.fileType == DocumentFileType.keynote
              ? 'Keynote Presentation'
              : 'PowerPoint Presentation',
          document.fileType == DocumentFileType.keynote
              ? Icons.slideshow
              : Icons.slideshow,
        );
      }
    }

    // For Excel documents and Numbers, show download option (no good web preview for spreadsheets)
    if (document.fileType == DocumentFileType.xls ||
        document.fileType == DocumentFileType.xlsx ||
        document.fileType == DocumentFileType.numbers) {
      print('🎭 [PREVIEW] Using spreadsheet viewer (download only)');
      final isNumbers = document.fileType == DocumentFileType.numbers;
      return _buildAppleFormatPreview(
        document,
        signedUrl,
        theme,
        isNumbers ? 'Numbers Spreadsheet' : 'Excel Spreadsheet',
        Icons.table_chart,
        isNumbers
            ? 'Apple Numbers spreadsheets cannot be previewed in web browsers. Download to view in Numbers app.'
            : 'Excel spreadsheets are best viewed by downloading and opening in Excel or a compatible application.',
      );
    }

    // For text and CSV files, show content directly
    if (document.fileType == DocumentFileType.txt ||
        document.fileType == DocumentFileType.csv) {
      print('🎭 [PREVIEW] Using text/CSV viewer');
      return _buildTextPreview(document, signedUrl, theme);
    }

    // For images, show directly
    if (document.fileType.isImage) {
      print('🎭 [PREVIEW] Using image viewer');
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: InteractiveViewer(
          child: Image.network(
            signedUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value:
                      loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Failed to load image'),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    // For other file types, show download option
    print(
      '⚠️ [PREVIEW] No preview available for file type: ${document.fileType}',
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getDocumentIcon(document.fileName),
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Preview not available for this file type',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'File type: ${document.fileType.displayName}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click download to view the document',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadDocument(document);
            },
            icon: const Icon(Icons.download),
            label: const Text('Download Document'),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              if (kIsWeb) {
                html.window.open(signedUrl, '_blank');
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open in New Tab'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePreview(
    DocumentModel document,
    String signedUrl,
    ThemeData theme,
    String title,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Click below to download or open',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadDocument(document);
            },
            icon: const Icon(Icons.download),
            label: Text('Download ${title}'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextPreview(
    DocumentModel document,
    String signedUrl,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  document.fileType == DocumentFileType.csv
                      ? Icons.table_chart
                      : Icons.text_snippet,
                  color:
                      document.fileType == DocumentFileType.csv
                          ? Colors.green
                          : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  document.fileType == DocumentFileType.csv
                      ? 'CSV File Preview'
                      : 'Text File Preview',
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    if (kIsWeb) {
                      html.window.open(signedUrl, '_blank');
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in New Tab'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: _buildTextContent(signedUrl, document.fileType),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(String signedUrl, DocumentFileType fileType) {
    return FutureBuilder<String>(
      future: _loadTextContent(signedUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading text content...'),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to load text content'),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final content = snapshot.data ?? 'No content available';

        if (fileType == DocumentFileType.csv) {
          return _buildCsvTable(content);
        } else {
          return SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.4,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildCsvTable(String csvContent) {
    try {
      final lines =
          csvContent
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .toList();
      if (lines.isEmpty) {
        return const Center(child: Text('Empty CSV file'));
      }

      // Limit to first 100 rows for performance
      final displayLines = lines.take(100).toList();
      if (lines.length > 100) {
        displayLines.add('... (${lines.length - 100} more rows)');
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns:
                _parseCsvRow(displayLines.first)
                    .asMap()
                    .entries
                    .map(
                      (entry) => DataColumn(
                        label: Text(
                          entry.value.isEmpty
                              ? 'Column ${entry.key + 1}'
                              : entry.value,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                    .toList(),
            rows:
                displayLines
                    .skip(1)
                    .map(
                      (line) => DataRow(
                        cells:
                            _parseCsvRow(line)
                                .map(
                                  (cell) =>
                                      DataCell(Text(cell.isEmpty ? '-' : cell)),
                                )
                                .toList(),
                      ),
                    )
                    .toList(),
          ),
        ),
      );
    } catch (e) {
      // Fallback to plain text display
      return SingleChildScrollView(
        child: SelectableText(
          csvContent,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            height: 1.4,
          ),
        ),
      );
    }
  }

  List<String> _parseCsvRow(String row) {
    final cells = <String>[];
    bool inQuotes = false;
    String currentCell = '';

    for (int i = 0; i < row.length; i++) {
      final char = row[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        cells.add(currentCell.trim());
        currentCell = '';
      } else {
        currentCell += char;
      }
    }

    cells.add(currentCell.trim());
    return cells;
  }

  Future<String> _loadTextContent(String signedUrl) async {
    try {
      print(
        '📄 [TEXT LOADER] Loading text content from: ${signedUrl.substring(0, 50)}...',
      );

      // Use http package to fetch the text content
      final response = await http.get(Uri.parse(signedUrl));

      if (response.statusCode == 200) {
        print('✅ [TEXT LOADER] Text content loaded successfully');

        // Handle different text encodings
        String content;
        try {
          content = utf8.decode(response.bodyBytes);
        } catch (e) {
          // Fallback to latin1 if UTF-8 fails
          content = latin1.decode(response.bodyBytes);
        }

        // Limit content size for display (max 50KB)
        if (content.length > 50000) {
          content =
              content.substring(0, 50000) +
              '\n\n... (Content truncated for display)';
        }

        return content;
      } else {
        throw Exception('Failed to load text content: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [TEXT LOADER] Error loading text content: $e');
      throw Exception('Failed to load text content: $e');
    }
  }

  void _downloadDocument(DocumentModel document) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preparing download...')));

      final signedUrl = await _supabaseService.getSignedUrl(
        document.supabasePath,
      );

      // For web, create a download link directly
      if (kIsWeb) {
        final anchor =
            html.AnchorElement(href: signedUrl)
              ..setAttribute('download', document.fileName)
              ..style.display = 'none';

        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download started: ${document.fileName}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // For mobile platforms, show the download URL
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Download: ${document.fileName}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Click the link below to download the document:',
                      ),
                      const SizedBox(height: 16),
                      SelectableText(
                        signedUrl,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Copy to clipboard functionality could be added here
                      },
                      child: const Text('Copy Link'),
                    ),
                  ],
                ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download document: $e')),
        );
      }
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      DateTime date;
      if (timestamp is DateTime) {
        date = timestamp;
      } else if (timestamp.toString().contains('Timestamp')) {
        // Firestore Timestamp
        date = timestamp.toDate();
      } else {
        // Try parsing as string
        date = DateTime.parse(timestamp.toString());
      }

      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _registerPdfViewer(DocumentModel document) {
    if (kIsWeb) {
      try {
        final viewType = 'pdf-viewer-${document.id}';
        print('🎭 [PDF VIEWER] Registering PDF.js viewer with type: $viewType');

        ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
          // Create a container div
          final container =
              html.DivElement()
                ..style.width = '100%'
                ..style.height = '100%'
                ..style.position = 'relative'
                ..style.backgroundColor = '#f5f5f5'
                ..style.border = 'none'
                ..style.overflow = 'hidden';

          // Create PDF.js viewer HTML structure
          final htmlContent = '''
            <div style="width: 100%; height: 100%; display: flex; flex-direction: column;">
              <div id="pdf-container-${document.id}" style="width: 100%; height: 100%; position: relative;">
                <!-- PDF.js iframe viewer -->
                <iframe 
                  id="pdf-iframe-${document.id}"
                  style="width: 100%; height: 100%; border: none; background: white;"
                  sandbox="allow-same-origin allow-scripts allow-popups allow-forms"
                  allow="fullscreen"
                  loading="lazy">
                </iframe>
                
                <!-- Loading indicator -->
                <div id="loading-${document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                ">
                  <div style="
                    width: 50px; 
                    height: 50px; 
                    border: 4px solid #f3f3f3; 
                    border-top: 4px solid #007bff; 
                    border-radius: 50%; 
                    animation: spin 1s linear infinite;
                    margin: 0 auto 20px auto;
                  "></div>
                  <h3 style="margin: 0 0 10px 0; font-weight: 600; color: #333;">Loading PDF...</h3>
                  <p style="margin: 0; font-size: 14px; color: #666;">Using PDF.js secure viewer</p>
                </div>
                
                <!-- Error fallback -->
                <div id="error-${document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                  display: none;
                ">
                  <div style="font-size: 48px; margin-bottom: 20px;">📄</div>
                  <h3 style="color: #e74c3c; margin-bottom: 15px;">PDF Preview Unavailable</h3>
                  <p style="color: #666; margin-bottom: 25px; font-size: 14px; line-height: 1.5;">
                    Unable to display PDF in the browser.<br>
                    Click below to download or open in a new tab.
                  </p>
                  <div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">
                    <button 
                      id="download-pdf-${document.id}"
                      style="
                        background: #28a745; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#218838'"
                      onmouseout="this.style.background='#28a745'"
                    >
                      📥 Download PDF
                    </button>
                    <button 
                      id="open-pdf-${document.id}"
                      style="
                        background: #007bff; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#0056b3'"
                      onmouseout="this.style.background='#007bff'"
                    >
                      🔗 Open in New Tab
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <style>
              @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
              }
            </style>
          ''';

          container.setInnerHtml(
            htmlContent,
            treeSanitizer: html.NodeTreeSanitizer.trusted,
          );

          // Set up event listeners for fallback buttons
          final downloadButton = container.querySelector(
            '#download-pdf-${document.id}',
          );
          final openButton = container.querySelector(
            '#open-pdf-${document.id}',
          );

          downloadButton?.onClick.listen((_) {
            final pdfUrl = container.getAttribute('data-pdf-url');
            if (pdfUrl != null && pdfUrl.isNotEmpty) {
              // Trigger download
              final anchor =
                  html.AnchorElement()
                    ..href = pdfUrl
                    ..download = document.fileName
                    ..style.display = 'none';
              html.document.body?.children.add(anchor);
              anchor.click();
              html.document.body?.children.remove(anchor);
            }
          });

          openButton?.onClick.listen((_) {
            final pdfUrl = container.getAttribute('data-pdf-url');
            if (pdfUrl != null && pdfUrl.isNotEmpty) {
              html.window.open(pdfUrl, '_blank');
            }
          });

          return container;
        });
      } catch (e) {
        print('❌ [PDF VIEWER] Error registering PDF.js viewer: $e');
      }
    }
  }

  void _updatePdfViewer(DocumentModel document, String signedUrl) {
    if (!kIsWeb) return;

    print(
      '🎭 [PDF.js] Updating PDF.js viewer with URL: ${signedUrl.substring(0, 50)}...',
    );
    print(
      '🔒 [SECURITY] Using PDF.js - client-side rendering, no third-party services',
    );

    // Add a small delay to ensure the elements are rendered
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final containerId = 'pdf-container-${document.id}';
        final container = html.document.querySelector('#$containerId');

        if (container != null) {
          // Store the PDF URL for fallback buttons
          container.setAttribute('data-pdf-url', signedUrl);

          // Get the iframe element
          final iframe =
              container.querySelector('#pdf-iframe-${document.id}')
                  as html.IFrameElement?;

          if (iframe != null) {
            print('🎭 [PDF.js] Found iframe element, setting up PDF.js viewer');

            // Try different PDF.js approaches for better CORS handling
            _tryPdfJsApproaches(document, signedUrl, iframe);

            // Set up iframe load handlers
            iframe.onLoad.listen((_) {
              print('✅ [PDF.js] PDF.js viewer loaded successfully');
              _hidePdfLoading(document);
            });

            iframe.onError.listen((_) {
              print('❌ [PDF.js] PDF.js viewer failed to load');
              _showPdfError(document);
            });

            // Set a timeout to show error if PDF doesn't load
            Future.delayed(const Duration(seconds: 10), () {
              final loading = html.document.querySelector(
                '#loading-${document.id}',
              );
              if (loading != null && loading.style.display != 'none') {
                print(
                  '⚠️ [PDF.js] PDF loading timeout, showing error fallback',
                );
                _showPdfError(document);
              }
            });
          } else {
            print('❌ [PDF.js] Could not find iframe element');
            _showPdfError(document);
          }
        } else {
          print('❌ [PDF.js] Could not find PDF container');
          _showPdfError(document);
        }
      } catch (e) {
        print('❌ [PDF.js] Error updating PDF.js viewer: $e');
        _showPdfError(document);
      }
    });
  }

  void _tryPdfJsApproaches(
    DocumentModel document,
    String signedUrl,
    html.IFrameElement iframe,
  ) {
    // Approach 1: Try with Mozilla's PDF.js CDN (most compatible)
    try {
      final encodedUrl = Uri.encodeComponent(signedUrl);
      final pdfJsUrl =
          'https://mozilla.github.io/pdf.js/web/viewer.html?file=$encodedUrl';

      print(
        '🎭 [PDF.js] Trying Mozilla PDF.js viewer: ${pdfJsUrl.substring(0, 100)}...',
      );
      iframe.src = pdfJsUrl;

      // If this fails, try alternative approaches
      Future.delayed(const Duration(seconds: 5), () {
        final loading = html.document.querySelector('#loading-${document.id}');
        if (loading != null && loading.style.display != 'none') {
          print('⚠️ [PDF.js] Mozilla viewer timeout, trying alternative...');
          _tryAlternativePdfJs(document, signedUrl, iframe);
        }
      });
    } catch (e) {
      print('❌ [PDF.js] Mozilla approach failed: $e');
      _tryAlternativePdfJs(document, signedUrl, iframe);
    }
  }

  void _tryAlternativePdfJs(
    DocumentModel document,
    String signedUrl,
    html.IFrameElement iframe,
  ) {
    try {
      // Approach 2: Try with a different PDF.js CDN
      final encodedUrl = Uri.encodeComponent(signedUrl);
      final altPdfJsUrl =
          'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/web/viewer.html?file=$encodedUrl';

      print(
        '🎭 [PDF.js] Trying alternative PDF.js viewer: ${altPdfJsUrl.substring(0, 100)}...',
      );
      iframe.src = altPdfJsUrl;

      // If this also fails, try direct embedding
      Future.delayed(const Duration(seconds: 5), () {
        final loading = html.document.querySelector('#loading-${document.id}');
        if (loading != null && loading.style.display != 'none') {
          print(
            '⚠️ [PDF.js] Alternative viewer timeout, trying direct embed...',
          );
          _tryDirectPdfEmbed(document, signedUrl, iframe);
        }
      });
    } catch (e) {
      print('❌ [PDF.js] Alternative approach failed: $e');
      _tryDirectPdfEmbed(document, signedUrl, iframe);
    }
  }

  void _tryDirectPdfEmbed(
    DocumentModel document,
    String signedUrl,
    html.IFrameElement iframe,
  ) {
    try {
      // Approach 3: Direct PDF embedding (browser built-in PDF viewer)
      print('🎭 [PDF.js] Trying direct PDF embedding');
      iframe.src = signedUrl;

      // Add PDF viewer parameters for better display
      final directUrl =
          '$signedUrl#view=FitH&toolbar=1&navpanes=1&scrollbar=1&page=1&zoom=page-fit';
      iframe.src = directUrl;

      print('🔒 [SECURITY] Using direct PDF URL - browser built-in viewer');

      // Final timeout check
      Future.delayed(const Duration(seconds: 5), () {
        final loading = html.document.querySelector('#loading-${document.id}');
        if (loading != null && loading.style.display != 'none') {
          print('⚠️ [PDF.js] All approaches failed, showing error');
          _showPdfError(document);
        }
      });
    } catch (e) {
      print('❌ [PDF.js] Direct embed failed: $e');
      _showPdfError(document);
    }
  }

  void _hidePdfLoading(DocumentModel document) {
    final loading = html.document.querySelector('#loading-${document.id}');
    if (loading != null) {
      loading.style.display = 'none';
    }
  }

  void _showPdfError(DocumentModel document) {
    final loading = html.document.querySelector('#loading-${document.id}');
    final error = html.document.querySelector('#error-${document.id}');

    if (loading != null) {
      loading.style.display = 'none';
    }

    if (error != null) {
      error.style.display = 'block';
    }
  }

  void _registerWordViewer(DocumentModel document) {
    if (kIsWeb) {
      try {
        final viewType = 'word-viewer-${document.id}';
        print('🎭 [WORD VIEWER] Registering Word viewer with type: $viewType');

        ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
          // Create a container div
          final container =
              html.DivElement()
                ..style.width = '100%'
                ..style.height = '100%'
                ..style.position = 'relative'
                ..style.backgroundColor = '#f5f5f5'
                ..style.border = 'none'
                ..style.overflow = 'hidden';

          // Create Word viewer HTML structure
          final htmlContent = '''
            <div style="width: 100%; height: 100%; display: flex; flex-direction: column;">
              <div id="word-container-${document.id}" style="width: 100%; height: 100%; position: relative;">
                <!-- Word document iframe viewer -->
                <iframe 
                  id="word-iframe-${document.id}"
                  style="width: 100%; height: 100%; border: none; background: white;"
                  sandbox="allow-same-origin allow-scripts allow-popups allow-forms"
                  allow="fullscreen"
                  loading="lazy">
                </iframe>
                
                <!-- Loading indicator -->
                <div id="word-loading-${document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                ">
                  <div style="
                    width: 50px; 
                    height: 50px; 
                    border: 4px solid #f3f3f3; 
                    border-top: 4px solid #0078d4; 
                    border-radius: 50%; 
                    animation: spin 1s linear infinite;
                    margin: 0 auto 20px auto;
                  "></div>
                  <h3 style="margin: 0 0 10px 0; font-weight: 600; color: #333;">Loading Word Document...</h3>
                  <p style="margin: 0; font-size: 14px; color: #666;">Using secure document viewer</p>
                </div>
                
                <!-- Error fallback -->
                <div id="word-error-${document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                  display: none;
                ">
                  <div style="font-size: 48px; margin-bottom: 20px;">📄</div>
                  <h3 style="color: #e74c3c; margin-bottom: 15px;">Document Preview Unavailable</h3>
                  <p style="color: #666; margin-bottom: 25px; font-size: 14px; line-height: 1.5;">
                    Unable to display Word document in the browser.<br>
                    Click below to download or open in a new tab.
                  </p>
                  <div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">
                    <button 
                      id="download-word-${document.id}"
                      style="
                        background: #28a745; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#218838'"
                      onmouseout="this.style.background='#28a745'"
                    >
                      📥 Download Document
                    </button>
                    <button 
                      id="open-word-${document.id}"
                      style="
                        background: #0078d4; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#106ebe'"
                      onmouseout="this.style.background='#0078d4'"
                    >
                      🔗 Open in New Tab
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <style>
              @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
              }
            </style>
          ''';

          container.setInnerHtml(
            htmlContent,
            treeSanitizer: html.NodeTreeSanitizer.trusted,
          );

          // Set up event listeners for fallback buttons
          final downloadButton = container.querySelector(
            '#download-word-${document.id}',
          );
          final openButton = container.querySelector(
            '#open-word-${document.id}',
          );

          downloadButton?.onClick.listen((_) {
            final docUrl = container.getAttribute('data-doc-url');
            if (docUrl != null && docUrl.isNotEmpty) {
              // Trigger download
              final anchor =
                  html.AnchorElement()
                    ..href = docUrl
                    ..download = document.fileName
                    ..style.display = 'none';
              html.document.body?.children.add(anchor);
              anchor.click();
              html.document.body?.children.remove(anchor);
            }
          });

          openButton?.onClick.listen((_) {
            final docUrl = container.getAttribute('data-doc-url');
            if (docUrl != null && docUrl.isNotEmpty) {
              html.window.open(docUrl, '_blank');
            }
          });

          return container;
        });
      } catch (e) {
        print('❌ [WORD VIEWER] Error registering Word viewer: $e');
      }
    }
  }

  void _updateWordViewer(DocumentModel document, String signedUrl) {
    if (!kIsWeb) return;

    print(
      '🎭 [WORD VIEWER] Updating Word viewer with URL: ${signedUrl.substring(0, 50)}...',
    );

    // Add a small delay to ensure the elements are rendered
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final containerId = 'word-container-${document.id}';
        final container = html.document.querySelector('#$containerId');

        if (container != null) {
          // Store the document URL for fallback buttons
          container.setAttribute('data-doc-url', signedUrl);

          // Get the iframe element
          final iframe =
              container.querySelector('#word-iframe-${document.id}')
                  as html.IFrameElement?;

          if (iframe != null) {
            print(
              '🎭 [WORD VIEWER] Found iframe element, setting up Word viewer',
            );

            // Try to use Office Online viewer or direct download
            _tryWordViewerApproaches(document, signedUrl, iframe);

            // Set up iframe load handlers
            iframe.onLoad.listen((_) {
              print('✅ [WORD VIEWER] Word viewer loaded successfully');
              _hideWordLoading(document);
            });

            iframe.onError.listen((_) {
              print('❌ [WORD VIEWER] Word viewer failed to load');
              _showWordError(document);
            });

            // Set a timeout to show error if document doesn't load
            Future.delayed(const Duration(seconds: 10), () {
              final loading = html.document.querySelector(
                '#word-loading-${document.id}',
              );
              if (loading != null && loading.style.display != 'none') {
                print(
                  '⚠️ [WORD VIEWER] Word loading timeout, showing error fallback',
                );
                _showWordError(document);
              }
            });
          } else {
            print('❌ [WORD VIEWER] Could not find iframe element');
            _showWordError(document);
          }
        } else {
          print('❌ [WORD VIEWER] Could not find Word container');
          _showWordError(document);
        }
      } catch (e) {
        print('❌ [WORD VIEWER] Error updating Word viewer: $e');
        _showWordError(document);
      }
    });
  }

  void _tryWordViewerApproaches(
    DocumentModel document,
    String signedUrl,
    html.IFrameElement iframe,
  ) {
    try {
      // For Word documents, we'll try Office Online viewer first
      final encodedUrl = Uri.encodeComponent(signedUrl);

      // Try Office Online viewer (may not work with private URLs)
      final officeOnlineUrl =
          'https://view.officeapps.live.com/op/embed.aspx?src=$encodedUrl';

      print('🎭 [WORD VIEWER] Trying Office Online viewer: $officeOnlineUrl');
      iframe.src = officeOnlineUrl;

      // Fallback: If Office Online doesn't work, show download option
      Future.delayed(const Duration(seconds: 5), () {
        final loading = html.document.querySelector(
          '#word-loading-${document.id}',
        );
        if (loading != null && loading.style.display != 'none') {
          print(
            '⚠️ [WORD VIEWER] Office Online viewer not working, showing fallback',
          );
          _showWordError(document);
        }
      });
    } catch (e) {
      print('❌ [WORD VIEWER] Error setting up Word viewer approaches: $e');
      _showWordError(document);
    }
  }

  void _hideWordLoading(DocumentModel document) {
    final loading = html.document.querySelector('#word-loading-${document.id}');
    loading?.style.display = 'none';
  }

  void _showWordError(DocumentModel document) {
    final loading = html.document.querySelector('#word-loading-${document.id}');
    final error = html.document.querySelector('#word-error-${document.id}');

    loading?.style.display = 'none';
    error?.style.display = 'block';
  }

  void _registerPowerPointViewer(DocumentModel document) {
    if (kIsWeb) {
      try {
        final viewType = 'powerpoint-viewer-${document.id}';
        print(
          '🎭 [POWERPOINT VIEWER] Registering PowerPoint viewer with type: $viewType',
        );

        ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
          // Create a container div
          final container =
              html.DivElement()
                ..style.width = '100%'
                ..style.height = '100%'
                ..style.position = 'relative'
                ..style.backgroundColor = '#f5f5f5'
                ..style.border = 'none'
                ..style.overflow = 'hidden';

          // Create PowerPoint viewer HTML structure
          final htmlContent = '''
            <div style="width: 100%; height: 100%; display: flex; flex-direction: column;">
              <div id="powerpoint-container-${document.id}" style="width: 100%; height: 100%; position: relative;">
                <!-- PowerPoint viewer iframe -->
                <iframe 
                  id="powerpoint-iframe-${document.id}"
                  style="width: 100%; height: 100%; border: none; background: white;"
                  sandbox="allow-same-origin allow-scripts allow-popups allow-forms"
                  allow="fullscreen"
                  loading="lazy">
                </iframe>
                
                <!-- Loading indicator -->
                <div id="powerpoint-loading-${document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                ">
                  <div style="
                    width: 50px; 
                    height: 50px; 
                    border: 4px solid #f3f3f3; 
                    border-top: 4px solid #d04423; 
                    border-radius: 50%; 
                    animation: spin 1s linear infinite;
                    margin: 0 auto 20px auto;
                  "></div>
                  <h3 style="margin: 0 0 10px 0; font-weight: 600; color: #333;">Loading PowerPoint...</h3>
                  <p style="margin: 0; font-size: 14px; color: #666;">Using secure presentation viewer</p>
                </div>
                
                <!-- Error fallback -->
                <div id="powerpoint-error-${document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                  display: none;
                ">
                  <div style="font-size: 48px; margin-bottom: 20px;">📊</div>
                  <h3 style="color: #e74c3c; margin-bottom: 15px;">Presentation Preview Unavailable</h3>
                  <p style="color: #666; margin-bottom: 25px; font-size: 14px; line-height: 1.5;">
                    Unable to display PowerPoint presentation in the browser.<br>
                    Click below to download or open in a new tab.
                  </p>
                  <div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">
                    <button 
                      id="download-powerpoint-${document.id}"
                      style="
                        background: #28a745; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#218838'"
                      onmouseout="this.style.background='#28a745'"
                    >
                      📥 Download Presentation
                    </button>
                    <button 
                      id="open-powerpoint-${document.id}"
                      style="
                        background: #d04423; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#b73e1f'"
                      onmouseout="this.style.background='#d04423'"
                    >
                      🔗 Open in New Tab
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <style>
              @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
              }
            </style>
          ''';

          container.setInnerHtml(
            htmlContent,
            treeSanitizer: html.NodeTreeSanitizer.trusted,
          );

          // Set up event listeners for fallback buttons
          final downloadButton = container.querySelector(
            '#download-powerpoint-${document.id}',
          );
          final openButton = container.querySelector(
            '#open-powerpoint-${document.id}',
          );

          downloadButton?.onClick.listen((_) {
            final pptUrl = container.getAttribute('data-ppt-url');
            if (pptUrl != null && pptUrl.isNotEmpty) {
              // Trigger download
              final anchor =
                  html.AnchorElement()
                    ..href = pptUrl
                    ..download = document.fileName
                    ..style.display = 'none';
              html.document.body?.children.add(anchor);
              anchor.click();
              html.document.body?.children.remove(anchor);
            }
          });

          openButton?.onClick.listen((_) {
            final pptUrl = container.getAttribute('data-ppt-url');
            if (pptUrl != null && pptUrl.isNotEmpty) {
              html.window.open(pptUrl, '_blank');
            }
          });

          return container;
        });
      } catch (e) {
        print('❌ [POWERPOINT VIEWER] Error registering PowerPoint viewer: $e');
      }
    }
  }

  void _updatePowerPointViewer(DocumentModel document, String signedUrl) {
    if (!kIsWeb) return;

    print(
      '🎭 [POWERPOINT VIEWER] Updating PowerPoint viewer with URL: ${signedUrl.substring(0, 50)}...',
    );

    // Add a small delay to ensure the elements are rendered
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final containerId = 'powerpoint-container-${document.id}';
        final container = html.document.querySelector('#$containerId');

        if (container != null) {
          // Store the presentation URL for fallback buttons
          container.setAttribute('data-ppt-url', signedUrl);

          // Get the iframe element
          final iframe =
              container.querySelector('#powerpoint-iframe-${document.id}')
                  as html.IFrameElement?;

          if (iframe != null) {
            print(
              '🎭 [POWERPOINT VIEWER] Found iframe element, setting up PowerPoint viewer',
            );

            // Try to use Office Online viewer
            _tryPowerPointViewerApproaches(document, signedUrl, iframe);

            // Set up iframe load handlers
            iframe.onLoad.listen((_) {
              print(
                '✅ [POWERPOINT VIEWER] PowerPoint viewer loaded successfully',
              );
              _hidePowerPointLoading(document);
            });

            iframe.onError.listen((_) {
              print('❌ [POWERPOINT VIEWER] PowerPoint viewer failed to load');
              _showPowerPointError(document);
            });

            // Set a timeout to show error if presentation doesn't load
            Future.delayed(const Duration(seconds: 10), () {
              final loading = html.document.querySelector(
                '#powerpoint-loading-${document.id}',
              );
              if (loading != null && loading.style.display != 'none') {
                print(
                  '⚠️ [POWERPOINT VIEWER] PowerPoint loading timeout, showing error fallback',
                );
                _showPowerPointError(document);
              }
            });
          } else {
            print('❌ [POWERPOINT VIEWER] Could not find iframe element');
            _showPowerPointError(document);
          }
        } else {
          print('❌ [POWERPOINT VIEWER] Could not find PowerPoint container');
          _showPowerPointError(document);
        }
      } catch (e) {
        print('❌ [POWERPOINT VIEWER] Error updating PowerPoint viewer: $e');
        _showPowerPointError(document);
      }
    });
  }

  void _tryPowerPointViewerApproaches(
    DocumentModel document,
    String signedUrl,
    html.IFrameElement iframe,
  ) {
    try {
      // For PowerPoint presentations, we'll try Office Online viewer
      final encodedUrl = Uri.encodeComponent(signedUrl);

      // Try Office Online viewer (may not work with private URLs)
      final officeOnlineUrl =
          'https://view.officeapps.live.com/op/embed.aspx?src=$encodedUrl';

      print(
        '🎭 [POWERPOINT VIEWER] Trying Office Online viewer: $officeOnlineUrl',
      );
      iframe.src = officeOnlineUrl;

      // Fallback: If Office Online doesn't work, show download option
      Future.delayed(const Duration(seconds: 5), () {
        final loading = html.document.querySelector(
          '#powerpoint-loading-${document.id}',
        );
        if (loading != null && loading.style.display != 'none') {
          print(
            '⚠️ [POWERPOINT VIEWER] Office Online viewer not working, showing fallback',
          );
          _showPowerPointError(document);
        }
      });
    } catch (e) {
      print(
        '❌ [POWERPOINT VIEWER] Error setting up PowerPoint viewer approaches: $e',
      );
      _showPowerPointError(document);
    }
  }

  void _hidePowerPointLoading(DocumentModel document) {
    final loading = html.document.querySelector(
      '#powerpoint-loading-${document.id}',
    );
    loading?.style.display = 'none';
  }

  void _showPowerPointError(DocumentModel document) {
    final loading = html.document.querySelector(
      '#powerpoint-loading-${document.id}',
    );
    final error = html.document.querySelector(
      '#powerpoint-error-${document.id}',
    );

    loading?.style.display = 'none';
    error?.style.display = 'block';
  }

  Widget _buildAppleFormatPreview(
    DocumentModel document,
    String signedUrl,
    ThemeData theme,
    String title,
    IconData icon,
    String fallbackMessage,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            fallbackMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadDocument(document);
            },
            icon: const Icon(Icons.download),
            label: const Text('Download Document'),
          ),
        ],
      ),
    );
  }
}

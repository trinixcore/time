import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document_model.dart';
import '../models/folder_model.dart';
import '../enums/document_enums.dart';
import '../enums/user_role.dart';

class FirebaseDocumentService {
  static final FirebaseDocumentService _instance =
      FirebaseDocumentService._internal();
  factory FirebaseDocumentService() => _instance;
  FirebaseDocumentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String documentsCollection = 'documents';
  static const String foldersCollection = 'folders';
  static const String documentAccessLogsCollection = 'document_access_logs';

  /// Create a new document metadata
  Future<String> createDocument(DocumentModel document) async {
    try {
      final docRef = await _firestore
          .collection(documentsCollection)
          .add(document.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  /// Update document metadata
  Future<void> updateDocument(String documentId, DocumentModel document) async {
    try {
      await _firestore
          .collection(documentsCollection)
          .doc(documentId)
          .update(document.toFirestore());
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  /// Get document by ID
  Future<DocumentModel?> getDocument(String documentId) async {
    try {
      final doc =
          await _firestore
              .collection(documentsCollection)
              .doc(documentId)
              .get();

      if (!doc.exists) return null;

      return DocumentModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  /// Delete document metadata
  Future<void> deleteDocument(String documentId) async {
    try {
      await _firestore.collection(documentsCollection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  /// Get documents by category
  Future<List<DocumentModel>> getDocumentsByCategory(
    DocumentCategory category, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(documentsCollection)
          .where('category', isEqualTo: category.value)
          .orderBy('uploadedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get documents by category: $e');
    }
  }

  /// Get documents accessible by user role
  Future<List<DocumentModel>> getDocumentsForRole(
    UserRole role, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(documentsCollection)
          .where(
            'accessRoles',
            arrayContainsAny: [role.value, role.displayName],
          )
          .orderBy('uploadedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get documents for role: $e');
    }
  }

  /// Get documents accessible by user ID
  Future<List<DocumentModel>> getDocumentsForUser(
    String userId, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(documentsCollection)
          .where('accessUserIds', arrayContains: userId)
          .orderBy('uploadedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get documents for user: $e');
    }
  }

  /// Get documents in a folder
  Future<List<DocumentModel>> getDocumentsInFolder(
    String folderId, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(documentsCollection)
          .where('folderId', isEqualTo: folderId)
          .orderBy('uploadedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get documents in folder: $e');
    }
  }

  /// Search documents by filename or description
  Future<List<DocumentModel>> searchDocuments(
    String searchTerm, {
    UserRole? userRole,
    String? userId,
    DocumentCategory? category,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(documentsCollection);

      // Count the number of array filters to avoid Firestore limitations
      bool hasRoleFilter = userRole != null;
      bool hasUserFilter = userId != null;

      // If both role and user filters are needed, we'll prioritize role filter
      // and do client-side filtering for user access
      if (hasRoleFilter && !hasUserFilter) {
        // Only role-based filtering
        query = query.where(
          'accessRoles',
          arrayContainsAny: [userRole!.value, userRole.displayName],
        );
      } else if (!hasRoleFilter && hasUserFilter) {
        // Only user-based filtering
        query = query.where('accessUserIds', arrayContains: userId);
      }
      // If both filters are needed, we'll apply role filter in query
      // and user filter client-side to avoid Firestore limitations
      else if (hasRoleFilter && hasUserFilter) {
        query = query.where(
          'accessRoles',
          arrayContainsAny: [userRole!.value, userRole.displayName],
        );
      }

      // Add category filtering
      if (category != null) {
        query = query.where('category', isEqualTo: category.value);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      // Convert to documents and apply all filters
      var documents =
          querySnapshot.docs
              .map((doc) => DocumentModel.fromFirestore(doc))
              .toList();

      // Apply user-based filtering client-side if needed
      if (hasRoleFilter && hasUserFilter && userId != null) {
        documents =
            documents.where((doc) => doc.isAccessibleByUser(userId)).toList();
      }

      // Filter by search term (client-side filtering for complex text search)
      documents =
          documents
              .where(
                (doc) =>
                    doc.originalFileName.toLowerCase().contains(
                      searchTerm.toLowerCase(),
                    ) ||
                    (doc.description?.toLowerCase().contains(
                          searchTerm.toLowerCase(),
                        ) ??
                        false) ||
                    (doc.tags?.any(
                          (tag) => tag.toLowerCase().contains(
                            searchTerm.toLowerCase(),
                          ),
                        ) ??
                        false),
              )
              .toList();

      return documents;
    } catch (e) {
      throw Exception('Failed to search documents: $e');
    }
  }

  /// Get documents by status
  Future<List<DocumentModel>> getDocumentsByStatus(
    DocumentStatus status, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(documentsCollection)
          .where('status', isEqualTo: status.value)
          .orderBy('updatedAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => DocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get documents by status: $e');
    }
  }

  /// Create a new folder
  Future<String> createFolder(FolderModel folder) async {
    try {
      final docRef = await _firestore
          .collection(foldersCollection)
          .add(folder.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create folder: $e');
    }
  }

  /// Update folder metadata
  Future<void> updateFolder(String folderId, FolderModel folder) async {
    try {
      await _firestore
          .collection(foldersCollection)
          .doc(folderId)
          .update(folder.toFirestore());
    } catch (e) {
      throw Exception('Failed to update folder: $e');
    }
  }

  /// Get folder by ID
  Future<FolderModel?> getFolder(String folderId) async {
    try {
      final doc =
          await _firestore.collection(foldersCollection).doc(folderId).get();

      if (!doc.exists) return null;

      return FolderModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get folder: $e');
    }
  }

  /// Delete folder
  Future<void> deleteFolder(String folderId) async {
    try {
      await _firestore.collection(foldersCollection).doc(folderId).delete();
    } catch (e) {
      throw Exception('Failed to delete folder: $e');
    }
  }

  /// Get folders by parent ID
  Future<List<FolderModel>> getFoldersByParent(
    String? parentId, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(foldersCollection)
          .where('parentId', isEqualTo: parentId)
          .orderBy('createdAt', descending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => FolderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get folders by parent: $e');
    }
  }

  /// Get folders accessible by user role
  Future<List<FolderModel>> getFoldersForRole(
    UserRole role, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(foldersCollection)
          .where(
            'accessRoles',
            arrayContainsAny: [role.value, role.displayName],
          )
          .orderBy('createdAt', descending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => FolderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get folders for role: $e');
    }
  }

  /// Get folders by category
  Future<List<FolderModel>> getFoldersByCategory(
    DocumentCategory category, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(foldersCollection)
          .where('category', isEqualTo: category.value)
          .orderBy('createdAt', descending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => FolderModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get folders by category: $e');
    }
  }

  /// Log document access
  Future<void> logDocumentAccess({
    required String documentId,
    required String userId,
    required String userName,
    required String action, // 'view', 'download', 'preview'
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      await _firestore.collection(documentAccessLogsCollection).add({
        'documentId': documentId,
        'userId': userId,
        'userName': userName,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': ipAddress,
        'userAgent': userAgent,
      });
    } catch (e) {
      throw Exception('Failed to log document access: $e');
    }
  }

  /// Get document access logs
  Future<List<Map<String, dynamic>>> getDocumentAccessLogs(
    String documentId, {
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(documentAccessLogsCollection)
          .where('documentId', isEqualTo: documentId)
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Failed to get document access logs: $e');
    }
  }

  /// Batch update document access permissions
  Future<void> batchUpdateDocumentAccess(
    List<String> documentIds,
    List<String> accessRoles,
    List<String> accessUserIds,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final documentId in documentIds) {
        final docRef = _firestore
            .collection(documentsCollection)
            .doc(documentId);
        batch.update(docRef, {
          'accessRoles': accessRoles,
          'accessUserIds': accessUserIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update document access: $e');
    }
  }

  /// Get document statistics
  Future<Map<String, dynamic>> getDocumentStatistics({
    UserRole? userRole,
    String? userId,
    DocumentCategory? category,
  }) async {
    try {
      Query query = _firestore.collection(documentsCollection);

      if (userRole != null) {
        query = query.where(
          'accessRoles',
          arrayContainsAny: [userRole.value, userRole.displayName],
        );
      }

      if (userId != null) {
        query = query.where('accessUserIds', arrayContains: userId);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category.value);
      }

      final querySnapshot = await query.get();
      final documents =
          querySnapshot.docs
              .map((doc) => DocumentModel.fromFirestore(doc))
              .toList();

      // Calculate statistics
      final totalDocuments = documents.length;
      final totalSize = documents.fold<int>(
        0,
        (sum, doc) => sum + doc.fileSizeBytes,
      );
      final statusCounts = <String, int>{};
      final categoryCounts = <String, int>{};
      final fileTypeCounts = <String, int>{};

      for (final doc in documents) {
        // Status counts
        statusCounts[doc.status.value] =
            (statusCounts[doc.status.value] ?? 0) + 1;

        // Category counts
        categoryCounts[doc.category.value] =
            (categoryCounts[doc.category.value] ?? 0) + 1;

        // File type counts
        fileTypeCounts[doc.fileType.name] =
            (fileTypeCounts[doc.fileType.name] ?? 0) + 1;
      }

      return {
        'totalDocuments': totalDocuments,
        'totalSizeBytes': totalSize,
        'statusCounts': statusCounts,
        'categoryCounts': categoryCounts,
        'fileTypeCounts': fileTypeCounts,
        'averageFileSize': totalDocuments > 0 ? totalSize / totalDocuments : 0,
      };
    } catch (e) {
      throw Exception('Failed to get document statistics: $e');
    }
  }

  /// Stream documents for real-time updates
  Stream<List<DocumentModel>> streamDocuments({
    UserRole? userRole,
    String? userId,
    DocumentCategory? category,
    String? folderId,
    int? limit,
  }) {
    try {
      Query query = _firestore.collection(documentsCollection);
      bool needsClientSideSort = false;

      // Simplify query to avoid composite index requirements
      if (folderId != null) {
        query = query.where('folderId', isEqualTo: folderId);
        query = query.orderBy('uploadedAt', descending: true);
      } else if (category != null) {
        query = query.where('category', isEqualTo: category.value);
        // Skip orderBy to avoid composite index requirement
        needsClientSideSort = true;
      } else if (userRole != null && userRole.level < 80) {
        // Only filter by role for non-admin users
        query = query.where('accessRoles', arrayContains: userRole.value);
        // Skip orderBy to avoid composite index requirement
        needsClientSideSort = true;
      } else {
        // No filters, can use orderBy
        query = query.orderBy('uploadedAt', descending: true);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        var documents =
            snapshot.docs.map((doc) => DocumentModel.fromFirestore(doc)).where((
              doc,
            ) {
              // Client-side filtering for additional criteria
              if (userRole != null && userRole.level < 80) {
                if (!doc.isAccessibleByRole(userRole)) return false;
              }
              if (userId != null && !doc.isAccessibleByUser(userId)) {
                return false;
              }
              return true;
            }).toList();

        // Client-side sorting when needed
        if (needsClientSideSort) {
          documents.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
        }

        return documents;
      });
    } catch (e) {
      throw Exception('Failed to stream documents: $e');
    }
  }

  /// Stream folders for real-time updates
  Stream<List<FolderModel>> streamFolders({
    String? parentId,
    UserRole? userRole,
    DocumentCategory? category,
    int? limit,
  }) {
    try {
      Query query = _firestore.collection(foldersCollection);
      bool needsClientSideSort = false;

      // Simplify query to avoid composite index requirements
      if (parentId != null) {
        query = query.where('parentId', isEqualTo: parentId);
        query = query.orderBy('createdAt', descending: false);
      } else if (category != null) {
        query = query.where('category', isEqualTo: category.value);
        // Skip orderBy to avoid composite index requirement
        needsClientSideSort = true;
      } else if (userRole != null && userRole.level < 80) {
        // Only filter by role for non-admin users
        query = query.where('accessRoles', arrayContains: userRole.value);
        // Skip orderBy to avoid composite index requirement
        needsClientSideSort = true;
      } else {
        // No filters, can use orderBy
        query = query.orderBy('createdAt', descending: false);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        var folders =
            snapshot.docs.map((doc) => FolderModel.fromFirestore(doc)).where((
              folder,
            ) {
              // Client-side filtering for additional criteria
              if (userRole != null && userRole.level < 80) {
                if (!folder.isAccessibleByRole(userRole)) return false;
              }
              return true;
            }).toList();

        // Client-side sorting when needed
        if (needsClientSideSort) {
          folders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        }

        return folders;
      });
    } catch (e) {
      throw Exception('Failed to stream folders: $e');
    }
  }
}

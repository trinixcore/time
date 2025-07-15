import 'dart:typed_data';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_document_model.dart';
import 'supabase_service.dart';
import 'firebase_service.dart';
import '../config/supabase_config.dart';

class TaskDocumentService {
  static final TaskDocumentService _instance = TaskDocumentService._internal();
  factory TaskDocumentService() => _instance;
  TaskDocumentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseService _supabaseService = SupabaseService();
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();

  // Service role client for storage operations (bypasses RLS)
  SupabaseClient? _serviceClient;

  // Collection references
  CollectionReference get _taskDocumentsCollection =>
      _firestore.collection('task_documents');

  // Initialize service client
  Future<void> _initializeServiceClient() async {
    if (_serviceClient == null) {
      try {
        final url = await SupabaseConfig.url;
        final serviceRoleKey = await SupabaseConfig.serviceRoleKey;

        _serviceClient = SupabaseClient(url, serviceRoleKey);
        print(
          '✅ TaskDocumentService: Service client initialized with dynamic config',
        );
      } catch (e) {
        print('❌ TaskDocumentService: Failed to initialize service client: $e');
        throw Exception('Failed to initialize service client: $e');
      }
    }
  }

  /// Upload a document for a specific task
  Future<TaskDocumentModel> uploadTaskDocument({
    required Uint8List bytes,
    required String fileName,
    required String taskId,
    required String uploadedBy,
    required String uploadedByName,
    Function(double progress, String status)? onProgress,
    String? description,
    List<String>? tags,
  }) async {
    try {
      print('🔧 TaskDocumentService: Starting upload...');
      print('📄 File name: $fileName');
      print('📊 File size: ${bytes.length} bytes');
      print('🎯 Task ID: $taskId');
      print('👤 Uploaded by: $uploadedByName ($uploadedBy)');

      onProgress?.call(0.1, 'Validating file...');

      // File validation
      final fileExtension = path.extension(fileName).toLowerCase();
      final fileSize = bytes.length;

      // Check file size (50MB limit)
      if (fileSize > 50 * 1024 * 1024) {
        throw Exception('File size exceeds 50MB limit');
      }

      // Check file type
      final allowedExtensions = [
        '.pdf',
        '.doc',
        '.docx',
        '.pages',
        '.xls',
        '.xlsx',
        '.numbers',
        '.ppt',
        '.pptx',
        '.keynote',
        '.txt',
        '.csv',
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.zip',
        '.rar',
        '.mp4',
        '.mp3',
      ];

      if (!allowedExtensions.contains(fileExtension)) {
        throw Exception('File type not allowed');
      }

      onProgress?.call(0.2, 'Preparing upload...');

      // Generate IDs and paths
      final documentId = _uuid.v4();
      final supabasePath = 'task-management/$taskId/$documentId$fileExtension';

      // Calculate checksum
      final checksum = sha256.convert(bytes).toString();

      onProgress?.call(0.3, 'Uploading to storage...');

      // Initialize service client
      await _initializeServiceClient();

      print('🔧 TaskDocumentService: Using service role client for upload...');
      print('📁 Storage path: $supabasePath');
      print('🎭 Content type: ${_getMimeType(fileName)}');

      // Upload to Supabase task-management bucket using service client (bypasses RLS)
      await _serviceClient!.storage
          .from('task-management')
          .uploadBinary(
            supabasePath,
            bytes,
            fileOptions: FileOptions(
              contentType: _getMimeType(fileName),
              upsert: false,
            ),
          );

      print('✅ TaskDocumentService: Upload to Supabase successful');

      onProgress?.call(0.8, 'Saving metadata...');

      // Create document model
      final document = TaskDocumentModel(
        id: documentId,
        taskId: taskId,
        fileName: fileName,
        originalFileName: fileName,
        supabasePath: supabasePath,
        firebasePath: 'task_documents/$documentId',
        fileType: fileExtension,
        mimeType: _getMimeType(fileName),
        fileSizeBytes: fileSize,
        uploadedBy: uploadedBy,
        uploadedByName: uploadedByName,
        uploadedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: description,
        tags: tags,
        checksum: checksum,
        isConfidential: false,
        status: 'approved',
      );

      // Save to Firebase
      print('💾 TaskDocumentService: Saving to Firestore...');
      final docRef = await _taskDocumentsCollection.add(document.toJson());
      final updatedDocument = document.copyWith(id: docRef.id);
      await _taskDocumentsCollection
          .doc(docRef.id)
          .update(updatedDocument.toJson());

      print('✅ TaskDocumentService: Firestore save successful');

      onProgress?.call(1.0, 'Upload completed successfully!');

      return updatedDocument;
    } catch (e) {
      print('💥 TaskDocumentService: Upload failed: $e');
      onProgress?.call(0.0, 'Upload failed: ${e.toString()}');
      rethrow;
    }
  }

  /// Get all documents for a specific task
  Future<List<TaskDocumentModel>> getTaskDocuments(String taskId) async {
    try {
      print('🔍 TaskDocumentService: Getting documents for task: $taskId');

      final querySnapshot =
          await _taskDocumentsCollection
              .where('taskId', isEqualTo: taskId)
              .orderBy('uploadedAt', descending: true)
              .get();

      final documents =
          querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Convert Firestore Timestamps to DateTime objects for existing data
            final convertedData = Map<String, dynamic>.from(data);

            // Handle timestamp fields
            final timestampFields = ['uploadedAt', 'updatedAt'];
            for (final field in timestampFields) {
              if (convertedData[field] is Timestamp) {
                convertedData[field] =
                    (convertedData[field] as Timestamp)
                        .toDate()
                        .toIso8601String();
              }
            }

            return TaskDocumentModel.fromJson(convertedData);
          }).toList();

      print('✅ TaskDocumentService: Found ${documents.length} documents');
      return documents;
    } catch (e) {
      print('💥 TaskDocumentService: Failed to get documents: $e');
      throw Exception('Failed to get task documents: $e');
    }
  }

  /// Get a single task document by ID
  Future<TaskDocumentModel?> getTaskDocumentById(String documentId) async {
    try {
      print('🔍 TaskDocumentService: Getting document by ID: $documentId');

      final doc = await _taskDocumentsCollection.doc(documentId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Firestore Timestamps to DateTime objects for existing data
        final convertedData = Map<String, dynamic>.from(data);

        // Handle timestamp fields
        final timestampFields = ['uploadedAt', 'updatedAt'];
        for (final field in timestampFields) {
          if (convertedData[field] is Timestamp) {
            convertedData[field] =
                (convertedData[field] as Timestamp).toDate().toIso8601String();
          }
        }

        return TaskDocumentModel.fromJson(convertedData);
      }
      return null;
    } catch (e) {
      print('💥 TaskDocumentService: Failed to get document: $e');
      throw Exception('Failed to get task document: $e');
    }
  }

  /// Delete a task document
  Future<void> deleteTaskDocument(String documentId) async {
    try {
      print('🗑️ TaskDocumentService: Deleting document: $documentId');

      final document = await getTaskDocumentById(documentId);
      if (document != null) {
        // Initialize service client
        await _initializeServiceClient();

        // Delete from Supabase using service client
        print('🗑️ TaskDocumentService: Deleting from Supabase...');
        await _serviceClient!.storage.from('task-management').remove([
          document.supabasePath,
        ]);

        // Delete from Firebase
        print('🗑️ TaskDocumentService: Deleting from Firestore...');
        await _taskDocumentsCollection.doc(documentId).delete();

        print('✅ TaskDocumentService: Document deleted successfully');
      }
    } catch (e) {
      print('💥 TaskDocumentService: Failed to delete document: $e');
      throw Exception('Failed to delete task document: $e');
    }
  }

  /// Delete all documents for a specific task
  Future<void> deleteAllTaskDocuments(String taskId) async {
    try {
      print(
        '🗑️ TaskDocumentService: Deleting all documents for task: $taskId',
      );

      // Get all documents for the task
      final documents = await getTaskDocuments(taskId);

      if (documents.isEmpty) {
        print('ℹ️ TaskDocumentService: No documents found for task: $taskId');
        return;
      }

      // Initialize service client
      await _initializeServiceClient();

      // Collect all Supabase paths to delete
      final supabasePaths = documents.map((doc) => doc.supabasePath).toList();

      // Delete from Supabase using service client
      print(
        '🗑️ TaskDocumentService: Deleting ${documents.length} documents from Supabase...',
      );
      await _serviceClient!.storage
          .from('task-management')
          .remove(supabasePaths);

      // Delete all documents from Firebase
      print(
        '🗑️ TaskDocumentService: Deleting ${documents.length} documents from Firestore...',
      );
      final batch = _firestore.batch();
      for (final document in documents) {
        batch.delete(_taskDocumentsCollection.doc(document.id));
      }
      await batch.commit();

      print(
        '✅ TaskDocumentService: All documents deleted successfully for task: $taskId',
      );
    } catch (e) {
      print('💥 TaskDocumentService: Failed to delete task documents: $e');
      throw Exception('Failed to delete task documents: $e');
    }
  }

  /// Get signed URL for document preview/download
  Future<String> getTaskDocumentUrl(String documentId) async {
    try {
      print(
        '🔗 TaskDocumentService: Getting signed URL for document: $documentId',
      );

      final document = await getTaskDocumentById(documentId);
      if (document == null) {
        throw Exception('Document not found');
      }

      // Initialize service client
      await _initializeServiceClient();

      // Use service client to generate signed URL with dynamic expiry
      final signedUrl = await _serviceClient!.storage
          .from('task-management')
          .createSignedUrl(
            document.supabasePath,
            await SupabaseConfig.taskDocumentExpiry, // Dynamic expiry
          );

      // print('✅ TaskDocumentService: Signed URL generated successfully');
      return signedUrl;
    } catch (e) {
      print('💥 TaskDocumentService: Failed to get document URL: $e');
      throw Exception('Failed to get document URL: $e');
    }
  }

  /// Update task document metadata
  Future<void> updateTaskDocument(
    String documentId,
    TaskDocumentModel document,
  ) async {
    try {
      print('✏️ TaskDocumentService: Updating document: $documentId');

      await _taskDocumentsCollection.doc(documentId).update(document.toJson());

      print('✅ TaskDocumentService: Document updated successfully');
    } catch (e) {
      print('💥 TaskDocumentService: Failed to update document: $e');
      throw Exception('Failed to update task document: $e');
    }
  }

  /// Get MIME type for file
  String _getMimeType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.ppt':
        return 'application/vnd.ms-powerpoint';
      case '.pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case '.txt':
        return 'text/plain';
      case '.csv':
        return 'text/csv';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.zip':
        return 'application/zip';
      case '.rar':
        return 'application/x-rar-compressed';
      case '.mp4':
        return 'video/mp4';
      case '.mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }
}

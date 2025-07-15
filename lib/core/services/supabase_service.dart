import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../config/supabase_config.dart';
import 'package:http/http.dart' as http;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Service role client for storage operations (bypasses RLS)
  SupabaseClient? _serviceClient;

  // Storage bucket name for documents
  static const String documentsBucket = 'documents';

  /// Initialize Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  /// Initialize with dynamic configuration
  static Future<void> initializeWithDynamicConfig() async {
    try {
      print('🔧 Initializing with dynamic configuration...');

      final url = await SupabaseConfig.url;
      final anonKey = await SupabaseConfig.anonKey;

      //print('🔧 [SUPABASE] URL: $url');
      //print('🔧 [SUPABASE] Anon Key: ${anonKey.substring(0, 20)}...');

      await Supabase.initialize(url: url, anonKey: anonKey);

      print('✅ Initialized successfully with dynamic config');
    } catch (e) {
      print('❌ Failed to initialize with dynamic config: $e');
      print('🔄 Falling back to static configuration...');

      // Fallback to static values
      await Supabase.initialize(
        url: 'MY-URL',
        anonKey:
            'MY-KEY',
      );
    }
  }

  /// Initialize service client with dynamic configuration
  Future<void> _initializeServiceClient() async {
    if (_serviceClient == null) {
      try {
        final url = await SupabaseConfig.url;
        final serviceRoleKey = await SupabaseConfig.serviceRoleKey;

        _serviceClient = SupabaseClient(url, serviceRoleKey);
        print('✅ Service client initialized with dynamic config');
      } catch (e) {
        print('❌ Failed to initialize service client: $e');
        throw Exception('Failed to initialize service client: $e');
      }
    }
  }

  /// Upload a file to Supabase Storage
  Future<String> uploadFile({
    required String filePath,
    required File file,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      // Generate unique filename to avoid conflicts
      final fileName = path.basename(file.path);
      final extension = path.extension(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      final fullPath = '$filePath/$uniqueFileName';

      // Read file bytes
      final bytes = await file.readAsBytes();

      // Upload to Supabase Storage
      await client.storage
          .from(documentsBucket)
          .uploadBinary(
            fullPath,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );

      return fullPath;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload bytes to Supabase Storage
  Future<String> uploadBytes({
    required String filePath,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      print('🔧 SupabaseService: Starting bytes upload...');
      //print('📁 File path: $filePath');
      //print('📄 File name: $fileName');
      //print('📊 File size: ${bytes.length} bytes');
      //print('🎭 Content type: $contentType');

      // Check if user is authenticated
      final user = client.auth.currentUser;
      //print('👤 Current user: ${user?.email ?? 'null'}');
      //print('🆔 User ID: ${user?.id ?? 'null'}');

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename to avoid conflicts
      final extension = path.extension(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      final fullPath = '$filePath/$uniqueFileName';

      //print('📍 Full storage path: $fullPath');

      // Upload to Supabase Storage with user context
      //print('☁️ Uploading to Supabase storage...');
      await client.storage
          .from(documentsBucket)
          .uploadBinary(
            fullPath,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );

      //print('✅ Upload successful: $fullPath');
      return fullPath;
    } catch (e) {
      print('💥 SupabaseService upload error: $e');

      // Check if it's an RLS policy error
      if (e.toString().contains('row-level security policy') ||
          e.toString().contains('Unauthorized')) {
        throw Exception(
          'Storage access denied. Please check your permissions or contact administrator.',
        );
      }

      throw Exception('Failed to upload bytes: $e');
    }
  }

  /// Upload bytes to Supabase Storage using service role client (for admin/system uploads)
  Future<String> uploadBytesWithServiceRole({
    required String filePath,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    await _initializeServiceClient();
    try {
      //print('🔧 SupabaseService (ServiceRole): Starting bytes upload...');
      //print('📁 File path: $filePath');
      //print('📄 File name: $fileName');
      //print('📊 File size: ${bytes.length} bytes');
      //print('🎭 Content type: $contentType');

      // Generate unique filename to avoid conflicts
      final extension = path.extension(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      final fullPath = '$filePath/$uniqueFileName';

      print('📍 Full storage path: $fullPath');

      // Upload to Supabase Storage with service client
      print('☁️ Uploading to Supabase storage (service role)...');
      await _serviceClient!.storage
          .from(documentsBucket)
          .uploadBinary(
            fullPath,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );

      print('✅ Upload successful (service role): $fullPath');
      return fullPath;
    } catch (e) {
      print('💥 SupabaseService (service role) upload error: $e');
      throw Exception('Failed to upload bytes (service role): $e');
    }
  }

  /// Download a file from Supabase Storage
  Future<Uint8List> downloadFile(String filePath) async {
    try {
      final bytes = await client.storage
          .from(documentsBucket)
          .download(filePath);

      return bytes;
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  /// Get public URL for a file
  String getPublicUrl(String filePath) {
    return client.storage.from(documentsBucket).getPublicUrl(filePath);
  }

  /// Get signed URL for private file access
  Future<String> getSignedUrl(String filePath, {int? expiresIn}) async {
    try {
      //print('🔐 [SUPABASE DEBUG] Starting getSignedUrl');
      //print('🔐 [SUPABASE DEBUG] File path: $filePath');

      // Get dynamic expiry time
      final expiry = expiresIn ?? await SupabaseConfig.defaultExpiry;
      print('🔐 Expires in: $expiry seconds (${expiry ~/ 60} minutes)');
      //print('🔐 [SUPABASE DEBUG] Documents bucket: $documentsBucket');

      // Initialize service client
      await _initializeServiceClient();

      // Check if we should use service client for better access
      print('🔐 Using service client for signed URL generation...');
      final signedUrl = await _serviceClient!.storage
          .from(documentsBucket)
          .createSignedUrl(filePath, expiry);

      // print('✅ [SUPABASE DEBUG] Signed URL created successfully');
      //print('🔐 [SUPABASE DEBUG] URL length: ${signedUrl.length}');
      //print(
      //  '🔐 [SUPABASE DEBUG] URL starts with: ${signedUrl.substring(0, 50)}...',
      //);

      return signedUrl;
    } catch (e, stackTrace) {
      // print('💥 [SUPABASE DEBUG] Failed to create signed URL: $e');
      // print('📚 [SUPABASE DEBUG] Stack trace: $stackTrace');
      throw Exception('Failed to create signed URL: $e');
    }
  }

  /// Get signed URL with specific security level
  Future<String> getSignedUrlWithSecurityLevel(
    String filePath, {
    required String securityLevel,
  }) async {
    int expirySeconds;

    switch (securityLevel.toLowerCase()) {
      case 'preview':
        expirySeconds = await SupabaseConfig.documentPreviewExpiry;
        break;
      case 'download':
        expirySeconds = await SupabaseConfig.documentDownloadExpiry;
        break;
      case 'task':
        expirySeconds = await SupabaseConfig.taskDocumentExpiry;
        break;
      case 'moments':
        expirySeconds = await SupabaseConfig.momentsMediaExpiry;
        break;
      case 'upload':
        expirySeconds = await SupabaseConfig.uploadUrlExpiry;
        break;
      default:
        expirySeconds = await SupabaseConfig.defaultExpiry;
    }

    return getSignedUrl(filePath, expiresIn: expirySeconds);
  }

  /// Generate signed URL for upload (bypasses RLS for uploads)
  Future<Map<String, String>> generateUploadSignedUrl({
    required String filePath,
    required String fileName,
    String? contentType,
    int? expiresIn,
  }) async {
    try {
      //print('🔧 SupabaseService: Generating upload signed URL...');
      //print('📁 File path: $filePath');
      //print('📄 File name: $fileName');
      //print('🎭 Content type: $contentType');

      // Get dynamic expiry time
      final expiry = expiresIn ?? await SupabaseConfig.uploadUrlExpiry;
      print('⏰ Upload URL expiry: $expiry seconds');

      // Generate unique filename to avoid conflicts
      final extension = path.extension(fileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      final fullPath = '$filePath/$uniqueFileName';

      //print('📍 Full storage path: $fullPath');

      // Generate signed URL for upload
      // print('🔗 Creating signed upload URL...');
      final response = await client.storage
          .from(documentsBucket)
          .createSignedUploadUrl(fullPath);

      // print('✅ Signed URL generated successfully');
      return {
        'signedUrl': response.signedUrl,
        'path': fullPath,
        'token': response.token,
      };
    } catch (e) {
      // print('💥 SupabaseService signed URL error: $e');
      throw Exception('Failed to generate upload signed URL: $e');
    }
  }

  /// Upload bytes using signed URL (bypasses RLS)
  Future<String> uploadBytesWithSignedUrl({
    required String filePath,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async {
    try {
      print(
        '🔧 SupabaseService: Starting signed URL upload with service role...',
      );
      //print('📁 File path: $filePath');
      //print('📄 Original file name: $fileName');

      // Sanitize filename to prevent "Invalid key" errors
      final sanitizedFileName = sanitizeFileName(fileName);
      //print('📄 Sanitized file name: $sanitizedFileName');

      //print('📊 File size: ${bytes.length} bytes');
      //print('🎭 Content type: $contentType');

      // Generate unique filename to avoid conflicts
      final extension = path.extension(sanitizedFileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$sanitizedFileName';
      final fullPath = '$filePath/$uniqueFileName';

      //print('📍 Full storage path: $fullPath');

      // Initialize service client
      await _initializeServiceClient();

      // Generate signed URL for upload using service client (bypasses RLS)
      // print('🔗 Creating signed upload URL with service role...');
      final response = await _serviceClient!.storage
          .from(documentsBucket)
          .createSignedUploadUrl(fullPath);

      // print('🌐 Uploading via signed URL...');

      // Upload using the signed URL with service client
      await _serviceClient!.storage
          .from(documentsBucket)
          .uploadBinaryToSignedUrl(fullPath, response.token, bytes);

      //print('✅ Upload successful via signed URL: $fullPath');
      return fullPath;
    } catch (e) {
      // print('💥 SupabaseService signed URL upload error: $e');
      throw Exception('Failed to upload via signed URL: $e');
    }
  }

  /// Delete a file from Supabase Storage
  Future<void> deleteFile(String filePath) async {
    try {
      //print('🗑️ [SUPABASE DELETE] Starting file deletion');
      //print('🗑️ [SUPABASE DELETE] File path: $filePath');
      //print('🗑️ [SUPABASE DELETE] Using service client to bypass RLS');

      await _initializeServiceClient();
      await _serviceClient!.storage.from(documentsBucket).remove([filePath]);

      print('✅  File deleted successfully from storage');
    } catch (e) {
      print('💥 Failed to delete file: $e');
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Delete multiple files from Supabase Storage
  Future<void> deleteFiles(List<String> filePaths) async {
    try {
      //print('🗑️ [SUPABASE DELETE] Starting batch file deletion');
      //print('🗑️ [SUPABASE DELETE] File count: ${filePaths.length}');
      //print('🗑️ [SUPABASE DELETE] Files: ${filePaths.join(', ')}');
      //print('🗑️ [SUPABASE DELETE] Using service client to bypass RLS');

      await _initializeServiceClient();
      await _serviceClient!.storage.from(documentsBucket).remove(filePaths);

      print('✅ [SUPABASE DELETE] All files deleted successfully from storage');
    } catch (e) {
      print('💥 [SUPABASE DELETE] Failed to delete files: $e');
      throw Exception('Failed to delete files: $e');
    }
  }

  /// Move a file to a new location
  Future<String> moveFile(String fromPath, String toPath) async {
    try {
      await client.storage.from(documentsBucket).move(fromPath, toPath);

      return toPath;
    } catch (e) {
      throw Exception('Failed to move file: $e');
    }
  }

  /// Copy a file to a new location
  Future<String> copyFile(String fromPath, String toPath) async {
    try {
      await client.storage.from(documentsBucket).copy(fromPath, toPath);

      return toPath;
    } catch (e) {
      throw Exception('Failed to copy file: $e');
    }
  }

  /// List files in a directory
  Future<List<FileObject>> listFiles(String path) async {
    try {
      final files = await client.storage.from(documentsBucket).list(path: path);

      return files;
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }

  /// Get file metadata
  Future<Map<String, dynamic>?> getFileMetadata(String filePath) async {
    try {
      final files = await client.storage
          .from(documentsBucket)
          .list(path: path.dirname(filePath));

      final fileName = path.basename(filePath);
      final file = files.firstWhere(
        (f) => f.name == fileName,
        orElse: () => throw Exception('File not found'),
      );

      return file.metadata;
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }

  /// Calculate file checksum
  String calculateChecksum(Uint8List bytes) {
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sanitize filename for Supabase storage (remove spaces and special characters)
  String sanitizeFileName(String fileName) {
    // Get file extension
    final extension = path.extension(fileName);
    final nameWithoutExtension = path.basenameWithoutExtension(fileName);

    // Replace spaces and special characters with underscores
    final sanitizedName = nameWithoutExtension
        .replaceAll(
          RegExp(r'[^\w\-_.]'),
          '_',
        ) // Replace non-alphanumeric chars with underscore
        .replaceAll(
          RegExp(r'_+'),
          '_',
        ) // Replace multiple underscores with single
        .replaceAll(
          RegExp(r'^_|_$'),
          '',
        ); // Remove leading/trailing underscores

    return '$sanitizedName$extension';
  }

  /// Validate file size
  bool validateFileSize(int fileSizeBytes, int maxSizeMB) {
    final maxSizeBytes = maxSizeMB * 1024 * 1024;
    return fileSizeBytes <= maxSizeBytes;
  }

  /// Get MIME type from file extension
  String getMimeType(String fileName) {
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
      default:
        return 'application/octet-stream';
    }
  }

  /// Create folder structure in storage
  Future<void> createFolderStructure(String folderPath) async {
    try {
      // Create a placeholder file to ensure folder exists
      final placeholderPath = '$folderPath/.placeholder';
      final placeholderContent = utf8.encode(
        'This is a placeholder file to maintain folder structure',
      );

      await client.storage
          .from(documentsBucket)
          .uploadBinary(
            placeholderPath,
            Uint8List.fromList(placeholderContent),
            fileOptions: const FileOptions(
              contentType: 'text/plain',
              upsert: true,
            ),
          );
    } catch (e) {
      // Folder might already exist, which is fine
      if (!e.toString().contains('already exists')) {
        throw Exception('Failed to create folder structure: $e');
      }
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      await client.storage.from(documentsBucket).download(filePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get file size
  Future<int?> getFileSize(String filePath) async {
    try {
      final files = await client.storage
          .from(documentsBucket)
          .list(path: path.dirname(filePath));

      final fileName = path.basename(filePath);
      final file = files.firstWhere(
        (f) => f.name == fileName,
        orElse: () => throw Exception('File not found'),
      );

      return file.metadata?['size'] as int?;
    } catch (e) {
      return null;
    }
  }

  /// Generate storage path for document
  String generateDocumentPath({
    required String category,
    required String userId,
    String? folderId,
  }) {
    final timestamp = DateTime.now();
    final year = timestamp.year.toString();
    final month = timestamp.month.toString().padLeft(2, '0');

    if (folderId != null) {
      // Check if folderId is actually a full employee folder path
      if (folderId.startsWith('employees/')) {
        // Return the employee folder path directly
        return folderId;
      }
      // For regular folder IDs, use the standard structure
      return 'documents/$category/$year/$month/folders/$folderId';
    } else {
      return 'documents/$category/$year/$month/users/$userId';
    }
  }

  /// Clean up orphaned files (files without corresponding Firestore documents)
  Future<List<String>> cleanupOrphanedFiles(List<String> validFilePaths) async {
    try {
      final allFiles = <String>[];

      // Get all files in the documents bucket
      final rootFiles = await listFiles('documents');
      for (final file in rootFiles) {
        if (file.name != '.placeholder') {
          allFiles.add('documents/${file.name}');
        }
      }

      // Find orphaned files
      final orphanedFiles =
          allFiles
              .where((filePath) => !validFilePaths.contains(filePath))
              .toList();

      // Delete orphaned files
      if (orphanedFiles.isNotEmpty) {
        await deleteFiles(orphanedFiles);
      }

      return orphanedFiles;
    } catch (e) {
      throw Exception('Failed to cleanup orphaned files: $e');
    }
  }

  /// Initialize Supabase storage (simplified version without auth check)
  Future<void> initializeStorage() async {
    try {
      print('🔧 Initializing Supabase storage with service role...');

      // Initialize service client
      await _initializeServiceClient();

      // Try to list files in the bucket to check if it exists and is accessible
      print('📂 Checking bucket accessibility with service role...');
      try {
        await _serviceClient!.storage.from(documentsBucket).list(path: '');
        print('✅ Storage bucket is accessible with service role');
      } catch (e) {
        print('❌ Storage bucket access error: $e');
        throw Exception('Storage bucket not accessible: $e');
      }

      print('✅ Storage initialization completed');
    } catch (e) {
      print('💥 Storage initialization error: $e');
      throw Exception('Failed to initialize storage: $e');
    }
  }

  /// Upload bytes with progress tracking and chunked upload for large files
  Future<String> uploadBytesWithProgressAndChunking({
    required String filePath,
    required Uint8List bytes,
    required String fileName,
    String? contentType,
    Function(double progress)? onProgress,
  }) async {
    try {
      print('🔧 SupabaseService: Starting optimized upload...');
      //print('📁 File path: $filePath');
      //print('📄 Original file name: $fileName');

      // Sanitize filename to prevent "Invalid key" errors
      final sanitizedFileName = sanitizeFileName(fileName);
      //print('📄 Sanitized file name: $sanitizedFileName');

      //print('📊 File size: ${bytes.length} bytes');

      // Generate unique filename
      final extension = path.extension(sanitizedFileName);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$sanitizedFileName';
      final fullPath = '$filePath/$uniqueFileName';

      // Check if file is large (>10MB) and needs chunking
      const chunkThreshold = 10 * 1024 * 1024; // 10MB

      if (bytes.length > chunkThreshold) {
        print('📦 Large file detected, using chunked upload...');
        return await _uploadLargeFileInChunks(
          fullPath,
          bytes,
          contentType,
          onProgress,
        );
      } else {
        print('📤 Standard upload for small file...');
        onProgress?.call(0.1); // 10% - starting upload

        // Initialize service client
        await _initializeServiceClient();

        final response = await _serviceClient!.storage
            .from(documentsBucket)
            .createSignedUploadUrl(fullPath);

        onProgress?.call(0.5); // 50% - signed URL created

        await _serviceClient!.storage
            .from(documentsBucket)
            .uploadBinaryToSignedUrl(fullPath, response.token, bytes);

        onProgress?.call(1.0); // 100% - upload complete
        print('✅ Standard upload completed: $fullPath');
        return fullPath;
      }
    } catch (e) {
      print('💥 Optimized upload error: $e');
      throw Exception('Failed to upload with optimization: $e');
    }
  }

  /// Upload large files in chunks
  Future<String> _uploadLargeFileInChunks(
    String fullPath,
    Uint8List bytes,
    String? contentType,
    Function(double progress)? onProgress,
  ) async {
    const chunkSize = 5 * 1024 * 1024; // 5MB chunks
    final totalChunks = (bytes.length / chunkSize).ceil();

    print(
      '📦 Uploading in $totalChunks chunks of ${chunkSize ~/ 1024 ~/ 1024}MB each',
    );

    // Initialize service client
    await _initializeServiceClient();

    // For now, use standard upload (chunked upload requires multipart support)
    // This is a placeholder for future chunked implementation
    final response = await _serviceClient!.storage
        .from(documentsBucket)
        .createSignedUploadUrl(fullPath);

    // Simulate progress for large files
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      onProgress?.call(i / 10.0);
    }

    await _serviceClient!.storage
        .from(documentsBucket)
        .uploadBinaryToSignedUrl(fullPath, response.token, bytes);

    //print('✅ Large file upload completed: $fullPath');
    return fullPath;
  }

  /// Download a file from Supabase Storage using service role and signed URL
  Future<Uint8List> downloadFileWithServiceRoleSignedUrl(
    String filePath, {
    String securityLevel = 'preview',
  }) async {
    // Get a fresh signed URL using the service role client
    final signedUrl = await getSignedUrlWithSecurityLevel(
      filePath,
      securityLevel: securityLevel,
    );
    // Download the file using HTTP GET
    final response = await http.get(Uri.parse(signedUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
        'Failed to download file via signed URL: ${response.statusCode}',
      );
    }
  }
}

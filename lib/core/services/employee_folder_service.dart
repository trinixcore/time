import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'dart:typed_data';
import '../models/user_model.dart';
import '../models/folder_model.dart';
import '../enums/document_enums.dart';
import 'supabase_service.dart';
import 'firebase_service.dart';

class EmployeeFolderService {
  static final EmployeeFolderService _instance =
      EmployeeFolderService._internal();
  factory EmployeeFolderService() => _instance;
  EmployeeFolderService._internal();

  final SupabaseService _supabaseService = SupabaseService();
  final FirebaseService _firebaseService = FirebaseService();
  static final Logger _logger = Logger();

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  /// Predefined folder structure for employees
  static const List<Map<String, String>> _employeeFolderStructure = [
    {
      'code': '01',
      'name': 'offer-letter',
      'description': 'Offer letter and employment contract',
    },
    {
      'code': '02',
      'name': 'payslips',
      'description': 'Monthly payslips and salary documents',
    },
    {
      'code': '03',
      'name': 'appraisal',
      'description': 'Performance appraisal documents',
    },
    {
      'code': '04',
      'name': 'resignation',
      'description': 'Resignation letter and exit documents',
    },
    {
      'code': '05',
      'name': 'kyc-documents',
      'description': 'KYC and identity verification documents',
    },
    {
      'code': '06',
      'name': 'employment-verification',
      'description': 'Employment verification letters',
    },
    {
      'code': '07',
      'name': 'policies-acknowledged',
      'description': 'Acknowledged company policies',
    },
    {
      'code': '08',
      'name': 'training-certificates',
      'description': 'Training and certification documents',
    },
    {
      'code': '09',
      'name': 'leave-documents',
      'description': 'Leave applications and approvals',
    },
    {
      'code': '10',
      'name': 'loan-agreements',
      'description': 'Loan agreements and financial documents',
    },
    {
      'code': '11',
      'name': 'infra-assets',
      'description': 'Infrastructure and asset allocation documents',
    },
    {
      'code': '12',
      'name': 'performance-warnings',
      'description': 'Performance improvement and warning letters',
    },
    {
      'code': '13',
      'name': 'awards-recognition',
      'description': 'Awards and recognition certificates',
    },
    {
      'code': '14',
      'name': 'feedbacks-surveys',
      'description': 'Feedback forms and survey responses',
    },
    {
      'code': '15',
      'name': 'exit-clearance',
      'description': 'Exit clearance and handover documents',
    },
    {
      'code': '99',
      'name': 'personal',
      'description': 'Personal documents and miscellaneous files',
    },
  ];

  /// Create complete folder structure for a new employee
  Future<Map<String, dynamic>> createEmployeeFolderStructure({
    required String employeeId,
    required String fullName,
    required String createdBy,
    required String createdByName,
    required String userId,
  }) async {
    _logger.i(
      'Creating employee folder structure for: $employeeId - $fullName',
    );

    try {
      // Generate folder path
      final employeeFolderPath =
          'employees/${employeeId}_${_sanitizeFolderName(fullName)}';

      _logger.i('Employee folder path: $employeeFolderPath');

      // Create main employee folder in Supabase
      await _createFolderInSupabase(employeeFolderPath);

      // Create all subfolders
      final createdFolders = <String, dynamic>{};
      final folderMetadata = <Map<String, dynamic>>[];

      for (final folderConfig in _employeeFolderStructure) {
        final folderName = '${folderConfig['code']}_${folderConfig['name']}';
        final folderPath = '$employeeFolderPath/$folderName';

        try {
          // Create folder in Supabase
          await _createFolderInSupabase(folderPath);

          // Create folder metadata for Firestore
          final folderModel = FolderModel(
            id: '${employeeId}_${folderConfig['code']}',
            name: folderName,
            path: folderPath,
            parentId: employeeId,
            category: DocumentCategory.employee,
            accessLevel: DocumentAccessLevel.private,
            createdBy: createdBy,
            createdByName: createdByName,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            accessRoles: ['hr', 'admin', 'superAdmin'],
            accessUserIds: [userId, createdBy],
            description: folderConfig['description'],
            documentCount: 0,
            subfolderCount: 0,
            tags: ['employee-folder', 'auto-created'],
            metadata: {
              'employeeId': employeeId,
              'folderCode': folderConfig['code'],
              'folderType': 'employee-document',
              'autoCreated': true,
            },
          );

          folderMetadata.add(folderModel.toFirestore());
          createdFolders[folderConfig['code']!] = folderPath;

          _logger.i('Created folder: $folderPath');
        } catch (e) {
          _logger.e('Failed to create folder ${folderConfig['name']}: $e');
          // Continue with other folders even if one fails
        }
      }

      // Log folder creation in Firestore
      await _logFolderCreation(
        employeeId: employeeId,
        fullName: fullName,
        userId: userId,
        createdBy: createdBy,
        createdByName: createdByName,
        folderPath: employeeFolderPath,
        createdFolders: createdFolders,
        folderMetadata: folderMetadata,
      );

      _logger.i(
        'Successfully created employee folder structure for: $employeeId',
      );

      return {
        'success': true,
        'employeeFolderPath': employeeFolderPath,
        'createdFolders': createdFolders,
        'folderCount': createdFolders.length,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('Failed to create employee folder structure: $e');

      // Log the failure
      await _logFolderCreation(
        employeeId: employeeId,
        fullName: fullName,
        userId: userId,
        createdBy: createdBy,
        createdByName: createdByName,
        folderPath: 'employees/${employeeId}_${_sanitizeFolderName(fullName)}',
        createdFolders: {},
        folderMetadata: [],
        error: e.toString(),
      );

      throw Exception('Failed to create employee folder structure: $e');
    }
  }

  /// Create a folder in Supabase storage
  Future<void> _createFolderInSupabase(String folderPath) async {
    try {
      // Create a placeholder file to establish the folder
      // Supabase storage doesn't support empty folders, so we create a .keep file
      final keepContent =
          'This folder was auto-created for employee documents.';
      final keepBytes = Uint8List.fromList(keepContent.codeUnits);

      // Upload using service role method to bypass RLS authentication
      // This is essential during user creation when no user is authenticated
      await _supabaseService.uploadBytesWithSignedUrl(
        filePath: folderPath,
        bytes: keepBytes,
        fileName: '.keep',
        contentType: 'text/plain',
      );

      _logger.i('Created folder in Supabase: $folderPath');
    } catch (e) {
      _logger.e('Failed to create folder in Supabase: $folderPath - $e');
      // Don't throw here, let the caller handle it
      rethrow;
    }
  }

  /// Log folder creation metadata in Firestore
  Future<void> _logFolderCreation({
    required String employeeId,
    required String fullName,
    required String userId,
    required String createdBy,
    required String createdByName,
    required String folderPath,
    required Map<String, dynamic> createdFolders,
    required List<Map<String, dynamic>> folderMetadata,
    String? error,
  }) async {
    try {
      final logData = {
        'employeeId': employeeId,
        'fullName': fullName,
        'userId': userId,
        'createdBy': createdBy,
        'createdByName': createdByName,
        'folderPath': folderPath,
        'createdFolders': createdFolders,
        'folderMetadata': folderMetadata,
        'totalFoldersCreated': createdFolders.length,
        'createdAt': FieldValue.serverTimestamp(),
        'success': error == null,
        if (error != null) 'error': error,
        'version': '1.0',
        'source': 'employee_folder_service',
      };

      // Store in employeeFolders collection
      await _firestore
          .collection('employeeFolders')
          .doc(employeeId)
          .set(logData);

      // Also store individual folder metadata
      final batch = _firestore.batch();
      for (final folder in folderMetadata) {
        final folderRef = _firestore
            .collection('employeeFolders')
            .doc(employeeId)
            .collection('folders')
            .doc(folder['id']);
        batch.set(folderRef, folder);
      }
      await batch.commit();

      _logger.i('Logged folder creation for employee: $employeeId');
    } catch (e) {
      _logger.e('Failed to log folder creation: $e');
      // Don't throw here as the main operation was successful
    }
  }

  /// Get employee folder structure from Firestore
  Future<Map<String, dynamic>?> getEmployeeFolderStructure(
    String employeeId,
  ) async {
    try {
      final doc =
          await _firestore.collection('employeeFolders').doc(employeeId).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      _logger.e('Failed to get employee folder structure: $e');
      return null;
    }
  }

  /// Check if employee folders exist
  Future<bool> employeeFoldersExist(String employeeId) async {
    try {
      final doc =
          await _firestore.collection('employeeFolders').doc(employeeId).get();

      return doc.exists && (doc.data()?['success'] == true);
    } catch (e) {
      _logger.e('Failed to check employee folders: $e');
      return false;
    }
  }

  /// Get employee folder contents
  Future<List<Map<String, dynamic>>> getEmployeeFolderContents(
    String employeeId,
  ) async {
    try {
      final folders =
          await _firestore
              .collection('employeeFolders')
              .doc(employeeId)
              .collection('folders')
              .orderBy('name')
              .get();

      return folders.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      _logger.e('Failed to get employee folder contents: $e');
      return [];
    }
  }

  /// Create or check employee folder structure (for existing employees)
  Future<Map<String, dynamic>> checkOrCreateEmployeeFolder({
    required String employeeId,
    required String fullName,
    required String userId,
    required String currentUserId,
    required String currentUserName,
  }) async {
    try {
      // Check if folders already exist
      final exists = await employeeFoldersExist(employeeId);

      if (exists) {
        _logger.i('Employee folders already exist for: $employeeId');
        final structure = await getEmployeeFolderStructure(employeeId);
        return structure ??
            {
              'success': false,
              'error': 'Failed to retrieve existing structure',
            };
      }

      // Create new folder structure
      _logger.i(
        'Creating new folder structure for existing employee: $employeeId',
      );
      return await createEmployeeFolderStructure(
        employeeId: employeeId,
        fullName: fullName,
        createdBy: currentUserId,
        createdByName: currentUserName,
        userId: userId,
      );
    } catch (e) {
      _logger.e('Failed to check/create employee folder: $e');
      throw Exception('Failed to initialize employee folder: $e');
    }
  }

  /// Sanitize folder name for storage
  String _sanitizeFolderName(String name) {
    return name
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }

  /// Get folder structure template
  static List<Map<String, String>> get folderStructureTemplate =>
      _employeeFolderStructure;
}

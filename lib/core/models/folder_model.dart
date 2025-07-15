import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/document_enums.dart';
import '../enums/user_role.dart';

part 'folder_model.freezed.dart';
part 'folder_model.g.dart';

// Custom converter for handling Firestore Timestamp and String dates
class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.parse(value);
    }

    throw ArgumentError('Cannot convert $value to DateTime');
  }

  @override
  dynamic toJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}

@freezed
class FolderModel with _$FolderModel {
  const factory FolderModel({
    required String id,
    required String name,
    required String path,
    required DocumentCategory category,
    required DocumentAccessLevel accessLevel,
    required String createdBy,
    required String createdByName,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    required List<String> accessRoles,
    required List<String> accessUserIds,
    String? parentId,
    String? parentPath,
    String? description,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    bool? isArchived,
    @TimestampConverter() DateTime? archivedAt,
    String? archivedBy,
    String? archivedByName,
    String? archiveReason,
    int? documentCount,
    int? subfolderCount,
    @TimestampConverter() DateTime? lastAccessedAt,
    String? lastAccessedBy,
  }) = _FolderModel;

  factory FolderModel.fromJson(Map<String, dynamic> json) =>
      _$FolderModelFromJson(json);

  factory FolderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FolderModel.fromJson({'id': doc.id, ...data});
  }
}

// Extension for helper methods
extension FolderModelX on FolderModel {
  /// Check if the folder is accessible by a specific role
  bool isAccessibleByRole(UserRole role) {
    return accessRoles.contains(role.value) ||
        accessRoles.contains(role.displayName) ||
        role.level >= 80; // Admin and above can access most folders
  }

  /// Check if the folder is accessible by a specific user ID
  bool isAccessibleByUser(String userId) {
    return accessUserIds.contains(userId);
  }

  /// Check if the folder is a root folder
  bool get isRootFolder => parentId == null || parentId!.isEmpty;

  /// Get folder depth level
  int get depth {
    if (isRootFolder) return 0;
    return path.split('/').length - 1;
  }

  /// Get folder display name
  String get displayName {
    return description?.isNotEmpty == true ? description! : name;
  }

  /// Get parent folder path
  String? get parentFolderPath {
    if (isRootFolder) return null;
    final pathParts = path.split('/');
    if (pathParts.length <= 1) return null;
    pathParts.removeLast();
    return pathParts.join('/');
  }

  /// Create a copy with updated access
  FolderModel copyWithAccess({
    List<String>? newAccessRoles,
    List<String>? newAccessUserIds,
  }) {
    return copyWith(
      accessRoles: newAccessRoles ?? accessRoles,
      accessUserIds: newAccessUserIds ?? accessUserIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with archive
  FolderModel archive(String archivedBy, String archivedByName, String reason) {
    return copyWith(
      isArchived: true,
      archivedBy: archivedBy,
      archivedByName: archivedByName,
      archivedAt: DateTime.now(),
      archiveReason: reason,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with unarchive
  FolderModel unarchive() {
    return copyWith(
      isArchived: false,
      archivedBy: null,
      archivedByName: null,
      archivedAt: null,
      archiveReason: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Update folder counts
  FolderModel updateCounts({int? documents, int? subfolders}) {
    return copyWith(
      documentCount: documents ?? documentCount,
      subfolderCount: subfolders ?? subfolderCount,
      updatedAt: DateTime.now(),
    );
  }

  /// Record folder access
  FolderModel recordAccess(String accessedBy) {
    return copyWith(
      lastAccessedAt: DateTime.now(),
      lastAccessedBy: accessedBy,
      updatedAt: DateTime.now(),
    );
  }

  /// Check if user can create subfolders
  bool canCreateSubfolders(UserRole role) {
    return isAccessibleByRole(role) && role.level >= 30; // TeamLead and above
  }

  /// Check if user can delete folder
  bool canDelete(UserRole role) {
    return role.level >= 60; // Manager and above
  }

  /// Check if user can modify folder
  bool canModify(UserRole role) {
    return isAccessibleByRole(role) &&
        role.level >= 40; // Senior Employee and above
  }

  /// Generate full path for a subfolder
  String generateSubfolderPath(String subfolderName) {
    return '$path/$subfolderName';
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove ID as it's handled by Firestore
    return json;
  }

  /// Get total item count (documents + subfolders)
  int? get itemCount {
    final docCount = documentCount ?? 0;
    final folderCount = subfolderCount ?? 0;
    return docCount + folderCount;
  }

  /// Validate folder name
  static bool isValidFolderName(String name) {
    if (name.trim().isEmpty) return false;
    if (name.length < 2 || name.length > 100) return false;

    // Check for invalid characters
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(name)) return false;

    // Check for reserved names
    final reservedNames = [
      'CON',
      'PRN',
      'AUX',
      'NUL',
      'COM1',
      'COM2',
      'COM3',
      'COM4',
      'COM5',
      'COM6',
      'COM7',
      'COM8',
      'COM9',
      'LPT1',
      'LPT2',
      'LPT3',
      'LPT4',
      'LPT5',
      'LPT6',
      'LPT7',
      'LPT8',
      'LPT9',
    ];
    if (reservedNames.contains(name.toUpperCase())) return false;

    return true;
  }
}

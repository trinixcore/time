import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/document_enums.dart';
import '../enums/user_role.dart';

part 'document_model.freezed.dart';
part 'document_model.g.dart';

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
class DocumentModel with _$DocumentModel {
  const factory DocumentModel({
    required String id,
    required String fileName,
    required String originalFileName,
    required String supabasePath,
    required String firebasePath,
    required DocumentCategory category,
    required DocumentFileType fileType,
    required DocumentStatus status,
    required DocumentAccessLevel accessLevel,
    required String uploadedBy,
    required String uploadedByName,
    @TimestampConverter() required DateTime uploadedAt,
    @TimestampConverter() required DateTime updatedAt,
    required int fileSizeBytes,
    required List<String> accessRoles,
    required List<String> accessUserIds,
    String? description,
    String? version,
    String? folderId,
    String? folderPath,
    String? mimeType,
    String? checksum,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? approvedBy,
    String? approvedByName,
    @TimestampConverter() DateTime? approvedAt,
    String? rejectedBy,
    String? rejectedByName,
    @TimestampConverter() DateTime? rejectedAt,
    String? rejectionReason,
    @TimestampConverter() DateTime? archivedAt,
    String? archivedBy,
    String? archivedByName,
    String? archiveReason,
    @TimestampConverter() DateTime? expiresAt,
    bool? isConfidential,
    bool? requiresApproval,
    int? downloadCount,
    @TimestampConverter() DateTime? lastAccessedAt,
    String? lastAccessedBy,
  }) = _DocumentModel;

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);

  factory DocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentModel.fromJson({...data, 'id': doc.id});
  }
}

// Extension for helper methods
extension DocumentModelX on DocumentModel {
  /// Check if the document is accessible by a specific role
  bool isAccessibleByRole(UserRole role) {
    return accessRoles.contains(role.value) ||
        accessRoles.contains(role.displayName) ||
        role.level >= 80; // Admin and above can access most documents
  }

  /// Check if the document is accessible by a specific user ID
  bool isAccessibleByUser(String userId) {
    return accessUserIds.contains(userId);
  }

  /// Check if the document is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if the document is archived
  bool get isArchived => status == DocumentStatus.archived;

  /// Check if the document is pending approval
  bool get isPendingApproval => status == DocumentStatus.pending;

  /// Check if the document is approved
  bool get isApproved => status == DocumentStatus.approved;

  /// Check if the document is rejected
  bool get isRejected => status == DocumentStatus.rejected;

  /// Get file size in human readable format
  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Get file extension
  String get fileExtension {
    return fileName.split('.').last.toLowerCase();
  }

  /// Check if the document can be previewed
  bool get canPreview {
    return fileType.isImage ||
        fileType == DocumentFileType.pdf ||
        fileType == DocumentFileType.txt;
  }

  /// Get display name for the document
  String get displayName {
    return description?.isNotEmpty == true ? description! : originalFileName;
  }

  /// Create a copy with updated access
  DocumentModel copyWithAccess({
    List<String>? newAccessRoles,
    List<String>? newAccessUserIds,
  }) {
    return copyWith(
      accessRoles: newAccessRoles ?? accessRoles,
      accessUserIds: newAccessUserIds ?? accessUserIds,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with approval
  DocumentModel approve(String approvedBy, String approvedByName) {
    return copyWith(
      status: DocumentStatus.approved,
      approvedBy: approvedBy,
      approvedByName: approvedByName,
      approvedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with rejection
  DocumentModel reject(
    String rejectedBy,
    String rejectedByName,
    String reason,
  ) {
    return copyWith(
      status: DocumentStatus.rejected,
      rejectedBy: rejectedBy,
      rejectedByName: rejectedByName,
      rejectedAt: DateTime.now(),
      rejectionReason: reason,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with archive
  DocumentModel archive(
    String archivedBy,
    String archivedByName,
    String reason,
  ) {
    return copyWith(
      status: DocumentStatus.archived,
      archivedBy: archivedBy,
      archivedByName: archivedByName,
      archivedAt: DateTime.now(),
      archiveReason: reason,
      updatedAt: DateTime.now(),
    );
  }

  /// Update download count and last access
  DocumentModel recordAccess(String accessedBy) {
    return copyWith(
      downloadCount: (downloadCount ?? 0) + 1,
      lastAccessedAt: DateTime.now(),
      lastAccessedBy: accessedBy,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // Remove ID as it's handled by Firestore
    return json;
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'letter_model.freezed.dart';
part 'letter_model.g.dart';

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

// Custom converter for LetterStatus
class LetterStatusConverter implements JsonConverter<LetterStatus, String> {
  const LetterStatusConverter();

  @override
  LetterStatus fromJson(String value) => LetterStatus.fromString(value);

  @override
  String toJson(LetterStatus status) {
    if (status is _LetterDraft) return 'draft';
    if (status is _LetterPendingApproval) return 'pending_approval';
    if (status is _LetterApproved) return 'approved';
    if (status is _LetterSent) return 'sent';
    if (status is _LetterAccepted) return 'accepted';
    if (status is _LetterRejected) return 'rejected';
    return 'draft';
  }
}

// Custom converter for SignatureStatus
class SignatureStatusConverter
    implements JsonConverter<SignatureStatus, String> {
  const SignatureStatusConverter();

  @override
  SignatureStatus fromJson(String value) => SignatureStatus.fromString(value);

  @override
  String toJson(SignatureStatus status) {
    if (status is _SignaturePending) return 'pending';
    if (status is _SignatureApproved) return 'approved';
    if (status is _SignatureRejected) return 'rejected';
    return 'pending';
  }
}

// Individual signature approval tracking
@freezed
class SignatureApproval with _$SignatureApproval {
  const factory SignatureApproval({
    required String signatureId, // ID of the signature authority
    required String signatureOwnerUid, // UID of the signature owner
    required String signatureOwnerName, // Name of the signature owner
    required String
    signatureTitle, // Title of the signature owner (e.g., "Director")
    @SignatureStatusConverter() required SignatureStatus status,
    @TimestampConverter() DateTime? approvedAt,
    @TimestampConverter() DateTime? rejectedAt,
    String?
    approvedBy, // UID of who approved (usually the same as signatureOwnerUid)
    String? approvedByName, // Name of who approved
    String? rejectionReason,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _SignatureApproval;

  factory SignatureApproval.fromJson(Map<String, dynamic> json) =>
      _$SignatureApprovalFromJson(json);
}

@freezed
class Letter with _$Letter {
  const factory Letter({
    required String id,
    required String type, // Offer Letter, Appointment Letter, etc.
    required String content, // GPT-generated content
    required String employeeName,
    required String employeeEmail,
    required String createdBy, // userId
    @Default([])
    List<String> signatureAuthorityUids, // Multiple director/authority UIDs
    @LetterStatusConverter() required LetterStatus letterStatus,
    @SignatureStatusConverter() required SignatureStatus signatureStatus,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,

    // PDF and storage information
    String? signedPdfPath, // letters/{letterId}/offer.pdf
    String?
    signedPdfUrl, // Supabase signed URL (deprecated - generated on demand)
    String? storedIn, // "supabase.process"
    // Timestamps for workflow tracking
    @TimestampConverter() DateTime? submittedForApprovalAt,
    @TimestampConverter() DateTime? approvedAt,
    @TimestampConverter() DateTime? rejectedAt,
    @TimestampConverter() DateTime? sentAt,
    @TimestampConverter() DateTime? acceptedAt,

    // Additional metadata
    String? rejectionReason,
    String? sentVia, // "email", "hand-delivered", etc.
    String? sentTo, // recipient email or contact info
    String? notes,
    Map<String, dynamic>? metadata,
    String? headerId,
    String? footerId,
    String? logoId,

    // Individual signature approvals tracking
    @Default([]) List<SignatureApproval> signatureApprovals,
  }) = _Letter;

  factory Letter.fromJson(Map<String, dynamic> json) => _$LetterFromJson(json);

  factory Letter.fromMap(Map<String, dynamic> map, String id) {
    return Letter(
      id: id,
      type: map['type'] as String,
      content: map['content'] as String,
      employeeName: map['employeeName'] as String,
      employeeEmail: map['employeeEmail'] as String,
      createdBy: map['createdBy'] as String,
      signatureAuthorityUids: List<String>.from(
        map['signatureAuthorityUids'] as List,
      ),
      letterStatus: LetterStatus.fromString(map['letterStatus'] as String),
      signatureStatus: SignatureStatus.fromString(
        map['signatureStatus'] as String,
      ),
      createdAt: TimestampConverter().fromJson(map['createdAt'])!,
      updatedAt: TimestampConverter().fromJson(map['updatedAt'])!,
      signedPdfPath: map['signedPdfPath'] as String?,
      signedPdfUrl: map['signedPdfUrl'] as String?,
      storedIn: map['storedIn'] as String?,
      submittedForApprovalAt: TimestampConverter().fromJson(
        map['submittedForApprovalAt'],
      ),
      approvedAt: TimestampConverter().fromJson(map['approvedAt']),
      rejectedAt: TimestampConverter().fromJson(map['rejectedAt']),
      sentAt: TimestampConverter().fromJson(map['sentAt']),
      acceptedAt: TimestampConverter().fromJson(map['acceptedAt']),
      rejectionReason: map['rejectionReason'] as String?,
      sentVia: map['sentVia'] as String?,
      sentTo: map['sentTo'] as String?,
      notes: map['notes'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      headerId: map['headerId'] as String?,
      footerId: map['footerId'] as String?,
      logoId: map['logoId'] as String?,
      signatureApprovals:
          (map['signatureApprovals'] as List<dynamic>?)
              ?.map(
                (e) => SignatureApproval.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

@freezed
class LetterStatus with _$LetterStatus {
  const factory LetterStatus.draft() = _LetterDraft;
  const factory LetterStatus.pendingApproval() = _LetterPendingApproval;
  const factory LetterStatus.approved() = _LetterApproved;
  const factory LetterStatus.sent() = _LetterSent;
  const factory LetterStatus.accepted() = _LetterAccepted;
  const factory LetterStatus.rejected() = _LetterRejected;

  factory LetterStatus.fromString(String value) {
    switch (value) {
      case 'draft':
        return const LetterStatus.draft();
      case 'pending_approval':
        return const LetterStatus.pendingApproval();
      case 'approved':
        return const LetterStatus.approved();
      case 'sent':
        return const LetterStatus.sent();
      case 'accepted':
        return const LetterStatus.accepted();
      case 'rejected':
        return const LetterStatus.rejected();
      default:
        return const LetterStatus.draft();
    }
  }
}

@freezed
class SignatureStatus with _$SignatureStatus {
  const factory SignatureStatus.pending() = _SignaturePending;
  const factory SignatureStatus.approved() = _SignatureApproved;
  const factory SignatureStatus.rejected() = _SignatureRejected;

  factory SignatureStatus.fromString(String value) {
    switch (value) {
      case 'pending':
        return const SignatureStatus.pending();
      case 'approved':
        return const SignatureStatus.approved();
      case 'rejected':
        return const SignatureStatus.rejected();
      default:
        return const SignatureStatus.pending();
    }
  }
}

// Extension for helper methods
extension LetterX on Letter {
  bool get isDraft => letterStatus is _LetterDraft;
  bool get isPendingApproval => letterStatus is _LetterPendingApproval;
  bool get isApproved => letterStatus is _LetterApproved;
  bool get isSent => letterStatus is _LetterSent;
  bool get isAccepted => letterStatus is _LetterAccepted;
  bool get isRejected => letterStatus is _LetterRejected;

  bool get signaturePending => signatureStatus is _SignaturePending;
  bool get signatureApproved => signatureStatus is _SignatureApproved;
  bool get signatureRejected => signatureStatus is _SignatureRejected;

  bool get canEdit => isDraft;
  bool get canSubmit => isDraft;
  bool get canApprove => isPendingApproval;
  bool get canReject => isPendingApproval;
  bool get canMarkSent => isApproved;
  bool get canMarkAccepted => isSent;

  String get statusDisplayName {
    if (isRejected) return 'Rejected';
    if (isAccepted) return 'Accepted';
    if (isSent) return 'Sent';
    if (isApproved) return 'Approved';
    if (isPendingApproval) return 'Pending Approval';
    return 'Draft';
  }

  // Multi-signature approval helpers
  bool get allSignaturesApproved {
    if (signatureApprovals.isEmpty) return false;
    return signatureApprovals.every(
      (approval) => approval.status is _SignatureApproved,
    );
  }

  bool get anySignatureRejected {
    return signatureApprovals.any(
      (approval) => approval.status is _SignatureRejected,
    );
  }

  bool get hasPendingSignatures {
    return signatureApprovals.any(
      (approval) => approval.status is _SignaturePending,
    );
  }

  List<SignatureApproval> get pendingApprovals {
    return signatureApprovals
        .where((approval) => approval.status is _SignaturePending)
        .toList();
  }

  List<SignatureApproval> get approvedSignatures {
    return signatureApprovals
        .where((approval) => approval.status is _SignatureApproved)
        .toList();
  }

  List<SignatureApproval> get rejectedSignatures {
    return signatureApprovals
        .where((approval) => approval.status is _SignatureRejected)
        .toList();
  }

  String get approvalProgress {
    final total = signatureApprovals.length;
    final approved = approvedSignatures.length;
    final rejected = rejectedSignatures.length;

    if (total == 0) return 'No signatures required';
    if (rejected > 0) return 'Rejected';
    if (approved == total) return 'All approved';
    return '$approved of $total approved';
  }

  /// Enhanced multi-approval status tracking
  /// Returns true if the letter should remain in pending status
  bool get shouldRemainPending {
    // If no signatures required, not pending
    if (signatureApprovals.isEmpty) return false;

    // If any signature is rejected, should not remain pending
    if (anySignatureRejected) return false;

    // If all signatures are approved, should not remain pending
    if (allSignaturesApproved) return false;

    // If there are still pending signatures, should remain pending
    return hasPendingSignatures;
  }

  /// Returns true if the letter is partially approved (some approved, some pending)
  bool get isPartiallyApproved {
    if (signatureApprovals.isEmpty) return false;
    if (allSignaturesApproved) return false;
    if (anySignatureRejected) return false;

    final approvedCount = approvedSignatures.length;
    final pendingCount = pendingApprovals.length;

    return approvedCount > 0 && pendingCount > 0;
  }

  /// Returns the current approval stage for multi-signature workflows
  String get approvalStage {
    if (signatureApprovals.isEmpty) return 'No Approvals Required';

    final total = signatureApprovals.length;
    final approved = approvedSignatures.length;
    final rejected = rejectedSignatures.length;
    final pending = pendingApprovals.length;

    if (rejected > 0) return 'Rejected';
    if (approved == total) return 'Fully Approved';
    if (approved > 0 && pending > 0) return 'Partially Approved';
    if (pending == total) return 'Awaiting First Approval';

    return 'Approval In Progress';
  }

  /// Returns detailed approval status for UI display
  String get detailedApprovalStatus {
    if (signatureApprovals.isEmpty) return 'No signatures required';

    final total = signatureApprovals.length;
    final approved = approvedSignatures.length;
    final rejected = rejectedSignatures.length;
    final pending = pendingApprovals.length;

    if (rejected > 0) {
      return 'Rejected (${rejected} signature${rejected > 1 ? 's' : ''} rejected)';
    }

    if (approved == total) {
      return 'All ${total} signature${total > 1 ? 's' : ''} approved';
    }

    if (approved > 0 && pending > 0) {
      return '$approved of $total approved, $pending pending';
    }

    if (pending == total) {
      return 'Awaiting ${total} signature${total > 1 ? 's' : ''}';
    }

    return '$approved of $total approved';
  }

  /// Returns the next required approver (if any)
  String? get nextRequiredApprover {
    final pending = pendingApprovals.firstOrNull;
    return pending?.signatureOwnerName;
  }

  /// Returns all pending approvers
  List<String> get pendingApprovers {
    return pendingApprovals
        .map((approval) => approval.signatureOwnerName)
        .toList();
  }

  /// Returns all approved signers
  List<String> get approvedSigners {
    return approvedSignatures
        .map((approval) => approval.signatureOwnerName)
        .toList();
  }

  /// Returns all rejected signers with reasons
  List<Map<String, String>> get rejectedSignersWithReasons {
    return rejectedSignatures
        .map(
          (approval) => {
            'name': approval.signatureOwnerName,
            'reason': approval.rejectionReason ?? 'No reason provided',
          },
        )
        .toList();
  }

  /// Returns true if the letter can be approved by the given user
  bool canUserApprove(String userId) {
    return signatureApprovals.any(
      (approval) =>
          approval.signatureOwnerUid == userId &&
          approval.status is _SignaturePending,
    );
  }

  /// Returns true if the letter can be rejected by the given user
  bool canUserReject(String userId) {
    return signatureApprovals.any(
      (approval) =>
          approval.signatureOwnerUid == userId &&
          approval.status is _SignaturePending,
    );
  }

  /// Returns the signature approval for a specific user
  SignatureApproval? getUserApproval(String userId) {
    try {
      return signatureApprovals.firstWhere(
        (approval) => approval.signatureOwnerUid == userId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Returns true if the user has already approved
  bool hasUserApproved(String userId) {
    return signatureApprovals.any(
      (approval) =>
          approval.signatureOwnerUid == userId &&
          approval.status is _SignatureApproved,
    );
  }

  /// Returns true if the user has already rejected
  bool hasUserRejected(String userId) {
    return signatureApprovals.any(
      (approval) =>
          approval.signatureOwnerUid == userId &&
          approval.status is _SignatureRejected,
    );
  }

  /// Returns the approval percentage (0-100)
  double get approvalPercentage {
    if (signatureApprovals.isEmpty) return 0.0;

    final total = signatureApprovals.length;
    final approved = approvedSignatures.length;

    return (approved / total) * 100;
  }

  /// Returns true if the letter is in a final state (approved, rejected, sent, accepted)
  bool get isInFinalState {
    return isApproved || isRejected || isSent || isAccepted;
  }

  /// Returns true if the letter can still be modified (draft or pending with no approvals yet)
  bool get canStillBeModified {
    return isDraft || (isPendingApproval && approvedSignatures.isEmpty);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
      'createdBy': createdBy,
      'signatureAuthorityUids': signatureAuthorityUids,
      'letterStatus': LetterStatusConverter().toJson(letterStatus),
      'signatureStatus': SignatureStatusConverter().toJson(signatureStatus),
      'createdAt': TimestampConverter().toJson(createdAt),
      'updatedAt': TimestampConverter().toJson(updatedAt),
      'signedPdfPath': signedPdfPath,
      'signedPdfUrl': signedPdfUrl,
      'storedIn': storedIn,
      'submittedForApprovalAt': TimestampConverter().toJson(
        submittedForApprovalAt,
      ),
      'approvedAt': TimestampConverter().toJson(approvedAt),
      'rejectedAt': TimestampConverter().toJson(rejectedAt),
      'sentAt': TimestampConverter().toJson(sentAt),
      'acceptedAt': TimestampConverter().toJson(acceptedAt),
      'rejectionReason': rejectionReason,
      'sentVia': sentVia,
      'sentTo': sentTo,
      'notes': notes,
      'metadata': metadata,
      'headerId': headerId,
      'footerId': footerId,
      'logoId': logoId,
      'signatureApprovals':
          signatureApprovals.map((sa) => sa.toJson()).toList(),
    };
  }
}

enum ProfileUpdateStatus {
  pending('pending', 'Pending Approval'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected'),
  cancelled('cancelled', 'Cancelled');

  const ProfileUpdateStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static ProfileUpdateStatus fromString(String value) {
    return ProfileUpdateStatus.values.firstWhere(
      (status) => status.value == value.toLowerCase(),
      orElse: () => ProfileUpdateStatus.pending,
    );
  }

  bool get isPending => this == ProfileUpdateStatus.pending;
  bool get isApproved => this == ProfileUpdateStatus.approved;
  bool get isRejected => this == ProfileUpdateStatus.rejected;
  bool get isCancelled => this == ProfileUpdateStatus.cancelled;
  bool get canBeModified => isPending;
  bool get isFinal => isApproved || isRejected || isCancelled;
}

class ProfileUpdateRequest {
  final String id;
  final String userId;
  final String userEmployeeId;
  final String userName;
  final String userEmail;
  final Map<String, dynamic> currentData;
  final Map<String, dynamic> proposedChanges;
  final List<String> changedFields;
  final ProfileUpdateStatus status;
  final DateTime requestedAt;
  final String requestedBy;
  final String? approverId;
  final String? approverName;
  final DateTime? reviewedAt;
  final String? approverComments;
  final String? rejectionReason;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const ProfileUpdateRequest({
    required this.id,
    required this.userId,
    required this.userEmployeeId,
    required this.userName,
    required this.userEmail,
    required this.currentData,
    required this.proposedChanges,
    required this.changedFields,
    required this.status,
    required this.requestedAt,
    required this.requestedBy,
    this.approverId,
    this.approverName,
    this.reviewedAt,
    this.approverComments,
    this.rejectionReason,
    this.updatedAt,
    this.metadata,
  });

  /// Get the display name for the field
  String getFieldDisplayName(String fieldKey) {
    const fieldNames = {
      'displayName': 'Full Name',
      'phoneNumber': 'Phone Number',
      'gender': 'Gender',
      'dateOfBirth': 'Date of Birth',
      'address': 'Address',
      'emergencyContactName': 'Emergency Contact Name',
      'emergencyContactPhone': 'Emergency Contact Phone',
      'joiningDate': 'Joining Date',
    };
    return fieldNames[fieldKey] ?? fieldKey;
  }

  /// Get the old value for a field
  dynamic getOldValue(String fieldKey) {
    return currentData[fieldKey];
  }

  /// Get the new value for a field
  dynamic getNewValue(String fieldKey) {
    return proposedChanges[fieldKey];
  }

  /// Get formatted change description
  String getChangeDescription(String fieldKey) {
    final oldValue = getOldValue(fieldKey);
    final newValue = getNewValue(fieldKey);
    final fieldName = getFieldDisplayName(fieldKey);

    if (oldValue == null || oldValue.toString().isEmpty) {
      return '$fieldName: Adding "${newValue}"';
    } else if (newValue == null || newValue.toString().isEmpty) {
      return '$fieldName: Removing "${oldValue}"';
    } else {
      return '$fieldName: "${oldValue}" → "${newValue}"';
    }
  }

  /// Get all change descriptions
  List<String> getAllChangeDescriptions() {
    return changedFields.map((field) => getChangeDescription(field)).toList();
  }

  /// Check if request can be approved
  bool get canBeApproved => status.isPending;

  /// Check if request can be rejected
  bool get canBeRejected => status.isPending;

  /// Check if request can be cancelled
  bool get canBeCancelled => status.isPending;

  /// Get days since request
  int get daysSinceRequest {
    return DateTime.now().difference(requestedAt).inDays;
  }

  /// Check if request is overdue (more than 3 days)
  bool get isOverdue => daysSinceRequest > 3;

  /// Create approved copy
  ProfileUpdateRequest approve({
    required String approverId,
    required String approverName,
    String? comments,
  }) {
    return copyWith(
      status: ProfileUpdateStatus.approved,
      approverId: approverId,
      approverName: approverName,
      reviewedAt: DateTime.now(),
      approverComments: comments,
      updatedAt: DateTime.now(),
    );
  }

  /// Create rejected copy
  ProfileUpdateRequest reject({
    required String approverId,
    required String approverName,
    required String reason,
    String? comments,
  }) {
    return copyWith(
      status: ProfileUpdateStatus.rejected,
      approverId: approverId,
      approverName: approverName,
      reviewedAt: DateTime.now(),
      rejectionReason: reason,
      approverComments: comments,
      updatedAt: DateTime.now(),
    );
  }

  /// Create cancelled copy
  ProfileUpdateRequest cancel() {
    return copyWith(
      status: ProfileUpdateStatus.cancelled,
      updatedAt: DateTime.now(),
    );
  }

  /// Copy with method
  ProfileUpdateRequest copyWith({
    String? id,
    String? userId,
    String? userEmployeeId,
    String? userName,
    String? userEmail,
    Map<String, dynamic>? currentData,
    Map<String, dynamic>? proposedChanges,
    List<String>? changedFields,
    ProfileUpdateStatus? status,
    DateTime? requestedAt,
    String? requestedBy,
    String? approverId,
    String? approverName,
    DateTime? reviewedAt,
    String? approverComments,
    String? rejectionReason,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ProfileUpdateRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmployeeId: userEmployeeId ?? this.userEmployeeId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      currentData: currentData ?? this.currentData,
      proposedChanges: proposedChanges ?? this.proposedChanges,
      changedFields: changedFields ?? this.changedFields,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      requestedBy: requestedBy ?? this.requestedBy,
      approverId: approverId ?? this.approverId,
      approverName: approverName ?? this.approverName,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      approverComments: approverComments ?? this.approverComments,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmployeeId': userEmployeeId,
      'userName': userName,
      'userEmail': userEmail,
      'currentData': currentData,
      'proposedChanges': proposedChanges,
      'changedFields': changedFields,
      'status': status.value,
      'requestedAt': requestedAt.toIso8601String(),
      'requestedBy': requestedBy,
      'approverId': approverId,
      'approverName': approverName,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'approverComments': approverComments,
      'rejectionReason': rejectionReason,
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateRequest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userEmployeeId: json['userEmployeeId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      currentData: Map<String, dynamic>.from(json['currentData'] as Map),
      proposedChanges: Map<String, dynamic>.from(
        json['proposedChanges'] as Map,
      ),
      changedFields: List<String>.from(json['changedFields'] as List),
      status: ProfileUpdateStatus.fromString(json['status'] as String),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      requestedBy: json['requestedBy'] as String,
      approverId: json['approverId'] as String?,
      approverName: json['approverName'] as String?,
      reviewedAt:
          json['reviewedAt'] != null
              ? DateTime.parse(json['reviewedAt'] as String)
              : null,
      approverComments: json['approverComments'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      metadata:
          json['metadata'] != null
              ? Map<String, dynamic>.from(json['metadata'] as Map)
              : null,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Create from Firestore
  factory ProfileUpdateRequest.fromFirestore(Map<String, dynamic> data) {
    return ProfileUpdateRequest.fromJson(data);
  }
}

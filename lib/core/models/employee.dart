import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/user_role.dart';
import '../enums/employee_status.dart';

part 'employee.freezed.dart';
part 'employee.g.dart';

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
class Employee with _$Employee {
  const factory Employee({
    required String id,
    required String userId, // Reference to Firebase Auth user
    required String employeeId, // TRX2024000001 format
    required String firstName,
    required String lastName,
    required String email,
    required UserRole role,
    required EmployeeStatus status,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    required String createdBy,

    // Contact Information
    String? phoneNumber,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? personalEmail,

    // Address Information
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,

    // Personal Information
    String? gender,
    @TimestampConverter() DateTime? dateOfBirth,
    String? nationality,
    String? maritalStatus,

    // Employment Information
    String? department,
    String? designation,
    String? position,
    @TimestampConverter() DateTime? joiningDate,
    @TimestampConverter() DateTime? probationEndDate,
    @TimestampConverter() DateTime? confirmationDate,
    @TimestampConverter() DateTime? terminationDate,
    String? employmentType, // Full-time, Part-time, Contract, Intern
    String? workLocation, // Office, Remote, Hybrid
    double? salary,
    String? salaryGrade,

    // Organizational Structure
    String? reportingManagerId,
    String? hiringManagerId,
    String? departmentId,
    @Default([]) List<String> teamIds,
    @Default([]) List<String> projectIds,
    @Default([]) List<String> subordinateIds,

    // Skills and Qualifications
    @Default([]) List<String> skills,
    @Default([]) List<Map<String, dynamic>> qualifications,
    @Default([]) List<Map<String, dynamic>> certifications,
    @Default([]) List<Map<String, dynamic>> workExperience,

    // Documents
    @Default([]) List<String> documentIds,
    String? profileImageUrl,
    String? resumeUrl,

    // Performance and Attendance
    double? performanceRating,
    @TimestampConverter() DateTime? lastPerformanceReview,
    int? totalLeaveDays,
    int? usedLeaveDays,
    double? attendancePercentage,

    // System Fields
    @TimestampConverter() DateTime? lastLoginAt,
    @TimestampConverter() DateTime? lastUpdatedBy,
    String? updatedBy,
    bool? isActive,
    Map<String, dynamic>? customFields,
    Map<String, dynamic>? metadata,

    // Audit Fields
    @Default([]) List<Map<String, dynamic>> auditLog,
  }) = _Employee;

  factory Employee.fromJson(Map<String, dynamic> json) =>
      _$EmployeeFromJson(json);

  // Additional methods and getters
  const Employee._();

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get initials from first and last name
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Get display name with employee ID
  String get displayNameWithId => '$fullName ($employeeId)';

  /// Check if employee is active
  bool get isEmployeeActive => status.isActive && (isActive ?? true);

  /// Check if employee is on probation
  bool get isOnProbation => status.isOnProbation;

  /// Check if employee is terminated
  bool get isTerminated => status.isTerminated;

  /// Check if employee can work
  bool get canWork => status.canWork && isEmployeeActive;

  /// Check if employee can take leave
  bool get canTakeLeave => status.canTakeLeave && isEmployeeActive;

  /// Get remaining leave days
  int get remainingLeaveDays => (totalLeaveDays ?? 0) - (usedLeaveDays ?? 0);

  /// Check if employee has manager
  bool get hasReportingManager =>
      reportingManagerId != null && reportingManagerId!.isNotEmpty;

  /// Check if employee has hiring manager
  bool get hasHiringManager =>
      hiringManagerId != null && hiringManagerId!.isNotEmpty;

  /// Check if employee is a manager (has subordinates)
  bool get isManager => subordinateIds.isNotEmpty;

  /// Get years of service
  double get yearsOfService {
    if (joiningDate == null) return 0.0;
    final now = DateTime.now();
    final difference = now.difference(joiningDate!);
    return difference.inDays / 365.25;
  }

  /// Get age
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Check if probation period is over
  bool get isProbationOver {
    if (probationEndDate == null) return true;
    return DateTime.now().isAfter(probationEndDate!);
  }

  /// Get employment duration in days
  int get employmentDurationInDays {
    if (joiningDate == null) return 0;
    final endDate = terminationDate ?? DateTime.now();
    return endDate.difference(joiningDate!).inDays;
  }

  /// Check if employee has specific skill
  bool hasSkill(String skill) => skills.contains(skill.toLowerCase());

  /// Get qualification by type
  Map<String, dynamic>? getQualificationByType(String type) {
    return qualifications.firstWhere(
      (qual) => qual['type']?.toString().toLowerCase() == type.toLowerCase(),
      orElse: () => {},
    );
  }

  /// Get certification by name
  Map<String, dynamic>? getCertificationByName(String name) {
    return certifications.firstWhere(
      (cert) => cert['name']?.toString().toLowerCase() == name.toLowerCase(),
      orElse: () => {},
    );
  }

  /// Update employee status
  Employee updateStatus(EmployeeStatus newStatus, {String? updatedBy}) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
      isActive: newStatus.canWork,
    );
  }

  /// Update contact information
  Employee updateContactInfo({
    String? phoneNumber,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? personalEmail,
    String? updatedBy,
  }) {
    return copyWith(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      personalEmail: personalEmail ?? this.personalEmail,
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Update address information
  Employee updateAddress({
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? updatedBy,
  }) {
    return copyWith(
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Update employment information
  Employee updateEmploymentInfo({
    String? department,
    String? designation,
    String? position,
    String? reportingManagerId,
    String? hiringManagerId,
    String? departmentId,
    double? salary,
    String? salaryGrade,
    String? employmentType,
    String? workLocation,
    String? updatedBy,
  }) {
    return copyWith(
      department: department ?? this.department,
      designation: designation ?? this.designation,
      position: position ?? this.position,
      reportingManagerId: reportingManagerId ?? this.reportingManagerId,
      hiringManagerId: hiringManagerId ?? this.hiringManagerId,
      departmentId: departmentId ?? this.departmentId,
      salary: salary ?? this.salary,
      salaryGrade: salaryGrade ?? this.salaryGrade,
      employmentType: employmentType ?? this.employmentType,
      workLocation: workLocation ?? this.workLocation,
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Add skill
  Employee addSkill(String skill, {String? updatedBy}) {
    if (skills.contains(skill.toLowerCase())) return this;
    return copyWith(
      skills: [...skills, skill.toLowerCase()],
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Remove skill
  Employee removeSkill(String skill, {String? updatedBy}) {
    return copyWith(
      skills: skills.where((s) => s != skill.toLowerCase()).toList(),
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Add qualification
  Employee addQualification(
    Map<String, dynamic> qualification, {
    String? updatedBy,
  }) {
    return copyWith(
      qualifications: [...qualifications, qualification],
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Add certification
  Employee addCertification(
    Map<String, dynamic> certification, {
    String? updatedBy,
  }) {
    return copyWith(
      certifications: [...certifications, certification],
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Add work experience
  Employee addWorkExperience(
    Map<String, dynamic> experience, {
    String? updatedBy,
  }) {
    return copyWith(
      workExperience: [...workExperience, experience],
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Add subordinate
  Employee addSubordinate(String subordinateId, {String? updatedBy}) {
    if (subordinateIds.contains(subordinateId)) return this;
    return copyWith(
      subordinateIds: [...subordinateIds, subordinateId],
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Remove subordinate
  Employee removeSubordinate(String subordinateId, {String? updatedBy}) {
    return copyWith(
      subordinateIds:
          subordinateIds.where((id) => id != subordinateId).toList(),
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Update performance rating
  Employee updatePerformanceRating(double rating, {String? updatedBy}) {
    return copyWith(
      performanceRating: rating,
      lastPerformanceReview: DateTime.now(),
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Update leave information
  Employee updateLeaveInfo({
    int? totalLeaveDays,
    int? usedLeaveDays,
    String? updatedBy,
  }) {
    return copyWith(
      totalLeaveDays: totalLeaveDays ?? this.totalLeaveDays,
      usedLeaveDays: usedLeaveDays ?? this.usedLeaveDays,
      updatedAt: DateTime.now(),
      updatedBy: updatedBy,
    );
  }

  /// Add audit log entry
  Employee addAuditLogEntry(
    String action,
    String performedBy, {
    Map<String, dynamic>? details,
  }) {
    final logEntry = {
      'action': action,
      'performedBy': performedBy,
      'timestamp': DateTime.now().toIso8601String(),
      'details': details ?? {},
    };

    return copyWith(
      auditLog: [...auditLog, logEntry],
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert enums to strings for Firestore
    json['role'] = role.value;
    json['status'] = status.value;
    return json;
  }

  /// Create from Firestore document
  factory Employee.fromFirestore(Map<String, dynamic> data) {
    // Convert string values back to enums
    if (data['role'] is String) {
      data['role'] = UserRole.fromString(data['role']).name;
    }
    if (data['status'] is String) {
      data['status'] = EmployeeStatus.fromString(data['status']).name;
    }
    return Employee.fromJson(data);
  }

  /// Create employee from user model
  factory Employee.fromUserModel({
    required String userId,
    required String employeeId,
    required String firstName,
    required String lastName,
    required String email,
    required UserRole role,
    required String createdBy,
    String? phoneNumber,
    String? department,
    String? designation,
    String? reportingManagerId,
    String? hiringManagerId,
    DateTime? joiningDate,
  }) {
    final now = DateTime.now();
    return Employee(
      id: userId,
      userId: userId,
      employeeId: employeeId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: role,
      status: EmployeeStatus.active,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      phoneNumber: phoneNumber,
      department: department,
      designation: designation,
      reportingManagerId: reportingManagerId,
      hiringManagerId: hiringManagerId,
      joiningDate: joiningDate ?? now,
      isActive: true,
      totalLeaveDays: 21, // Default annual leave
      usedLeaveDays: 0,
      employmentType: 'Full-time',
      workLocation: 'Office',
    );
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'candidate_model.freezed.dart';
part 'candidate_model.g.dart';

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
class Candidate with _$Candidate {
  const factory Candidate({
    required String id,
    required String candidateId, // CND2024000001 format
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    required String createdBy,

    // Personal Information
    String? gender,
    @TimestampConverter() DateTime? dateOfBirth,
    String? nationality,
    String? maritalStatus,
    String? personalEmail,

    // Address Information
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,

    // Employment Information
    String? department,
    String? designation,
    String? position,
    String? employmentType, // Full-time, Part-time, Contract, Intern
    String? workLocation, // Office, Remote, Hybrid
    double? offeredSalary,
    String? salaryGrade,
    @TimestampConverter() DateTime? expectedJoiningDate,
    @TimestampConverter() DateTime? offerDate,
    @TimestampConverter() DateTime? acceptanceDate,

    // Organizational Structure
    String? reportingManagerId,
    String? hiringManagerId,
    String? departmentId,

    // Skills and Qualifications
    @Default([]) List<String> skills,
    @Default([]) List<Map<String, dynamic>> qualifications,
    @Default([]) List<Map<String, dynamic>> certifications,
    @Default([]) List<Map<String, dynamic>> workExperience,

    // Documents
    @Default([]) List<String> documentIds,
    String? profileImageUrl,
    String? resumeUrl,
    String? offerLetterUrl,
    String? appointmentLetterUrl,

    // Status and Workflow
    String?
    status, // "applied", "interviewed", "offered", "accepted", "onboarded"
    String? currentStage, // "screening", "interview", "offer", "onboarding"
    @TimestampConverter() DateTime? lastStageUpdate,
    String? stageUpdatedBy,

    // Employee ID (assigned after onboarding)
    String? employeeId,
    String? userId, // Firebase Auth user ID (assigned after user creation)
    // Additional metadata
    String? notes,
    String? rejectionReason,
    @TimestampConverter() DateTime? rejectedAt,
    String? rejectedBy,
    Map<String, dynamic>? metadata,
  }) = _Candidate;

  factory Candidate.fromJson(Map<String, dynamic> json) =>
      _$CandidateFromJson(json);

  // Additional methods and getters
  const Candidate._();

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get initials from first and last name
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  /// Get display name with candidate ID
  String get displayNameWithId => '$fullName ($candidateId)';

  /// Check if candidate has been onboarded
  bool get isOnboarded => employeeId != null && userId != null;

  /// Check if candidate has accepted offer
  bool get hasAcceptedOffer => acceptanceDate != null;

  /// Check if candidate has been offered position
  bool get hasBeenOffered => offerDate != null;

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

  /// Check if candidate has specific skill
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

  /// Update candidate status
  Candidate updateStatus(String newStatus, {String? updatedBy}) {
    return copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
      stageUpdatedBy: updatedBy,
      lastStageUpdate: DateTime.now(),
    );
  }

  /// Assign employee ID after onboarding
  Candidate assignEmployeeId(String employeeId, String userId) {
    return copyWith(
      employeeId: employeeId,
      userId: userId,
      status: 'onboarded',
      currentStage: 'onboarded',
      updatedAt: DateTime.now(),
      lastStageUpdate: DateTime.now(),
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return json;
  }

  /// Create from Firestore document
  factory Candidate.fromFirestore(Map<String, dynamic> data) {
    return Candidate.fromJson(data);
  }

  /// Create candidate from basic information
  factory Candidate.create({
    String? candidateId, // Optional - will be auto-generated if not provided
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String createdBy,
    String? department,
    String? designation,
    String? position,
    String? employmentType,
    double? offeredSalary,
    @TimestampConverter() DateTime? expectedJoiningDate,
  }) {
    final now = DateTime.now();
    return Candidate(
      id: candidateId ?? '', // Will be set by service when creating
      candidateId: candidateId ?? '', // Will be auto-generated by service
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      department: department,
      designation: designation,
      position: position,
      employmentType: employmentType,
      offeredSalary: offeredSalary,
      expectedJoiningDate: expectedJoiningDate,
      status: 'applied',
      currentStage: 'screening',
      lastStageUpdate: now,
      stageUpdatedBy: createdBy,
    );
  }
}

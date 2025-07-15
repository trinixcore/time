import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'signature_model.freezed.dart';
part 'signature_model.g.dart';

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
class Signature with _$Signature {
  const factory Signature({
    required String id,
    required String ownerUid, // UID of director/authority
    required String ownerName, // "Shila De Sarkar"
    required String imagePath, // "signatures/director_1.png"
    required bool requiresApproval, // Whether approval is needed before use
    @Default([])
    List<String> allowedLetterTypes, // ["Offer Letter", "Experience"]
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,

    // Additional metadata
    String? title, // "Director", "CEO", "HR Manager"
    String? department,
    String? email,
    String? phoneNumber,
    bool? isActive,
    String? notes,
    Map<String, dynamic>? metadata,
  }) = _Signature;

  factory Signature.fromJson(Map<String, dynamic> json) =>
      _$SignatureFromJson(json);
}

// Extension for helper methods
extension SignatureX on Signature {
  bool get canSignOfferLetter => allowedLetterTypes.contains('Offer Letter');
  bool get canSignAppointmentLetter =>
      allowedLetterTypes.contains('Appointment Letter');
  bool get canSignExperienceCertificate =>
      allowedLetterTypes.contains('Experience Certificate');
  bool get canSignRelievingLetter =>
      allowedLetterTypes.contains('Relieving Letter');
  bool get canSignPromotionLetter =>
      allowedLetterTypes.contains('Promotion Letter');
  bool get canSignLeaveApproval =>
      allowedLetterTypes.contains('Leave Approval');
  bool get canSignWarningLetter =>
      allowedLetterTypes.contains('Warning Letter');
  bool get canSignCustomLetter => allowedLetterTypes.contains('Custom Letter');

  bool get isActiveSignature => isActive ?? true;

  String get displayName => title != null ? '$ownerName ($title)' : ownerName;

  bool canSignLetterType(String letterType) {
    return allowedLetterTypes.contains(letterType);
  }
}

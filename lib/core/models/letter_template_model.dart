import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'letter_template_model.freezed.dart';
part 'letter_template_model.g.dart';

// Custom converter for handling Firestore Timestamp
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
class LetterTemplate with _$LetterTemplate {
  const factory LetterTemplate({
    required String id,
    required String name,
    required String type, // 'Offer Letter', 'Appointment Letter', etc.
    required String content,
    @Default([]) List<String> variables, // ['employeeName', 'department', etc.]
    @Default({}) Map<String, String> defaultValues,
    @Default(true) bool isActive,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    required String createdBy,
    String? description,
    String? category, // 'HR', 'Management', 'Legal'
    @Default([]) List<String> requiredFields,
    @Default([]) List<String> optionalFields,
    String? signatureId, // Default signature for this template
    @Default({}) Map<String, dynamic> metadata,
  }) = _LetterTemplate;

  factory LetterTemplate.fromJson(Map<String, dynamic> json) =>
      _$LetterTemplateFromJson(json);

  const LetterTemplate._();

  /// Get template variables as a map with default values
  Map<String, String> get variablesWithDefaults {
    final result = <String, String>{};
    for (final variable in variables) {
      result[variable] = defaultValues[variable] ?? '';
    }
    return result;
  }

  /// Check if template has required signature
  bool get requiresSignature => signatureId != null;

  /// Get template display name
  String get displayName => '$name ($type)';

  /// Create template from basic information
  factory LetterTemplate.create({
    required String name,
    required String type,
    required String content,
    required String createdBy,
    List<String>? variables,
    Map<String, String>? defaultValues,
    String? description,
    String? category,
    List<String>? requiredFields,
    List<String>? optionalFields,
    String? signatureId,
  }) {
    final now = DateTime.now();
    return LetterTemplate(
      id: '', // Will be set by Firestore
      name: name,
      type: type,
      content: content,
      variables: variables ?? [],
      defaultValues: defaultValues ?? {},
      description: description,
      category: category,
      requiredFields: requiredFields ?? [],
      optionalFields: optionalFields ?? [],
      signatureId: signatureId,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
    );
  }

  /// Update template content
  LetterTemplate updateContent(String newContent) {
    return copyWith(content: newContent, updatedAt: DateTime.now());
  }

  /// Update template variables
  LetterTemplate updateVariables(List<String> newVariables) {
    return copyWith(variables: newVariables, updatedAt: DateTime.now());
  }

  /// Activate/deactivate template
  LetterTemplate setActive(bool active) {
    return copyWith(isActive: active, updatedAt: DateTime.now());
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    return json;
  }

  /// Create from Firestore document
  factory LetterTemplate.fromFirestore(Map<String, dynamic> data) {
    return LetterTemplate.fromJson(data);
  }
}

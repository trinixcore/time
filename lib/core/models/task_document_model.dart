import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'task_document_model.freezed.dart';
part 'task_document_model.g.dart';

class TimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const TimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? object) {
    if (object == null) return null;
    return object.toIso8601String();
  }
}

@freezed
class TaskDocumentModel with _$TaskDocumentModel {
  const factory TaskDocumentModel({
    required String id,
    required String taskId,
    required String fileName,
    required String originalFileName,
    required String supabasePath,
    required String firebasePath,
    required String fileType,
    required String mimeType,
    required int fileSizeBytes,
    required String uploadedBy,
    required String uploadedByName,
    @TimestampConverter() required DateTime uploadedAt,
    @TimestampConverter() required DateTime updatedAt,
    String? description,
    List<String>? tags,
    String? checksum,
    @Default(false) bool isConfidential,
    @Default('approved') String status,
  }) = _TaskDocumentModel;

  factory TaskDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$TaskDocumentModelFromJson(json);
}

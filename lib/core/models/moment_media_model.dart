import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'moment_media_model.freezed.dart';
part 'moment_media_model.g.dart';

enum MediaType { image, video }

@freezed
class MomentMedia with _$MomentMedia {
  const factory MomentMedia({
    required String id,
    required String fileName,
    required String fileUrl,
    required MediaType mediaType,
    required int displayOrder,
    required String uploadedBy,
    required DateTime uploadedAt,
    String? title,
    String? description,
    @Default(true) bool isActive,
    @Default(null) @JsonKey(ignore: true) String? signedUrl,
  }) = _MomentMedia;

  factory MomentMedia.fromJson(Map<String, dynamic> json) =>
      _$MomentMediaFromJson(json);
}

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
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
}

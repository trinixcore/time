import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'announcement_model.freezed.dart';
part 'announcement_model.g.dart';

@freezed
class Announcement with _$Announcement {
  const factory Announcement({
    required String id,
    required String title,
    required String content,
    required String createdBy,
    required DateTime createdAt,
    @TimestampConverter() DateTime? expiresAt,
    @Default(true) bool isActive,
    @Default('medium') String priority, // high, medium, low
    @Default([])
    List<String> tags, // ['urgent', 'update', 'maintenance', 'celebration']
    String? category, // 'system', 'event', 'maintenance', 'general'
    String? richContent, // HTML/Markdown content
    @Default([]) List<String> attachments, // Links to documents/images
    @Default([]) List<String> targetDepartments, // Specific departments
    @Default([]) List<String> targetRoles, // Specific roles
    @Default(true) bool isGlobal, // Show to all users
    @Default(false) bool requiresAcknowledgment, // Users must mark as read
    @Default([]) List<String> acknowledgedBy, // Track who has seen it
    int? maxViews, // Limit visibility after X views
    @Default(0) int viewCount, // Track total views
    String? createdByName, // Name of the creator
  }) = _Announcement;

  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  // Additional methods and getters
  const Announcement._();

  bool get isHighPriority => priority == 'high';
  bool get isMediumPriority => priority == 'medium';
  bool get isLowPriority => priority == 'low';

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
  bool get isExpiringSoon {
    if (expiresAt == null) return false;
    final now = DateTime.now();
    final difference = expiresAt!.difference(now);
    return difference.inDays <= 1 && difference.inHours > 0;
  }

  bool get isUrgent => tags.contains('urgent') || isHighPriority;
  bool get isSystem => category == 'system';
  bool get isEvent => category == 'event';
  bool get isMaintenance => category == 'maintenance';

  String get priorityDisplayName {
    switch (priority) {
      case 'high':
        return 'High Priority';
      case 'medium':
        return 'Medium Priority';
      case 'low':
        return 'Low Priority';
      default:
        return 'Medium Priority';
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case 'system':
        return 'System';
      case 'event':
        return 'Event';
      case 'maintenance':
        return 'Maintenance';
      case 'general':
        return 'General';
      default:
        return 'General';
    }
  }
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

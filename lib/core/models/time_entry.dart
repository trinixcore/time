import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_entry.freezed.dart';
part 'time_entry.g.dart';

@freezed
class TimeEntry with _$TimeEntry {
  const factory TimeEntry({
    required String id,
    required String employeeId,
    String? taskId,
    String? projectId,
    required DateTime startTime,
    DateTime? endTime,
    String? description,
    @Default(0) int durationMinutes,
    @Default(false) bool isManualEntry,
    @Default(false) bool isApproved,
    String? approvedById,
    DateTime? approvedAt,
    @Default([]) List<String> tags,
    String? location,
    Map<String, dynamic>? customFields,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? createdById,
    Map<String, dynamic>? metadata,
  }) = _TimeEntry;

  factory TimeEntry.fromJson(Map<String, dynamic> json) =>
      _$TimeEntryFromJson(json);

  // Additional methods and getters
  const TimeEntry._();

  /// Get calculated duration in minutes
  int get calculatedDurationMinutes {
    if (durationMinutes > 0) return durationMinutes;
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }

  /// Get duration in hours as decimal
  double get durationHours => calculatedDurationMinutes / 60.0;

  /// Get duration as formatted string (e.g., "2h 30m")
  String get durationFormatted {
    final minutes = calculatedDurationMinutes;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '${remainingMinutes}m';
    } else if (remainingMinutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${remainingMinutes}m';
    }
  }

  /// Check if time entry is currently active (no end time)
  bool get isActive => endTime == null;

  /// Check if time entry is completed
  bool get isCompleted => endTime != null;

  /// Check if time entry is for today
  bool get isToday {
    final now = DateTime.now();
    final entryDate = startTime;
    return entryDate.year == now.year &&
        entryDate.month == now.month &&
        entryDate.day == now.day;
  }

  /// Check if time entry is for this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return startTime.isAfter(startOfWeek) &&
        startTime.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if time entry is for this month
  bool get isThisMonth {
    final now = DateTime.now();
    return startTime.year == now.year && startTime.month == now.month;
  }

  /// Check if time entry spans multiple days
  bool get spansMultipleDays {
    if (endTime == null) return false;
    return startTime.day != endTime!.day ||
        startTime.month != endTime!.month ||
        startTime.year != endTime!.year;
  }

  /// Check if time entry is overtime (more than 8 hours)
  bool get isOvertime => durationHours > 8.0;

  /// Get overtime hours (hours beyond 8)
  double get overtimeHours => durationHours > 8.0 ? durationHours - 8.0 : 0.0;

  /// Check if time entry needs approval
  bool get needsApproval => !isApproved && isCompleted;

  /// Get date of the time entry
  DateTime get entryDate =>
      DateTime(startTime.year, startTime.month, startTime.day);

  /// Get start time formatted as string
  String get startTimeFormatted {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get end time formatted as string
  String get endTimeFormatted {
    if (endTime == null) return 'Active';
    return '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
  }

  /// Get time range as string
  String get timeRangeFormatted {
    return '$startTimeFormatted - $endTimeFormatted';
  }

  /// Check if time entry overlaps with another time entry
  bool overlapsWith(TimeEntry other) {
    if (employeeId != other.employeeId) return false;
    if (isActive || other.isActive) return false;

    final thisStart = startTime;
    final thisEnd = endTime!;
    final otherStart = other.startTime;
    final otherEnd = other.endTime!;

    return thisStart.isBefore(otherEnd) && thisEnd.isAfter(otherStart);
  }

  /// Stop the time entry (set end time)
  TimeEntry stop({DateTime? endTime}) {
    final stopTime = endTime ?? DateTime.now();
    final duration = stopTime.difference(startTime).inMinutes;

    return copyWith(
      endTime: stopTime,
      durationMinutes: duration,
      updatedAt: DateTime.now(),
    );
  }

  /// Resume the time entry (remove end time)
  TimeEntry resume() {
    return copyWith(
      endTime: null,
      durationMinutes: 0,
      updatedAt: DateTime.now(),
    );
  }

  /// Update description
  TimeEntry updateDescription(String newDescription) {
    return copyWith(description: newDescription, updatedAt: DateTime.now());
  }

  /// Update duration manually
  TimeEntry updateDuration(int minutes) {
    return copyWith(
      durationMinutes: minutes,
      isManualEntry: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Approve time entry
  TimeEntry approve(String approvedById) {
    return copyWith(
      isApproved: true,
      approvedById: approvedById,
      approvedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Unapprove time entry
  TimeEntry unapprove() {
    return copyWith(
      isApproved: false,
      approvedById: null,
      approvedAt: null,
      updatedAt: DateTime.now(),
    );
  }

  /// Add tag to time entry
  TimeEntry addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag], updatedAt: DateTime.now());
  }

  /// Remove tag from time entry
  TimeEntry removeTag(String tag) {
    return copyWith(
      tags: tags.where((t) => t != tag).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Update location
  TimeEntry updateLocation(String? newLocation) {
    return copyWith(location: newLocation, updatedAt: DateTime.now());
  }

  /// Update custom field
  TimeEntry updateCustomField(String key, dynamic value) {
    final updatedFields = Map<String, dynamic>.from(customFields ?? {});
    updatedFields[key] = value;

    return copyWith(customFields: updatedFields, updatedAt: DateTime.now());
  }

  /// Remove custom field
  TimeEntry removeCustomField(String key) {
    if (customFields == null || !customFields!.containsKey(key)) return this;

    final updatedFields = Map<String, dynamic>.from(customFields!);
    updatedFields.remove(key);

    return copyWith(
      customFields: updatedFields.isEmpty ? null : updatedFields,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// Create from Firestore document
  factory TimeEntry.fromFirestore(Map<String, dynamic> data) {
    return TimeEntry.fromJson(data);
  }
}

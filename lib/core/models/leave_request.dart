import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/leave_status.dart';

part 'leave_request.freezed.dart';
part 'leave_request.g.dart';

@freezed
class LeaveRequest with _$LeaveRequest {
  const factory LeaveRequest({
    required String id,
    required String employeeId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required LeaveStatus status,
    String? approvedById,
    String? rejectedById,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    String? approverComments,
    String? rejectionReason,
    @Default(false) bool isHalfDay,
    @Default(false) bool isEmergency,
    @Default(0.0) double totalDays,
    @Default([]) List<String> attachments,
    required DateTime createdAt,
    required DateTime updatedAt,
    Map<String, dynamic>? metadata,
  }) = _LeaveRequest;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestFromJson(json);

  // Additional methods and getters
  const LeaveRequest._();

  /// Calculate total leave days
  double get calculatedTotalDays {
    if (totalDays > 0) return totalDays;

    final difference = endDate.difference(startDate).inDays + 1;
    return isHalfDay ? 0.5 : difference.toDouble();
  }

  /// Check if leave is currently active
  bool get isActive {
    if (!status.isApproved) return false;
    final now = DateTime.now();
    return now.isAfter(startDate) &&
        now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Check if leave is upcoming
  bool get isUpcoming {
    if (!status.isApproved) return false;
    return DateTime.now().isBefore(startDate);
  }

  /// Check if leave is past
  bool get isPast {
    return DateTime.now().isAfter(endDate);
  }

  /// Get days until leave starts
  int get daysUntilStart {
    if (DateTime.now().isAfter(startDate)) return 0;
    return startDate.difference(DateTime.now()).inDays;
  }

  /// Get days since leave ended
  int get daysSinceEnd {
    if (DateTime.now().isBefore(endDate)) return 0;
    return DateTime.now().difference(endDate).inDays;
  }

  /// Check if leave can be cancelled
  bool get canBeCancelled => status.canBeCancelled && isUpcoming;

  /// Check if leave can be modified
  bool get canBeModified => status.canBeModified && isUpcoming;

  /// Check if leave requires approval
  bool get requiresApproval => status.isPending;

  /// Get leave duration in a readable format
  String get durationText {
    if (isHalfDay) return '0.5 day';
    final days = calculatedTotalDays.toInt();
    return days == 1 ? '1 day' : '$days days';
  }

  /// Get leave date range as string
  String get dateRangeText {
    if (startDate.isAtSameMomentAs(endDate)) {
      return '${startDate.day}/${startDate.month}/${startDate.year}';
    }
    return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
  }

  /// Check if leave spans multiple months
  bool get spansMultipleMonths =>
      startDate.month != endDate.month || startDate.year != endDate.year;

  /// Check if leave includes weekends
  bool get includesWeekends {
    DateTime current = startDate;
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (current.weekday == DateTime.saturday ||
          current.weekday == DateTime.sunday) {
        return true;
      }
      current = current.add(const Duration(days: 1));
    }
    return false;
  }

  /// Get working days in leave period (excluding weekends)
  int get workingDays {
    int count = 0;
    DateTime current = startDate;
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }
    return isHalfDay ? 1 : count;
  }

  /// Create a copy with approved status
  LeaveRequest approve({required String approvedById, String? comments}) {
    final now = DateTime.now();
    return copyWith(
      status: LeaveStatus.approved,
      approvedById: approvedById,
      approvedAt: now,
      approverComments: comments,
      updatedAt: now,
    );
  }

  /// Create a copy with rejected status
  LeaveRequest reject({required String rejectedById, required String reason}) {
    final now = DateTime.now();
    return copyWith(
      status: LeaveStatus.rejected,
      rejectedById: rejectedById,
      rejectedAt: now,
      rejectionReason: reason,
      updatedAt: now,
    );
  }

  /// Create a copy with cancelled status
  LeaveRequest cancel() {
    return copyWith(status: LeaveStatus.cancelled, updatedAt: DateTime.now());
  }

  /// Create a copy with updated dates
  LeaveRequest updateDates({
    required DateTime startDate,
    required DateTime endDate,
    bool? isHalfDay,
  }) {
    final newTotalDays =
        isHalfDay == true ? 0.5 : endDate.difference(startDate).inDays + 1.0;

    return copyWith(
      startDate: startDate,
      endDate: endDate,
      isHalfDay: isHalfDay ?? this.isHalfDay,
      totalDays: newTotalDays,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy with updated reason
  LeaveRequest updateReason(String newReason) {
    return copyWith(reason: newReason, updatedAt: DateTime.now());
  }

  /// Add attachment to leave request
  LeaveRequest addAttachment(String attachment) {
    if (attachments.contains(attachment)) return this;
    return copyWith(
      attachments: [...attachments, attachment],
      updatedAt: DateTime.now(),
    );
  }

  /// Remove attachment from leave request
  LeaveRequest removeAttachment(String attachment) {
    return copyWith(
      attachments: attachments.where((a) => a != attachment).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Convert enum to string for Firestore
    json['status'] = status.value;
    return json;
  }

  /// Create from Firestore document
  factory LeaveRequest.fromFirestore(Map<String, dynamic> data) {
    // Convert string value back to enum
    if (data['status'] is String) {
      data['status'] = LeaveStatus.fromString(data['status']).name;
    }
    return LeaveRequest.fromJson(data);
  }
}

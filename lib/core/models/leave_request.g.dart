// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeaveRequestImpl _$$LeaveRequestImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$LeaveRequestImpl', json, ($checkedConvert) {
  final val = _$LeaveRequestImpl(
    id: $checkedConvert('id', (v) => v as String),
    employeeId: $checkedConvert('employeeId', (v) => v as String),
    leaveType: $checkedConvert('leaveType', (v) => v as String),
    startDate: $checkedConvert('startDate', (v) => DateTime.parse(v as String)),
    endDate: $checkedConvert('endDate', (v) => DateTime.parse(v as String)),
    reason: $checkedConvert('reason', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$LeaveStatusEnumMap, v),
    ),
    approvedById: $checkedConvert('approvedById', (v) => v as String?),
    rejectedById: $checkedConvert('rejectedById', (v) => v as String?),
    approvedAt: $checkedConvert(
      'approvedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    rejectedAt: $checkedConvert(
      'rejectedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    approverComments: $checkedConvert('approverComments', (v) => v as String?),
    rejectionReason: $checkedConvert('rejectionReason', (v) => v as String?),
    isHalfDay: $checkedConvert('isHalfDay', (v) => v as bool? ?? false),
    isEmergency: $checkedConvert('isEmergency', (v) => v as bool? ?? false),
    totalDays: $checkedConvert(
      'totalDays',
      (v) => (v as num?)?.toDouble() ?? 0.0,
    ),
    attachments: $checkedConvert(
      'attachments',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
  );
  return val;
});

Map<String, dynamic> _$$LeaveRequestImplToJson(_$LeaveRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'leaveType': instance.leaveType,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'reason': instance.reason,
      'status': _$LeaveStatusEnumMap[instance.status]!,
      'approvedById': instance.approvedById,
      'rejectedById': instance.rejectedById,
      'approvedAt': instance.approvedAt?.toIso8601String(),
      'rejectedAt': instance.rejectedAt?.toIso8601String(),
      'approverComments': instance.approverComments,
      'rejectionReason': instance.rejectionReason,
      'isHalfDay': instance.isHalfDay,
      'isEmergency': instance.isEmergency,
      'totalDays': instance.totalDays,
      'attachments': instance.attachments,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$LeaveStatusEnumMap = {
  LeaveStatus.pending: 'pending',
  LeaveStatus.approved: 'approved',
  LeaveStatus.rejected: 'rejected',
  LeaveStatus.cancelled: 'cancelled',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignatureApprovalImpl _$$SignatureApprovalImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$SignatureApprovalImpl', json, ($checkedConvert) {
  final val = _$SignatureApprovalImpl(
    signatureId: $checkedConvert('signatureId', (v) => v as String),
    signatureOwnerUid: $checkedConvert('signatureOwnerUid', (v) => v as String),
    signatureOwnerName: $checkedConvert(
      'signatureOwnerName',
      (v) => v as String,
    ),
    signatureTitle: $checkedConvert('signatureTitle', (v) => v as String),
    status: $checkedConvert(
      'status',
      (v) => const SignatureStatusConverter().fromJson(v as String),
    ),
    approvedAt: $checkedConvert(
      'approvedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    rejectedAt: $checkedConvert(
      'rejectedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    approvedBy: $checkedConvert('approvedBy', (v) => v as String?),
    approvedByName: $checkedConvert('approvedByName', (v) => v as String?),
    rejectionReason: $checkedConvert('rejectionReason', (v) => v as String?),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$$SignatureApprovalImplToJson(
  _$SignatureApprovalImpl instance,
) => <String, dynamic>{
  'signatureId': instance.signatureId,
  'signatureOwnerUid': instance.signatureOwnerUid,
  'signatureOwnerName': instance.signatureOwnerName,
  'signatureTitle': instance.signatureTitle,
  'status': const SignatureStatusConverter().toJson(instance.status),
  'approvedAt': const TimestampConverter().toJson(instance.approvedAt),
  'rejectedAt': const TimestampConverter().toJson(instance.rejectedAt),
  'approvedBy': instance.approvedBy,
  'approvedByName': instance.approvedByName,
  'rejectionReason': instance.rejectionReason,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$LetterImpl _$$LetterImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$LetterImpl', json, ($checkedConvert) {
  final val = _$LetterImpl(
    id: $checkedConvert('id', (v) => v as String),
    type: $checkedConvert('type', (v) => v as String),
    content: $checkedConvert('content', (v) => v as String),
    employeeName: $checkedConvert('employeeName', (v) => v as String),
    employeeEmail: $checkedConvert('employeeEmail', (v) => v as String),
    createdBy: $checkedConvert('createdBy', (v) => v as String),
    signatureAuthorityUids: $checkedConvert(
      'signatureAuthorityUids',
      (v) =>
          (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    ),
    letterStatus: $checkedConvert(
      'letterStatus',
      (v) => const LetterStatusConverter().fromJson(v as String),
    ),
    signatureStatus: $checkedConvert(
      'signatureStatus',
      (v) => const SignatureStatusConverter().fromJson(v as String),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    signedPdfPath: $checkedConvert('signedPdfPath', (v) => v as String?),
    signedPdfUrl: $checkedConvert('signedPdfUrl', (v) => v as String?),
    storedIn: $checkedConvert('storedIn', (v) => v as String?),
    submittedForApprovalAt: $checkedConvert(
      'submittedForApprovalAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    approvedAt: $checkedConvert(
      'approvedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    rejectedAt: $checkedConvert(
      'rejectedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    sentAt: $checkedConvert(
      'sentAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    acceptedAt: $checkedConvert(
      'acceptedAt',
      (v) => const TimestampConverter().fromJson(v),
    ),
    rejectionReason: $checkedConvert('rejectionReason', (v) => v as String?),
    sentVia: $checkedConvert('sentVia', (v) => v as String?),
    sentTo: $checkedConvert('sentTo', (v) => v as String?),
    notes: $checkedConvert('notes', (v) => v as String?),
    metadata: $checkedConvert('metadata', (v) => v as Map<String, dynamic>?),
    headerId: $checkedConvert('headerId', (v) => v as String?),
    footerId: $checkedConvert('footerId', (v) => v as String?),
    logoId: $checkedConvert('logoId', (v) => v as String?),
    signatureApprovals: $checkedConvert(
      'signatureApprovals',
      (v) =>
          (v as List<dynamic>?)
              ?.map(
                (e) => SignatureApproval.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    ),
  );
  return val;
});

Map<String, dynamic> _$$LetterImplToJson(
  _$LetterImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'content': instance.content,
  'employeeName': instance.employeeName,
  'employeeEmail': instance.employeeEmail,
  'createdBy': instance.createdBy,
  'signatureAuthorityUids': instance.signatureAuthorityUids,
  'letterStatus': const LetterStatusConverter().toJson(instance.letterStatus),
  'signatureStatus': const SignatureStatusConverter().toJson(
    instance.signatureStatus,
  ),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'signedPdfPath': instance.signedPdfPath,
  'signedPdfUrl': instance.signedPdfUrl,
  'storedIn': instance.storedIn,
  'submittedForApprovalAt': const TimestampConverter().toJson(
    instance.submittedForApprovalAt,
  ),
  'approvedAt': const TimestampConverter().toJson(instance.approvedAt),
  'rejectedAt': const TimestampConverter().toJson(instance.rejectedAt),
  'sentAt': const TimestampConverter().toJson(instance.sentAt),
  'acceptedAt': const TimestampConverter().toJson(instance.acceptedAt),
  'rejectionReason': instance.rejectionReason,
  'sentVia': instance.sentVia,
  'sentTo': instance.sentTo,
  'notes': instance.notes,
  'metadata': instance.metadata,
  'headerId': instance.headerId,
  'footerId': instance.footerId,
  'logoId': instance.logoId,
  'signatureApprovals': instance.signatureApprovals,
};

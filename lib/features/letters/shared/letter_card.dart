import 'package:flutter/material.dart';
import '../../../core/models/letter_model.dart';
import 'package:intl/intl.dart';

class LetterCard extends StatefulWidget {
  final Letter letter;
  final Future<void> Function()? onEdit;
  final Future<void> Function()? onSubmit;
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onApprove;
  final Future<void> Function()? onReject;
  final Future<void> Function()? onDownload;
  final Future<void> Function()? onMarkSent;
  final Future<void> Function()? onMarkAccepted;
  final Future<void> Function()? onPreview;
  final Future<void> Function()? onMoveToDraft;
  final bool showApprovalProgress;

  const LetterCard({
    super.key,
    required this.letter,
    this.onEdit,
    this.onSubmit,
    this.onDelete,
    this.onApprove,
    this.onReject,
    this.onDownload,
    this.onMarkSent,
    this.onMarkAccepted,
    this.onPreview,
    this.onMoveToDraft,
    this.showApprovalProgress = false,
  });

  @override
  State<LetterCard> createState() => _LetterCardState();
}

class _LetterCardState extends State<LetterCard> {
  bool _isLoadingEdit = false;
  bool _isLoadingSubmit = false;
  bool _isLoadingDelete = false;
  bool _isLoadingApprove = false;
  bool _isLoadingReject = false;
  bool _isLoadingDownload = false;
  bool _isLoadingMarkSent = false;
  bool _isLoadingMarkAccepted = false;
  bool _isLoadingPreview = false;
  bool _isLoadingMoveToDraft = false;

  Future<void> _handleAction(
    Future<void> Function()? action,
    void Function(bool) setLoading,
  ) async {
    if (action == null) return;
    setLoading(true);
    try {
      await action();
    } finally {
      if (mounted) setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final letter = widget.letter;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        letter.type,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(letter.letterStatus),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          letter.statusDisplayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _getLetterTypeIcon(letter.type),
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Employee information
            _buildInfoRow('Employee', letter.employeeName),
            _buildInfoRow('Email', letter.employeeEmail),
            _buildInfoRow(
              'Created',
              DateFormat('MMM dd, yyyy').format(letter.createdAt),
            ),

            if (letter.updatedAt != letter.createdAt)
              _buildInfoRow(
                'Updated',
                DateFormat('MMM dd, yyyy').format(letter.updatedAt),
              ),

            // Additional timestamps based on status
            if (letter.submittedForApprovalAt != null)
              _buildInfoRow(
                'Submitted',
                DateFormat(
                  'MMM dd, yyyy',
                ).format(letter.submittedForApprovalAt!),
              ),

            if (letter.approvedAt != null)
              _buildInfoRow(
                'Approved',
                DateFormat('MMM dd, yyyy').format(letter.approvedAt!),
              ),

            if (letter.sentAt != null)
              _buildInfoRow(
                'Sent',
                DateFormat('MMM dd, yyyy').format(letter.sentAt!),
              ),

            if (letter.acceptedAt != null)
              _buildInfoRow(
                'Accepted',
                DateFormat('MMM dd, yyyy').format(letter.acceptedAt!),
              ),

            if (letter.rejectionReason != null)
              _buildInfoRow('Rejection Reason', letter.rejectionReason!),

            if (letter.sentVia != null)
              _buildInfoRow('Sent Via', letter.sentVia!),

            if (letter.sentTo != null) _buildInfoRow('Sent To', letter.sentTo!),

            // Approval progress section
            if (widget.showApprovalProgress &&
                letter.signatureApprovals.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildApprovalProgress(context),
            ],

            const SizedBox(height: 16),

            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalProgress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Approval Progress',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Enhanced status display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overall status
              Row(
                children: [
                  Icon(
                    _getStatusIcon(widget.letter.approvalStage),
                    size: 20,
                    color: _getApprovalStageColor(widget.letter.approvalStage),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.letter.detailedApprovalStatus,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getApprovalStageColor(
                          widget.letter.approvalStage,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress bar
              if (widget.letter.signatureApprovals.isNotEmpty) ...[
                LinearProgressIndicator(
                  value: widget.letter.approvalPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.letter.anySignatureRejected
                        ? Colors.red
                        : widget.letter.allSignaturesApproved
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.letter.approvalPercentage.toStringAsFixed(0)}% Complete',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
              ],

              // Next approver info
              if (widget.letter.nextRequiredApprover != null &&
                  !widget.letter.allSignaturesApproved &&
                  !widget.letter.anySignatureRejected) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Next: ${widget.letter.nextRequiredApprover}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Individual signature statuses
              ...widget.letter.signatureApprovals.map((approval) {
                final isApproved =
                    approval.status.toString() == 'SignatureStatus.approved()';
                final isRejected =
                    approval.status.toString() == 'SignatureStatus.rejected()';
                final isPending =
                    approval.status.toString() == 'SignatureStatus.pending()';

                Color statusColor;
                IconData statusIcon;
                String statusText;

                if (isApproved) {
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  statusText = 'Approved';
                } else if (isRejected) {
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  statusText = 'Rejected';
                } else {
                  statusColor = Colors.orange;
                  statusIcon = Icons.pending;
                  statusText = 'Pending';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              approval.signatureOwnerName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (approval.signatureTitle != null)
                              Text(
                                approval.signatureTitle!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              // Rejection reasons if any
              if (widget.letter.rejectedSignersWithReasons.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Rejection Reasons:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 4),
                ...widget.letter.rejectedSignersWithReasons.map(
                  (rejection) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '• ${rejection['name']}: ${rejection['reason']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.red[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final letter = widget.letter;
    final buttons = <Widget>[];

    // Draft actions
    if (letter.canEdit && widget.onEdit != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed:
              _isLoadingEdit
                  ? null
                  : () => _handleAction(
                    widget.onEdit,
                    (v) => setState(() => _isLoadingEdit = v),
                  ),
          icon:
              _isLoadingEdit
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.edit, size: 16),
          label: const Text('Edit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    if (letter.canSubmit && widget.onSubmit != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed:
              _isLoadingSubmit
                  ? null
                  : () => _handleAction(
                    widget.onSubmit,
                    (v) => setState(() => _isLoadingSubmit = v),
                  ),
          icon:
              _isLoadingSubmit
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.send, size: 16),
          label: const Text('Submit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // Approval actions
    if (widget.onPreview != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed:
              _isLoadingPreview
                  ? null
                  : () => _handleAction(
                    widget.onPreview,
                    (v) => setState(() => _isLoadingPreview = v),
                  ),
          icon:
              _isLoadingPreview
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.visibility, size: 16),
          label: const Text('Preview & Edit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }
    if (letter.canApprove && widget.onApprove != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed:
              _isLoadingApprove
                  ? null
                  : () => _handleAction(
                    widget.onApprove,
                    (v) => setState(() => _isLoadingApprove = v),
                  ),
          icon:
              _isLoadingApprove
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.check, size: 16),
          label: const Text('Approve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }
    if (letter.canReject && widget.onReject != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed:
              _isLoadingReject
                  ? null
                  : () => _handleAction(
                    widget.onReject,
                    (v) => setState(() => _isLoadingReject = v),
                  ),
          icon:
              _isLoadingReject
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.close, size: 16),
          label: const Text('Reject'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // Download action
    if ((letter.signedPdfPath != null && letter.signedPdfPath!.isNotEmpty) &&
        widget.onDownload != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed:
              _isLoadingDownload
                  ? null
                  : () => _handleAction(
                    widget.onDownload,
                    (v) => setState(() => _isLoadingDownload = v),
                  ),
          icon:
              _isLoadingDownload
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.download, size: 16),
          label: const Text('Download'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // Mark as sent
    if (letter.canMarkSent && widget.onMarkSent != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed:
              _isLoadingMarkSent
                  ? null
                  : () => _handleAction(
                    widget.onMarkSent,
                    (v) => setState(() => _isLoadingMarkSent = v),
                  ),
          icon:
              _isLoadingMarkSent
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.mark_email_read, size: 16),
          label: const Text('Mark Sent'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // Mark as accepted
    if (letter.canMarkAccepted && widget.onMarkAccepted != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed:
              _isLoadingMarkAccepted
                  ? null
                  : () => _handleAction(
                    widget.onMarkAccepted,
                    (v) => setState(() => _isLoadingMarkAccepted = v),
                  ),
          icon:
              _isLoadingMarkAccepted
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.done_all, size: 16),
          label: const Text('Mark Accepted'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // Delete action (only for drafts)
    if (letter.canEdit && widget.onDelete != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed:
              _isLoadingDelete
                  ? null
                  : () => _handleAction(
                    widget.onDelete,
                    (v) => setState(() => _isLoadingDelete = v),
                  ),
          icon:
              _isLoadingDelete
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.delete, size: 16),
          label: const Text('Delete'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    // Move to draft action (only for rejected letters)
    if (letter.isRejected && widget.onMoveToDraft != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed:
              _isLoadingMoveToDraft
                  ? null
                  : () => _handleAction(
                    widget.onMoveToDraft,
                    (v) => setState(() => _isLoadingMoveToDraft = v),
                  ),
          icon:
              _isLoadingMoveToDraft
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.edit, size: 16),
          label: const Text('Move to Draft'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(spacing: 8, runSpacing: 8, children: buttons);
  }

  Color _getStatusColor(LetterStatus status) {
    // Use a switch statement to check the status
    switch (status.runtimeType.toString()) {
      case '_LetterDraft':
        return Colors.grey;
      case '_LetterPendingApproval':
        return Colors.orange;
      case '_LetterApproved':
        return Colors.green;
      case '_LetterSent':
        return Colors.purple;
      case '_LetterAccepted':
        return Colors.teal;
      case '_LetterRejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getLetterTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'offer letter':
        return Icons.work;
      case 'appointment letter':
        return Icons.person_add;
      case 'experience certificate':
        return Icons.school;
      case 'relieving letter':
        return Icons.exit_to_app;
      case 'promotion letter':
        return Icons.trending_up;
      case 'leave approval':
        return Icons.event_available;
      case 'warning letter':
        return Icons.warning;
      default:
        return Icons.description;
    }
  }

  IconData _getStatusIcon(String stage) {
    switch (stage) {
      case 'Rejected':
        return Icons.cancel;
      case 'Fully Approved':
        return Icons.check_circle;
      case 'Partially Approved':
        return Icons.pending;
      case 'Awaiting First Approval':
        return Icons.schedule;
      case 'Approval In Progress':
        return Icons.pending;
      default:
        return Icons.info;
    }
  }

  Color _getApprovalStageColor(String stage) {
    switch (stage) {
      case 'Rejected':
        return Colors.red;
      case 'Fully Approved':
        return Colors.green;
      case 'Partially Approved':
        return Colors.orange;
      case 'Awaiting First Approval':
        return Colors.blue;
      case 'Approval In Progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
// Web-specific imports
import 'dart:html' as html;

import '../../../core/models/document_model.dart';
import '../../../core/enums/document_enums.dart';
import '../providers/document_providers.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../shared/widgets/password_confirmation_dialog.dart';

class DocumentCard extends ConsumerStatefulWidget {
  final DocumentModel document;
  final VoidCallback? onTap;
  final bool showActions;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.showActions = true,
  });

  @override
  ConsumerState<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends ConsumerState<DocumentCard> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final documentActions = ref.watch(documentActionsProvider);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with file icon and name
              Row(
                children: [
                  _buildFileIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.document.fileName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.document.description?.isNotEmpty ==
                            true) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.document.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.showActions) _buildActionMenu(context, ref),
                ],
              ),

              const SizedBox(height: 12),

              // Document metadata
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildChip(
                    label: widget.document.category.displayName,
                    color: _getCategoryColor(widget.document.category),
                    icon: Icons.category,
                  ),
                  _buildChip(
                    label: widget.document.accessLevel.displayName,
                    color: _getAccessLevelColor(widget.document.accessLevel),
                    icon: Icons.security,
                  ),
                  _buildChip(
                    label: widget.document.status.displayName,
                    color: _getStatusColor(widget.document.status),
                    icon: _getStatusIcon(widget.document.status),
                  ),
                  if (widget.document.fileSizeBytes != null)
                    _buildChip(
                      label: _formatFileSize(widget.document.fileSizeBytes),
                      color: Colors.grey,
                      icon: Icons.storage,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer with upload info and date
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'By ${widget.document.uploadedByName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat(
                      'MMM dd, yyyy',
                    ).format(widget.document.uploadedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Tags if available
              if (widget.document.tags?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children:
                      widget.document.tags!
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: theme.textTheme.bodySmall,
                              ),
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              side: BorderSide.none,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon() {
    IconData iconData;
    Color iconColor;

    switch (widget.document.fileType) {
      case DocumentFileType.pdf:
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case DocumentFileType.doc:
      case DocumentFileType.docx:
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case DocumentFileType.xls:
      case DocumentFileType.xlsx:
        iconData = Icons.table_chart;
        iconColor = Colors.green;
        break;
      case DocumentFileType.ppt:
      case DocumentFileType.pptx:
        iconData = Icons.slideshow;
        iconColor = Colors.orange;
        break;
      case DocumentFileType.jpg:
      case DocumentFileType.jpeg:
      case DocumentFileType.png:
      case DocumentFileType.gif:
        iconData = Icons.image;
        iconColor = Colors.purple;
        break;
      case DocumentFileType.zip:
      case DocumentFileType.rar:
        iconData = Icons.archive;
        iconColor = Colors.brown;
        break;
      case DocumentFileType.mp4:
        iconData = Icons.video_file;
        iconColor = Colors.indigo;
        break;
      case DocumentFileType.mp3:
        iconData = Icons.audio_file;
        iconColor = Colors.teal;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final canDeleteAsync = ref.watch(
          canDeleteFromCategoryProvider(widget.document.category),
        );

        return PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleAction(context, ref, value),
          itemBuilder: (context) {
            final items = <PopupMenuItem<String>>[
              PopupMenuItem(
                value: 'download',
                child: ListTile(
                  leading:
                      _isDownloading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.download),
                  title: Text(_isDownloading ? 'Downloading...' : 'Download'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ];

            if (widget.document.status == DocumentStatus.pending) {
              items.addAll([
                const PopupMenuItem(
                  value: 'approve',
                  child: ListTile(
                    leading: Icon(Icons.check, color: Colors.green),
                    title: Text('Approve'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: ListTile(
                    leading: Icon(Icons.close, color: Colors.red),
                    title: Text('Reject'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ]);
            }

            // Add delete option if user has permission
            final canDelete = canDeleteAsync.valueOrNull ?? false;
            if (canDelete) {
              items.add(
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              );
            }

            return items;
          },
        );
      },
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    final documentActions = ref.read(documentActionsProvider.notifier);

    switch (action) {
      case 'download':
        _downloadDocument(context, ref);
        break;
      case 'approve':
        documentActions.approveDocument(widget.document.id);
        break;
      case 'reject':
        _showRejectDialog(context, ref);
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
  }

  Future<void> _downloadDocument(BuildContext context, WidgetRef ref) async {
    if (_isDownloading) return;

    try {
      print(
        '📥 [CARD DOWNLOAD] Starting download for: ${widget.document.fileName}',
      );

      setState(() {
        _isDownloading = true;
      });

      // Get signed URL for download
      final documentActions = ref.read(documentActionsProvider.notifier);
      final signedUrl = await documentActions.getDocumentSignedUrl(
        widget.document.id,
      );

      print(
        '✅ [CARD DOWNLOAD] Signed URL received for: ${widget.document.fileName}',
      );

      // For web, use the signed URL directly to trigger download
      if (kIsWeb) {
        final anchor =
            html.AnchorElement(href: signedUrl)
              ..setAttribute('download', widget.document.fileName)
              ..style.display = 'none';

        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);

        print(
          '✅ [CARD DOWNLOAD] Download completed for: ${widget.document.fileName}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download started: ${widget.document.fileName}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // For mobile platforms, use the document actions provider
        await documentActions.downloadDocument(widget.document.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download completed: ${widget.document.fileName}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      setState(() {
        _isDownloading = false;
      });
    } catch (e, stackTrace) {
      print('💥 [CARD DOWNLOAD] Download failed: $e');
      print('📚 [CARD DOWNLOAD] Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: ${widget.document.fileName}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Document'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to reject "${widget.document.fileName}"?',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for rejection',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (reasonController.text.trim().isNotEmpty) {
                    ref
                        .read(documentActionsProvider.notifier)
                        .rejectDocument(
                          widget.document.id,
                          reasonController.text.trim(),
                        );
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    // Show password confirmation dialog first
    await showPasswordConfirmationDialog(
      context: context,
      title: 'Confirm Document Deletion',
      message:
          'You are about to permanently delete "${widget.document.fileName}". This action cannot be undone and requires password verification for security.',
      actionButtonText: 'Delete Document',
      actionButtonColor: Colors.red,
      icon: Icons.delete_forever,
      onConfirmed: () {
        // Password verified, proceed with deletion
        ref
            .read(documentActionsProvider.notifier)
            .deleteDocument(widget.document.id);

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Document "${widget.document.fileName}" has been deleted successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  Color _getCategoryColor(DocumentCategory category) {
    switch (category) {
      case DocumentCategory.company:
        return Colors.blue;
      case DocumentCategory.department:
        return Colors.green;
      case DocumentCategory.employee:
        return Colors.orange;
      case DocumentCategory.project:
        return Colors.purple;
      case DocumentCategory.shared:
        return Colors.teal;
      case DocumentCategory.hr:
        return Colors.pink;
      case DocumentCategory.finance:
        return Colors.indigo;
      case DocumentCategory.legal:
        return Colors.red;
      case DocumentCategory.training:
        return Colors.amber;
      case DocumentCategory.compliance:
        return Colors.brown;
    }
  }

  Color _getAccessLevelColor(DocumentAccessLevel accessLevel) {
    switch (accessLevel) {
      case DocumentAccessLevel.public:
        return Colors.green;
      case DocumentAccessLevel.restricted:
        return Colors.orange;
      case DocumentAccessLevel.confidential:
        return Colors.red;
      case DocumentAccessLevel.private:
        return Colors.purple;
    }
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return Colors.grey;
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.approved:
        return Colors.green;
      case DocumentStatus.rejected:
        return Colors.red;
      case DocumentStatus.archived:
        return Colors.blue;
      case DocumentStatus.deleted:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.draft:
        return Icons.edit;
      case DocumentStatus.pending:
        return Icons.pending;
      case DocumentStatus.approved:
        return Icons.check_circle;
      case DocumentStatus.rejected:
        return Icons.cancel;
      case DocumentStatus.archived:
        return Icons.archive;
      case DocumentStatus.deleted:
        return Icons.delete;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

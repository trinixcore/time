import 'package:flutter/material.dart';

class EmployeeFolderCard extends StatelessWidget {
  final Map<String, dynamic> folder;
  final VoidCallback onTap;
  final VoidCallback onUpload;
  final bool readOnly;

  const EmployeeFolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    required this.onUpload,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final folderName = folder['name'] as String? ?? 'Unknown Folder';
    final description = folder['description'] as String? ?? '';
    final documentCount = folder['documentCount'] as int? ?? 0;
    final folderCode = folder['metadata']?['folderCode'] as String? ?? '';

    // Extract folder type from name (e.g., "01_offer-letter" -> "Offer Letter")
    final displayName = _formatFolderName(folderName);
    final folderIcon = _getFolderIcon(folderCode);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon, code, and menu
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      folderIcon,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      folderCode,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      if (value == 'upload') {
                        onUpload();
                      } else if (value == 'open') {
                        onTap();
                      } else if (value == 'download') {
                        // TODO: Implement download all functionality
                        _downloadAllDocuments();
                      }
                    },
                    itemBuilder: (context) {
                      final items = <PopupMenuEntry<String>>[
                        const PopupMenuItem(
                          value: 'open',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_open, size: 16),
                              SizedBox(width: 8),
                              Text('Open Folder'),
                            ],
                          ),
                        ),
                      ];

                      if (!readOnly) {
                        items.add(
                          const PopupMenuItem(
                            value: 'upload',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.upload_file, size: 16),
                                SizedBox(width: 8),
                                Text('Upload Document'),
                              ],
                            ),
                          ),
                        );
                      }

                      if (documentCount > 0) {
                        items.add(
                          const PopupMenuItem(
                            value: 'download',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.download, size: 16),
                                SizedBox(width: 8),
                                Text('Download All'),
                              ],
                            ),
                          ),
                        );
                      }

                      return items;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Folder name
              Flexible(
                child: Text(
                  displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 4),

              // Description
              if (description.isNotEmpty)
                Flexible(
                  child: Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              const Spacer(),

              // Footer with document count
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.description,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '$documentCount ${documentCount == 1 ? 'document' : 'documents'}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFolderName(String folderName) {
    // Remove code prefix and format name
    final parts = folderName.split('_');
    if (parts.length > 1) {
      final nameWithoutCode = parts.sublist(1).join(' ');
      return nameWithoutCode
          .split('-')
          .where((word) => word.isNotEmpty) // Filter out empty words
          .map(
            (word) =>
                word.isNotEmpty
                    ? word[0].toUpperCase() + word.substring(1)
                    : '',
          )
          .where((word) => word.isNotEmpty) // Filter out empty results
          .join(' ');
    }
    return folderName;
  }

  IconData _getFolderIcon(String folderCode) {
    switch (folderCode) {
      case '01': // offer-letter
        return Icons.assignment;
      case '02': // payslips
        return Icons.receipt;
      case '03': // appraisal
        return Icons.star;
      case '04': // resignation
        return Icons.exit_to_app;
      case '05': // kyc-documents
        return Icons.verified_user;
      case '06': // employment-verification
        return Icons.work;
      case '07': // policies-acknowledged
        return Icons.policy;
      case '08': // training-certificates
        return Icons.school;
      case '09': // leave-documents
        return Icons.event_available;
      case '10': // loan-agreements
        return Icons.account_balance;
      case '11': // infra-assets
        return Icons.devices;
      case '12': // performance-warnings
        return Icons.warning;
      case '13': // awards-recognition
        return Icons.emoji_events;
      case '14': // feedbacks-surveys
        return Icons.feedback;
      case '15': // exit-clearance
        return Icons.check_circle;
      case '99': // personal
        return Icons.person;
      default:
        return Icons.folder;
    }
  }

  void _downloadAllDocuments() {
    // TODO: Implement download all functionality
  }
}

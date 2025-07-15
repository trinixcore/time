import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/folder_model.dart';
import '../../../core/enums/document_enums.dart';

class FolderCard extends ConsumerWidget {
  final FolderModel folder;
  final VoidCallback? onTap;
  final bool showActions;

  const FolderCard({
    super.key,
    required this.folder,
    this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with folder icon and name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        folder.category,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.folder,
                      color: _getCategoryColor(folder.category),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          folder.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (folder.description?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          Text(
                            folder.description!,
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
                  if (showActions) _buildActionMenu(context, ref),
                ],
              ),

              const SizedBox(height: 12),

              // Folder metadata
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildChip(
                    label: folder.category.displayName,
                    color: _getCategoryColor(folder.category),
                    icon: Icons.category,
                  ),
                  _buildChip(
                    label: folder.accessLevel.displayName,
                    color: _getAccessLevelColor(folder.accessLevel),
                    icon: Icons.security,
                  ),
                  if (folder.itemCount != null && folder.itemCount! > 0)
                    _buildChip(
                      label: '${folder.itemCount} items',
                      color: Colors.grey,
                      icon: Icons.inventory,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer with creator info and date
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'By ${folder.createdByName}',
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
                    DateFormat('MMM dd, yyyy').format(folder.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Tags if available
              if (folder.tags?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children:
                      folder.tags!
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
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _handleAction(context, ref, value),
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'rename',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Rename'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text('Share'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'rename':
        _showRenameDialog(context, ref);
        break;
      case 'share':
        // TODO: Implement share functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share functionality coming soon')),
        );
        break;
      case 'delete':
        _showDeleteDialog(context, ref);
        break;
    }
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: folder.name);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rename Folder'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Folder name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty &&
                      nameController.text.trim() != folder.name) {
                    // TODO: Implement rename functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rename functionality coming soon'),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Rename'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Folder'),
            content: Text('Are you sure you want to delete "${folder.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement delete functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Delete functionality coming soon'),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
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
}

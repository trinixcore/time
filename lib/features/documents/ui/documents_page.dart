import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/document_model.dart';
import '../../../core/models/folder_model.dart';
import '../../../core/enums/document_enums.dart';
import '../widgets/document_search_bar.dart';
import '../widgets/upload_document_dialog.dart';
import '../widgets/create_folder_dialog.dart';
import '../widgets/document_card.dart';
import '../widgets/folder_card.dart';
import '../providers/document_providers.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../widgets/document_preview_dialog.dart';

class DocumentsPage extends ConsumerStatefulWidget {
  final String? folderId;
  final DocumentCategory? category;

  const DocumentsPage({super.key, this.folderId, this.category});

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage> {
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardScaffold(
      currentPath: '/documents',
      child: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh documents data
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(theme),

              const SizedBox(height: 24),

              // Search and Filters
              _buildSearchAndFilters(theme),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(theme),

              const SizedBox(height: 32),

              // Content Area
              _buildContent(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category?.displayName ?? 'Document Library',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage and organize your documents',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
                if (widget.folderId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Current folder: ${widget.folderId}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.folder_open,
            size: 64,
            color: theme.colorScheme.onPrimary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search & Filter',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            DocumentSearchBar(
              initialValue: _searchTerm,
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchTerm = '';
                });
              },
            ),

            // Category filters
            const SizedBox(height: 16),
            Text(
              'Categories',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildCategoryFilters(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: widget.category == null,
          onSelected: (selected) {
            if (selected) {
              context.go('/documents');
            }
          },
        ),
        ...DocumentCategory.values.map((category) {
          return FilterChip(
            label: Text(category.displayName),
            selected: widget.category == category,
            onSelected: (selected) {
              if (selected) {
                context.go(
                  '/documents/category/${category.name.toLowerCase()}',
                );
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionCard(
                  context: context,
                  theme: theme,
                  icon: Icons.upload_file,
                  title: 'Upload Document',
                  subtitle: 'Add new document',
                  color: Colors.blue,
                  onTap: () => _showUploadDialog(),
                ),
                _buildActionCard(
                  context: context,
                  theme: theme,
                  icon: Icons.create_new_folder,
                  title: 'Create Folder',
                  subtitle: 'Organize documents',
                  color: Colors.green,
                  onTap: () => _showCreateFolderDialog(),
                ),
                _buildActionCard(
                  context: context,
                  theme: theme,
                  icon: Icons.search,
                  title: 'Advanced Search',
                  subtitle: 'Find specific documents',
                  color: Colors.orange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Advanced search coming soon!'),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context: context,
                  theme: theme,
                  icon: Icons.analytics,
                  title: 'Document Stats',
                  subtitle: 'View usage analytics',
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Analytics coming soon!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 200,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    // Create document query based on current filters
    final documentQuery = DocumentQuery(
      category: widget.category,
      folderId: widget.folderId,
      searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
      limit: 50,
    );

    // Create folder query
    final folderQuery = FolderQuery(
      parentId: widget.folderId,
      category: widget.category,
      limit: 50,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Documents & Folders',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.view_list),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('List view coming soon!')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.view_module),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Grid view coming soon!')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Documents and Folders Content
            Consumer(
              builder: (context, ref, child) {
                final documentsAsync = ref.watch(
                  documentsProvider(documentQuery),
                );
                final foldersAsync = ref.watch(foldersProvider(folderQuery));

                return documentsAsync.when(
                  data: (documents) {
                    return foldersAsync.when(
                      data: (folders) {
                        // Show content if we have documents or folders
                        if (documents.isNotEmpty || folders.isNotEmpty) {
                          return _buildDocumentsAndFolders(
                            theme,
                            documents,
                            folders,
                          );
                        } else {
                          // Show empty state only if both are empty
                          return _buildEmptyState(theme);
                        }
                      },
                      loading: () => _buildLoadingState(theme),
                      error: (error, stack) => _buildErrorState(theme, error),
                    );
                  },
                  loading: () => _buildLoadingState(theme),
                  error: (error, stack) => _buildErrorState(theme, error),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsAndFolders(
    ThemeData theme,
    List<DocumentModel> documents,
    List<FolderModel> folders,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show folders first
        if (folders.isNotEmpty) ...[
          Text(
            'Folders',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...folders.map(
            (folder) => FolderCard(
              folder: folder,
              onTap: () {
                context.go('/documents/folder/${folder.id}');
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Show documents
        if (documents.isNotEmpty) ...[
          Text(
            'Documents',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...documents.map(
            (document) => DocumentCard(
              document: document,
              onTap: () {
                print(
                  '🎯 [DOCUMENTS PAGE] Document card tapped: ${document.fileName}',
                );
                print('🎯 [DOCUMENTS PAGE] Document ID: ${document.id}');

                // Open document preview dialog
                showDialog(
                  context: context,
                  builder:
                      (context) => DocumentPreviewDialog(document: document),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.folder_open,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No documents yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first document to get started',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showUploadDialog(),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Document'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading documents...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error loading documents',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Refresh the data
                context.go('/documents');
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => UploadDocumentDialog(folderId: widget.folderId),
    );
  }

  void _showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateFolderDialog(parentId: widget.folderId),
    );
  }
}

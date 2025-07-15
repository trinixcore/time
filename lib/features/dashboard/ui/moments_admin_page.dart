import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/models/moment_media_model.dart';
import '../../../core/models/announcement_model.dart';
import '../providers/moments_providers.dart';
import '../../../shared/providers/auth_providers.dart';
import '../ui/dashboard_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MomentsAdminPage extends ConsumerWidget {
  const MomentsAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaList = ref.watch(activeMomentMediaProvider);
    final announcements = ref.watch(activeAnnouncementsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return DashboardScaffold(
      currentPath: '/admin/moments',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            // Carousel Media Section
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Carousel Media',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload images and videos to display in the dashboard carousel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildMediaUploadSection(context, ref, currentUser),
                    const SizedBox(height: 24),
                    mediaList.when(
                      data:
                          (media) =>
                              _buildMediaList(context, ref, media, theme),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (e, _) => Card(
                            color: theme.colorScheme.errorContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Error loading media: $e',
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Announcements Section
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.campaign, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Announcements',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create and manage announcements displayed on the dashboard',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _AnnouncementCreateSection(
                      currentUser: currentUser,
                      theme: theme,
                      ref: ref,
                    ),
                    const SizedBox(height: 24),
                    announcements.when(
                      data:
                          (ann) =>
                              _buildAnnouncementList(context, ref, ann, theme),
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (e, _) => Card(
                            color: theme.colorScheme.errorContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Error loading announcements: $e',
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaUploadSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> currentUser,
  ) {
    final theme = Theme.of(context);
    final uploadState = ref.watch(momentMediaUploadProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload New Media',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: uploadState.when(
                data:
                    (_) => FilledButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Select Image/Video(s)'),
                      onPressed: () async {
                        final user = currentUser.value;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User not authenticated')),
                          );
                          return;
                        }

                        try {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: [
                              'jpg',
                              'jpeg',
                              'png',
                              'gif',
                              'mp4',
                              'mov',
                              'webm',
                            ],
                            withData: true,
                            allowMultiple: true,
                          );

                          if (result != null && result.files.isNotEmpty) {
                            for (final file in result.files) {
                              final ext = file.extension?.toLowerCase();
                              final mediaType =
                                  (ext == 'mp4' ||
                                          ext == 'mov' ||
                                          ext == 'webm')
                                      ? MediaType.video
                                      : MediaType.image;

                              final upload = ref.read(
                                momentMediaUploadProvider.notifier,
                              );
                              final uploaded = await upload.uploadMedia(
                                fileName: file.name,
                                fileBytes: file.bytes!,
                                mediaType: mediaType,
                                uploadedBy: user.uid,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    uploaded != null
                                        ? 'Media uploaded: ${file.name}'
                                        : 'Failed to upload: ${file.name}',
                                  ),
                                  backgroundColor:
                                      uploaded != null
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.error,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to upload media: $e'),
                              backgroundColor: theme.colorScheme.error,
                            ),
                          );
                        }
                      },
                    ),
                loading:
                    () => FilledButton(
                      onPressed: null,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Uploading...'),
                        ],
                      ),
                    ),
                error:
                    (error, _) => FilledButton.icon(
                      icon: const Icon(Icons.error),
                      label: const Text('Retry Upload'),
                      onPressed: () {
                        ref.invalidate(momentMediaUploadProvider);
                      },
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Supported formats: JPG, PNG, GIF, MP4, MOV, WEBM',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaList(
    BuildContext context,
    WidgetRef ref,
    List<MomentMedia> media,
    ThemeData theme,
  ) {
    if (media.isEmpty) {
      return Card(
        color: theme.colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No media uploaded yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload images or videos to display in the dashboard carousel',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploaded Media (${media.length})',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...media
            .map(
              (m) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      if (m.mediaType == MediaType.image &&
                          m.signedUrl != null) {
                        showDialog(
                          context: context,
                          builder:
                              (context) => Dialog(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    m.signedUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                        );
                      } else if (m.mediaType == MediaType.video &&
                          m.signedUrl != null) {
                        showDialog(
                          context: context,
                          builder:
                              (context) => Dialog(
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Center(
                                    child:
                                        m.signedUrl != null
                                            ? HtmlElementView(
                                              viewType: m.signedUrl!,
                                            )
                                            : const Text('No preview'),
                                  ),
                                ),
                              ),
                        );
                      }
                    },
                    child:
                        m.mediaType == MediaType.image && m.signedUrl != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                m.signedUrl!,
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.broken_image,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            )
                            : Icon(
                              Icons.videocam,
                              color: theme.colorScheme.primary,
                              size: 48,
                            ),
                  ),
                  title: Text(m.fileName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.mediaType == MediaType.image ? 'Image' : 'Video'),
                      if (m.title != null) Text('Title: ${m.title}'),
                      Text('Order: ${m.displayOrder}'),
                      Text('Uploaded by: ${m.uploadedBy}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: theme.colorScheme.error),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Delete Media'),
                              content: Text(
                                'Are you sure you want to delete "${m.fileName}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                      );

                      if (confirmed == true) {
                        await ref
                            .read(momentMediaDeleteProvider.notifier)
                            .deleteMedia(m.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Media deleted successfully')),
                        );
                      }
                    },
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }
}

class _AnnouncementCreateSection extends StatefulWidget {
  final AsyncValue<dynamic> currentUser;
  final ThemeData theme;
  final WidgetRef ref;
  const _AnnouncementCreateSection({
    required this.currentUser,
    required this.theme,
    required this.ref,
  });

  @override
  State<_AnnouncementCreateSection> createState() =>
      _AnnouncementCreateSectionState();
}

class _AnnouncementCreateSectionState
    extends State<_AnnouncementCreateSection> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  String selectedPriority = 'medium';
  String selectedCategory = 'general';
  DateTime? selectedExpirationDate;
  List<String> selectedTags = [];
  bool requiresAcknowledgment = false;
  bool isGlobal = true;
  int? maxViews;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createState = widget.ref.watch(announcementCreateProvider);
    final theme = widget.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create New Announcement',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        // Title and Priority Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter announcement title',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'high',
                    child: Text('🔴 High Priority'),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text('🟡 Medium Priority'),
                  ),
                  DropdownMenuItem(
                    value: 'low',
                    child: Text('🟢 Low Priority'),
                  ),
                ],
                onChanged:
                    (value) =>
                        setState(() => selectedPriority = value ?? 'medium'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Content
        TextField(
          controller: contentController,
          decoration: const InputDecoration(
            labelText: 'Content',
            hintText: 'Enter announcement content...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          minLines: 2,
        ),
        const SizedBox(height: 16),
        // Category and Expiration Row
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('📢 General')),
                  DropdownMenuItem(value: 'system', child: Text('⚙️ System')),
                  DropdownMenuItem(value: 'event', child: Text('🎉 Event')),
                  DropdownMenuItem(
                    value: 'maintenance',
                    child: Text('🔧 Maintenance'),
                  ),
                ],
                onChanged:
                    (value) =>
                        setState(() => selectedCategory = value ?? 'general'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Expires At (Optional)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        selectedExpirationDate ??
                        DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                        selectedExpirationDate ?? DateTime.now(),
                      ),
                    );
                    if (time != null) {
                      setState(() {
                        selectedExpirationDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                controller: TextEditingController(
                  text:
                      selectedExpirationDate != null
                          ? '${selectedExpirationDate!.day}/${selectedExpirationDate!.month}/${selectedExpirationDate!.year} ${selectedExpirationDate!.hour}:${selectedExpirationDate!.minute.toString().padLeft(2, '0')}'
                          : '',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Tags Selection
        Text(
          'Tags',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              [
                'urgent',
                'update',
                'maintenance',
                'celebration',
                'important',
                'reminder',
              ].map((tag) {
                final isSelected = selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedTags.add(tag);
                      } else {
                        selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.onPrimaryContainer,
                );
              }).toList(),
        ),
        const SizedBox(height: 16),
        // Additional Options
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Requires Acknowledgment'),
                subtitle: const Text('Users must mark as read'),
                value: requiresAcknowledgment,
                onChanged:
                    (value) =>
                        setState(() => requiresAcknowledgment = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Global Announcement'),
                subtitle: const Text('Show to all users'),
                value: isGlobal,
                onChanged: (value) => setState(() => isGlobal = value ?? true),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Max Views (Optional)
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Max Views (Optional)',
            border: OutlineInputBorder(),
            hintText: 'Leave empty for unlimited views',
            helperText: 'Announcement will be hidden after this many views',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => setState(() => maxViews = int.tryParse(value)),
        ),
        const SizedBox(height: 24),
        // Create Button
        Row(
          children: [
            Expanded(
              child: createState.when(
                data:
                    (_) => FilledButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create Announcement'),
                      onPressed: () async {
                        final user = widget.currentUser.value;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User not authenticated'),
                            ),
                          );
                          return;
                        }
                        if (titleController.text.isEmpty ||
                            contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please fill in both title and content',
                              ),
                            ),
                          );
                          return;
                        }
                        await widget.ref
                            .read(announcementCreateProvider.notifier)
                            .createAnnouncement(
                              title: titleController.text,
                              content: contentController.text,
                              createdBy: user.uid,
                              priority: selectedPriority,
                              category: selectedCategory,
                              expiresAt: selectedExpirationDate,
                              tags: selectedTags,
                              requiresAcknowledgment: requiresAcknowledgment,
                              isGlobal: isGlobal,
                              maxViews: maxViews,
                              createdByName:
                                  user.displayName ?? user.email ?? 'Unknown',
                            );
                        setState(() {
                          titleController.clear();
                          contentController.clear();
                          selectedTags.clear();
                          selectedExpirationDate = null;
                          requiresAcknowledgment = false;
                          isGlobal = true;
                          maxViews = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Announcement created successfully!'),
                          ),
                        );
                      },
                    ),
                loading:
                    () => const FilledButton(
                      onPressed: null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Creating...'),
                        ],
                      ),
                    ),
                error:
                    (error, _) => FilledButton.icon(
                      icon: const Icon(Icons.error),
                      label: const Text('Retry'),
                      onPressed: () {
                        widget.ref.invalidate(announcementCreateProvider);
                      },
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Widget _buildAnnouncementList(
  BuildContext context,
  WidgetRef ref,
  List<Announcement> announcements,
  ThemeData theme,
) {
  if (announcements.isEmpty) {
    return Card(
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No announcements yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create announcements to display on the dashboard',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Current Announcements (${announcements.length})',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
      ...announcements
          .map((a) => _AdminAnnouncementCard(a: a, theme: theme, ref: ref))
          .toList(),
    ],
  );
}

class _AdminAnnouncementCard extends StatefulWidget {
  final Announcement a;
  final ThemeData theme;
  final WidgetRef ref;
  const _AdminAnnouncementCard({
    required this.a,
    required this.theme,
    required this.ref,
  });

  @override
  State<_AdminAnnouncementCard> createState() => _AdminAnnouncementCardState();
}

class _AdminAnnouncementCardState extends State<_AdminAnnouncementCard> {
  bool showAck = false;
  List<Map<String, dynamic>> ackUsers = [];
  bool loadingAck = false;

  Future<void> _fetchAckUsers() async {
    setState(() {
      loadingAck = true;
    });
    try {
      if (widget.a.acknowledgedBy.isEmpty) {
        ackUsers = [];
      } else {
        final usersSnap =
            await FirebaseFirestore.instance
                .collection('users')
                .where(
                  'uid',
                  whereIn: widget.a.acknowledgedBy.take(10).toList(),
                )
                .get();
        ackUsers = usersSnap.docs.map((d) => d.data()).toList();
      }
    } catch (_) {
      ackUsers = [];
    }
    setState(() {
      loadingAck = false;
    });
  }

  void _showEditDialog() async {
    final a = widget.a;
    final theme = widget.theme;
    final ref = widget.ref;
    final titleController = TextEditingController(text: a.title);
    final contentController = TextEditingController(text: a.content);
    String selectedPriority = a.priority;
    String selectedCategory = a.category ?? 'general';
    DateTime? selectedExpirationDate = a.expiresAt;
    List<String> selectedTags = List.from(a.tags);
    bool requiresAcknowledgment = a.requiresAcknowledgment;
    bool isGlobal = a.isGlobal;
    int? maxViews = a.maxViews;
    bool loading = false;
    bool error = false;
    String? errorMsg;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Announcement'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: contentController,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedPriority,
                                decoration: const InputDecoration(
                                  labelText: 'Priority',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'high',
                                    child: Text('🔴 High Priority'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'medium',
                                    child: Text('🟡 Medium Priority'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'low',
                                    child: Text('🟢 Low Priority'),
                                  ),
                                ],
                                onChanged:
                                    (v) => setState(
                                      () => selectedPriority = v ?? 'medium',
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'general',
                                    child: Text('📢 General'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'system',
                                    child: Text('⚙️ System'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'event',
                                    child: Text('🎉 Event'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'maintenance',
                                    child: Text('🔧 Maintenance'),
                                  ),
                                ],
                                onChanged:
                                    (v) => setState(
                                      () => selectedCategory = v ?? 'general',
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Expires At (Optional)',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  selectedExpirationDate ??
                                  DateTime.now().add(const Duration(days: 7)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                  selectedExpirationDate ?? DateTime.now(),
                                ),
                              );
                              if (time != null) {
                                setState(() {
                                  selectedExpirationDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          controller: TextEditingController(
                            text:
                                selectedExpirationDate != null
                                    ? '${selectedExpirationDate!.day}/${selectedExpirationDate!.month}/${selectedExpirationDate!.year} ${selectedExpirationDate!.hour}:${selectedExpirationDate!.minute.toString().padLeft(2, '0')}'
                                    : '',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Tags'),
                        Wrap(
                          spacing: 8,
                          children:
                              [
                                'urgent',
                                'update',
                                'maintenance',
                                'celebration',
                                'important',
                                'reminder',
                              ].map((tag) {
                                final isSelected = selectedTags.contains(tag);
                                return FilterChip(
                                  label: Text(tag),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedTags.add(tag);
                                      } else {
                                        selectedTags.remove(tag);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('Requires Acknowledgment'),
                                value: requiresAcknowledgment,
                                onChanged:
                                    (v) => setState(
                                      () => requiresAcknowledgment = v ?? false,
                                    ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                title: const Text('Global Announcement'),
                                value: isGlobal,
                                onChanged:
                                    (v) => setState(() => isGlobal = v ?? true),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Max Views (Optional)',
                          ),
                          initialValue: maxViews?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          onChanged:
                              (v) => setState(() => maxViews = int.tryParse(v)),
                        ),
                        if (error && errorMsg != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            errorMsg!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed:
                          loading
                              ? null
                              : () async {
                                setState(() {
                                  loading = true;
                                  error = false;
                                });
                                try {
                                  final updateData = {
                                    'title': titleController.text,
                                    'content': contentController.text,
                                    'category': selectedCategory,
                                    'tags': selectedTags,
                                    'requiresAcknowledgment':
                                        requiresAcknowledgment,
                                    'isGlobal': isGlobal,
                                    'maxViews': maxViews,
                                    'priority': selectedPriority,
                                    'isActive': a.isActive,
                                  };
                                  if (selectedExpirationDate != null) {
                                    updateData['expiresAt'] =
                                        Timestamp.fromDate(
                                          selectedExpirationDate!,
                                        );
                                  } else {
                                    updateData['expiresAt'] = null;
                                  }
                                  await FirebaseFirestore.instance
                                      .collection('announcements')
                                      .doc(a.id)
                                      .update(updateData);
                                  ref.invalidate(activeAnnouncementsProvider);
                                  if (mounted) Navigator.of(context).pop();
                                } catch (e) {
                                  setState(() {
                                    error = true;
                                    errorMsg = 'Failed to update: $e';
                                    loading = false;
                                  });
                                }
                              },
                      child:
                          loading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.a;
    final theme = widget.theme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: a.isHighPriority ? 4 : 1,
      color:
          a.isHighPriority
              ? theme.colorScheme.errorContainer.withOpacity(0.1)
              : null,
      child: Container(
        decoration:
            a.isHighPriority
                ? BoxDecoration(
                  border: Border.all(color: theme.colorScheme.error, width: 2),
                  borderRadius: BorderRadius.circular(12),
                )
                : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with priority indicator
              Row(
                children: [
                  Icon(
                    a.isHighPriority ? Icons.priority_high : Icons.campaign,
                    color:
                        a.isHighPriority
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      a.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            a.isHighPriority
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (a.isHighPriority)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'HIGH PRIORITY',
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Content
              Text(a.content, style: theme.textTheme.bodyMedium),

              const SizedBox(height: 12),

              // Tags
              if (a.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  children:
                      a.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag),
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontSize: 10,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Metadata row
              Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    a.categoryDisplayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatRelativeTime(a.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Additional info
              if (a.requiresAcknowledgment || a.maxViews != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (a.requiresAcknowledgment) ...[
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Requires acknowledgment',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: Icon(
                          showAck ? Icons.expand_less : Icons.expand_more,
                        ),
                        label: Text(
                          'Acknowledged (${a.acknowledgedBy.length})',
                        ),
                        onPressed: () async {
                          setState(() {
                            showAck = !showAck;
                          });
                          if (showAck &&
                              ackUsers.isEmpty &&
                              a.acknowledgedBy.isNotEmpty) {
                            await _fetchAckUsers();
                          }
                        },
                      ),
                    ],
                    if (a.maxViews != null) ...[
                      Icon(
                        Icons.visibility,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${a.viewCount}/${a.maxViews} views',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
                if (showAck)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 24),
                    child:
                        loadingAck
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : ackUsers.isEmpty
                            ? Text(
                              'No acknowledgments yet',
                              style: theme.textTheme.bodySmall,
                            )
                            : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  ackUsers
                                      .map(
                                        (u) => Text(
                                          u['displayName'] ??
                                              u['email'] ??
                                              u['uid'] ??
                                              'Unknown',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      )
                                      .toList(),
                            ),
                  ),
              ],

              // Actions
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                    onPressed: _showEditDialog,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: theme.colorScheme.error),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Delete Announcement'),
                              content: Text(
                                'Are you sure you want to delete "${a.title}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                      );
                      if (confirmed == true) {
                        await widget.ref
                            .read(announcementDeleteProvider.notifier)
                            .deleteAnnouncement(a.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Announcement deleted successfully'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}

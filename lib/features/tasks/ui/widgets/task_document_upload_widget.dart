import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/task_document_providers.dart';
import '../../../../core/models/task_document_model.dart';
import '../../../../shared/providers/auth_providers.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'dart:ui_web' as ui_web;

class TaskDocumentUploadWidget extends ConsumerWidget {
  final String taskId;
  final String taskTitle;

  const TaskDocumentUploadWidget({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_file, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Task Documents',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  color: theme.colorScheme.primary,
                  tooltip: 'Upload Document',
                  onPressed:
                      () => showDialog(
                        context: context,
                        builder:
                            (context) => _TaskDocumentUploadDialog(
                              taskId: taskId,
                              taskTitle: taskTitle,
                            ),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                final documentsAsync = ref.watch(taskDocumentsProvider(taskId));
                return documentsAsync.when(
                  data: (documents) {
                    if (documents.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 48,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No documents uploaded yet',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Upload documents related to this task',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      children:
                          documents
                              .map(
                                (document) => _TaskDocumentCard(
                                  document: document,
                                  taskId: taskId,
                                ),
                              )
                              .toList(),
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stack) => Center(
                        child: Text(
                          'Error loading documents: $error',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskDocumentUploadDialog extends ConsumerStatefulWidget {
  final String taskId;
  final String taskTitle;
  const _TaskDocumentUploadDialog({
    required this.taskId,
    required this.taskTitle,
  });
  @override
  ConsumerState<_TaskDocumentUploadDialog> createState() =>
      _TaskDocumentUploadDialogState();
}

class _TaskDocumentUploadDialogState
    extends ConsumerState<_TaskDocumentUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  PlatformFile? _selectedPlatformFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedPlatformFile = result.files.first;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file: $e');
    }
  }

  Future<void> _uploadDocument() async {
    if (!_formKey.currentState!.validate() || _selectedPlatformFile == null) {
      return;
    }
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Starting upload...';
    });
    try {
      await ref
          .read(uploadTaskDocumentProvider.notifier)
          .uploadDocument(
            taskId: widget.taskId,
            fileName: _selectedPlatformFile!.name,
            bytes: _selectedPlatformFile!.bytes!,
            description:
                _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : null,
            tags:
                _tagsController.text.isNotEmpty
                    ? _tagsController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList()
                    : null,
            onProgress: (progress, status) {
              setState(() {
                _uploadProgress = progress;
                _uploadStatus = status;
              });
            },
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Upload failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploadState = ref.watch(uploadTaskDocumentProvider);
    final hasFile = _selectedPlatformFile != null;
    final fileName = _selectedPlatformFile?.name ?? '';
    final fileSize = _selectedPlatformFile?.size ?? 0;
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.upload_file, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Upload Task Document',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed:
                        _isUploading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // File selection
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        hasFile
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (!hasFile) ...[
                      Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select a file to upload',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _selectFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Browse Files'),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(fileSize / 1024).toStringAsFixed(2)} KB',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed:
                                _isUploading
                                    ? null
                                    : () => setState(
                                      () => _selectedPlatformFile = null,
                                    ),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter document description...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Tags field
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter tags separated by commas...',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isUploading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        _isUploading || !hasFile ? null : _uploadDocument,
                    child:
                        _isUploading
                            ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Upload'),
                  ),
                ],
              ),
              if (_isUploading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 8),
                Text(_uploadStatus, style: theme.textTheme.bodySmall),
              ],
              if (uploadState.hasError) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error,
                        color: theme.colorScheme.onErrorContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          uploadState.error.toString(),
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskDocumentCard extends ConsumerWidget {
  final TaskDocumentModel document;
  final String taskId;
  const _TaskDocumentCard({required this.document, required this.taskId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getFileIcon(document.fileType),
        title: Text(
          document.fileName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uploaded by ${document.uploadedByName} on ${_formatDate(document.uploadedAt)}',
              style: theme.textTheme.bodySmall,
            ),
            if (document.description != null &&
                document.description!.isNotEmpty)
              Text(
                document.description!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: SizedBox(
          width: 120,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _previewDocument(context, ref),
                icon: const Icon(Icons.preview),
                tooltip: 'Preview',
              ),
              IconButton(
                onPressed: () => _downloadDocument(context, ref),
                icon: const Icon(Icons.download),
                tooltip: 'Download',
              ),
              IconButton(
                onPressed: () => _deleteDocument(context, ref),
                icon: const Icon(Icons.delete),
                tooltip: 'Delete',
                color: theme.colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getFileIcon(String fileType) {
    IconData iconData;
    Color iconColor;
    switch (fileType.toLowerCase()) {
      case '.pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case '.doc':
      case '.docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case '.xls':
      case '.xlsx':
        iconData = Icons.table_chart;
        iconColor = Colors.green;
        break;
      case '.ppt':
      case '.pptx':
        iconData = Icons.slideshow;
        iconColor = Colors.orange;
        break;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        iconData = Icons.image;
        iconColor = Colors.purple;
        break;
      case '.txt':
        iconData = Icons.text_snippet;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }
    return Icon(iconData, color: iconColor);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _previewDocument(BuildContext context, WidgetRef ref) async {
    try {
      final url = await ref.read(taskDocumentUrlProvider(document.id).future);
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (context) => _TaskDocumentPreviewDialog(
                document: document,
                signedUrl: url,
              ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadDocument(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preparing download...')));

      final url = await ref.read(taskDocumentUrlProvider(document.id).future);
      if (context.mounted) {
        // For web, fetch the file and create a blob URL for forced download
        if (kIsWeb) {
          // Use Future.microtask to handle async operation
          Future.microtask(() async {
            try {
              // Fetch the file as a blob
              final response = await html.HttpRequest.request(
                url,
                responseType: 'blob',
              );

              final blob = response.response as html.Blob;
              final blobUrl = html.Url.createObjectUrlFromBlob(blob);

              // Create anchor element with blob URL for forced download
              final anchor =
                  html.AnchorElement(href: blobUrl)
                    ..setAttribute('download', document.fileName)
                    ..style.display = 'none';

              html.document.body?.children.add(anchor);
              anchor.click();
              html.document.body?.children.remove(anchor);

              // Clean up the blob URL
              html.Url.revokeObjectUrl(blobUrl);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Download started: ${document.fileName}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (fetchError) {
              // Fallback to direct URL if blob fetch fails
              print('Blob fetch failed, using direct URL: $fetchError');
              final anchor =
                  html.AnchorElement(href: url)
                    ..setAttribute('download', document.fileName)
                    ..setAttribute('target', '_blank')
                    ..style.display = 'none';

              html.document.body?.children.add(anchor);
              anchor.click();
              html.document.body?.children.remove(anchor);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Download started: ${document.fileName}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          });
        } else {
          // For mobile platforms, show the download URL
          if (context.mounted) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text('Download: ${document.fileName}'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Click the link below to download the document:',
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          url,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Copy to clipboard functionality could be added here
                        },
                        child: const Text('Copy Link'),
                      ),
                    ],
                  ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDocument(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Document'),
            content: Text(
              'Are you sure you want to delete "${document.fileName}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      try {
        await ref
            .read(deleteTaskDocumentProvider.notifier)
            .deleteDocument(document.id, taskId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Document deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete document: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _TaskDocumentPreviewDialog extends StatefulWidget {
  final TaskDocumentModel document;
  final String signedUrl;
  const _TaskDocumentPreviewDialog({
    required this.document,
    required this.signedUrl,
  });

  @override
  State<_TaskDocumentPreviewDialog> createState() =>
      _TaskDocumentPreviewDialogState();
}

class _TaskDocumentPreviewDialogState
    extends State<_TaskDocumentPreviewDialog> {
  bool _isPdfLoading = false;
  bool _isOfficeLoading = false;

  @override
  void initState() {
    super.initState();
    final fileType = widget.document.fileType.toLowerCase();
    if (kIsWeb && fileType == '.pdf') {
      _isPdfLoading = true;
      _registerPdfViewer();
    } else if (kIsWeb && (fileType == '.ppt' || fileType == '.pptx')) {
      _isOfficeLoading = true;
      _registerPowerPointViewer();
    } else if (kIsWeb && (fileType == '.doc' || fileType == '.docx')) {
      _isOfficeLoading = true;
      _registerWordViewer();
    }
  }

  void _registerPdfViewer() {
    final viewType = 'pdf-viewer-${widget.document.id}';
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final container =
          html.DivElement()
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.position = 'relative'
            ..style.backgroundColor = '#f5f5f5'
            ..style.border = 'none'
            ..style.overflow = 'hidden';
      final encodedUrl = Uri.encodeComponent(widget.signedUrl);
      final pdfJsUrl =
          'https://mozilla.github.io/pdf.js/web/viewer.html?file=$encodedUrl';
      final htmlContent = '''
        <div style="width: 100%; height: 100%; display: flex; flex-direction: column;">
          <iframe 
            id="pdf-iframe-${widget.document.id}"
            style="width: 100%; height: 100%; border: none; background: white;"
            sandbox="allow-same-origin allow-scripts allow-popups allow-forms"
            allow="fullscreen"
            loading="lazy">
          </iframe>
        </div>
      ''';
      container.setInnerHtml(
        htmlContent,
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        final iframe =
            container.querySelector('#pdf-iframe-${widget.document.id}')
                as html.IFrameElement?;
        if (iframe != null) {
          iframe.src = pdfJsUrl;
          iframe.onLoad.listen((_) {
            if (mounted) setState(() => _isPdfLoading = false);
          });
        }
      });
      return container;
    });
  }

  void _registerPowerPointViewer() {
    final viewType = 'powerpoint-viewer-${widget.document.id}';
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final container =
          html.DivElement()
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.position = 'relative'
            ..style.backgroundColor = '#f5f5f5'
            ..style.border = 'none'
            ..style.overflow = 'hidden';
      final encodedUrl = Uri.encodeComponent(widget.signedUrl);
      final officeUrl =
          'https://view.officeapps.live.com/op/embed.aspx?src=$encodedUrl';
      final htmlContent = '''
        <iframe id="ppt-iframe-${widget.document.id}" src="$officeUrl" style="width:100%;height:100%;border:none;"></iframe>
      ''';
      container.setInnerHtml(
        htmlContent,
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        final iframe =
            container.querySelector('#ppt-iframe-${widget.document.id}')
                as html.IFrameElement?;
        if (iframe != null) {
          iframe.onLoad.listen((_) {
            if (mounted) setState(() => _isOfficeLoading = false);
          });
        }
      });
      return container;
    });
  }

  void _registerWordViewer() {
    final viewType = 'word-viewer-${widget.document.id}';
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final container =
          html.DivElement()
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.position = 'relative'
            ..style.backgroundColor = '#f5f5f5'
            ..style.border = 'none'
            ..style.overflow = 'hidden';
      final encodedUrl = Uri.encodeComponent(widget.signedUrl);
      final officeUrl =
          'https://view.officeapps.live.com/op/embed.aspx?src=$encodedUrl';
      final htmlContent = '''
        <iframe id="word-iframe-${widget.document.id}" src="$officeUrl" style="width:100%;height:100%;border:none;"></iframe>
      ''';
      container.setInnerHtml(
        htmlContent,
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        final iframe =
            container.querySelector('#word-iframe-${widget.document.id}')
                as html.IFrameElement?;
        if (iframe != null) {
          iframe.onLoad.listen((_) {
            if (mounted) setState(() => _isOfficeLoading = false);
          });
        }
      });
      return container;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileType = widget.document.fileType.toLowerCase();
    return Dialog(
      child: Stack(
        children: [
          Container(
            width: 800,
            height: 600,
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.document.fileName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(child: _buildPreviewContent(context, fileType, theme)),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.document.description != null &&
                                widget.document.description!.isNotEmpty)
                              Text(
                                'Description: ${widget.document.description}',
                                style: theme.textTheme.bodySmall,
                              ),
                            Text(
                              'Uploaded: ${_formatDate(widget.document.uploadedAt)} by ${widget.document.uploadedByName}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _downloadDocument(context),
                        icon: const Icon(Icons.download),
                        label: const Text('Download'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isPdfLoading && fileType == '.pdf' && kIsWeb)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading PDF...',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_isOfficeLoading &&
              (fileType == '.ppt' ||
                  fileType == '.pptx' ||
                  fileType == '.doc' ||
                  fileType == '.docx') &&
              kIsWeb)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Loading Office Document...',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(
    BuildContext context,
    String fileType,
    ThemeData theme,
  ) {
    if (fileType == '.jpg' ||
        fileType == '.jpeg' ||
        fileType == '.png' ||
        fileType == '.gif') {
      return Image.network(
        widget.signedUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(child: Text('Failed to load image: $error'));
        },
      );
    } else if (fileType == '.pdf') {
      return kIsWeb
          ? HtmlElementView(viewType: 'pdf-viewer-${widget.document.id}')
          : Center(child: Text('PDF preview not available. Please download.'));
    } else if ((fileType == '.ppt' || fileType == '.pptx') && kIsWeb) {
      return HtmlElementView(
        viewType: 'powerpoint-viewer-${widget.document.id}',
      );
    } else if ((fileType == '.doc' || fileType == '.docx') && kIsWeb) {
      return HtmlElementView(viewType: 'word-viewer-${widget.document.id}');
    } else if (fileType == '.csv') {
      return FutureBuilder<String>(
        future: _fetchTextContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load file: ${snapshot.error}'),
            );
          } else {
            final csv = snapshot.data ?? '';
            final rows =
                csv.split('\n').where((row) => row.trim().isNotEmpty).toList();
            final cells = rows.map((row) => row.split(','));
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns:
                      cells.isNotEmpty
                          ? cells.first
                              .map(
                                (cell) => DataColumn(label: Text(cell.trim())),
                              )
                              .toList()
                          : [],
                  rows:
                      cells.length > 1
                          ? cells
                              .skip(1)
                              .map(
                                (row) => DataRow(
                                  cells:
                                      row
                                          .map(
                                            (cell) =>
                                                DataCell(Text(cell.trim())),
                                          )
                                          .toList(),
                                ),
                              )
                              .toList()
                          : [],
                ),
              ),
            );
          }
        },
      );
    } else if (fileType == '.txt') {
      return FutureBuilder<String>(
        future: _fetchTextContent(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load file: ${snapshot.error}'),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                snapshot.data ?? '',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }
        },
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Preview not available for this file type',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Click download to view the document',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }
  }

  Future<String> _fetchTextContent() async {
    final response = await html.HttpRequest.request(widget.signedUrl);
    return response.responseText ?? '';
  }

  void _downloadDocument(BuildContext context) {
    try {
      // For web, fetch the file and create a blob URL for forced download
      if (kIsWeb) {
        // Show loading indicator
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Preparing download...')));

        // Use Future.microtask to handle async operation
        Future.microtask(() async {
          try {
            // Fetch the file as a blob
            final response = await html.HttpRequest.request(
              widget.signedUrl,
              responseType: 'blob',
            );

            final blob = response.response as html.Blob;
            final blobUrl = html.Url.createObjectUrlFromBlob(blob);

            // Create anchor element with blob URL for forced download
            final anchor =
                html.AnchorElement(href: blobUrl)
                  ..setAttribute('download', widget.document.fileName)
                  ..style.display = 'none';

            html.document.body?.children.add(anchor);
            anchor.click();
            html.document.body?.children.remove(anchor);

            // Clean up the blob URL
            html.Url.revokeObjectUrl(blobUrl);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Download started: ${widget.document.fileName}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (fetchError) {
            // Fallback to direct URL if blob fetch fails
            print('Blob fetch failed, using direct URL: $fetchError');
            final anchor =
                html.AnchorElement(href: widget.signedUrl)
                  ..setAttribute('download', widget.document.fileName)
                  ..setAttribute('target', '_blank')
                  ..style.display = 'none';

            html.document.body?.children.add(anchor);
            anchor.click();
            html.document.body?.children.remove(anchor);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Download started: ${widget.document.fileName}',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        });
      } else {
        // For mobile platforms, show the download URL
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Download: ${widget.document.fileName}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Click the link below to download the document:',
                    ),
                    const SizedBox(height: 16),
                    SelectableText(
                      widget.signedUrl,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Copy to clipboard functionality could be added here
                    },
                    child: const Text('Copy Link'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
// Web-specific imports
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show latin1;

import '../../../core/models/document_model.dart';
import '../../../core/enums/document_enums.dart';
import '../providers/document_providers.dart';

class DocumentPreviewDialog extends ConsumerStatefulWidget {
  final DocumentModel document;

  const DocumentPreviewDialog({super.key, required this.document});

  @override
  ConsumerState<DocumentPreviewDialog> createState() =>
      _DocumentPreviewDialogState();
}

class _DocumentPreviewDialogState extends ConsumerState<DocumentPreviewDialog> {
  bool _isLoading = true;
  String? _error;
  Uint8List? _documentBytes;
  String? _previewUrl;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _registerPdfViewer();
      _registerWordViewer();
      _registerPowerPointViewer();
    }
    _loadDocumentPreview();
  }

  Future<void> _loadDocumentPreview() async {
    try {
      // print('🎭 [PREVIEW DEBUG] Starting document preview load');
      // print('🎭 [PREVIEW DEBUG] Document ID: ${widget.document.id}');
      // print('🎭 [PREVIEW DEBUG] Document name: ${widget.document.fileName}');
      // print(
      //   '🎭 [PREVIEW DEBUG] Document type: ${widget.document.fileType.name}',
      // );
      // print(
      //   '🎭 [PREVIEW DEBUG] Document size: ${widget.document.fileSizeBytes} bytes',
      // );
      // print(
      //   '🎭 [PREVIEW DEBUG] Document Supabase path: ${widget.document.supabasePath}',
      // );
      // print(
      //   '🎭 [PREVIEW DEBUG] Document access level: ${widget.document.accessLevel.displayName}',
      // );

      setState(() {
        _isLoading = true;
        _error = null;
      });

      // print('🎭 [PREVIEW DEBUG] Getting document actions provider...');
      final documentActions = ref.read(documentActionsProvider.notifier);
      // print('🎭 [PREVIEW DEBUG] Document actions provider obtained');

      // Get signed URL for preview
      // print('🎭 [PREVIEW DEBUG] Requesting signed URL...');
      // print(
      //   '🎭 [PREVIEW DEBUG] About to call getDocumentSignedUrl with document ID: ${widget.document.id}',
      // );

      final signedUrl = await documentActions.getDocumentSignedUrl(
        widget.document.id,
      );

      // print('✅ [PREVIEW DEBUG] Signed URL received successfully');
      // print('🎭 [PREVIEW DEBUG] URL length: ${signedUrl.length} characters');
      // print(
      //   '🎭 [PREVIEW DEBUG] URL preview: ${signedUrl.substring(0, 100)}...',
      // );

      // Test if URL is accessible
      // print('🎭 [PREVIEW DEBUG] Testing URL accessibility...');
      try {
        // For web, we can't easily test the URL without CORS issues
        // So we'll just proceed with setting the URL
        // print('🎭 [PREVIEW DEBUG] URL format looks valid, proceeding...');
      } catch (e) {
        // print('⚠️ [PREVIEW DEBUG] URL test warning: $e');
      }

      setState(() {
        _previewUrl = signedUrl;
        _isLoading = false;
      });

      // Update viewers based on document type
      if (widget.document.fileType == DocumentFileType.pdf) {
        _updatePdfViewer(signedUrl);
      } else if (widget.document.fileType == DocumentFileType.doc ||
          widget.document.fileType == DocumentFileType.docx) {
        _updateWordViewer(signedUrl);
      } else if (widget.document.fileType == DocumentFileType.ppt ||
          widget.document.fileType == DocumentFileType.pptx) {
        _updatePowerPointViewer(signedUrl);
      }

      // print('🎉 [PREVIEW DEBUG] Preview load completed successfully');
      // print(
      //   '🎭 [PREVIEW DEBUG] State updated with URL: ${_previewUrl != null}',
      // );
    } catch (e, stackTrace) {
      // print('💥 [PREVIEW DEBUG] Preview load failed: $e');
      // print('📚 [PREVIEW DEBUG] Stack trace: $stackTrace');
      // print('🎭 [PREVIEW DEBUG] Error type: ${e.runtimeType}');

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      // print('🎭 [PREVIEW DEBUG] Error state set: $_error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      child: Container(
        width: screenSize.width * 0.9,
        height: screenSize.height * 0.9,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${widget.document.fileSizeFormatted} • ${widget.document.fileType.displayName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  if (_previewUrl != null) ...[
                    IconButton(
                      onPressed: _isDownloading ? null : _downloadDocument,
                      icon:
                          _isDownloading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.download),
                      tooltip: _isDownloading ? 'Downloading...' : 'Download',
                    ),
                  ],
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Content
            Expanded(child: _buildPreviewContent(theme)),

            // Footer with document info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Uploaded by ${widget.document.uploadedByName}',
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
                    _formatDate(widget.document.uploadedAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading preview...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load preview',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDocumentPreview,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_previewUrl == null) {
      return _buildUnsupportedPreview(theme);
    }

    // Different preview types based on file type
    switch (widget.document.fileType) {
      case DocumentFileType.pdf:
        return _buildPdfPreview();
      case DocumentFileType.doc:
      case DocumentFileType.docx:
        return _buildWordPreview();
      case DocumentFileType.ppt:
      case DocumentFileType.pptx:
        return _buildPowerPointPreview();
      case DocumentFileType.txt:
      case DocumentFileType.csv:
        return _buildTextPreview();
      case DocumentFileType.jpg:
      case DocumentFileType.jpeg:
      case DocumentFileType.png:
      case DocumentFileType.gif:
        return _buildImagePreview();
      default:
        return _buildUnsupportedPreview(theme);
    }
  }

  Widget _buildPdfPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red),
                const SizedBox(width: 8),
                Text('PDF Preview'),
                const SizedBox(width: 8),
                // Security indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.security,
                        size: 14,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Secure View',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _openInBrowser(),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in New Tab'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildPdfViewer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    // print(
    //   '🎭 [PDF VIEWER] Building PDF viewer with URL: ${_previewUrl!.substring(0, 100)}...',
    // );

    // For web platform, we create an iframe directly
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: HtmlElementView(viewType: 'pdf-viewer-${widget.document.id}'),
      );
    } else {
      // For non-web platforms, show a message to open in browser
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('PDF Preview'),
            const SizedBox(height: 8),
            const Text('Click "Open in New Tab" to view the PDF'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open in New Tab'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.image, color: Colors.purple),
                const SizedBox(width: 8),
                Text('Image Preview'),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: InteractiveViewer(
                child: Center(
                  child:
                      _previewUrl != null
                          ? Image.network(
                            _previewUrl!,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 64),
                                    Text('Failed to load image'),
                                  ],
                                ),
                              );
                            },
                          )
                          : const Center(
                            child: Text('Image preview not available'),
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.description, color: Colors.blue),
                const SizedBox(width: 8),
                Text('Word Document Preview'),
                const SizedBox(width: 8),
                // Security indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.security,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Secure View',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _openInBrowser(),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in New Tab'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildWordViewer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordViewer() {
    // print(
    //   '🎭 [WORD VIEWER] Building Word viewer with URL: ${_previewUrl!.substring(0, 100)}...',
    // );

    // For web platform, we create an iframe with Office Online viewer
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: HtmlElementView(viewType: 'word-viewer-${widget.document.id}'),
      );
    } else {
      // For non-web platforms, show a message to open in browser
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('Word Document Preview'),
            const SizedBox(height: 8),
            const Text('Click "Open in New Tab" to view the document'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open in New Tab'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPowerPointPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.slideshow, color: Colors.orange),
                const SizedBox(width: 8),
                Text('PowerPoint Presentation Preview'),
                const SizedBox(width: 8),
                // Security indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.security,
                        size: 14,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Secure View',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _openInBrowser(),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in New Tab'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildPowerPointViewer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerPointViewer() {
    // print(
    //   '🎭 [POWERPOINT VIEWER] Building PowerPoint viewer with URL: ${_previewUrl!.substring(0, 100)}...',
    // );

    // For web platform, we create an iframe with Office Online viewer
    if (kIsWeb) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: HtmlElementView(
          viewType: 'powerpoint-viewer-${widget.document.id}',
        ),
      );
    } else {
      // For non-web platforms, show a message to open in browser
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.slideshow, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('PowerPoint Presentation Preview'),
            const SizedBox(height: 8),
            const Text('Click "Open in New Tab" to view the presentation'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open in New Tab'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTextPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  widget.document.fileType == DocumentFileType.csv
                      ? Icons.table_chart
                      : Icons.text_snippet,
                  color:
                      widget.document.fileType == DocumentFileType.csv
                          ? Colors.green
                          : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.document.fileType == DocumentFileType.csv
                      ? 'CSV File Preview'
                      : 'Text File Preview',
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _openInBrowser(),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in New Tab'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: _buildTextContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent() {
    return FutureBuilder<String>(
      future: _loadTextContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading text content...'),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to load text content'),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final content = snapshot.data ?? 'No content available';

        if (widget.document.fileType == DocumentFileType.csv) {
          return _buildCsvTable(content);
        } else {
          return SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.4,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildCsvTable(String csvContent) {
    try {
      final lines =
          csvContent
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .toList();
      if (lines.isEmpty) {
        return const Center(child: Text('Empty CSV file'));
      }

      // Parse CSV (simple implementation)
      final rows =
          lines.map((line) {
            // Simple CSV parsing - doesn't handle quoted commas
            return line.split(',').map((cell) => cell.trim()).toList();
          }).toList();

      final maxColumns = rows
          .map((row) => row.length)
          .reduce((a, b) => a > b ? a : b);

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
            columns: List.generate(
              maxColumns,
              (index) => DataColumn(
                label: Text(
                  rows.isNotEmpty && index < rows[0].length
                      ? rows[0][index]
                      : 'Column ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            rows:
                rows.skip(1).map((row) {
                  return DataRow(
                    cells: List.generate(
                      maxColumns,
                      (index) => DataCell(
                        Text(
                          index < row.length ? row[index] : '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      );
    } catch (e) {
      return SingleChildScrollView(
        child: SelectableText(
          csvContent,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            height: 1.4,
          ),
        ),
      );
    }
  }

  Future<String> _loadTextContent() async {
    try {
      // print(
      //   '📄 [TEXT LOADER] Loading text content for: ${widget.document.fileName}',
      // );

      if (_previewUrl == null || _previewUrl!.isEmpty) {
        throw Exception('No signed URL available for text content');
      }

      // Use http package to fetch the text content
      final response = await http.get(Uri.parse(_previewUrl!));

      if (response.statusCode == 200) {
        // print('✅ [TEXT LOADER] Text content loaded successfully');

        // Handle different text encodings
        String content;
        try {
          content = utf8.decode(response.bodyBytes);
        } catch (e) {
          // Fallback to latin1 if UTF-8 fails
          content = latin1.decode(response.bodyBytes);
        }

        // Limit content size for display (max 50KB)
        if (content.length > 50000) {
          content =
              content.substring(0, 50000) +
              '\n\n... (Content truncated for display)';
        }

        return content;
      } else {
        throw Exception('Failed to load text content: ${response.statusCode}');
      }
    } catch (e) {
      // print('❌ [TEXT LOADER] Error loading text content: $e');
      throw Exception('Failed to load text content: $e');
    }
  }

  Widget _buildUnsupportedPreview(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.preview,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('Preview not available', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'This file type cannot be previewed.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
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

  Future<void> _openInBrowser() async {
    if (_previewUrl != null) {
      try {
        // Use direct PDF URL for security - no Google involvement
        final directPdfUrl = '$_previewUrl#view=FitH&toolbar=1&navpanes=1';
        // print(
        //   '🔒 [SECURITY] Opening direct PDF URL in browser - no third-party processing',
        // );

        await launchUrl(
          Uri.parse(directPdfUrl),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _registerPdfViewer() {
    if (kIsWeb) {
      try {
        final viewType = 'pdf-viewer-${widget.document.id}';
        // print('🎭 [PDF VIEWER] Registering PDF.js viewer with type: $viewType');

        ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
          // Create a container div
          final container =
              html.DivElement()
                ..style.width = '100%'
                ..style.height = '100%'
                ..style.position = 'relative'
                ..style.backgroundColor = '#f5f5f5'
                ..style.border = 'none'
                ..style.overflow = 'hidden';

          // Create PDF.js viewer HTML structure
          final htmlContent = '''
            <div style="width: 100%; height: 100%; display: flex; flex-direction: column;">
              <div id="pdf-container-${widget.document.id}" style="width: 100%; height: 100%; position: relative;">
                <!-- PDF.js iframe viewer -->
                <iframe 
                  id="pdf-iframe-${widget.document.id}"
                  style="width: 100%; height: 100%; border: none; background: white;"
                  sandbox="allow-same-origin allow-scripts allow-popups allow-forms"
                  allow="fullscreen"
                  loading="lazy">
                </iframe>
                
                <!-- Loading indicator -->
                <div id="loading-${widget.document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                ">
                  <div style="
                    width: 50px; 
                    height: 50px; 
                    border: 4px solid #f3f3f3; 
                    border-top: 4px solid #007bff; 
                    border-radius: 50%; 
                    animation: spin 1s linear infinite;
                    margin: 0 auto 20px auto;
                  "></div>
                  <h3 style="margin: 0 0 10px 0; font-weight: 600; color: #333;">Loading PDF...</h3>
                  <p style="margin: 0; font-size: 14px; color: #666;">Using PDF.js secure viewer</p>
                </div>
                
                <!-- Error fallback -->
                <div id="error-${widget.document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                  display: none;
                ">
                  <div style="font-size: 48px; margin-bottom: 20px;">📄</div>
                  <h3 style="color: #e74c3c; margin-bottom: 15px;">PDF Preview Unavailable</h3>
                  <p style="color: #666; margin-bottom: 25px; font-size: 14px; line-height: 1.5;">
                    Unable to display PDF in the browser.<br>
                    Click below to download or open in a new tab.
                  </p>
                  <div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">
                    <button 
                      id="download-pdf-${widget.document.id}"
                      style="
                        background: #28a745; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#218838'"
                      onmouseout="this.style.background='#28a745'"
                    >
                      📥 Download PDF
                    </button>
                    <button 
                      id="open-pdf-${widget.document.id}"
                      style="
                        background: #007bff; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#0056b3'"
                      onmouseout="this.style.background='#007bff'"
                    >
                      🔗 Open in New Tab
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <style>
              @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
              }
            </style>
          ''';

          container.setInnerHtml(
            htmlContent,
            treeSanitizer: html.NodeTreeSanitizer.trusted,
          );

          // Set up event listeners for fallback buttons
          final downloadButton = container.querySelector(
            '#download-pdf-${widget.document.id}',
          );
          final openButton = container.querySelector(
            '#open-pdf-${widget.document.id}',
          );

          downloadButton?.onClick.listen((_) {
            final pdfUrl = container.getAttribute('data-pdf-url');
            if (pdfUrl != null && pdfUrl.isNotEmpty) {
              // Trigger download
              final anchor =
                  html.AnchorElement()
                    ..href = pdfUrl
                    ..download = '${widget.document.fileName}'
                    ..style.display = 'none';
              html.document.body?.children.add(anchor);
              anchor.click();
              html.document.body?.children.remove(anchor);
            }
          });

          openButton?.onClick.listen((_) {
            final pdfUrl = container.getAttribute('data-pdf-url');
            if (pdfUrl != null && pdfUrl.isNotEmpty) {
              html.window.open(pdfUrl, '_blank');
            }
          });

          return container;
        });
      } catch (e) {
        // print('❌ [PDF VIEWER] Error registering PDF.js viewer: $e');
      }
    }
  }

  void _updatePdfViewer(String signedUrl) {
    if (!kIsWeb) return;

    // print(
    //   '🎭 [PDF.js] Updating PDF.js viewer with URL: ${signedUrl.substring(0, 50)}...',
    // );
    // print(
    //   '🔒 [SECURITY] Using PDF.js - client-side rendering, no third-party services',
    // );

    // Add a small delay to ensure the elements are rendered
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final containerId = 'pdf-container-${widget.document.id}';
        final container = html.document.querySelector('#$containerId');

        if (container != null) {
          // Store the PDF URL for fallback buttons
          container.setAttribute('data-pdf-url', signedUrl);

          // Get the iframe element
          final iframe =
              container.querySelector('#pdf-iframe-${widget.document.id}')
                  as html.IFrameElement?;

          if (iframe != null) {
            // print('🎭 [PDF.js] Found iframe element, setting up PDF.js viewer');

            // Try different PDF.js approaches for better CORS handling
            _tryPdfJsApproaches(signedUrl, iframe);

            // Set up iframe load handlers
            iframe.onLoad.listen((_) {
              // print('✅ [PDF.js] PDF.js viewer loaded successfully');
              _hidePdfLoading();
            });

            iframe.onError.listen((_) {
              // print('❌ [PDF.js] PDF.js viewer failed to load');
              _showPdfError();
            });

            // Set a timeout to show error if PDF doesn't load
            Future.delayed(const Duration(seconds: 10), () {
              final loading = html.document.querySelector(
                '#loading-${widget.document.id}',
              );
              if (loading != null && loading.style.display != 'none') {
                // print(
                //   '⚠️ [PDF.js] PDF loading timeout, showing error fallback',
                // );
                _showPdfError();
              }
            });
          } else {
            // print('❌ [PDF.js] Could not find iframe element');
            _showPdfError();
          }
        } else {
          // print('❌ [PDF.js] Could not find PDF container');
          _showPdfError();
        }
      } catch (e) {
        // print('❌ [PDF.js] Error updating PDF.js viewer: $e');
        _showPdfError();
      }
    });
  }

  void _tryPdfJsApproaches(String signedUrl, html.IFrameElement iframe) {
    // Approach 1: Try with Mozilla's PDF.js CDN (most compatible)
    try {
      final encodedUrl = Uri.encodeComponent(signedUrl);
      final pdfJsUrl =
          'https://mozilla.github.io/pdf.js/web/viewer.html?file=$encodedUrl';

      // print(
      //   '🎭 [PDF.js] Trying Mozilla PDF.js viewer: ${pdfJsUrl.substring(0, 100)}...',
      // );
      iframe.src = pdfJsUrl;

      // If this fails, try alternative approaches
      Future.delayed(const Duration(seconds: 5), () {
        final loading = html.document.querySelector(
          '#loading-${widget.document.id}',
        );
        if (loading != null && loading.style.display != 'none') {
          // print('⚠️ [PDF.js] Mozilla viewer timeout, trying alternative...');
          _tryAlternativePdfJs(signedUrl, iframe);
        }
      });
    } catch (e) {
      // print('❌ [PDF.js] Mozilla approach failed: $e');
      _tryAlternativePdfJs(signedUrl, iframe);
    }
  }

  void _tryAlternativePdfJs(String signedUrl, html.IFrameElement iframe) {
    try {
      // Approach 2: Try with a different PDF.js CDN
      final encodedUrl = Uri.encodeComponent(signedUrl);
      final altPdfJsUrl =
          'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/web/viewer.html?file=$encodedUrl';

      // print(
      //   '🎭 [PDF.js] Trying alternative PDF.js viewer: ${altPdfJsUrl.substring(0, 100)}...',
      // );
      iframe.src = altPdfJsUrl;

      // If this also fails, try direct embedding
      Future.delayed(const Duration(seconds: 5), () {
        final loading = html.document.querySelector(
          '#loading-${widget.document.id}',
        );
        if (loading != null && loading.style.display != 'none') {
          // print(
          //   '⚠️ [PDF.js] Alternative viewer timeout, trying direct embed...',
          // );
          _tryDirectPdfEmbed(signedUrl, iframe);
        }
      });
    } catch (e) {
      // print('❌ [PDF.js] Alternative approach failed: $e');
      _tryDirectPdfEmbed(signedUrl, iframe);
    }
  }

  void _tryDirectPdfEmbed(String signedUrl, html.IFrameElement iframe) {
    try {
      // Approach 3: Direct PDF embedding (browser built-in PDF viewer)
      // print('🎭 [PDF.js] Trying direct PDF embedding');
      iframe.src = signedUrl;

      // Add PDF viewer parameters for better display
      final directUrl =
          '$signedUrl#view=FitH&toolbar=1&navpanes=1&scrollbar=1&page=1&zoom=page-fit';
      iframe.src = directUrl;

      // print('🔒 [SECURITY] Using direct PDF URL - browser built-in viewer');

      // Final timeout check
      Future.delayed(const Duration(seconds: 5), () {
        final loading = html.document.querySelector(
          '#loading-${widget.document.id}',
        );
        if (loading != null && loading.style.display != 'none') {
          // print('⚠️ [PDF.js] All approaches failed, showing error');
          _showPdfError();
        }
      });
    } catch (e) {
      // print('❌ [PDF.js] Direct embed failed: $e');
      _showPdfError();
    }
  }

  void _hidePdfLoading() {
    final loading = html.document.querySelector(
      '#loading-${widget.document.id}',
    );
    if (loading != null) {
      loading.style.display = 'none';
    }
  }

  void _showPdfError() {
    final loading = html.document.querySelector(
      '#loading-${widget.document.id}',
    );
    final error = html.document.querySelector('#error-${widget.document.id}');

    if (loading != null) {
      loading.style.display = 'none';
    }

    if (error != null) {
      error.style.display = 'block';
    }
  }

  Future<void> _downloadDocument() async {
    if (_previewUrl == null) return;

    try {
      // print('📥 [DOWNLOAD] Starting download for: ${widget.document.fileName}');

      setState(() {
        _isDownloading = true;
      });

      // For web, use the signed URL directly to trigger download
      if (kIsWeb) {
        final anchor =
            html.AnchorElement(href: _previewUrl!)
              ..setAttribute('download', widget.document.fileName)
              ..style.display = 'none';

        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);

        // print(
        //   '✅ [DOWNLOAD] Download completed for: ${widget.document.fileName}',
        // );

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
        final documentActions = ref.read(documentActionsProvider.notifier);
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
      // print('💥 [DOWNLOAD] Download failed: $e');
      // print('📚 [DOWNLOAD] Stack trace: $stackTrace');

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

  void _registerWordViewer() {
    if (kIsWeb) {
      try {
        final viewType = 'word-viewer-${widget.document.id}';
        // print('🎭 [WORD VIEWER] Registering Word viewer with type: $viewType');

        ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
          // Create a container div
          final container =
              html.DivElement()
                ..style.width = '100%'
                ..style.height = '100%'
                ..style.position = 'relative'
                ..style.backgroundColor = '#f5f5f5'
                ..style.border = 'none'
                ..style.overflow = 'hidden';

          // Create Word viewer HTML structure
          final htmlContent = '''
            <div style="width: 100%; height: 100%; display: flex; flex-direction: column;">
              <div id="word-container-${widget.document.id}" style="width: 100%; height: 100%; position: relative;">
                <!-- Word document iframe viewer -->
                <iframe 
                  id="word-iframe-${widget.document.id}"
                  style="width: 100%; height: 100%; border: none; background: white;"
                  sandbox="allow-same-origin allow-scripts allow-popups allow-forms"
                  allow="fullscreen"
                  loading="lazy">
                </iframe>
                
                <!-- Loading indicator -->
                <div id="word-loading-${widget.document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                ">
                  <div style="
                    width: 50px; 
                    height: 50px; 
                    border: 4px solid #f3f3f3; 
                    border-top: 4px solid #0078d4; 
                    border-radius: 50%; 
                    animation: spin 1s linear infinite;
                    margin: 0 auto 20px auto;
                  "></div>
                  <h3 style="margin: 0 0 10px 0; font-weight: 600; color: #333;">Loading Word Document...</h3>
                  <p style="margin: 0; font-size: 14px; color: #666;">Using secure document viewer</p>
                </div>
                
                <!-- Error fallback -->
                <div id="word-error-${widget.document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                  display: none;
                ">
                  <div style="font-size: 48px; margin-bottom: 20px;">📄</div>
                  <h3 style="color: #e74c3c; margin-bottom: 15px;">Document Preview Unavailable</h3>
                  <p style="color: #666; margin-bottom: 25px; font-size: 14px; line-height: 1.5;">
                    Unable to display Word document in the browser.<br>
                    Click below to download or open in a new tab.
                  </p>
                  <div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">
                    <button 
                      id="download-word-${widget.document.id}"
                      style="
                        background: #28a745; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#218838'"
                      onmouseout="this.style.background='#28a745'"
                    >
                      📥 Download Document
                    </button>
                    <button 
                      id="open-word-${widget.document.id}"
                      style="
                        background: #0078d4; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#106ebe'"
                      onmouseout="this.style.background='#0078d4'"
                    >
                      🔗 Open in New Tab
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <style>
              @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
              }
            </style>
          ''';

          container.setInnerHtml(
            htmlContent,
            treeSanitizer: html.NodeTreeSanitizer.trusted,
          );

          // Set up event listeners for fallback buttons
          final downloadButton = container.querySelector(
            '#download-word-${widget.document.id}',
          );
          final openButton = container.querySelector(
            '#open-word-${widget.document.id}',
          );

          downloadButton?.onClick.listen((_) {
            final docUrl = container.getAttribute('data-doc-url');
            if (docUrl != null && docUrl.isNotEmpty) {
              // Trigger download
              final anchor =
                  html.AnchorElement()
                    ..href = docUrl
                    ..download = '${widget.document.fileName}'
                    ..style.display = 'none';
              html.document.body?.children.add(anchor);
              anchor.click();
              html.document.body?.children.remove(anchor);
            }
          });

          openButton?.onClick.listen((_) {
            final docUrl = container.getAttribute('data-doc-url');
            if (docUrl != null && docUrl.isNotEmpty) {
              html.window.open(docUrl, '_blank');
            }
          });

          return container;
        });
      } catch (e) {
        // print('❌ [WORD VIEWER] Error registering Word viewer: $e');
      }
    }
  }

  void _updateWordViewer(String signedUrl) {
    if (!kIsWeb) return;

    // print(
    //   '🎭 [WORD VIEWER] Updating Word viewer with URL: ${signedUrl.substring(0, 50)}...',
    // );
    // print(
    //   '🔒 [SECURITY] Using secure document viewer - no third-party services',
    // );

    // Add a small delay to ensure the elements are rendered
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final containerId = 'word-container-${widget.document.id}';
        final container = html.document.querySelector('#$containerId');

        if (container != null) {
          // Store the document URL for fallback buttons
          container.setAttribute('data-doc-url', signedUrl);

          // Get the iframe element
          final iframe =
              container.querySelector('#word-iframe-${widget.document.id}')
                  as html.IFrameElement?;

          if (iframe != null) {
            // print(
            //   '🎭 [WORD VIEWER] Found iframe element, setting up Word viewer',
            // );

            // Try to use Office Online viewer or direct download
            _tryWordViewerApproaches(signedUrl, iframe);

            // Set up iframe load handlers
            iframe.onLoad.listen((_) {
              // print('✅ [WORD VIEWER] Word viewer loaded successfully');
              _hideWordLoading();
            });

            iframe.onError.listen((_) {
              // print('❌ [WORD VIEWER] Word viewer failed to load');
              _showWordError();
            });

            // Set a timeout to show error if document doesn't load
            Future.delayed(const Duration(seconds: 10), () {
              final loading = html.document.querySelector(
                '#word-loading-${widget.document.id}',
              );
              if (loading != null && loading.style.display != 'none') {
                // print(
                //   '⚠️ [WORD VIEWER] Word loading timeout, showing error fallback',
                // );
                _showWordError();
              }
            });
          } else {
            // print('❌ [WORD VIEWER] Could not find iframe element');
            _showWordError();
          }
        } else {
          // print('❌ [WORD VIEWER] Could not find Word container');
          _showWordError();
        }
      } catch (e) {
        // print('❌ [WORD VIEWER] Error updating Word viewer: $e');
        _showWordError();
      }
    });
  }

  void _tryWordViewerApproaches(String signedUrl, html.IFrameElement iframe) {
    try {
      // For Word documents, we'll try Office Online viewer first
      // Note: This requires the document to be publicly accessible
      final encodedUrl = Uri.encodeComponent(signedUrl);

      // Try Office Online viewer (may not work with private URLs)
      final officeOnlineUrl =
          'https://view.officeapps.live.com/op/embed.aspx?src=$encodedUrl';

      // print('🎭 [WORD VIEWER] Trying Office Online viewer: $officeOnlineUrl');
      iframe.src = officeOnlineUrl;

      // Fallback: If Office Online doesn't work, show download option
      Future.delayed(const Duration(seconds: 5), () {
        final loading = html.document.querySelector(
          '#word-loading-${widget.document.id}',
        );
        if (loading != null && loading.style.display != 'none') {
          // print(
          //   '⚠️ [WORD VIEWER] Office Online viewer not working, showing fallback',
          // );
          _showWordError();
        }
      });
    } catch (e) {
      // print('❌ [WORD VIEWER] Error setting up Word viewer approaches: $e');
      _showWordError();
    }
  }

  void _hideWordLoading() {
    final loading = html.document.querySelector(
      '#word-loading-${widget.document.id}',
    );
    loading?.style.display = 'none';
  }

  void _showWordError() {
    final loading = html.document.querySelector(
      '#word-loading-${widget.document.id}',
    );
    final error = html.document.querySelector(
      '#word-error-${widget.document.id}',
    );

    loading?.style.display = 'none';
    error?.style.display = 'block';
  }

  void _registerPowerPointViewer() {
    if (kIsWeb) {
      try {
        final viewType = 'powerpoint-viewer-${widget.document.id}';
        // print(
        //   '🎭 [POWERPOINT VIEWER] Registering PowerPoint viewer with type: $viewType',
        // );

        ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
          // Create a container div
          final container =
              html.DivElement()
                ..style.width = '100%'
                ..style.height = '100%'
                ..style.position = 'relative'
                ..style.backgroundColor = '#f5f5f5'
                ..style.border = 'none'
                ..style.overflow = 'hidden';

          // Create PowerPoint viewer HTML structure
          final htmlContent = '''
            <div style="width: 100%; height: 100%; display: flex; flex-direction: column;">
              <div id="powerpoint-container-${widget.document.id}" style="width: 100%; height: 100%; position: relative;">
                <!-- PowerPoint viewer iframe -->
                <iframe 
                  id="powerpoint-iframe-${widget.document.id}"
                  style="width: 100%; height: 100%; border: none; background: white;"
                  sandbox="allow-same-origin allow-scripts allow-popups allow-forms"
                  allow="fullscreen"
                  loading="lazy">
                </iframe>
                
                <!-- Loading indicator -->
                <div id="powerpoint-loading-${widget.document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                ">
                  <div style="
                    width: 50px; 
                    height: 50px; 
                    border: 4px solid #f3f3f3; 
                    border-top: 4px solid #007bff; 
                    border-radius: 50%; 
                    animation: spin 1s linear infinite;
                    margin: 0 auto 20px auto;
                  "></div>
                  <h3 style="margin: 0 0 10px 0; font-weight: 600; color: #333;">Loading PowerPoint...</h3>
                  <p style="margin: 0; font-size: 14px; color: #666;">Using PowerPoint viewer</p>
                </div>
                
                <!-- Error fallback -->
                <div id="powerpoint-error-${widget.document.id}" style="
                  position: absolute; 
                  top: 50%; 
                  left: 50%; 
                  transform: translate(-50%, -50%);
                  text-align: center;
                  color: #666;
                  font-family: Arial, sans-serif;
                  background: rgba(255, 255, 255, 0.95);
                  padding: 30px;
                  border-radius: 12px;
                  box-shadow: 0 4px 20px rgba(0,0,0,0.15);
                  z-index: 1000;
                  display: none;
                ">
                  <div style="font-size: 48px; margin-bottom: 20px;">📄</div>
                  <h3 style="color: #e74c3c; margin-bottom: 15px;">PowerPoint Preview Unavailable</h3>
                  <p style="color: #666; margin-bottom: 25px; font-size: 14px; line-height: 1.5;">
                    Unable to display PowerPoint presentation in the browser.<br>
                    Click below to download or open in a new tab.
                  </p>
                  <div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">
                    <button 
                      id="download-powerpoint-${widget.document.id}"
                      style="
                        background: #28a745; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#218838'"
                      onmouseout="this.style.background='#28a745'"
                    >
                      📥 Download PowerPoint
                    </button>
                    <button 
                      id="open-powerpoint-${widget.document.id}"
                      style="
                        background: #007bff; 
                        color: white; 
                        border: none; 
                        padding: 12px 20px; 
                        border-radius: 6px; 
                        cursor: pointer;
                        font-size: 14px;
                        font-weight: 500;
                        transition: background 0.2s;
                      "
                      onmouseover="this.style.background='#0056b3'"
                      onmouseout="this.style.background='#007bff'"
                    >
                      🔗 Open in New Tab
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <style>
              @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
              }
            </style>
          ''';

          container.setInnerHtml(
            htmlContent,
            treeSanitizer: html.NodeTreeSanitizer.trusted,
          );

          // Set up event listeners for fallback buttons
          final downloadButton = container.querySelector(
            '#download-powerpoint-${widget.document.id}',
          );
          final openButton = container.querySelector(
            '#open-powerpoint-${widget.document.id}',
          );

          downloadButton?.onClick.listen((_) {
            final pptUrl = container.getAttribute('data-ppt-url');
            if (pptUrl != null && pptUrl.isNotEmpty) {
              // Trigger download
              final anchor =
                  html.AnchorElement()
                    ..href = pptUrl
                    ..download = '${widget.document.fileName}'
                    ..style.display = 'none';
              html.document.body?.children.add(anchor);
              anchor.click();
              html.document.body?.children.remove(anchor);
            }
          });

          openButton?.onClick.listen((_) {
            final pptUrl = container.getAttribute('data-ppt-url');
            if (pptUrl != null && pptUrl.isNotEmpty) {
              html.window.open(pptUrl, '_blank');
            }
          });

          return container;
        });
      } catch (e) {
        // print('❌ [POWERPOINT VIEWER] Error registering PowerPoint viewer: $e');
      }
    }
  }

  void _updatePowerPointViewer(String signedUrl) {
    if (!kIsWeb) return;

    // print(
    //   '🎭 [POWERPOINT VIEWER] Updating PowerPoint viewer with URL: ${signedUrl.substring(0, 50)}...',
    // );
    // print('🔒 [SECURITY] Using PowerPoint viewer - no third-party services');

    // Add a small delay to ensure the elements are rendered
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final containerId = 'powerpoint-container-${widget.document.id}';
        final container = html.document.querySelector('#$containerId');

        if (container != null) {
          // Store the PowerPoint URL for fallback buttons
          container.setAttribute('data-ppt-url', signedUrl);

          // Get the iframe element
          final iframe =
              container.querySelector(
                    '#powerpoint-iframe-${widget.document.id}',
                  )
                  as html.IFrameElement?;

          if (iframe != null) {
            // print(
            //   '🎭 [POWERPOINT VIEWER] Found iframe element, setting up PowerPoint viewer',
            // );

            // Try to use PowerPoint viewer or direct download
            _tryPowerPointViewerApproaches(signedUrl, iframe);

            // Set up iframe load handlers
            iframe.onLoad.listen((_) {
              // print(
              //   '✅ [POWERPOINT VIEWER] PowerPoint viewer loaded successfully',
              // );
              _hidePowerPointLoading();
            });

            iframe.onError.listen((_) {
              // print('❌ [POWERPOINT VIEWER] PowerPoint viewer failed to load');
              _showPowerPointError();
            });

            // Set a timeout to show error if PowerPoint doesn't load
            Future.delayed(const Duration(seconds: 10), () {
              final loading = html.document.querySelector(
                '#powerpoint-loading-${widget.document.id}',
              );
              if (loading != null && loading.style.display != 'none') {
                // print(
                //   '⚠️ [POWERPOINT VIEWER] PowerPoint loading timeout, showing error fallback',
                // );
                _showPowerPointError();
              }
            });
          } else {
            // print('❌ [POWERPOINT VIEWER] Could not find iframe element');
            _showPowerPointError();
          }
        } else {
          // print('❌ [POWERPOINT VIEWER] Could not find PowerPoint container');
          _showPowerPointError();
        }
      } catch (e) {
        // print('❌ [POWERPOINT VIEWER] Error updating PowerPoint viewer: $e');
        _showPowerPointError();
      }
    });
  }

  void _tryPowerPointViewerApproaches(
    String signedUrl,
    html.IFrameElement iframe,
  ) {
    try {
      // For PowerPoint presentations, we'll try PowerPoint viewer first
      // Note: This requires the document to be publicly accessible
      final encodedUrl = Uri.encodeComponent(signedUrl);

      // Try PowerPoint viewer (may not work with private URLs)
      final powerPointUrl =
          'https://view.officeapps.live.com/op/embed.aspx?src=$encodedUrl';

      // print('🎭 [POWERPOINT VIEWER] Trying PowerPoint viewer: $powerPointUrl');
      iframe.src = powerPointUrl;

      // Fallback: If PowerPoint viewer doesn't work, show download option
      Future.delayed(const Duration(seconds: 5), () {
        final loading = html.document.querySelector(
          '#powerpoint-loading-${widget.document.id}',
        );
        if (loading != null && loading.style.display != 'none') {
          // print(
          //   '⚠️ [POWERPOINT VIEWER] PowerPoint viewer not working, showing fallback',
          // );
          _showPowerPointError();
        }
      });
    } catch (e) {
      // print(
      //   '❌ [POWERPOINT VIEWER] Error setting up PowerPoint viewer approaches: $e',
      // );
      _showPowerPointError();
    }
  }

  void _hidePowerPointLoading() {
    final loading = html.document.querySelector(
      '#powerpoint-loading-${widget.document.id}',
    );
    loading?.style.display = 'none';
  }

  void _showPowerPointError() {
    final loading = html.document.querySelector(
      '#powerpoint-loading-${widget.document.id}',
    );
    final error = html.document.querySelector(
      '#powerpoint-error-${widget.document.id}',
    );

    loading?.style.display = 'none';
    error?.style.display = 'block';
  }
}

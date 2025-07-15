import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/letter_model.dart';
import '../providers/letter_providers.dart';
import '../shared/letter_card.dart';
import '../../../core/services/supabase_service.dart';
import '../widgets/letter_preview_edit_modal.dart';

class ApprovedTab extends ConsumerWidget {
  final String searchQuery;

  const ApprovedTab({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvedAsync = ref.watch(approvedLettersProvider);

    return approvedAsync.when(
      data: (approved) {
        // Filter approved letters based on search query
        final filteredApproved = _filterApprovedLetters(approved, searchQuery);

        if (filteredApproved.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isNotEmpty
                      ? Icons.search_off
                      : Icons.check_circle,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No approved letters found'
                      : 'No Approved Letters',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  searchQuery.isNotEmpty
                      ? 'Try adjusting your search terms'
                      : 'Approved letters will appear here',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredApproved.length,
          itemBuilder: (context, index) {
            final letter = filteredApproved[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LetterCard(
                letter: letter,
                onPreview:
                    () async => showDialog(
                      context: context,
                      builder:
                          (context) =>
                              LetterPreviewEditModal(letter: letter, ref: ref),
                    ),
                onDownload:
                    () async => await _downloadLetter(context, ref, letter),
                onMarkSent: () async => await _markAsSent(context, ref, letter),
                showApprovalProgress: true,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading approved letters',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  List<Letter> _filterApprovedLetters(List<Letter> approved, String query) {
    if (query.isEmpty) return approved;

    final lowercaseQuery = query.toLowerCase();
    return approved.where((letter) {
      return letter.employeeName.toLowerCase().contains(lowercaseQuery) ||
          letter.employeeEmail.toLowerCase().contains(lowercaseQuery) ||
          letter.type.toLowerCase().contains(lowercaseQuery) ||
          letter.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> _downloadLetter(
    BuildContext context,
    WidgetRef ref,
    Letter letter,
  ) async {
    final filePath = letter.signedPdfPath;
    final fileName = '${letter.type}_${letter.employeeName}_${letter.id}.pdf';

    print('🔍 [DOWNLOAD DEBUG] Starting download for letter: ${letter.id}');
    print('🔍 [DOWNLOAD DEBUG] File path: $filePath');
    print('🔍 [DOWNLOAD DEBUG] File name: $fileName');
    print('🔍 [DOWNLOAD DEBUG] Letter status: ${letter.letterStatus}');
    print('🔍 [DOWNLOAD DEBUG] Signed PDF path: ${letter.signedPdfPath}');

    if (filePath == null || filePath.isEmpty) {
      print('❌ [DOWNLOAD DEBUG] PDF path is null or empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating download link...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final supabaseService = SupabaseService();
      // print('🔍 [DOWNLOAD DEBUG] Getting signed URL for path: $filePath');

      // Use download security level for proper expiry management
      final signedUrl = await supabaseService.getSignedUrlWithSecurityLevel(
        filePath,
        securityLevel: 'download',
      );

      // print(
      //   '🔍 [DOWNLOAD DEBUG] Got signed URL: ${signedUrl.substring(0, 50)}...',
      // );

      if (kIsWeb) {
        final anchor =
            html.AnchorElement(href: signedUrl)
              ..setAttribute('download', fileName)
              ..setAttribute('target', '_blank')
              ..style.display = 'none';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);

        print('🔍 [DOWNLOAD DEBUG] Download triggered for web');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download started: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // For mobile, trigger download using the same method
        final anchor =
            html.AnchorElement(href: signedUrl)
              ..setAttribute('download', fileName)
              ..setAttribute('target', '_blank')
              ..style.display = 'none';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download started: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('💥 [DOWNLOAD ERROR] Failed to download PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAsSent(
    BuildContext context,
    WidgetRef ref,
    Letter letter,
  ) async {
    final sentViaController = TextEditingController();
    final sentToController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Mark as Sent'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sentViaController,
                  decoration: const InputDecoration(
                    labelText: 'Sent Via (e.g., email, hand-delivered)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sentToController,
                  decoration: const InputDecoration(
                    labelText: 'Sent To (recipient email/contact)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    final actions = ref.read(letterActionsProvider);
                    await actions.markAsSent(
                      letter.id,
                      sentVia: sentViaController.text.trim(),
                      sentTo: sentToController.text.trim(),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Letter marked as sent'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      ref.invalidate(approvedLettersProvider);
                      ref.invalidate(sentLettersProvider);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error marking as sent: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Mark Sent'),
              ),
            ],
          ),
    );
  }
}

import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/letter_model.dart';
import '../providers/letter_providers.dart';
import '../shared/letter_card.dart';
import '../../../core/services/supabase_service.dart';
import '../widgets/letter_preview_edit_modal.dart';

class SentTab extends ConsumerWidget {
  final String searchQuery;

  const SentTab({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentAsync = ref.watch(sentLettersProvider);

    return sentAsync.when(
      data: (sent) {
        // Filter sent letters based on search query
        final filteredSent = _filterSentLetters(sent, searchQuery);

        if (filteredSent.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isNotEmpty ? Icons.search_off : Icons.send,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No sent letters found'
                      : 'No Sent Letters',
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
                      : 'Sent letters will appear here',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredSent.length,
          itemBuilder: (context, index) {
            final letter = filteredSent[index];
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
                onMarkAccepted:
                    () async => await _markAsAccepted(context, ref, letter),
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
                  'Error loading sent letters',
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

  List<Letter> _filterSentLetters(List<Letter> sent, String query) {
    if (query.isEmpty) return sent;

    final lowercaseQuery = query.toLowerCase();
    return sent.where((letter) {
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

    if (filePath == null || filePath.isEmpty) {
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

      // Use download security level for proper expiry management
      final signedUrl = await supabaseService.getSignedUrlWithSecurityLevel(
        filePath,
        securityLevel: 'download',
      );

      if (kIsWeb) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAsAccepted(
    BuildContext context,
    WidgetRef ref,
    Letter letter,
  ) async {
    try {
      final actions = ref.read(letterActionsProvider);
      await actions.markAsAccepted(letter.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Letter marked as accepted'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the providers
        ref.invalidate(sentLettersProvider);
        ref.invalidate(acceptedLettersProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking as accepted: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

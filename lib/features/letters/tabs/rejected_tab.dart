import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/letter_model.dart';
import '../providers/letter_providers.dart';
import '../shared/letter_card.dart';
import '../widgets/letter_preview_edit_modal.dart';

class RejectedTab extends ConsumerWidget {
  final String searchQuery;

  const RejectedTab({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rejectedAsync = ref.watch(rejectedLettersProvider);

    return rejectedAsync.when(
      data: (rejected) {
        // Filter rejected letters based on search query
        final filteredRejected = _filterRejectedLetters(rejected, searchQuery);

        if (filteredRejected.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isNotEmpty ? Icons.search_off : Icons.cancel,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No rejected letters found'
                      : 'No Rejected Letters',
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
                      : 'Rejected letters will appear here',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredRejected.length,
          itemBuilder: (context, index) {
            final letter = filteredRejected[index];
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
                onMoveToDraft:
                    () async => await _moveToDraft(context, ref, letter),
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
                  'Error loading rejected letters',
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

  List<Letter> _filterRejectedLetters(List<Letter> rejected, String query) {
    if (query.isEmpty) return rejected;

    final lowercaseQuery = query.toLowerCase();
    return rejected.where((letter) {
      return letter.employeeName.toLowerCase().contains(lowercaseQuery) ||
          letter.employeeEmail.toLowerCase().contains(lowercaseQuery) ||
          letter.type.toLowerCase().contains(lowercaseQuery) ||
          letter.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> _moveToDraft(
    BuildContext context,
    WidgetRef ref,
    Letter letter,
  ) async {
    try {
      final actions = ref.read(letterActionsProvider);
      await actions.moveToDraft(letter.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Letter moved to draft successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the providers
        ref.invalidate(rejectedLettersProvider);
        ref.invalidate(draftLettersProvider);
        ref.invalidate(allLettersProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error moving to draft: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

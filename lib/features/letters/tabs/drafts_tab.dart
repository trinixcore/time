import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/letter_model.dart';
import '../providers/letter_providers.dart';
import '../shared/letter_card.dart';
import '../widgets/letter_preview_edit_modal.dart';

class DraftsTab extends ConsumerWidget {
  final String searchQuery;

  const DraftsTab({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftsAsync = ref.watch(draftLettersProvider);

    return draftsAsync.when(
      data: (drafts) {
        // Filter drafts based on search query
        final filteredDrafts = _filterDrafts(drafts, searchQuery);

        if (filteredDrafts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isNotEmpty ? Icons.search_off : Icons.edit,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No drafts found'
                      : 'No Draft Letters',
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
                      : 'Create your first letter to get started',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDrafts.length,
          itemBuilder: (context, index) {
            final letter = filteredDrafts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LetterCard(
                letter: letter,
                onEdit:
                    () async => showDialog(
                      context: context,
                      builder:
                          (context) =>
                              LetterPreviewEditModal(letter: letter, ref: ref),
                    ),
                onSubmit:
                    () async => await _submitForApproval(context, ref, letter),
                onDelete: () async => await _deleteLetter(context, ref, letter),
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
                  'Error loading drafts',
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

  List<Letter> _filterDrafts(List<Letter> drafts, String query) {
    if (query.isEmpty) return drafts;

    final lowercaseQuery = query.toLowerCase();
    return drafts.where((letter) {
      return letter.employeeName.toLowerCase().contains(lowercaseQuery) ||
          letter.employeeEmail.toLowerCase().contains(lowercaseQuery) ||
          letter.type.toLowerCase().contains(lowercaseQuery) ||
          letter.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> _submitForApproval(
    BuildContext context,
    WidgetRef ref,
    Letter letter,
  ) async {
    try {
      final actions = ref.read(letterActionsProvider);
      await actions.submitForApproval(letter.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Letter submitted for approval'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the providers
        ref.invalidate(draftLettersProvider);
        ref.invalidate(pendingApprovalLettersProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting letter: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLetter(
    BuildContext context,
    WidgetRef ref,
    Letter letter,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Letter'),
            content: Text(
              'Are you sure you want to delete this ${letter.type}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final actions = ref.read(letterActionsProvider);
        await actions.deleteLetter(letter.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Letter deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the providers
          ref.invalidate(draftLettersProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting letter: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

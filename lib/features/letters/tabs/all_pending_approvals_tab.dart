import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/letter_model.dart';
import '../providers/letter_providers.dart';
import '../shared/letter_card.dart';
import '../widgets/letter_preview_edit_modal.dart';

class AllPendingApprovalsTab extends ConsumerWidget {
  final String searchQuery;

  const AllPendingApprovalsTab({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingApprovalLettersProvider);

    return pendingAsync.when(
      data: (pending) {
        // Filter all pending approvals based on search query
        final filteredPending = _filterAllPendingApprovals(
          pending,
          searchQuery,
        );

        if (filteredPending.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isNotEmpty
                      ? Icons.search_off
                      : Icons.pending_actions,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isNotEmpty
                      ? 'No pending approvals found'
                      : 'No Pending Approvals',
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
                      : 'All letters awaiting approval will appear here',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredPending.length,
          itemBuilder: (context, index) {
            final letter = filteredPending[index];
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
                  'Error loading pending approvals',
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

  List<Letter> _filterAllPendingApprovals(List<Letter> pending, String query) {
    if (query.isEmpty) return pending;

    final lowercaseQuery = query.toLowerCase();
    return pending.where((letter) {
      return letter.employeeName.toLowerCase().contains(lowercaseQuery) ||
          letter.employeeEmail.toLowerCase().contains(lowercaseQuery) ||
          letter.type.toLowerCase().contains(lowercaseQuery) ||
          letter.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}

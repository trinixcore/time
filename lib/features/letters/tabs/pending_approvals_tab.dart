import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/letter_model.dart';
import '../providers/letter_providers.dart';
import '../shared/letter_card.dart';
import '../widgets/letter_preview_edit_modal.dart';
import '../widgets/signature_approval_dialog.dart';

class PendingApprovalsTab extends ConsumerWidget {
  final String searchQuery;

  const PendingApprovalsTab({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(lettersPendingUserApprovalProvider);

    return pendingAsync.when(
      data: (pending) {
        // Filter pending approvals based on search query
        final filteredPending = _filterPendingApprovals(pending, searchQuery);

        if (filteredPending.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isNotEmpty ? Icons.search_off : Icons.pending,
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
                      : 'Letters awaiting your approval will appear here',
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
                onApprove:
                    () async => await _approveLetter(context, ref, letter),
                onReject: () async => await _rejectLetter(context, ref, letter),
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

  List<Letter> _filterPendingApprovals(List<Letter> pending, String query) {
    if (query.isEmpty) return pending;

    final lowercaseQuery = query.toLowerCase();
    return pending.where((letter) {
      return letter.employeeName.toLowerCase().contains(lowercaseQuery) ||
          letter.employeeEmail.toLowerCase().contains(lowercaseQuery) ||
          letter.type.toLowerCase().contains(lowercaseQuery) ||
          letter.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<void> _approveLetter(
    BuildContext context,
    WidgetRef ref,
    Letter letter,
  ) async {
    try {
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Find the signature approval for the current user
      final userApproval = letter.signatureApprovals.firstWhere(
        (approval) => approval.signatureOwnerUid == currentUser.uid,
        orElse:
            () => throw Exception('No pending approval found for current user'),
      );

      final actions = ref.read(letterActionsProvider);
      await actions.approveIndividualSignature(
        letter.id,
        userApproval.signatureId,
        currentUser.uid,
        currentUser.displayName ?? 'Unknown',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Letter approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the providers
        ref.invalidate(lettersPendingUserApprovalProvider);
        ref.invalidate(pendingApprovalLettersProvider);
        ref.invalidate(approvedLettersProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving letter: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectLetter(
    BuildContext context,
    WidgetRef ref,
    Letter letter,
  ) async {
    try {
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Find the signature approval for the current user
      final userApproval = letter.signatureApprovals.firstWhere(
        (approval) => approval.signatureOwnerUid == currentUser.uid,
        orElse:
            () => throw Exception('No pending approval found for current user'),
      );

      // Show rejection dialog
      final reason = await showDialog<String>(
        context: context,
        builder: (context) => const SignatureApprovalDialog(isRejection: true),
      );

      if (reason != null && context.mounted) {
        final actions = ref.read(letterActionsProvider);
        await actions.rejectIndividualSignature(
          letter.id,
          userApproval.signatureId,
          currentUser.uid,
          currentUser.displayName ?? 'Unknown',
          reason,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Letter rejected successfully'),
              backgroundColor: Colors.orange,
            ),
          );
          // Refresh the providers
          ref.invalidate(lettersPendingUserApprovalProvider);
          ref.invalidate(pendingApprovalLettersProvider);
          ref.invalidate(rejectedLettersProvider);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting letter: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

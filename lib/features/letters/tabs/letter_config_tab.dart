import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/candidate_model.dart';
import '../providers/candidate_providers.dart';
import '../modals/create_candidate_modal.dart';
import '../modals/generate_letter_modal.dart';
import '../widgets/template_management_widget.dart';
import '../widgets/signature_management_widget.dart';
import 'package:go_router/go_router.dart';

class LetterConfigTab extends ConsumerStatefulWidget {
  const LetterConfigTab({super.key});

  @override
  ConsumerState<LetterConfigTab> createState() => _LetterConfigTabState();
}

class _LetterConfigTabState extends ConsumerState<LetterConfigTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidatesAsync = ref.watch(candidatesProvider);

    return Column(
      children: [
        // Header with search and filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search candidates...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'applied', child: Text('Applied')),
                    DropdownMenuItem(
                      value: 'interviewed',
                      child: Text('Interviewed'),
                    ),
                    DropdownMenuItem(value: 'offered', child: Text('Offered')),
                    DropdownMenuItem(
                      value: 'accepted',
                      child: Text('Accepted'),
                    ),
                    DropdownMenuItem(
                      value: 'onboarded',
                      child: Text('Onboarded'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showCreateCandidateModal(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Candidate'),
              ),
            ],
          ),
        ),

        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              // Refresh candidates when the Candidates tab is clicked
              if (index == 0) {
                ref.invalidate(candidatesProvider);
              }
            },
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(text: 'Candidates', icon: Icon(Icons.people)),
              Tab(text: 'Signatures', icon: Icon(Icons.draw)),
              Tab(text: 'Templates', icon: Icon(Icons.description)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCandidatesTab(candidatesAsync),
              _buildSignaturesTab(),
              _buildTemplatesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCandidatesTab(AsyncValue<List<Candidate>> candidatesAsync) {
    return candidatesAsync.when(
      data: (candidates) {
        // Filter candidates based on search and status
        final filteredCandidates =
            candidates.where((candidate) {
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  candidate.fullName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  candidate.email.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  candidate.candidateId.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );

              final matchesStatus =
                  _selectedStatus == 'all' ||
                  candidate.status == _selectedStatus;

              return matchesSearch && matchesStatus;
            }).toList();

        if (filteredCandidates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'No candidates found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first candidate to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredCandidates.length,
          itemBuilder: (context, index) {
            final candidate = filteredCandidates[index];
            return _buildCandidateCard(candidate);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading candidates',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCandidateCard(Candidate candidate) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    candidate.initials,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.fullName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        candidate.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        candidate.candidateId,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(candidate.status ?? 'applied'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (candidate.department != null) ...[
                  _buildInfoChip('Department', candidate.department!),
                  const SizedBox(width: 8),
                ],
                if (candidate.designation != null) ...[
                  _buildInfoChip('Position', candidate.designation!),
                  const SizedBox(width: 8),
                ],
                if (candidate.employmentType != null) ...[
                  _buildInfoChip('Type', candidate.employmentType!),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created: ${_formatDate(candidate.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _editCandidate(candidate),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _deleteCandidate(candidate),
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                    ),
                    PopupMenuButton<String>(
                      onSelected:
                          (status) => _updateCandidateStatus(candidate, status),
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'applied',
                              child: Text('Mark as Applied'),
                            ),
                            const PopupMenuItem(
                              value: 'interviewed',
                              child: Text('Mark as Interviewed'),
                            ),
                            const PopupMenuItem(
                              value: 'offered',
                              child: Text('Mark as Offered'),
                            ),
                            const PopupMenuItem(
                              value: 'accepted',
                              child: Text('Mark as Accepted'),
                            ),
                            const PopupMenuItem(
                              value: 'onboarded',
                              child: Text('Mark as Onboarded'),
                            ),
                          ],
                      child: const Icon(Icons.more_vert),
                      tooltip: 'Update Status',
                    ),
                    IconButton(
                      onPressed: () => _generateLetter(candidate),
                      icon: const Icon(Icons.description),
                      tooltip: 'Generate Letter',
                    ),
                    if (!candidate.isOnboarded)
                      IconButton(
                        onPressed: () => _onboardCandidate(candidate),
                        icon: const Icon(Icons.person_add),
                        tooltip: 'Onboard',
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'applied':
        color = Colors.blue;
        label = 'Applied';
        break;
      case 'interviewed':
        color = Colors.orange;
        label = 'Interviewed';
        break;
      case 'offered':
        color = Colors.purple;
        label = 'Offered';
        break;
      case 'accepted':
        color = Colors.green;
        label = 'Accepted';
        break;
      case 'onboarded':
        color = Colors.teal;
        label = 'Onboarded';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSignaturesTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: SignatureManagementWidget(),
    );
  }

  Widget _buildTemplatesTab() {
    return const TemplateManagementWidget();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateCandidateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateCandidateModal(),
    );
  }

  void _editCandidate(Candidate candidate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateCandidateModal(candidate: candidate),
    );
  }

  void _generateLetter(Candidate candidate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GenerateLetterModal(candidate: candidate),
    );
  }

  void _onboardCandidate(Candidate candidate) {
    // Navigate to user creation with candidate pre-filled
    final queryParams = {
      'candidateId': candidate.id,
      'candidateName': candidate.fullName,
      'candidateEmail': candidate.email,
      if (candidate.department != null)
        'candidateDepartment': candidate.department!,
      if (candidate.designation != null)
        'candidateDesignation': candidate.designation!,
    };

    final uri = Uri(path: '/admin/users/create', queryParameters: queryParams);

    context.go(uri.toString());
  }

  void _updateCandidateStatus(Candidate candidate, String newStatus) async {
    try {
      final notifier = ref.read(candidateNotifierProvider.notifier);
      await notifier.updateCandidateStatus(candidate.id, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status updated to $newStatus for ${candidate.fullName}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteCandidate(Candidate candidate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Candidate'),
            content: Text(
              'Are you sure you want to delete ${candidate.fullName}? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      try {
        final notifier = ref.read(candidateNotifierProvider.notifier);
        await notifier.deleteCandidate(candidate.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Candidate deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting candidate: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

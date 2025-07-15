import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/letter_model.dart';
import '../../../shared/providers/auth_providers.dart';
import '../providers/letter_providers.dart' as letter_providers;
import '../providers/candidate_providers.dart';
import '../tabs/drafts_tab.dart';
import '../tabs/pending_approvals_tab.dart';
import '../tabs/all_pending_approvals_tab.dart';
import '../tabs/approved_tab.dart';
import '../tabs/sent_tab.dart';
import '../tabs/accepted_tab.dart';
import '../tabs/rejected_tab.dart';
import '../tabs/letter_config_tab.dart';
import '../modals/generate_letter_modal.dart';
import '../../../features/dashboard/ui/dashboard_scaffold.dart';
import '../tabs/pdf_config_tab.dart';

class LettersPage extends ConsumerStatefulWidget {
  const LettersPage({super.key});

  @override
  ConsumerState<LettersPage> createState() => _LettersPageState();
}

class _LettersPageState extends ConsumerState<LettersPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      // Refresh the specific provider for the tab being switched to
      switch (_tabController.index) {
        case 0: // Drafts
          ref.invalidate(letter_providers.draftLettersProvider);
          break;
        case 1: // My Approvals
          ref.invalidate(letter_providers.lettersPendingUserApprovalProvider);
          break;
        case 2: // All Pending
          ref.invalidate(letter_providers.pendingApprovalLettersProvider);
          break;
        case 3: // Approved
          ref.invalidate(letter_providers.approvedLettersProvider);
          break;
        case 4: // Sent
          ref.invalidate(letter_providers.sentLettersProvider);
          break;
        case 5: // Accepted
          ref.invalidate(letter_providers.acceptedLettersProvider);
          break;
        case 6: // Rejected
          ref.invalidate(letter_providers.rejectedLettersProvider);
          break;
        case 7: // Letter Config
          ref.invalidate(candidatesProvider);
          break;
        case 8: // PDF Config
          // These tabs don't need letter data refresh
          break;
      }

      // Always refresh the all letters provider for statistics cards
      ref.invalidate(letter_providers.allLettersProvider);
    }
  }

  void _refreshCurrentTab() {
    // Refresh the specific provider for the current tab
    switch (_tabController.index) {
      case 0: // Drafts
        ref.invalidate(letter_providers.draftLettersProvider);
        break;
      case 1: // My Approvals
        ref.invalidate(letter_providers.lettersPendingUserApprovalProvider);
        break;
      case 2: // All Pending
        ref.invalidate(letter_providers.pendingApprovalLettersProvider);
        break;
      case 3: // Approved
        ref.invalidate(letter_providers.approvedLettersProvider);
        break;
      case 4: // Sent
        ref.invalidate(letter_providers.sentLettersProvider);
        break;
      case 5: // Accepted
        ref.invalidate(letter_providers.acceptedLettersProvider);
        break;
      case 6: // Rejected
        ref.invalidate(letter_providers.rejectedLettersProvider);
        break;
      case 7: // Letter Config
        ref.invalidate(candidatesProvider);
        break;
      case 8: // PDF Config
        // These tabs don't need letter data refresh
        break;
    }

    // Always refresh the all letters provider for statistics cards
    ref.invalidate(letter_providers.allLettersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final lettersAsync = ref.watch(letter_providers.allLettersProvider);

    return DashboardScaffold(
      currentPath: '/letters',
      child: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Please log in to access letters.'),
            );
          }

          return Column(
            children: [
              // Header with title and actions
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Letters & Signatures',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage letter generation, signatures, and workflows',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showGenerateLetterModal(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Generate Letter'),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText:
                                  'Search letters by employee name, email, type, or content...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.trim();
                              });
                            },
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear search',
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Statistics Cards
              _buildStatisticsCards(lettersAsync),

              // Tab Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Custom TabBar
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          onTap: (index) {
                            // Refresh the current tab when tapped
                            _refreshCurrentTab();
                          },
                          indicator: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelColor: Theme.of(context).colorScheme.onPrimary,
                          unselectedLabelColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                          tabs: const [
                            Tab(text: 'Drafts', icon: Icon(Icons.edit)),
                            Tab(
                              text: 'My Approvals',
                              icon: Icon(Icons.pending),
                            ),
                            Tab(
                              text: 'All Pending',
                              icon: Icon(Icons.pending_actions),
                            ),
                            Tab(
                              text: 'Approved',
                              icon: Icon(Icons.check_circle),
                            ),
                            Tab(text: 'Sent', icon: Icon(Icons.send)),
                            Tab(text: 'Accepted', icon: Icon(Icons.done_all)),
                            Tab(text: 'Rejected', icon: Icon(Icons.clear)),
                            Tab(
                              text: 'Letter Config',
                              icon: Icon(Icons.settings),
                            ),
                            Tab(
                              text: 'PDF Config',
                              icon: Icon(Icons.picture_as_pdf),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            DraftsTab(searchQuery: _searchQuery),
                            PendingApprovalsTab(searchQuery: _searchQuery),
                            AllPendingApprovalsTab(searchQuery: _searchQuery),
                            ApprovedTab(searchQuery: _searchQuery),
                            SentTab(searchQuery: _searchQuery),
                            AcceptedTab(searchQuery: _searchQuery),
                            RejectedTab(searchQuery: _searchQuery),
                            LetterConfigTab(),
                            PdfConfigTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatisticsCards(AsyncValue<List<Letter>> lettersAsync) {
    return lettersAsync.when(
      data: (letters) {
        // Filter letters based on search query
        final filteredLetters = _filterLetters(letters, _searchQuery);

        final drafts = filteredLetters.where((l) => l.isDraft).length;
        final pending =
            filteredLetters.where((l) => l.isPendingApproval).length;
        final approved = filteredLetters.where((l) => l.isApproved).length;
        final sent = filteredLetters.where((l) => l.isSent).length;
        final accepted = filteredLetters.where((l) => l.isAccepted).length;
        final rejected = filteredLetters.where((l) => l.isRejected).length;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Drafts',
                  drafts.toString(),
                  Icons.edit,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  pending.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Approved',
                  approved.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Sent',
                  sent.toString(),
                  Icons.send,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Accepted',
                  accepted.toString(),
                  Icons.done_all,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Rejected',
                  rejected.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
        );
      },
      loading:
          () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stack) => Padding(
            padding: const EdgeInsets.all(16),
            child: Center(child: Text('Error loading statistics: $error')),
          ),
    );
  }

  List<Letter> _filterLetters(List<Letter> letters, String query) {
    if (query.isEmpty) return letters;

    final lowercaseQuery = query.toLowerCase();
    return letters.where((letter) {
      return letter.employeeName.toLowerCase().contains(lowercaseQuery) ||
          letter.employeeEmail.toLowerCase().contains(lowercaseQuery) ||
          letter.type.toLowerCase().contains(lowercaseQuery) ||
          letter.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              count,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showGenerateLetterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GenerateLetterModal(candidate: null),
    );
  }
}

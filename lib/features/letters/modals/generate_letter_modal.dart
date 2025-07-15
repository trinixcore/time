import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/signature_model.dart';
import '../../../core/models/candidate_model.dart';
import '../../../core/models/user_model.dart';
import '../providers/letter_providers.dart';
import '../providers/candidate_providers.dart';
import '../providers/signature_providers.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../../core/services/employee_service.dart';
import 'package:collection/collection.dart';
import '../widgets/multi_signature_selection.dart';
import '../../../core/services/supabase_service.dart';

final activeUsersForLettersProvider = FutureProvider<
  List<Map<String, dynamic>>
>((ref) async {
  final authService = ref.read(authServiceProvider);
  final firebaseService = ref.read(firebaseServiceProvider);
  final firestore = firebaseService.firestore;

  try {
    // Get users from both collections
    final usersQuery = await firestore.collection('users').get();
    final pendingUsersQuery = await firestore.collection('pending_users').get();

    print('DEBUG: Found ${usersQuery.docs.length} users in users collection');
    print(
      'DEBUG: Found ${pendingUsersQuery.docs.length} users in pending_users collection',
    );

    final allUsers = <Map<String, dynamic>>[];

    // Process users from users collection
    for (final doc in usersQuery.docs) {
      try {
        final userData = doc.data();
        print(
          'DEBUG: User from users collection - uid: "${doc.id}", displayName: "${userData['displayName']}", isActive: ${userData['isActive']}',
        );
        final user = UserModel.fromJson({...userData, 'uid': doc.id});
        allUsers.add({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'employeeId': user.employeeId ?? '',
          'department': user.department ?? '',
          'designation': user.position ?? user.role.displayName,
          'role': user.role.value,
          'address': userData['address'] ?? '',
          'city': userData['city'] ?? '',
          'state': userData['state'] ?? '',
          'postalCode': userData['postalCode'] ?? '',
        });
      } catch (e) {
        print('DEBUG: Error parsing user from users collection: $e');
      }
    }

    // Process users from pending_users collection
    for (final doc in pendingUsersQuery.docs) {
      try {
        final userData = doc.data();
        print(
          'DEBUG: User from pending_users collection - uid: "${doc.id}", displayName: "${userData['displayName']}", isActive: ${userData['isActive']}',
        );
        final user = UserModel.fromJson({...userData, 'uid': doc.id});
        allUsers.add({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'employeeId': user.employeeId ?? '',
          'department': user.department ?? '',
          'designation': user.position ?? user.role.displayName,
          'role': user.role.value,
          'address': userData['address'] ?? '',
          'city': userData['city'] ?? '',
          'state': userData['state'] ?? '',
          'postalCode': userData['postalCode'] ?? '',
        });
      } catch (e) {
        print('DEBUG: Error parsing user from pending_users collection: $e');
      }
    }

    print('DEBUG: Total users loaded: ${allUsers.length}');

    // Less restrictive filtering - only check if displayName exists and is not empty
    final filteredUsers =
        allUsers.where((u) => (u['name'] as String).isNotEmpty).toList();

    print('DEBUG: After filtering, ${filteredUsers.length} users remain');

    // Debug: Print which users passed the filter
    for (final user in filteredUsers) {
      print(
        'DEBUG: Filtered User - uid: "${user['uid']}", displayName: "${user['name']}"',
      );
    }

    return filteredUsers;
  } catch (e) {
    print('DEBUG: Error in activeUsersForLettersProvider: $e');
    return [];
  }
});

class GenerateLetterModal extends ConsumerStatefulWidget {
  final Candidate? candidate;

  const GenerateLetterModal({super.key, this.candidate});

  @override
  ConsumerState<GenerateLetterModal> createState() =>
      _GenerateLetterModalState();
}

class _GenerateLetterModalState extends ConsumerState<GenerateLetterModal>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _employeeNameController = TextEditingController();
  final _employeeEmailController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedLetterType = 'Offer Letter';
  List<String> _selectedSignatureIds = [];
  List<Signature> _availableSignatures = [];
  bool _isGenerating = false;
  bool _isCreating = false;

  // Selection tabs
  late TabController _tabController;
  int _selectedTabIndex = 0; // 0 = Manual, 1 = Users, 2 = Candidates

  // User/Candidate selection
  String? _selectedUserId;
  String? _selectedCandidateId;
  List<Map<String, dynamic>> _availableUsers = [];
  List<Candidate> _availableCandidates = [];
  bool _isLoadingUsers = false;
  bool _isLoadingCandidates = false;

  // New fields for department and designation
  String? _selectedDepartment;
  String? _selectedDesignation;
  List<String> _departments = [];
  List<String> _designations = [];

  // New fields for letterhead and other details
  final _addressController = TextEditingController();
  final _cityStateZipController = TextEditingController();
  final _companyNameController = TextEditingController(
    text: 'TRINIX AI PRIVATE LIMITED',
  );
  final _hrContactController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  final List<String> _letterTypes = [
    'Offer Letter',
    'Appointment Letter',
    'Experience Certificate',
    'Relieving Letter',
    'Promotion Letter',
    'Leave Approval',
    'Warning Letter',
    'Custom Letter',
  ];

  final TextEditingController _userSearchController = TextEditingController();
  List<Map<String, dynamic>> _filteredUsers = [];

  String? _selectedUserUid;
  final TextEditingController _userSearchController2 = TextEditingController();
  bool _showUserDropdown2 = false;
  List<Map<String, dynamic>> _filteredUsers2 = [];

  // Add state for HR search
  final TextEditingController _hrSearchController = TextEditingController();
  String? _selectedHrUid;
  bool _showHrDropdown = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSignatures();
    _loadDepartmentsAndDesignations();
    _prefillCandidateData();
    _userSearchController.addListener(_onUserSearchChanged);
  }

  void _prefillCandidateData() {
    if (widget.candidate != null) {
      final candidate = widget.candidate!;
      _employeeNameController.text = candidate.fullName;
      _employeeEmailController.text = candidate.email;
      _selectedDepartment = candidate.department;
      _selectedDesignation = candidate.designation;

      // Set default letter type based on candidate status
      if (candidate.status == 'offered') {
        _selectedLetterType = 'Offer Letter';
      } else if (candidate.status == 'accepted') {
        _selectedLetterType = 'Appointment Letter';
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _employeeNameController.dispose();
    _employeeEmailController.dispose();
    _contentController.dispose();
    _addressController.dispose();
    _cityStateZipController.dispose();
    _companyNameController.dispose();
    _hrContactController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  void _onUserSearchChanged() {
    final query = _userSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _availableUsers;
      } else {
        _filteredUsers =
            _availableUsers.where((user) {
              final name = (user['name'] ?? '').toString().toLowerCase();
              final email = (user['email'] ?? '').toString().toLowerCase();
              final empId = (user['employeeId'] ?? '').toString().toLowerCase();
              return name.contains(query) ||
                  email.contains(query) ||
                  empId.contains(query);
            }).toList();
      }
    });
  }

  void _filterUsers2(List<Map<String, dynamic>> allUsers, String query) {
    if (query.isEmpty) {
      _filteredUsers2 = allUsers;
    } else {
      _filteredUsers2 =
          allUsers.where((user) {
            final name = user['name']?.toString().toLowerCase() ?? '';
            final email = user['email']?.toString().toLowerCase() ?? '';
            final employeeId =
                user['employeeId']?.toString().toLowerCase() ?? '';
            final searchQuery = query.toLowerCase();
            return name.contains(searchQuery) ||
                email.contains(searchQuery) ||
                employeeId.contains(searchQuery);
          }).toList();
    }
  }

  Future<void> _loadSignatures() async {
    try {
      final signatures = await ref.read(
        refreshedSignaturesForLetterTypeProvider(_selectedLetterType).future,
      );
      setState(() {
        _availableSignatures = signatures;
        if (_availableSignatures.isNotEmpty && _selectedSignatureIds.isEmpty) {
          _selectedSignatureIds =
              _availableSignatures.map((s) => s.id).toList();
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadDepartmentsAndDesignations() async {
    final authService = ref.read(authServiceProvider);
    final departments = await authService.getDepartments();
    final designations = await authService.getDesignations();
    setState(() {
      _departments = departments;
      _designations = designations;
      if (_departments.isNotEmpty) _selectedDepartment = _departments.first;
      if (_designations.isNotEmpty) _selectedDesignation = _designations.first;
    });
  }

  Future<void> _loadUsersAndCandidates() async {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final users = await authService.getAllUsers();
      print('DEBUG: Loaded users from Firestore:');
      for (final user in users) {
        print(
          '  uid: \'${user.uid}\', displayName: \'${user.displayName}\', email: \'${user.email}\'',
        );
      }
      setState(() {
        _availableUsers =
            users
                .map(
                  (user) => {
                    'id': user.uid,
                    'employeeId': user.employeeId ?? '',
                    'name': user.displayName ?? '',
                    'email': user.email,
                    'department': user.department ?? '',
                    'designation': user.position ?? user.role.displayName,
                    'role': user.role.value,
                  },
                )
                .toList();
        _filteredUsers = _availableUsers;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      print('Error loading users: $e');
    }
  }

  void _onUserSelected(String? userId) {
    if (userId == null) {
      _clearForm();
      return;
    }

    final selectedUser = _availableUsers.firstWhereOrNull(
      (u) => u['id'] == userId,
    );
    if (selectedUser != null) {
      setState(() {
        _employeeNameController.text = selectedUser['name'] ?? '';
        _employeeEmailController.text = selectedUser['email'] ?? '';
        _selectedDepartment = selectedUser['department'] ?? '';
        _selectedDesignation = selectedUser['designation'] ?? '';
        _selectedUserId = userId;
        _selectedCandidateId = null; // Clear candidate selection
      });
    }
  }

  void _clearForm() {
    setState(() {
      _employeeNameController.clear();
      _employeeEmailController.clear();
      _selectedDepartment = null;
      _selectedDesignation = null;
      _selectedUserId = null;
      _selectedCandidateId = null;
    });
  }

  Future<void> _generateContent() async {
    if (_employeeNameController.text.isEmpty ||
        _employeeEmailController.text.isEmpty ||
        _selectedDepartment == null ||
        _selectedDesignation == null ||
        _addressController.text.isEmpty ||
        _cityStateZipController.text.isEmpty ||
        _companyNameController.text.isEmpty ||
        _hrContactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all required fields first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final letterService = ref.read(letterServiceProvider);
      final content = await letterService.generateLetterContent(
        letterType: _selectedLetterType,
        employeeName: _employeeNameController.text,
        employeeEmail: _employeeEmailController.text,
        additionalContext: {
          'department': _selectedDepartment,
          'position': _selectedDesignation,
          'currentDate': _selectedDate.toIso8601String().split('T')[0],
          'address': _addressController.text,
          'cityStateZip': _cityStateZipController.text,
          'companyName': _companyNameController.text,
          'hrContact': _hrContactController.text,
          'signatoryName': 'Authorized Signatory',
          'signatoryTitle': 'Authorized Signatory',
        },
      );

      setState(() {
        _contentController.text = content;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating content: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createLetter() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSignatureIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a signature authority'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedDepartment == null || _selectedDesignation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select department and designation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_addressController.text.isEmpty ||
        _cityStateZipController.text.isEmpty ||
        _companyNameController.text.isEmpty ||
        _hrContactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // Get signatory details from selected signatures
      final selectedSignatures =
          _availableSignatures
              .where((sig) => _selectedSignatureIds.contains(sig.id))
              .toList();

      // Use the first signature's details for the letter context
      final primarySignature =
          selectedSignatures.isNotEmpty ? selectedSignatures.first : null;

      final additionalContext = {
        'currentDate': _selectedDate.toString().split(' ')[0],
        'address': _addressController.text,
        'cityStateZip': _cityStateZipController.text,
        'companyName': _companyNameController.text,
        'hrContact': _hrContactController.text,
        'signatoryName': primarySignature?.ownerName ?? 'Authorized Signatory',
        'signatoryTitle': primarySignature?.title ?? 'Authorized Signatory',
        'department': _selectedDepartment,
        'position': _selectedDesignation,
      };

      await ref
          .read(letterCreationProvider.notifier)
          .createLetter(
            type: _selectedLetterType,
            employeeName: _employeeNameController.text,
            employeeEmail: _employeeEmailController.text,
            signatureAuthorityUids: _selectedSignatureIds,
            content:
                _contentController.text.isEmpty
                    ? null
                    : _contentController.text,
            additionalContext: additionalContext,
          );

      // Get the created letter from the provider state
      final letterState = ref.read(letterCreationProvider);
      final letter = letterState.value;

      if (letter != null && mounted) {
        Navigator.of(context).pop(letter);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Letter created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating letter: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: screenHeight * 0.92,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Generate Letter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selection Tabs
            Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                    if (index == 0) {
                      _clearForm();
                    }
                  });
                },
                tabs: const [
                  Tab(icon: Icon(Icons.edit), text: 'Manual'),
                  Tab(icon: Icon(Icons.people), text: 'Users'),
                  Tab(icon: Icon(Icons.person_add), text: 'Candidates'),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Letter Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedLetterType,
                        decoration: const InputDecoration(
                          labelText: 'Letter Type',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            _letterTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedLetterType = value!;
                            _loadSignatures();
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // --- User Search Section ---
                      if (_selectedTabIndex == 1) ...[
                        Text(
                          'Select Employee',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Material(
                              elevation: 2,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Consumer(
                                      builder: (context, ref, _) {
                                        final usersAsync = ref.watch(
                                          activeUsersForLettersProvider,
                                        );
                                        return usersAsync.when(
                                          data: (users) {
                                            print(
                                              'DEBUG: activeUsersForLettersProvider returned \'${users.length}\' users',
                                            );
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                TextFormField(
                                                  controller:
                                                      _userSearchController2,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        'Search by name, email, or employee ID',
                                                    border:
                                                        const OutlineInputBorder(),
                                                    suffixIcon:
                                                        _selectedUserUid != null
                                                            ? IconButton(
                                                              icon: const Icon(
                                                                Icons.clear,
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  _selectedUserUid =
                                                                      null;
                                                                  _userSearchController2
                                                                      .clear();
                                                                  _showUserDropdown2 =
                                                                      false;
                                                                  _employeeNameController
                                                                      .clear();
                                                                  _employeeEmailController
                                                                      .clear();
                                                                  _selectedDepartment =
                                                                      null;
                                                                  _selectedDesignation =
                                                                      null;
                                                                });
                                                              },
                                                            )
                                                            : const Icon(
                                                              Icons.search,
                                                            ),
                                                  ),
                                                  onChanged: (value) {
                                                    _filterUsers2(users, value);
                                                    setState(() {
                                                      // Always show dropdown if field is focused, regardless of value
                                                      _showUserDropdown2 = true;
                                                    });
                                                  },
                                                  onTap: () {
                                                    _filterUsers2(
                                                      users,
                                                      _userSearchController2
                                                          .text,
                                                    );
                                                    setState(() {
                                                      // Always show dropdown on tap
                                                      _showUserDropdown2 = true;
                                                    });
                                                  },
                                                  readOnly:
                                                      _selectedUserUid != null,
                                                ),
                                                if (_showUserDropdown2 &&
                                                    _selectedUserUid == null)
                                                  Material(
                                                    elevation: 4,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                            maxHeight: 220,
                                                          ),
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child:
                                                          _filteredUsers2
                                                                  .isEmpty
                                                              ? const Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                      16,
                                                                    ),
                                                                child: Text(
                                                                  'No users found',
                                                                ),
                                                              )
                                                              : ListView.builder(
                                                                shrinkWrap:
                                                                    true,
                                                                itemCount:
                                                                    _filteredUsers2
                                                                        .length,
                                                                itemBuilder: (
                                                                  context,
                                                                  index,
                                                                ) {
                                                                  final user =
                                                                      _filteredUsers2[index];
                                                                  return ListTile(
                                                                    dense: true,
                                                                    title: Text(
                                                                      user['name'] ??
                                                                          'Unknown',
                                                                    ),
                                                                    subtitle: Text(
                                                                      '${user['email'] ?? ''} • ${user['employeeId'] ?? 'No ID'}',
                                                                    ),
                                                                    onTap: () {
                                                                      print(
                                                                        'DEBUG: Selected user:',
                                                                      );
                                                                      print(
                                                                        '  address: \'${user['address']}\'',
                                                                      );
                                                                      print(
                                                                        '  city: \'${user['city']}\'',
                                                                      );
                                                                      print(
                                                                        '  state: \'${user['state']}\'',
                                                                      );
                                                                      print(
                                                                        '  postalCode: \'${user['postalCode']}\'',
                                                                      );
                                                                      setState(() {
                                                                        _selectedUserUid =
                                                                            user['uid'];
                                                                        _userSearchController2.text =
                                                                            user['name'] ??
                                                                            '';
                                                                        _showUserDropdown2 =
                                                                            false;
                                                                        _employeeNameController.text =
                                                                            user['name'] ??
                                                                            '';
                                                                        _employeeEmailController.text =
                                                                            user['email'] ??
                                                                            '';
                                                                        _selectedDepartment =
                                                                            user['department'] ??
                                                                            '';
                                                                        _selectedDesignation =
                                                                            user['designation'] ??
                                                                            '';
                                                                        // Populate address fields from user data
                                                                        if (user['address'] !=
                                                                            null) {
                                                                          print(
                                                                            'DEBUG: Setting _addressController.text = \'${user['address']}\'',
                                                                          );
                                                                          _addressController.text =
                                                                              user['address'];
                                                                        }
                                                                        if (user['city'] !=
                                                                                null &&
                                                                            user['state'] !=
                                                                                null &&
                                                                            user['postalCode'] !=
                                                                                null) {
                                                                          print(
                                                                            'DEBUG: Setting _cityStateZipController.text = \'${user['city']}, ${user['state']} ${user['postalCode']}\'',
                                                                          );
                                                                          _cityStateZipController.text =
                                                                              '${user['city']}, ${user['state']} ${user['postalCode']}';
                                                                        }
                                                                      });
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                          loading:
                                              () =>
                                                  const LinearProgressIndicator(),
                                          error:
                                              (_, __) => const Text(
                                                'Error loading users',
                                              ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ] else if (_selectedTabIndex == 2) ...[
                        // Candidates Dropdown or message using Consumer
                        Consumer(
                          builder: (context, ref, _) {
                            final candidatesAsync = ref.watch(
                              candidatesForLettersProvider,
                            );
                            return candidatesAsync.when(
                              data: (candidates) {
                                if (candidates.isEmpty) {
                                  return const Text(
                                    'No one left in pre-boarding step. Please select from onboarded users.',
                                    style: TextStyle(color: Colors.orange),
                                  );
                                }
                                return DropdownButtonFormField<String>(
                                  value: _selectedCandidateId,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Candidate',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Select a candidate'),
                                    ),
                                    ...candidates.map((candidate) {
                                      return DropdownMenuItem<String>(
                                        value: candidate.id,
                                        child: Text(
                                          '${candidate.fullName} (${candidate.candidateId})',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (id) {
                                    final selectedCandidate = candidates
                                        .firstWhereOrNull((c) => c.id == id);
                                    if (selectedCandidate != null) {
                                      setState(() {
                                        _selectedCandidateId = id;
                                        _employeeNameController.text =
                                            '${selectedCandidate.firstName} ${selectedCandidate.lastName}';
                                        _employeeEmailController.text =
                                            selectedCandidate.email;
                                        _selectedDepartment =
                                            selectedCandidate.department;
                                        _selectedDesignation =
                                            selectedCandidate.designation;
                                        _addressController.text =
                                            selectedCandidate.address ?? '';
                                        final city =
                                            selectedCandidate.city ?? '';
                                        final state =
                                            selectedCandidate.state ?? '';
                                        final postalCode =
                                            selectedCandidate.postalCode ?? '';
                                        if (city.isNotEmpty ||
                                            state.isNotEmpty ||
                                            postalCode.isNotEmpty) {
                                          _cityStateZipController.text =
                                              [city, state]
                                                  .where((s) => s.isNotEmpty)
                                                  .join(', ') +
                                              (postalCode.isNotEmpty
                                                  ? ' $postalCode'
                                                  : '');
                                        } else {
                                          _cityStateZipController.clear();
                                        }
                                        if (selectedCandidate.status ==
                                            'offered') {
                                          _selectedLetterType = 'Offer Letter';
                                        } else if (selectedCandidate.status ==
                                            'accepted') {
                                          _selectedLetterType =
                                              'Appointment Letter';
                                        }
                                        _selectedUserId =
                                            null; // Clear user selection
                                      });
                                    } else {
                                      setState(() {
                                        _selectedCandidateId = id;
                                        _employeeNameController.clear();
                                        _employeeEmailController.clear();
                                        _selectedDepartment = null;
                                        _selectedDesignation = null;
                                        _addressController.clear();
                                        _cityStateZipController.clear();
                                      });
                                    }
                                  },
                                );
                              },
                              loading:
                                  () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              error:
                                  (error, stack) =>
                                      Text('Error loading candidates'),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Employee Information Section
                      Text(
                        'Employee Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Employee Name
                      TextFormField(
                        controller: _employeeNameController,
                        decoration: const InputDecoration(
                          labelText: 'Employee Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Employee Email
                      TextFormField(
                        controller: _employeeEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Employee Email *',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Department Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedDepartment,
                        decoration: const InputDecoration(
                          labelText: 'Department *',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Select Department'),
                          ),
                          ..._departments
                              .map(
                                (dept) => DropdownMenuItem(
                                  value: dept,
                                  child: Text(dept),
                                ),
                              )
                              .toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartment = value;
                          });
                        },
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Designation Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedDesignation,
                        decoration: const InputDecoration(
                          labelText: 'Designation *',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Select Designation'),
                          ),
                          ..._designations
                              .map(
                                (desig) => DropdownMenuItem(
                                  value: desig,
                                  child: Text(desig),
                                ),
                              )
                              .toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedDesignation = value;
                          });
                        },
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 24),

                      // Company Information Section
                      Text(
                        'Company Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Current Date
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Current Date *',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${_selectedDate.toLocal()}'.split(' ')[0],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Employee Address *',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // City, State, Zip
                      TextFormField(
                        controller: _cityStateZipController,
                        decoration: const InputDecoration(
                          labelText: 'City, State, Zip Code *',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Company Name
                      TextFormField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // HR Contact Information
                      Consumer(
                        builder: (context, ref, _) {
                          final usersAsync = ref.watch(
                            activeUsersForLettersProvider,
                          );
                          return usersAsync.when(
                            data: (users) {
                              print(
                                'DEBUG: Total users from provider: ${users.length}',
                              );
                              final hrUsers =
                                  users
                                      .where((u) => u['role'] == 'hr')
                                      .toList();
                              print('DEBUG: HR users found: ${hrUsers.length}');
                              for (final hr in hrUsers) {
                                print('DEBUG: HR user: ' + hr.toString());
                              }
                              final hrSearchQuery =
                                  _hrSearchController.text.toLowerCase();
                              final filteredHrUsers =
                                  hrSearchQuery.isEmpty
                                      ? hrUsers
                                      : hrUsers.where((u) {
                                        final name =
                                            (u['name'] ?? '')
                                                .toString()
                                                .toLowerCase();
                                        final email =
                                            (u['email'] ?? '')
                                                .toString()
                                                .toLowerCase();
                                        final empId =
                                            (u['employeeId'] ?? '')
                                                .toString()
                                                .toLowerCase();
                                        return name.contains(hrSearchQuery) ||
                                            email.contains(hrSearchQuery) ||
                                            empId.contains(hrSearchQuery);
                                      }).toList();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HR Contact Information',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Stack(
                                    children: [
                                      Material(
                                        elevation: 2,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextFormField(
                                                controller: _hrSearchController,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Search HR by name, email, or employee ID',
                                                  border:
                                                      const OutlineInputBorder(),
                                                  suffixIcon:
                                                      _selectedHrUid != null
                                                          ? IconButton(
                                                            icon: const Icon(
                                                              Icons.clear,
                                                            ),
                                                            onPressed: () {
                                                              setState(() {
                                                                _selectedHrUid =
                                                                    null;
                                                                _hrSearchController
                                                                    .clear();
                                                                _showHrDropdown =
                                                                    false;
                                                                _hrContactController
                                                                    .clear();
                                                              });
                                                            },
                                                          )
                                                          : const Icon(
                                                            Icons.search,
                                                          ),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _showHrDropdown = true;
                                                  });
                                                },
                                                onTap: () {
                                                  setState(() {
                                                    _showHrDropdown = true;
                                                  });
                                                },
                                                readOnly:
                                                    _selectedHrUid != null,
                                                validator:
                                                    (value) =>
                                                        value == null ||
                                                                value.isEmpty
                                                            ? 'Required'
                                                            : null,
                                              ),
                                              if (_showHrDropdown &&
                                                  _selectedHrUid == null)
                                                Material(
                                                  elevation: 4,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                          maxHeight: 220,
                                                        ),
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade300,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child:
                                                        filteredHrUsers.isEmpty
                                                            ? const Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                    16,
                                                                  ),
                                                              child: Text(
                                                                'No HR users found',
                                                              ),
                                                            )
                                                            : ListView.builder(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  filteredHrUsers
                                                                      .length,
                                                              itemBuilder: (
                                                                context,
                                                                index,
                                                              ) {
                                                                final hr =
                                                                    filteredHrUsers[index];
                                                                return ListTile(
                                                                  dense: true,
                                                                  title: Text(
                                                                    hr['name'] ??
                                                                        'Unknown',
                                                                  ),
                                                                  subtitle: Text(
                                                                    '${hr['email'] ?? ''} • ${hr['employeeId'] ?? 'No ID'}',
                                                                  ),
                                                                  onTap: () {
                                                                    setState(() {
                                                                      _selectedHrUid =
                                                                          hr['uid'];
                                                                      _hrSearchController
                                                                              .text =
                                                                          hr['name'] ??
                                                                          '';
                                                                      _showHrDropdown =
                                                                          false;
                                                                      _hrContactController
                                                                              .text =
                                                                          '${hr['name']} <${hr['email']}>';
                                                                    });
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Error: $e'),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Multi-Signature Selection
                      MultiSignatureSelection(
                        letterType: _selectedLetterType,
                        selectedSignatureIds: _selectedSignatureIds,
                        onSignaturesChanged: (signatureIds) {
                          setState(() {
                            _selectedSignatureIds = signatureIds;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Display selected signatories' details
                      if (_selectedSignatureIds.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Signatories',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._selectedSignatureIds.map((sigId) {
                              final sig = _availableSignatures.firstWhere(
                                (s) => s.id == sigId,
                                orElse:
                                    () => Signature(
                                      id: sigId,
                                      ownerUid: '',
                                      ownerName: 'Unknown',
                                      imagePath: '',
                                      requiresApproval: false,
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                    ),
                              );
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: FutureBuilder<String>(
                                    future: SupabaseService().getSignedUrl(
                                      sig.imagePath,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      }

                                      if (snapshot.hasError ||
                                          !snapshot.hasData) {
                                        return const SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.grey,
                                          ),
                                        );
                                      }

                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          snapshot.data!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey,
                                                  ),
                                        ),
                                      );
                                    },
                                  ),
                                  title: Text(sig.ownerName),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (sig.title != null)
                                        Text('Title: ${sig.title}'),
                                      if (sig.department != null)
                                        Text('Department: ${sig.department}'),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      const SizedBox(height: 24),

                      // Generate with AI Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateContent,
                          icon: const Icon(Icons.auto_awesome),
                          label:
                              _isGenerating
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Generate with AI'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Letter Content
                      TextFormField(
                        controller: _contentController,
                        minLines: 6,
                        maxLines: 16,
                        decoration: const InputDecoration(
                          labelText: 'Letter Content *',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 24),

                      // Create Letter Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isCreating ? null : _createLetter,
                          icon: const Icon(Icons.check),
                          label:
                              _isCreating
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Create Letter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

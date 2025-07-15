import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/models/profile_update_request.dart';
import '../../../shared/widgets/common_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late TabController _tabController;

  // Form controllers
  final _displayNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();

  // Current user data
  Map<String, dynamic> _currentUserData = {};
  Map<String, dynamic>? _hiringManager;
  List<ProfileUpdateRequest> _updateRequests = [];

  // Form state
  bool _isLoading = false;
  bool _hasChanges = false;
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  DateTime? _selectedJoiningDate;

  // Read-only fields (cannot be changed by user)
  final Set<String> _readOnlyFields = {
    'employeeId',
    'email',
    'department',
    'designation',
    'position',
    'hiringManagerId',
    'hiringManagerName',
    'reportingManagerId',
    'reportingManagerName',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileData();
    _loadUpdateRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final userData = await _profileService.getCurrentUserProfile();
      final hiringManager = await _profileService.getUserHiringManager(
        FirebaseAuth.instance.currentUser!.uid,
      );

      setState(() {
        _currentUserData = userData;
        _hiringManager = hiringManager;

        // Populate form fields
        _displayNameController.text = userData['displayName'] ?? '';
        _phoneNumberController.text = userData['phoneNumber'] ?? '';
        _addressController.text = userData['address'] ?? '';
        _emergencyContactNameController.text =
            userData['emergencyContactName'] ?? '';
        _emergencyContactPhoneController.text =
            userData['emergencyContactPhone'] ?? '';

        _selectedGender = userData['gender'] as String?;

        if (userData['dateOfBirth'] != null) {
          _selectedDateOfBirth = DateTime.parse(userData['dateOfBirth']);
        }

        if (userData['joiningDate'] != null) {
          _selectedJoiningDate = DateTime.parse(userData['joiningDate']);
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load profile data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUpdateRequests() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _profileService.getUserProfileUpdateRequests(userId).listen((requests) {
      setState(() {
        _updateRequests = requests;
      });
    });
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = _checkForChanges();
    });
  }

  bool _checkForChanges() {
    final currentData = _getCurrentFormData();

    for (final key in currentData.keys) {
      if (_readOnlyFields.contains(key)) continue;

      final currentValue = _currentUserData[key];
      final newValue = currentData[key];

      if (currentValue != newValue) {
        return true;
      }
    }

    return false;
  }

  Map<String, dynamic> _getCurrentFormData() {
    return {
      'displayName': _displayNameController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'address': _addressController.text.trim(),
      'emergencyContactName': _emergencyContactNameController.text.trim(),
      'emergencyContactPhone': _emergencyContactPhoneController.text.trim(),
      'gender': _selectedGender,
      'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
      'joiningDate': _selectedJoiningDate?.toIso8601String(),
    };
  }

  Future<void> _submitProfileUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasChanges) {
      _showErrorSnackBar('No changes detected');
      return;
    }

    if (_hiringManager == null) {
      _showErrorSnackBar(
        'No hiring manager found. Cannot submit update request.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final proposedChanges = _getCurrentFormData();

      // Remove null values and unchanged fields
      proposedChanges.removeWhere(
        (key, value) => value == null || _currentUserData[key] == value,
      );

      await _profileService.submitProfileUpdateRequest(
        userId: userId,
        currentData: _currentUserData,
        proposedChanges: proposedChanges,
        hiringManagerId: _hiringManager!['id'],
      );

      _showSuccessSnackBar('Profile update request submitted successfully');
      setState(() => _hasChanges = false);
    } catch (e) {
      _showErrorSnackBar('Failed to submit profile update: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelUpdateRequest(String requestId) async {
    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await _profileService.cancelProfileUpdateRequest(requestId, userId);
      _showSuccessSnackBar('Update request cancelled successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to cancel request: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile Information'),
            Tab(text: 'Update Requests'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const LoadingIndicator(message: 'Loading profile...')
              : TabBarView(
                controller: _tabController,
                children: [_buildProfileTab(), _buildRequestsTab()],
              ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReadOnlySection(),
            const SizedBox(height: 24),
            _buildEditableSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Company Information (Read Only)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField('Employee ID', _currentUserData['employeeId']),
            _buildReadOnlyField('Email', _currentUserData['email']),
            _buildReadOnlyField('Department', _currentUserData['department']),
            _buildReadOnlyField(
              'Designation',
              _currentUserData['designation'] ?? _currentUserData['position'],
            ),
            if (_hiringManager != null) ...[
              _buildReadOnlyField('Hiring Manager', _hiringManager!['name']),
            ],
            if (_currentUserData['reportingManagerName'] != null)
              _buildReadOnlyField(
                'Reporting Manager',
                _currentUserData['reportingManagerName'],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Not specified',
              style: TextStyle(
                color: value != null ? Colors.black87 : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Personal Information (Editable)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone number is required';
                }
                return null;
              },
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),
            _buildGenderDropdown(),
            const SizedBox(height: 16),
            _buildDateField(
              label: 'Date of Birth',
              selectedDate: _selectedDateOfBirth,
              onDateSelected: (date) {
                setState(() {
                  _selectedDateOfBirth = date;
                  _onFieldChanged();
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emergencyContactNameController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Emergency contact name is required';
                }
                return null;
              },
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emergencyContactPhoneController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Emergency contact phone is required';
                }
                return null;
              },
              onChanged: (_) => _onFieldChanged(),
            ),
            const SizedBox(height: 16),
            _buildDateField(
              label: 'Joining Date',
              selectedDate: _selectedJoiningDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedJoiningDate = date;
                  _onFieldChanged();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
          _onFieldChanged();
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Gender is required';
        }
        return null;
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate != null
              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
              : 'Select date',
          style: TextStyle(
            color: selectedDate != null ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _hasChanges ? _submitProfileUpdate : null,
        icon: const Icon(Icons.send),
        label: const Text('Submit Update Request'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: _loadUpdateRequests,
      child:
          _updateRequests.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No update requests found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _updateRequests.length,
                itemBuilder: (context, index) {
                  final request = _updateRequests[index];
                  return _buildRequestCard(request);
                },
              ),
    );
  }

  Widget _buildRequestCard(ProfileUpdateRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusChip(request.status),
                const Spacer(),
                Text(
                  '${request.daysSinceRequest} days ago',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Changes Requested:',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...request.getAllChangeDescriptions().map(
              (change) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(child: Text(change)),
                  ],
                ),
              ),
            ),
            if (request.approverComments != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manager Comments:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(request.approverComments!),
                  ],
                ),
              ),
            ],
            if (request.rejectionReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rejection Reason:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.rejectionReason!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ],
                ),
              ),
            ],
            if (request.canBeCancelled) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _cancelUpdateRequest(request.id),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text(
                    'Cancel Request',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProfileUpdateStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ProfileUpdateStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.pending;
        break;
      case ProfileUpdateStatus.approved:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
        break;
      case ProfileUpdateStatus.rejected:
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.cancel;
        break;
      case ProfileUpdateStatus.cancelled:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        icon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

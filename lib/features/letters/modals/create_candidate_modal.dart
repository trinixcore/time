import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/candidate_model.dart';
import '../providers/candidate_providers.dart';
import '../../../shared/providers/auth_providers.dart';

class CreateCandidateModal extends ConsumerStatefulWidget {
  final Candidate? candidate;
  const CreateCandidateModal({super.key, this.candidate});

  @override
  ConsumerState<CreateCandidateModal> createState() =>
      _CreateCandidateModalState();
}

class _CreateCandidateModalState extends ConsumerState<CreateCandidateModal> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salaryController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  String _selectedEmploymentType = 'Full-time';
  String _selectedWorkLocation = 'Office';
  String? _selectedDepartment;
  String? _selectedDesignation;
  DateTime? _expectedJoiningDate;
  bool _isLoading = false;

  // Data from system_data collection
  List<String> _departments = [];
  List<String> _designations = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadSystemData();
    if (widget.candidate != null) {
      final c = widget.candidate!;
      _firstNameController.text = c.firstName;
      _lastNameController.text = c.lastName;
      _emailController.text = c.email;
      _phoneController.text = c.phoneNumber;
      _salaryController.text = c.offeredSalary?.toString() ?? '';
      _selectedEmploymentType = c.employmentType ?? 'Full-time';
      _selectedWorkLocation = c.workLocation ?? 'Office';
      _selectedDepartment = c.department;
      _selectedDesignation = c.designation;
      _expectedJoiningDate = c.expectedJoiningDate;
      _addressController.text = c.address ?? '';
      _cityController.text = c.city ?? '';
      _stateController.text = c.state ?? '';
      _zipController.text = c.postalCode ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _loadSystemData() async {
    try {
      final authService = ref.read(authServiceProvider);
      final departments = await authService.getDepartments();
      final designations = await authService.getDesignations();

      if (mounted) {
        setState(() {
          _departments = departments;
          _designations = designations;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading departments and designations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextCandidateIdAsync = ref.watch(nextCandidateIdProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.candidate != null
                      ? 'Edit Candidate'
                      : 'Add New Candidate',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Form
          Expanded(
            child:
                _isLoadingData
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Candidate ID
                            nextCandidateIdAsync.when(
                              data:
                                  (candidateId) => Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.badge,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Candidate ID: $candidateId',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              loading:
                                  () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              error: (error, stack) => Text('Error: $error'),
                            ),
                            const SizedBox(height: 20),

                            // Personal Information
                            Text(
                              'Personal Information',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'First Name *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'First name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lastNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Last Name *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Last name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Email *',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Phone Number *',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Phone number is required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Address Information
                            Text(
                              'Address Information',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _cityController,
                                    decoration: const InputDecoration(
                                      labelText: 'City',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _stateController,
                                    decoration: const InputDecoration(
                                      labelText: 'State',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _zipController,
                                    decoration: const InputDecoration(
                                      labelText: 'ZIP Code',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Employment Information
                            Text(
                              'Employment Information',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedDepartment,
                                    decoration: const InputDecoration(
                                      labelText: 'Department',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Select Department'),
                                      ),
                                      ..._departments.map(
                                        (dept) => DropdownMenuItem<String>(
                                          value: dept,
                                          child: Text(dept),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDepartment = value;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedDesignation,
                                    decoration: const InputDecoration(
                                      labelText: 'Designation',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Select Designation'),
                                      ),
                                      ..._designations.map(
                                        (designation) =>
                                            DropdownMenuItem<String>(
                                              value: designation,
                                              child: Text(designation),
                                            ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedDesignation = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _salaryController,
                                    decoration: const InputDecoration(
                                      labelText: 'Offered Salary',
                                      border: OutlineInputBorder(),
                                      prefixText: '\$',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedEmploymentType,
                                    decoration: const InputDecoration(
                                      labelText: 'Employment Type',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Full-time',
                                        child: Text('Full-time'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Part-time',
                                        child: Text('Part-time'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Contract',
                                        child: Text('Contract'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Intern',
                                        child: Text('Intern'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedEmploymentType = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedWorkLocation,
                                    decoration: const InputDecoration(
                                      labelText: 'Work Location',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Office',
                                        child: Text('Office'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Remote',
                                        child: Text('Remote'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Hybrid',
                                        child: Text('Hybrid'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedWorkLocation = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Expected Joining Date
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _expectedJoiningDate == null
                                          ? 'Expected Joining Date'
                                          : 'Joining Date: ${_formatDate(_expectedJoiningDate!)}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        color:
                                            _expectedJoiningDate == null
                                                ? Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant
                                                : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _onSubmit,
                                    child:
                                        _isLoading
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : Text(
                                              widget.candidate != null
                                                  ? 'Update'
                                                  : 'Add',
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _expectedJoiningDate) {
      setState(() {
        _expectedJoiningDate = picked;
      });
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final notifier = ref.read(candidateNotifierProvider.notifier);
      final candidate = Candidate(
        id: widget.candidate?.id ?? '',
        candidateId: widget.candidate?.candidateId ?? '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        createdAt: widget.candidate?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.candidate?.createdBy ?? '',
        department: _selectedDepartment,
        designation: _selectedDesignation,
        employmentType: _selectedEmploymentType,
        workLocation: _selectedWorkLocation,
        offeredSalary: double.tryParse(_salaryController.text),
        expectedJoiningDate: _expectedJoiningDate,
        status:
            widget.candidate?.status ??
            'applied', // Preserve existing status or default to 'applied'
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _zipController.text.trim(),
      );
      if (widget.candidate != null) {
        await notifier.updateCandidate(candidate);
      } else {
        await notifier.createCandidate(candidate);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

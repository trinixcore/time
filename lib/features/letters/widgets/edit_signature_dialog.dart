import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/signature_model.dart';
import '../services/signature_service.dart';
import '../providers/signature_providers.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/providers/page_access_providers.dart';
import '../providers/letter_providers.dart';

class EditSignatureDialog extends ConsumerStatefulWidget {
  final Signature signature;

  const EditSignatureDialog({Key? key, required this.signature})
    : super(key: key);

  @override
  ConsumerState<EditSignatureDialog> createState() =>
      _EditSignatureDialogState();
}

class _EditSignatureDialogState extends ConsumerState<EditSignatureDialog> {
  bool _isSaving = false;
  String? _error;

  // Form fields
  final _formKey = GlobalKey<FormState>();
  String? _ownerUid;
  String? _ownerName;
  String? _title;
  String? _department;
  String? _email;
  String? _phoneNumber;
  List<String> _allowedLetterTypes = [];
  bool _requiresApproval = false;
  bool _isActive = true;
  String? _notes;
  Uint8List? _newImageBytes;
  String? _newImageFileName;

  // Controllers for auto-populated fields
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final TextEditingController _userSearchController = TextEditingController();
  String? _selectedUserId;

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

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _initializeForm();
    _userSearchController.addListener(_onUserSearchChanged);
  }

  @override
  void dispose() {
    _userSearchController.dispose();
    _ownerNameController.dispose();
    _titleController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final signature = widget.signature;
    _ownerUid = signature.ownerUid;
    _ownerName = signature.ownerName;
    _title = signature.title;
    _department = signature.department;
    _email = signature.email;
    _phoneNumber = signature.phoneNumber;
    _allowedLetterTypes = List.from(signature.allowedLetterTypes);
    _requiresApproval = signature.requiresApproval;
    _isActive = signature.isActive ?? true;
    _notes = signature.notes;

    _ownerNameController.text = signature.ownerName;
    _titleController.text = signature.title ?? '';
    _departmentController.text = signature.department ?? '';
    _emailController.text = signature.email ?? '';
    _phoneController.text = signature.phoneNumber ?? '';
  }

  Future<void> _loadUsers() async {
    final authService = AuthService();
    final users = await authService.getAllUsers();
    setState(() {
      _allUsers =
          users
              .map(
                (user) => {
                  'uid': user.uid,
                  'name': user.displayName ?? '',
                  'email': user.email,
                  'employeeId': user.employeeId ?? '',
                  'department': user.department ?? '',
                  'phoneNumber': user.phoneNumber ?? '',
                  'title': user.position ?? '',
                },
              )
              .toList();
      _filteredUsers = _allUsers;
    });
  }

  void _onUserSearchChanged() {
    final query = _userSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers =
            _allUsers.where((user) {
              final name = (user['name'] ?? '').toLowerCase();
              final email = (user['email'] ?? '').toLowerCase();
              final empId = (user['employeeId'] ?? '').toLowerCase();
              return name.contains(query) ||
                  email.contains(query) ||
                  empId.contains(query);
            }).toList();
      }
    });
  }

  void _onUserSelected(String? userId) {
    if (userId == null) {
      setState(() {
        _selectedUserId = null;
        _ownerUid = null;
        _ownerName = null;
        _email = null;
        _department = null;
        _phoneNumber = null;
        _title = null;
        _ownerNameController.text = '';
        _titleController.text = '';
        _departmentController.text = '';
        _emailController.text = '';
        _phoneController.text = '';
      });
      return;
    }
    final userList = _allUsers.where((u) => u['uid'] == userId).toList();
    if (userList.isEmpty) {
      setState(() {
        _selectedUserId = null;
        _ownerUid = null;
        _ownerName = null;
        _email = null;
        _department = null;
        _phoneNumber = null;
        _title = null;
        _ownerNameController.text = '';
        _titleController.text = '';
        _departmentController.text = '';
        _emailController.text = '';
        _phoneController.text = '';
      });
      return;
    }
    final user = userList.first;
    setState(() {
      _selectedUserId = userId;
      _ownerUid = user['uid'];
      _ownerName = user['name'];
      _email = user['email'];
      _department = user['department'];
      _phoneNumber = user['phoneNumber'];
      _title = user['title'];
      _ownerNameController.text = user['name'] ?? '';
      _titleController.text = user['title'] ?? '';
      _departmentController.text = user['department'] ?? '';
      _emailController.text = user['email'] ?? '';
      _phoneController.text = user['phoneNumber'] ?? '';
    });
  }

  Future<void> _pickNewImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _newImageBytes = result.files.single.bytes;
        _newImageFileName = result.files.single.name;
      });
    }
  }

  Future<void> _saveSignature() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final signatureService = ref.read(signatureServiceProvider);
      await signatureService.updateSignatureAuthority(
        signatureId: widget.signature.id,
        ownerUid: _ownerUid!,
        ownerName: _ownerName!,
        allowedLetterTypes: _allowedLetterTypes,
        title: _title,
        department: _department,
        email: _email,
        phoneNumber: _phoneNumber,
        requiresApproval: _requiresApproval,
        isActive: _isActive,
        notes: _notes,
        newImageBytes: _newImageBytes,
        newImageFileName: _newImageFileName,
      );

      // Invalidate signature cache to refresh the list
      ref.read(signatureRefreshProvider.notifier).state++;

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEditSignatures = ref.watch(canEditSignaturesProvider);

    return canEditSignatures.when(
      data: (canEdit) {
        if (!canEdit) {
          return AlertDialog(
            title: const Text('Permission Denied'),
            content: const Text(
              'You do not have permission to edit signatures.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        }

        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildUserSelection(),
                          const SizedBox(height: 16),
                          _buildAutoPopulatedFields(),
                          const SizedBox(height: 16),
                          _buildLetterTypesSelection(),
                          const SizedBox(height: 16),
                          _buildOptions(),
                          const SizedBox(height: 16),
                          _buildImageSection(),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                _buildActions(),
              ],
            ),
          ),
        );
      },
      loading:
          () => const AlertDialog(
            content: Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stack) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to check permissions: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Signature Authority',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Update signature details and permissions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Selection',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _userSearchController,
          decoration: const InputDecoration(
            labelText: 'Search user',
            hintText: 'Type name, email, or employee ID',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedUserId,
          decoration: const InputDecoration(
            labelText: 'Select User (Owner UID)',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Select a user'),
            ),
            ..._filteredUsers.map((user) {
              return DropdownMenuItem<String>(
                value: user['uid'],
                child: Text(
                  '${user['name']} (${user['employeeId']})',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ],
          onChanged: _onUserSelected,
        ),
      ],
    );
  }

  Widget _buildAutoPopulatedFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signature Details',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Owner Name'),
                controller: _ownerNameController,
                enabled: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                controller: _titleController,
                enabled: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Department'),
                controller: _departmentController,
                enabled: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                controller: _emailController,
                enabled: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Phone Number'),
          controller: _phoneController,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildLetterTypesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Allowed Letter Types:',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              _letterTypes.map((type) {
                return FilterChip(
                  label: Text(type),
                  selected: _allowedLetterTypes.contains(type),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _allowedLetterTypes.add(type);
                      } else {
                        _allowedLetterTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _requiresApproval,
              onChanged: (v) => setState(() => _requiresApproval = v ?? false),
            ),
            const Text('Requires Approval'),
            const SizedBox(width: 32),
            Checkbox(
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v ?? true),
            ),
            const Text('Active'),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          initialValue: _notes,
          onChanged: (v) => _notes = v,
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signature Image',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload New Image'),
              onPressed: _pickNewImage,
            ),
            if (_newImageFileName != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _newImageFileName!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        if (_newImageFileName == null) ...[
          const SizedBox(height: 8),
          Text(
            'Current image will be retained if no new image is uploaded',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveSignature,
            child:
                _isSaving
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

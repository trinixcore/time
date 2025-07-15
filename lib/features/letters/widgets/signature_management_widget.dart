import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/signature_model.dart';
import '../providers/letter_providers.dart';
import '../providers/signature_providers.dart';
import '../services/signature_service.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/providers/page_access_providers.dart';
import 'edit_signature_dialog.dart';

class SignatureManagementWidget extends ConsumerStatefulWidget {
  const SignatureManagementWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<SignatureManagementWidget> createState() =>
      _SignatureManagementWidgetState();
}

class _SignatureManagementWidgetState
    extends ConsumerState<SignatureManagementWidget> {
  bool _isAdding = false;
  bool _isUploading = false;
  String? _error;

  // Add Signature form fields
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
  Uint8List? _imageBytes;
  String? _imageFileName;

  // Add controllers for auto-populated fields
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

  void _resetForm() {
    _formKey.currentState?.reset();
    _ownerUid = null;
    _ownerName = null;
    _title = null;
    _department = null;
    _email = null;
    _phoneNumber = null;
    _allowedLetterTypes = [];
    _requiresApproval = false;
    _isActive = true;
    _notes = null;
    _imageBytes = null;
    _imageFileName = null;
    _error = null;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _imageFileName = result.files.single.name;
      });
    }
  }

  Future<void> _addSignature(BuildContext context) async {
    if (!_formKey.currentState!.validate() || _imageBytes == null) return;
    setState(() {
      _isUploading = true;
      _error = null;
    });
    try {
      final service = ref.read(signatureServiceProvider);
      await service.addSignatureAuthority(
        ownerUid: _ownerUid!,
        ownerName: _ownerName!,
        imageBytes: _imageBytes!,
        imageFileName: _imageFileName!,
        allowedLetterTypes: _allowedLetterTypes,
        title: _title,
        department: _department,
        email: _email,
        phoneNumber: _phoneNumber,
        requiresApproval: _requiresApproval,
        isActive: _isActive,
        notes: _notes,
      );
      _resetForm();
      setState(() {
        _isAdding = false;
      });
      // Invalidate signature cache to refresh the list
      ref.read(signatureRefreshProvider.notifier).state++;
      ref.invalidate(allSignaturesProvider);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _editSignature(Signature signature) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => EditSignatureDialog(signature: signature),
    );

    if (result == true) {
      // Invalidate signature cache to refresh the list
      ref.read(signatureRefreshProvider.notifier).state++;
      ref.invalidate(allSignaturesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Signature updated successfully!')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteSignature(Signature signature) async {
    final canDeleteSignatures = ref.read(canDeleteSignaturesProvider);

    final canDelete = await canDeleteSignatures.when(
      data: (canDelete) => canDelete,
      loading: () => false,
      error: (_, __) => false,
    );

    if (!canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to delete signatures.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete the signature for "${signature.ownerName}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await ref.read(signatureServiceProvider).deleteSignature(signature.id);
        // Invalidate signature cache to refresh the list
        ref.read(signatureRefreshProvider.notifier).state++;
        ref.invalidate(allSignaturesProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text('Signature deleted successfully!')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete signature: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signaturesAsync = ref.watch(allSignaturesProvider);
    final canManageSignatures = ref.watch(canManageSignaturesProvider);
    final canAddSignatures = ref.watch(canAddSignaturesProvider);
    final canEditSignatures = ref.watch(canEditSignaturesProvider);
    final canDeleteSignatures = ref.watch(canDeleteSignaturesProvider);

    return canManageSignatures.when(
      data: (canManage) {
        if (!canManage) {
          return const Center(
            child: Text('You do not have permission to manage signatures.'),
          );
        }

        return canAddSignatures.when(
          data: (canAdd) {
            return canEditSignatures.when(
              data: (canEdit) {
                return canDeleteSignatures.when(
                  data: (canDelete) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Signature Authorities',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (canAdd)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Signature'),
                                  onPressed: () {
                                    setState(() {
                                      _isAdding = true;
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          signaturesAsync.when(
                            data: (signatures) {
                              if (signatures.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No signature authorities found.',
                                  ),
                                );
                              }
                              return SizedBox(
                                height: 200,
                                child: ListView.builder(
                                  itemCount: signatures.length,
                                  itemBuilder: (context, index) {
                                    final signature = signatures[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: ListTile(
                                        leading: FutureBuilder<String>(
                                          future: SupabaseService()
                                              .getSignedUrl(
                                                signature.imagePath,
                                              ),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            }
                                            if (snapshot.hasError) {
                                              return const SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                              );
                                            }
                                            return SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Image.network(
                                                  snapshot.data!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey,
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        title: Text(signature.ownerName),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (signature.title != null)
                                              Text('Title: ${signature.title}'),
                                            if (signature.department != null)
                                              Text(
                                                'Department: ${signature.department}',
                                              ),
                                            Text(
                                              'Letter Types: ${signature.allowedLetterTypes.join(', ')}',
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Switch(
                                              value:
                                                  signature.isActive ?? false,
                                              onChanged: (value) async {
                                                try {
                                                  await ref
                                                      .read(
                                                        signatureServiceProvider,
                                                      )
                                                      .setSignatureActive(
                                                        signature.id,
                                                        value,
                                                      );
                                                  ref.invalidate(
                                                    allSignaturesProvider,
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Failed to update signature: $e',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                            if (canEdit) ...[
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed:
                                                    () => _editSignature(
                                                      signature,
                                                    ),
                                                tooltip: 'Edit Signature',
                                              ),
                                            ],
                                            if (canDelete) ...[
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed:
                                                    () => _deleteSignature(
                                                      signature,
                                                    ),
                                                tooltip: 'Delete Signature',
                                                color: Colors.red,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            loading:
                                () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            error:
                                (error, stack) =>
                                    Center(child: Text('Error: $error')),
                          ),
                          if (_isAdding && canAdd) ...[
                            const Divider(),
                            Text(
                              'Add Signature Authority',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User search and dropdown
                                  TextFormField(
                                    controller: _userSearchController,
                                    decoration: const InputDecoration(
                                      labelText: 'Search user',
                                      hintText:
                                          'Type name, email, or employee ID',
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
                                  const SizedBox(height: 16),
                                  // Auto-populated fields
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Owner Name',
                                          ),
                                          controller: _ownerNameController,
                                          enabled: false,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Title',
                                          ),
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
                                          decoration: const InputDecoration(
                                            labelText: 'Department',
                                          ),
                                          controller: _departmentController,
                                          enabled: false,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                          ),
                                          controller: _emailController,
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
                                          decoration: const InputDecoration(
                                            labelText: 'Phone Number',
                                          ),
                                          controller: _phoneController,
                                          enabled: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Allowed Letter Types:',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children:
                                        _letterTypes.map((type) {
                                          return FilterChip(
                                            label: Text(type),
                                            selected: _allowedLetterTypes
                                                .contains(type),
                                            onSelected: (selected) {
                                              setState(() {
                                                if (selected) {
                                                  _allowedLetterTypes.add(type);
                                                } else {
                                                  _allowedLetterTypes.remove(
                                                    type,
                                                  );
                                                }
                                              });
                                            },
                                          );
                                        }).toList(),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _requiresApproval,
                                        onChanged:
                                            (v) => setState(
                                              () =>
                                                  _requiresApproval =
                                                      v ?? false,
                                            ),
                                      ),
                                      const Text('Requires Approval'),
                                      const SizedBox(width: 32),
                                      Checkbox(
                                        value: _isActive,
                                        onChanged:
                                            (v) => setState(
                                              () => _isActive = v ?? true,
                                            ),
                                      ),
                                      const Text('Active'),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Notes',
                                    ),
                                    onChanged: (v) => _notes = v,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.upload_file),
                                        label: const Text(
                                          'Upload Signature Image',
                                        ),
                                        onPressed: _pickImage,
                                      ),
                                      if (_imageFileName != null) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _imageFileName!,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (_error != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      _error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed:
                                            _isUploading
                                                ? null
                                                : () => _addSignature(context),
                                        child:
                                            _isUploading
                                                ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                                : const Text('Add'),
                                      ),
                                      const SizedBox(width: 16),
                                      TextButton(
                                        onPressed:
                                            _isUploading
                                                ? null
                                                : () {
                                                  setState(() {
                                                    _isAdding = false;
                                                    _resetForm();
                                                  });
                                                },
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

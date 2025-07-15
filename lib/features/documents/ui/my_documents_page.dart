import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/employee_folder_service.dart';
import '../../../core/services/permission_management_service.dart';
import '../../../core/enums/document_enums.dart';
import '../../../core/enums/user_role.dart';
import '../../../shared/providers/auth_providers.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../../../shared/widgets/custom_loader.dart';
import '../widgets/employee_folder_card.dart';
import '../widgets/upload_document_dialog.dart';
import '../widgets/employee_upload_dialog.dart';
import '../../../core/providers/permission_providers.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../core/utils/logger.dart';

class MyDocumentsPage extends ConsumerStatefulWidget {
  const MyDocumentsPage({super.key});

  @override
  ConsumerState<MyDocumentsPage> createState() => _MyDocumentsPageState();
}

class _MyDocumentsPageState extends ConsumerState<MyDocumentsPage> {
  final EmployeeFolderService _folderService = EmployeeFolderService();
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _folders = [];
  Map<String, dynamic>? _folderStructure;

  // View As feature state
  String? _selectedEmployeeId; // null means viewing own documents
  List<Map<String, dynamic>> _employeesForViewAs = [];
  bool _loadingEmployees = false;
  Map<String, dynamic>? _selectedEmployeeData;

  @override
  void initState() {
    super.initState();
    _loadEmployeeFolders();
    _loadEmployeesForViewAs();
  }

  Future<void> _loadEmployeeFolders() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final currentUser = ref.read(currentUserProvider).value;

      // Determine which employee's folders to load
      String? targetEmployeeId;
      String? targetEmployeeName;
      String? targetEmployeeUid;

      if (_selectedEmployeeId != null && _selectedEmployeeData != null) {
        // Viewing another employee's documents
        targetEmployeeId = _selectedEmployeeData!['employeeId'] as String?;
        targetEmployeeName = _selectedEmployeeData!['displayName'] as String?;
        targetEmployeeUid = _selectedEmployeeData!['uid'] as String?;
      } else {
        // Viewing own documents
        targetEmployeeId = currentUser?.employeeId;
        targetEmployeeName = currentUser?.displayName;
        targetEmployeeUid = currentUser?.uid;
      }

      if (targetEmployeeId == null || targetEmployeeUid == null) {
        throw Exception('Employee ID not found');
      }

      // Check or create employee folder structure
      final folderStructure = await _folderService.checkOrCreateEmployeeFolder(
        employeeId: targetEmployeeId,
        fullName: targetEmployeeName ?? 'Unknown User',
        userId: targetEmployeeUid,
        currentUserId: currentUser?.uid ?? '',
        currentUserName: currentUser?.displayName ?? 'Unknown User',
      );

      // Load folder contents from Firestore
      final folders = await _folderService.getEmployeeFolderContents(
        targetEmployeeId,
      );

      // If no folders in Firestore, create default structure from template
      List<Map<String, dynamic>> allFolders = folders;
      if (folders.isEmpty) {
        allFolders =
            EmployeeFolderService.folderStructureTemplate
                .map(
                  (template) => {
                    'id': '${targetEmployeeId}_${template['code']}',
                    'name': '${template['code']}_${template['name']}',
                    'path':
                        'employees/${targetEmployeeId}_${targetEmployeeName?.replaceAll(' ', '_')}/${template['code']}_${template['name']}',
                    'description': template['description'],
                    'documentCount': 0,
                    'metadata': {
                      'employeeId': targetEmployeeId,
                      'folderCode': template['code'],
                      'folderType': 'employee-document',
                      'autoCreated': true,
                    },
                  },
                )
                .toList();
      }

      // Filter folders based on user permissions
      final permissionService = PermissionManagementService();
      final isViewingOwnDocuments = currentUser?.employeeId == targetEmployeeId;

      List<Map<String, dynamic>> filteredFolders = [];

      // Get the permission config for the current user's role
      final permissionConfig = await permissionService.getPermissionConfig(
        currentUser!.role,
      );

      AppLogger.folderFilter(
        'Checking permissions for ${allFolders.length} folders',
      );
      AppLogger.info('USER', 'Current user role: ${currentUser.role.value}');
      AppLogger.info('USER', 'Viewing own documents: $isViewingOwnDocuments');

      for (final folder in allFolders) {
        final folderPath = folder['path'] as String;
        final folderInfo = permissionService.extractFolderInfo(folderPath);

        bool hasAccess = false;

        if (isViewingOwnDocuments) {
          // Users always have view access to their own documents
          hasAccess = true;
          AppLogger.folderFilterSuccess(
            'User has default access to own folder: ${folder['name']}',
          );
        } else if (folderInfo != null) {
          // When viewing other employee's documents, strictly check folder-specific permissions
          final folderKey = '${folderInfo['code']}_${folderInfo['name']}';

          if (permissionConfig != null) {
            // Use folder-specific permission from admin settings
            hasAccess =
                permissionConfig
                    .documentConfig
                    .employeeFolderViewPermissions[folderKey] ??
                false;
            AppLogger.folderFilter(
              'Using admin settings for ${folderKey}: $hasAccess',
            );
          } else {
            // If no permission config found, deny access
            hasAccess = false;
            AppLogger.folderFilterError(
              'No permission config found for folder: ${folderKey}',
            );
          }
        }

        if (hasAccess) {
          filteredFolders.add(folder);
          AppLogger.folderFilterSuccess('Added folder: ${folder['name']}');
        } else {
          AppLogger.folderFilterError('Filtered out folder: ${folder['name']}');
        }
      }

      AppLogger.folderFilterSuccess(
        'Showing ${filteredFolders.length} out of ${allFolders.length} folders',
      );

      // Calculate actual document counts for accessible folders
      for (final folder in filteredFolders) {
        final folderPath = folder['path'] as String;
        final documentCount = await _getDocumentCountForFolder(folderPath);
        folder['documentCount'] = documentCount;
      }

      setState(() {
        _folderStructure = folderStructure;
        _folders = filteredFolders;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.folderFilterError('Error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<int> _getDocumentCountForFolder(String folderPath) async {
    try {
      // Get current user for permission checking
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        AppLogger.docCountError('User not authenticated');
        return 0;
      }

      AppLogger.docCount('Calculating count for folder: $folderPath');
      AppLogger.docCount('User role: ${currentUser.role.value}');

      // Get dynamic permissions for the current user
      final permissionService = PermissionManagementService();
      final permissions = await permissionService.getEffectivePermissionsAsync(
        currentUser.role,
      );

      AppLogger.docCount(
        'User permissions: canViewAll=${permissions.canViewAll}',
      );

      // Start with base query
      Query<Map<String, dynamic>> query = _firebaseService.firestore.collection(
        'documents',
      );

      // If user doesn't have canViewAll permission, filter by category
      if (!permissions.canViewAll) {
        // Check if user can access employee category
        if (!permissions.accessibleCategories.contains(
          DocumentCategory.employee,
        )) {
          AppLogger.docCountError('User cannot access employee documents');
          return 0;
        }

        // Filter by employee category only
        query = query.where('category', isEqualTo: 'employee');
        AppLogger.docCount('Filtering by employee category only');
      } else {
        AppLogger.docCountSuccess(
          'User has canViewAll - counting all documents',
        );
      }

      final querySnapshot = await query.get();
      AppLogger.docCount(
        'Found ${querySnapshot.docs.length} total documents to check',
      );

      int count = 0;
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final supabasePath = data['supabasePath'] as String?;

        if (supabasePath != null && supabasePath.startsWith(folderPath)) {
          // Check if document is directly in this folder (not in a subfolder)
          final relativePath = supabasePath.substring(folderPath.length);
          if (relativePath.startsWith('/') &&
              relativePath.substring(1).split('/').length == 1) {
            // For users without canViewAll, do additional access checks
            if (!permissions.canViewAll) {
              // Check if user has access to this specific document
              final accessRoles = List<String>.from(data['accessRoles'] ?? []);
              final accessUserIds = List<String>.from(
                data['accessUserIds'] ?? [],
              );

              // Check if user has access based on role or user ID
              bool hasAccess = false;

              // Check role-based access
              if (accessRoles.contains(currentUser.role.value) ||
                  accessRoles.contains('all') ||
                  accessRoles.isEmpty) {
                hasAccess = true;
              }

              // Check user-specific access
              if (accessUserIds.contains(currentUser.uid) ||
                  accessUserIds.isEmpty) {
                hasAccess = true;
              }

              // Check if it's the user's own employee folder
              if (supabasePath.contains(currentUser.employeeId ?? '')) {
                hasAccess = true;
              }

              if (!hasAccess) {
                continue; // Skip this document
              }
            }

            count++;
          }
        }
      }

      AppLogger.docCountSuccess('Final count for folder $folderPath: $count');
      return count;
    } catch (e) {
      AppLogger.docCountError(
        'Error getting document count for folder $folderPath: $e',
      );
      return 0;
    }
  }

  Future<void> _loadEmployeesForViewAs() async {
    final canViewAsOthers = await ref.read(canViewAsEmployeeProvider.future);

    if (!canViewAsOthers) return;

    setState(() {
      _loadingEmployees = true;
    });

    try {
      final employees = await _authService.getActiveUsersForSelection();
      setState(() {
        _employeesForViewAs =
            employees
                .where(
                  (emp) =>
                      emp['employeeId'] != null && emp['employeeId'].isNotEmpty,
                )
                .toList();
        _loadingEmployees = false;
      });
    } catch (e) {
      AppLogger.error('EMPLOYEE', 'Error loading employees for View As: $e');
      setState(() {
        _loadingEmployees = false;
      });
    }
  }

  Future<void> _changeViewAsEmployee(String? employeeUid) async {
    // Handle special cases
    if (employeeUid == '__search__') {
      _showEmployeeSearchDialog();
      return;
    }

    if (employeeUid == '__manual__') {
      _showManualEmployeeIdDialog();
      return;
    }

    setState(() {
      _selectedEmployeeId = employeeUid;
      if (employeeUid != null) {
        _selectedEmployeeData = _employeesForViewAs.firstWhere(
          (emp) => emp['uid'] == employeeUid,
          orElse: () => {},
        );
      } else {
        _selectedEmployeeData = null;
      }
    });

    // Reload folders for the selected employee
    await _loadEmployeeFolders();
  }

  void _showEmployeeSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _EmployeeSearchDialog(
            employees: _employeesForViewAs,
            onEmployeeSelected: (employee) {
              Navigator.of(context).pop();
              _changeViewAsEmployee(employee['uid']);
            },
          ),
    );
  }

  void _showManualEmployeeIdDialog() {
    showDialog(
      context: context,
      builder:
          (context) => _ManualEmployeeIdDialog(
            onEmployeeIdEntered: (employeeId) async {
              Navigator.of(context).pop();
              await _findAndSelectEmployeeById(employeeId);
            },
          ),
    );
  }

  Future<void> _findAndSelectEmployeeById(String employeeId) async {
    // First, try to find in current employees list
    final employee =
        _employeesForViewAs
            .where(
              (emp) =>
                  emp['employeeId']?.toString().toLowerCase() ==
                  employeeId.toLowerCase(),
            )
            .firstOrNull;

    if (employee != null) {
      await _changeViewAsEmployee(employee['uid']);
      return;
    }

    // If not found, try to fetch from server
    try {
      final allEmployees = await _authService.getActiveUsersForSelection();
      final foundEmployee =
          allEmployees
              .where(
                (emp) =>
                    emp['employeeId']?.toString().toLowerCase() ==
                    employeeId.toLowerCase(),
              )
              .firstOrNull;

      if (foundEmployee != null) {
        // Add to employees list if not already there
        if (!_employeesForViewAs.any(
          (emp) => emp['uid'] == foundEmployee['uid'],
        )) {
          setState(() {
            _employeesForViewAs.add(foundEmployee);
          });
        }
        await _changeViewAsEmployee(foundEmployee['uid']);
      } else {
        // Show error dialog
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Employee Not Found'),
                  content: Text('No employee found with ID: $employeeId'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      }
    } catch (e) {
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to search for employee: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    return DashboardScaffold(
      currentPath: '/my-documents',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedEmployeeId != null
                        ? '👁️ Viewing Documents'
                        : '📁 My Documents',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                // Upload to Employee Button - Always use main user's permissions
                Consumer(
                  builder: (context, ref, child) {
                    final currentUserAsync = ref.watch(currentUserProvider);

                    return currentUserAsync.when(
                      data: (mainUser) {
                        if (mainUser == null) return const SizedBox.shrink();

                        // Always check main user's permissions, not the viewed employee's
                        final canUploadToEmployee = ref
                            .watch(permissionConfigProvider(mainUser.role))
                            .when(
                              data:
                                  (config) =>
                                      config
                                          ?.documentConfig
                                          .canUploadToEmployeeDocuments ??
                                      false,
                              loading: () => false,
                              error: (_, __) => false,
                            );

                        if (!canUploadToEmployee)
                          return const SizedBox.shrink();

                        return Container(
                          constraints: const BoxConstraints(maxWidth: 200),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.secondary,
                                theme.colorScheme.secondary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.secondary.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => const EmployeeUploadDialog(),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      color: theme.colorScheme.onSecondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Upload to Employee',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onSecondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (error, stack) => const SizedBox.shrink(),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _loadEmployeeFolders();
                    _loadEmployeesForViewAs();
                  },
                  icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
                  tooltip: 'Refresh folders',
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Subtitle with user info
            currentUser.when(
              data: (user) {
                if (_selectedEmployeeId != null &&
                    _selectedEmployeeData != null) {
                  // Viewing another employee's documents
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Viewing documents for: ${_selectedEmployeeData!['name'] ?? _selectedEmployeeData!['displayName'] ?? 'Unknown User'}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Employee ID: ${_selectedEmployeeData!['employeeId'] ?? 'N/A'} • ${_selectedEmployeeData!['department'] ?? 'No Department'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                } else if (user != null) {
                  // Viewing own documents
                  return Text(
                    'Employee ID: ${user.employeeId ?? 'N/A'} • ${user.displayName ?? 'Unknown User'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // View As Section - Now separate from header to avoid overflow
            currentUser.when(
              data: (user) {
                return ref
                    .watch(canViewAsEmployeeProvider)
                    .when(
                      data: (canViewAsOthers) {
                        if (canViewAsOthers) {
                          return _buildViewAsSection();
                        }
                        return const SizedBox.shrink();
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Content
            Expanded(child: _buildContent(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CustomLoader(message: 'Loading your documents...', size: 80),
      );
    }

    if (_hasError) {
      return _buildErrorWidget(theme);
    }

    if (_folders.isEmpty) {
      return _buildEmptyState(theme);
    }

    return _buildFolderGrid(theme);
  }

  Widget _buildErrorWidget(ThemeData theme) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load documents',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Unknown error occurred',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadEmployeeFolders,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_open_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Setting up your document folders...',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your personal document folders are being created. Please refresh the page.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadEmployeeFolders,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderGrid(ThemeData theme) {
    final currentUser = ref.read(currentUserProvider).value;
    final isReadOnly =
        currentUser?.role.isEmployee == true ||
        currentUser?.role.isSeniorEmployee == true ||
        currentUser?.role.isContractor == true ||
        currentUser?.role.isIntern == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid columns based on screen width
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 1; // Mobile: 1 column
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 2; // Tablet: 2 columns
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 3; // Small desktop: 3 columns
        } else {
          crossAxisCount = 4; // Large desktop: 4 columns
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _folders.length,
          itemBuilder: (context, index) {
            final folder = _folders[index];
            return EmployeeFolderCard(
              folder: folder,
              onTap: () => _openFolder(folder),
              onUpload: () => _uploadToFolder(folder),
              readOnly: isReadOnly,
            );
          },
        );
      },
    );
  }

  void _openFolder(Map<String, dynamic> folder) {
    final folderPath = folder['path'] as String?;
    final folderName = folder['name'] as String?;

    if (folderPath != null && folderName != null) {
      // Navigate to folder contents
      context.push('/my-documents/folder/${Uri.encodeComponent(folderPath)}');
    }
  }

  void _uploadToFolder(Map<String, dynamic> folder) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    // Extract folder info for permission checking
    final folderPath = folder['path'] as String;
    final permissionService = PermissionManagementService();

    try {
      // Extract folder code and name from path
      final folderInfo = permissionService.extractFolderInfo(folderPath);

      bool canUpload = false;

      if (folderInfo != null) {
        // Check folder-specific upload permission
        canUpload = await permissionService.canUploadToEmployeeFolder(
          currentUser.role,
          folderInfo['code']!,
          folderInfo['name']!,
        );

        //print(
        //  '🔍 [UPLOAD PERMISSION] Folder: ${folderInfo['code']}_${folderInfo['name']}, Can Upload: $canUpload',
        //);
      } else {
        // Fallback to category-level permission check
        final permissions = await permissionService
            .getEffectivePermissionsAsync(currentUser.role);
        canUpload = permissions.uploadableCategories.contains(
          DocumentCategory.employee,
        );

        //print(
        //  '🔍 [UPLOAD PERMISSION] Using category-level check, Can Upload: $canUpload',
        //);
      }

      if (!canUpload) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You do not have permission to upload documents to this folder',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Proceed with upload
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const EmployeeUploadDialog(),
      );

      if (result == true) {
        // Refresh the folder list
        _loadEmployeeFolders();
      }
    } catch (e) {
      AppLogger.uploadError('Error checking permissions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error checking permissions. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildViewAsSection() {
    final currentUser = ref.watch(currentUserProvider).value;

    // Use dynamic permission checking for "View As" feature
    return Consumer(
      builder: (context, ref, child) {
        final canManageEmployeesAsync = ref.watch(canViewAsEmployeeProvider);

        return canManageEmployeesAsync.when(
          data: (canManageEmployees) {
            if (!canManageEmployees) {
              return const SizedBox.shrink(); // Hide if no permission
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'View As Employee',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedEmployeeData != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              _selectedEmployeeData!['name']
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'E',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedEmployeeData!['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'ID: ${_selectedEmployeeData!['employeeId'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedEmployeeId = null;
                                _selectedEmployeeData = null;
                              });
                              _loadEmployeeFolders();
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: PopupMenuButton<String>(
                      key: ValueKey(
                        'view_as_dropdown_${DateTime.now().millisecondsSinceEpoch}',
                      ), // Force rebuild with unique key
                      onSelected: (value) async {
                        if (value == 'search') {
                          _showEmployeeSearchDialog();
                        } else if (value == 'manual') {
                          _showManualEmployeeIdDialog();
                        } else {
                          // Handle employee selection from dropdown
                          final employee = _employeesForViewAs.firstWhere(
                            (emp) => emp['employeeId'] == value,
                            orElse: () => {},
                          );
                          if (employee.isNotEmpty) {
                            await _changeViewAsEmployee(employee['uid']);
                          }
                        }
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'search',
                              child: Row(
                                children: [
                                  Icon(Icons.search),
                                  SizedBox(width: 8),
                                  Text('Search Employee'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'manual',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Enter Employee ID'),
                                ],
                              ),
                            ),
                            if (_employeesForViewAs.isNotEmpty) ...[
                              const PopupMenuDivider(),
                              ..._employeesForViewAs
                                  .take(10)
                                  .map(
                                    (employee) => PopupMenuItem(
                                      value: employee['employeeId'],
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor:
                                                Colors.blue.shade100,
                                            child: Text(
                                              employee['name']
                                                      ?.substring(0, 1)
                                                      .toUpperCase() ??
                                                  'E',
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  employee['name'] ?? 'Unknown',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  employee['employeeId'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
                          ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedEmployeeData != null
                                  ? 'Change Employee'
                                  : 'Select Employee',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.blue.shade700,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }
}

// Employee Search Dialog Widget
class _EmployeeSearchDialog extends StatefulWidget {
  final List<Map<String, dynamic>> employees;
  final Function(Map<String, dynamic>) onEmployeeSelected;

  const _EmployeeSearchDialog({
    required this.employees,
    required this.onEmployeeSelected,
  });

  @override
  State<_EmployeeSearchDialog> createState() => _EmployeeSearchDialogState();
}

class _EmployeeSearchDialogState extends State<_EmployeeSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _filteredEmployees = widget.employees;
    _searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEmployees =
          widget.employees.where((employee) {
            final name =
                (employee['name'] ?? employee['displayName'] ?? '')
                    .toLowerCase();
            final employeeId = (employee['employeeId'] ?? '').toLowerCase();
            final department = (employee['department'] ?? '').toLowerCase();
            return name.contains(query) ||
                employeeId.contains(query) ||
                department.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.search, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Search Employee',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search field
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name, ID, or department',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),

            const SizedBox(height: 16),

            // Results count
            Text(
              '${_filteredEmployees.length} employee(s) found',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 8),

            // Employee list
            Expanded(
              child:
                  _filteredEmployees.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No employees found',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = _filteredEmployees[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: Text(
                                (employee['name'] ??
                                        employee['displayName'] ??
                                        'U')[0]
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              employee['name'] ??
                                  employee['displayName'] ??
                                  'Unknown User',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'ID: ${employee['employeeId'] ?? 'N/A'} • ${employee['department'] ?? 'No Department'}',
                              style: theme.textTheme.bodySmall,
                            ),
                            onTap: () => widget.onEmployeeSelected(employee),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// Manual Employee ID Dialog Widget
class _ManualEmployeeIdDialog extends StatefulWidget {
  final Function(String) onEmployeeIdEntered;

  const _ManualEmployeeIdDialog({required this.onEmployeeIdEntered});

  @override
  State<_ManualEmployeeIdDialog> createState() =>
      _ManualEmployeeIdDialogState();
}

class _ManualEmployeeIdDialogState extends State<_ManualEmployeeIdDialog> {
  final TextEditingController _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _submitEmployeeId() {
    if (_formKey.currentState!.validate()) {
      widget.onEmployeeIdEntered(_idController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.edit, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Enter Employee ID',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Info text
              Text(
                'Enter the employee ID to view their documents. The system will search for the employee and load their document folders.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),

              // Employee ID field
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  hintText: 'e.g., TRX2025000001',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an employee ID';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submitEmployeeId(),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitEmployeeId,
                    child: const Text('Search'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

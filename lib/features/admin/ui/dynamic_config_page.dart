import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/initialize_config.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../dashboard/ui/dashboard_scaffold.dart';
import '../../../shared/providers/page_access_providers.dart';

/// Dynamic Configuration Management Page - Super Admin Only
class DynamicConfigPage extends ConsumerStatefulWidget {
  const DynamicConfigPage({super.key});

  @override
  ConsumerState<DynamicConfigPage> createState() => _DynamicConfigPageState();
}

class _DynamicConfigPageState extends ConsumerState<DynamicConfigPage> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _currentConfig;
  Map<String, dynamic>? _healthStatus;

  // Form controllers
  final _urlController = TextEditingController();
  final _anonKeyController = TextEditingController();
  final _serviceRoleKeyController = TextEditingController();
  final _previewExpiryController = TextEditingController();
  final _downloadExpiryController = TextEditingController();
  final _taskExpiryController = TextEditingController();
  final _momentsExpiryController = TextEditingController();
  final _uploadExpiryController = TextEditingController();
  final _defaultExpiryController = TextEditingController();
  final _openAiKeyController = TextEditingController();
  bool _obscureOpenAiKey = true;
  DateTime? _openAiKeyLastUpdated;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
    _loadOpenAIApiKey();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _anonKeyController.dispose();
    _serviceRoleKeyController.dispose();
    _previewExpiryController.dispose();
    _downloadExpiryController.dispose();
    _taskExpiryController.dispose();
    _momentsExpiryController.dispose();
    _uploadExpiryController.dispose();
    _defaultExpiryController.dispose();
    _openAiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentConfig() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final config = await ConfigInitializer.getCurrentConfig();
      final health = await ConfigInitializer.verifyConfig();

      setState(() {
        _currentConfig = config;
        _healthStatus = health;
        _isLoading = false;
      });

      // Populate form controllers
      _populateFormControllers();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _populateFormControllers() {
    if (_currentConfig != null) {
      _urlController.text = _currentConfig!['supabase_url'] ?? '';
      _anonKeyController.text = _currentConfig!['supabase_anon_key'] ?? '';
      _serviceRoleKeyController.text =
          _currentConfig!['supabase_service_role_key'] ?? '';
      _previewExpiryController.text =
          (_currentConfig!['document_preview_expiry'] ?? 60).toString();
      _downloadExpiryController.text =
          (_currentConfig!['document_download_expiry'] ?? 60).toString();
      _taskExpiryController.text =
          (_currentConfig!['task_document_expiry'] ?? 60).toString();
      _momentsExpiryController.text =
          (_currentConfig!['moments_media_expiry'] ?? 60).toString();
      _uploadExpiryController.text =
          (_currentConfig!['upload_url_expiry'] ?? 60).toString();
      _defaultExpiryController.text =
          (_currentConfig!['default_expiry'] ?? 60).toString();
    }
  }

  Future<void> _initializeDefaultConfig() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ConfigInitializer.initializeDefaultConfig();
      await _loadCurrentConfig();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Default configuration initialized successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSupabaseKeys() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Validate form fields
      if (_urlController.text.trim().isEmpty) {
        throw Exception('Supabase URL is required');
      }
      if (_anonKeyController.text.trim().isEmpty) {
        throw Exception('Anonymous Key is required');
      }
      if (_serviceRoleKeyController.text.trim().isEmpty) {
        throw Exception('Service Role Key is required');
      }

      await ConfigInitializer.setSupabaseKeys(
        url: _urlController.text.trim(),
        anonKey: _anonKeyController.text.trim(),
        serviceRoleKey: _serviceRoleKeyController.text.trim(),
      );

      await _loadCurrentConfig();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Supabase keys updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updateExpiryTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Validate form fields
      final previewExpiry = int.tryParse(_previewExpiryController.text);
      final downloadExpiry = int.tryParse(_downloadExpiryController.text);
      final taskExpiry = int.tryParse(_taskExpiryController.text);
      final momentsExpiry = int.tryParse(_momentsExpiryController.text);
      final uploadExpiry = int.tryParse(_uploadExpiryController.text);
      final defaultExpiry = int.tryParse(_defaultExpiryController.text);

      // Check if at least one field has a valid value
      if (previewExpiry == null &&
          downloadExpiry == null &&
          taskExpiry == null &&
          momentsExpiry == null &&
          uploadExpiry == null &&
          defaultExpiry == null) {
        throw Exception('At least one expiry time must be provided');
      }

      await ConfigInitializer.setCustomExpiryTimes(
        documentPreviewExpiry: previewExpiry,
        documentDownloadExpiry: downloadExpiry,
        taskDocumentExpiry: taskExpiry,
        momentsMediaExpiry: momentsExpiry,
        uploadUrlExpiry: uploadExpiry,
        defaultExpiry: defaultExpiry,
      );

      await _loadCurrentConfig();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Expiry times updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _clearCache() async {
    ConfigInitializer.clearCache();
    await _loadCurrentConfig();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Configuration cache cleared'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _loadOpenAIApiKey() async {
    final key = await ConfigInitializer.getOpenAIApiKey();
    final updated = await ConfigInitializer.getOpenAIApiKeyLastUpdated();
    setState(() {
      _openAiKeyController.text = key ?? '';
      _openAiKeyLastUpdated = updated;
    });
  }

  Future<void> _saveOpenAIApiKey() async {
    await ConfigInitializer.setOpenAIApiKey(_openAiKeyController.text.trim());
    await _loadOpenAIApiKey();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OpenAI API key updated!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DashboardScaffold(
      currentPath: '/admin/config',
      child: Container(
        color: theme.colorScheme.surfaceContainerLowest,
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.settings,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dynamic Configuration',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage Supabase keys and expiry times dynamically',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action buttons
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadCurrentConfig,
                            tooltip: 'Refresh',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.clear_all),
                            onPressed: _clearCache,
                            tooltip: 'Clear Cache',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.help_outline),
                            onPressed: () => _showHelpDialog(),
                            tooltip: 'Help',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content Section
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: LoadingWidget())
                      : _error != null
                      ? Center(
                        child: CustomErrorWidget(
                          message: _error!,
                          onRetry: _loadCurrentConfig,
                        ),
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHealthStatus(theme),
                            const SizedBox(height: 24),
                            _buildOpenAIApiKeySection(theme),
                            const SizedBox(height: 24),
                            _buildSupabaseKeysSection(theme),
                            const SizedBox(height: 24),
                            _buildExpiryTimesSection(theme),
                            const SizedBox(height: 24),
                            _buildActionsSection(theme),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStatus(ThemeData theme) {
    final isHealthy = _healthStatus?['health']?['status'] == 'healthy';
    final hasRequiredFields = _healthStatus?['has_required_fields'] ?? false;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isHealthy ? Icons.check_circle : Icons.error,
                  color: isHealthy ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Text(
                  'Configuration Health',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHealthIndicator(
                  'Status',
                  isHealthy ? 'Healthy' : 'Unhealthy',
                  isHealthy ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 16),
                _buildHealthIndicator(
                  'Required Fields',
                  hasRequiredFields ? 'Complete' : 'Missing',
                  hasRequiredFields ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildHealthIndicator(
                  'Cache',
                  _healthStatus?['health']?['cache_valid'] == true
                      ? 'Valid'
                      : 'Invalid',
                  _healthStatus?['health']?['cache_valid'] == true
                      ? Colors.green
                      : Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSupabaseKeysSection(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.key, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Supabase Configuration',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Supabase URL',
                hintText: 'https://your-project.supabase.co',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _anonKeyController,
              decoration: const InputDecoration(
                labelText: 'Anonymous Key',
                hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _serviceRoleKeyController,
              decoration: const InputDecoration(
                labelText: 'Service Role Key',
                hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _updateSupabaseKeys,
                icon: const Icon(Icons.save),
                label: const Text('Update Supabase Keys'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryTimesSection(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'URL Expiry Times (seconds)',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _previewExpiryController,
                    decoration: const InputDecoration(
                      labelText: 'Document Preview',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _downloadExpiryController,
                    decoration: const InputDecoration(
                      labelText: 'Document Download',
                      border: OutlineInputBorder(),
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
                  child: TextField(
                    controller: _taskExpiryController,
                    decoration: const InputDecoration(
                      labelText: 'Task Documents',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _momentsExpiryController,
                    decoration: const InputDecoration(
                      labelText: 'Moments Media',
                      border: OutlineInputBorder(),
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
                  child: TextField(
                    controller: _uploadExpiryController,
                    decoration: const InputDecoration(
                      labelText: 'Upload URLs',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _defaultExpiryController,
                    decoration: const InputDecoration(
                      labelText: 'Default Expiry',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _updateExpiryTimes,
                icon: const Icon(Icons.timer),
                label: const Text('Update Expiry Times'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Configuration Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _initializeDefaultConfig,
                    icon: const Icon(Icons.restore),
                    label: const Text('Initialize Defaults'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearCache,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Cache'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenAIApiKeySection(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vpn_key, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'OpenAI API Key',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _openAiKeyController,
                    obscureText: _obscureOpenAiKey,
                    decoration: InputDecoration(
                      labelText: 'API Key',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureOpenAiKey
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed:
                            () => setState(
                              () => _obscureOpenAiKey = !_obscureOpenAiKey,
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveOpenAIApiKey,
                  child: const Text('Save'),
                ),
              ],
            ),
            if (_openAiKeyLastUpdated != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Last updated: ${_openAiKeyLastUpdated}'),
              ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Dynamic Configuration Help'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Dynamic Configuration Management',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Supabase keys are stored securely in Firestore\n'
                    '• Expiry times can be updated without app deployment\n'
                    '• Configuration is cached for 30 minutes\n'
                    '• Changes take effect immediately after cache clear\n'
                    '• All expiry times are in seconds',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Security Benefits',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Keys not hardcoded in app\n'
                    '• Can rotate keys without redeployment\n'
                    '• Centralized configuration management\n'
                    '• Audit trail for configuration changes',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

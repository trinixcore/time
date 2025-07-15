import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DynamicConfigService {
  static final DynamicConfigService _instance =
      DynamicConfigService._internal();
  factory DynamicConfigService() => _instance;
  DynamicConfigService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache for configuration data
  Map<String, dynamic>? _configCache;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheExpiry = Duration(minutes: 30);

  /// Get configuration from Firestore with caching
  Future<Map<String, dynamic>> getConfig() async {
    // Check if cache is valid
    if (_configCache != null && _lastCacheUpdate != null) {
      final timeSinceUpdate = DateTime.now().difference(_lastCacheUpdate!);
      if (timeSinceUpdate < _cacheExpiry) {
        print('📋 [CONFIG] Using cached configuration');
        return _configCache!;
      }
    }

    try {
      print('🔄 [CONFIG] Fetching configuration from Firestore...');

      final doc =
          await _firestore
              .collection('system_data')
              .doc('supabase_config')
              .get();

      if (!doc.exists) {
        print('❌ [CONFIG] Configuration document not found in Firestore');
        throw Exception(
          'Configuration document not found in Firestore. Please initialize the configuration first.',
        );
      }

      final data = doc.data() as Map<String, dynamic>;

      // Validate required fields
      final requiredFields = [
        'supabase_url',
        'supabase_anon_key',
        'supabase_service_role_key',
      ];
      for (final field in requiredFields) {
        if (!data.containsKey(field) || data[field] == null) {
          print('❌ [CONFIG] Missing required field: $field');
          throw Exception('Missing required configuration field: $field');
        }
      }

      // Update cache
      _configCache = data;
      _lastCacheUpdate = DateTime.now();

      print('✅ [CONFIG] Configuration loaded successfully from Firestore');
      return data;
    } catch (e) {
      print('❌ [CONFIG] Error loading configuration: $e');
      throw Exception('Failed to load configuration from Firestore: $e');
    }
  }

  /// Get specific configuration value
  Future<String?> getConfigValue(String key) async {
    final config = await getConfig();
    return config[key]?.toString();
  }

  /// Get Supabase URL
  Future<String> getSupabaseUrl() async {
    final url = await getConfigValue('supabase_url');
    // return url ?? 'https://jfahmudhqiozaotquakd.supabase.co';
    if (url == null || url.isEmpty) {
      throw Exception('Supabase URL not configured in Firestore');
    }
    return url;
  }

  /// Get Supabase Anonymous Key
  Future<String> getSupabaseAnonKey() async {
    final key = await getConfigValue('supabase_anon_key');
    // return key ??
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmYWhtdWRocWlvemFvdHF1YWtkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwNDAzNzgsImV4cCI6MjA2NTYxNjM3OH0.pEh2GKQ_InR13Cv5wUkHg2v2gREmxw9nK6JQaM4917Q';
    if (key == null || key.isEmpty) {
      throw Exception('Supabase Anonymous Key not configured in Firestore');
    }
    return key;
  }

  /// Get Supabase Service Role Key
  Future<String> getSupabaseServiceRoleKey() async {
    final key = await getConfigValue('supabase_service_role_key');
    // return key ??
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmYWhtdWRocWlvemFvdHF1YWtkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MDA0MDM3OCwiZXhwIjoyMDY1NjE2Mzc4fQ.2tv1fZaSgdFEFoXduJd4MfKWa7VolckHFPpdRTOp3D0';
    if (key == null || key.isEmpty) {
      throw Exception('Supabase Service Role Key not configured in Firestore');
    }
    return key;
  }

  /// Get expiry configuration
  Future<Map<String, int>> getExpiryConfig() async {
    final config = await getConfig();

    final expiryConfig = <String, int>{};

    // Check each expiry field
    final expiryFields = {
      'documentPreviewExpiry': 'document_preview_expiry',
      'documentDownloadExpiry': 'document_download_expiry',
      'taskDocumentExpiry': 'task_document_expiry',
      'momentsMediaExpiry': 'moments_media_expiry',
      'uploadUrlExpiry': 'upload_url_expiry',
      'defaultExpiry': 'default_expiry',
    };

    for (final entry in expiryFields.entries) {
      final value = config[entry.value];
      if (value == null) {
        throw Exception('Missing expiry configuration: ${entry.value}');
      }
      expiryConfig[entry.key] = value as int;
    }

    return expiryConfig;
  }

  /// Clear configuration cache
  void clearCache() {
    _configCache = null;
    _lastCacheUpdate = null;
    print('🗑️ [CONFIG] Configuration cache cleared');
  }

  /// Initialize default configuration in Firestore
  Future<void> initializeDefaultConfig() async {
    try {
      print('🚀 [CONFIG] Initializing default configuration in Firestore...');

      final defaultConfig = _getDefaultConfig();

      await _firestore
          .collection('system_data')
          .doc('supabase_config')
          .set(defaultConfig, SetOptions(merge: true));

      print('✅ [CONFIG] Default configuration initialized in Firestore');
    } catch (e) {
      print('❌ [CONFIG] Error initializing default configuration: $e');
    }
  }

  /// Ensure configuration document exists
  Future<void> ensureConfigExists() async {
    try {
      final doc =
          await _firestore
              .collection('system_data')
              .doc('supabase_config')
              .get();

      if (!doc.exists) {
        print('📝 [CONFIG] Creating configuration document...');
        await initializeDefaultConfig();
      }
    } catch (e) {
      print('❌ [CONFIG] Error ensuring config exists: $e');
      throw Exception('Failed to ensure configuration exists: $e');
    }
  }

  /// Update configuration in Firestore
  Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    try {
      print('🔄 [CONFIG] Updating configuration in Firestore...');

      // Ensure the document exists first
      await ensureConfigExists();

      // Create a copy of the config for Firestore update
      final firestoreConfig = Map<String, dynamic>.from(newConfig);

      // Add timestamp to track when it was last updated
      firestoreConfig['last_updated'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('system_data')
          .doc('supabase_config')
          .set(firestoreConfig, SetOptions(merge: true));

      // Clear cache to force refresh
      clearCache();

      print('✅ [CONFIG] Configuration updated successfully');
    } catch (e) {
      print('❌ [CONFIG] Error updating configuration: $e');
      throw Exception('Failed to update configuration: $e');
    }
  }

  /// Get default configuration
  Map<String, dynamic> _getDefaultConfig() {
    return {
      'supabase_url': 'https://jfahmudhqiozaotquakd.supabase.co',
      'supabase_anon_key':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmYWhtdWRocWlvemFvdHF1YWtkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwNDAzNzgsImV4cCI6MjA2NTYxNjM3OH0.pEh2GKQ_InR13Cv5wUkHg2v2gREmxw9nK6JQaM4917Q',
      'supabase_service_role_key':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmYWhtdWRocWlvemFvdHF1YWtkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MDA0MDM3OCwiZXhwIjoyMDY1NjE2Mzc4fQ.2tv1fZaSgdFEFoXduJd4MfKWa7VolckHFPpdRTOp3D0',
      'document_preview_expiry': 60,
      'document_download_expiry': 60,
      'task_document_expiry': 60,
      'moments_media_expiry': 60,
      'upload_url_expiry': 60,
      'default_expiry': 60,
      'last_updated': FieldValue.serverTimestamp(),
      'version': '1.0.0',
    };
  }

  /// Health check for configuration service
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final config = await getConfig();
      return {
        'status': 'healthy',
        'cache_valid': _configCache != null && _lastCacheUpdate != null,
        'last_update': _lastCacheUpdate?.toIso8601String(),
        'config_keys': config.keys.toList(),
        'has_required_fields':
            config.containsKey('supabase_url') &&
            config.containsKey('supabase_anon_key') &&
            config.containsKey('supabase_service_role_key'),
      };
    } catch (e) {
      return {'status': 'unhealthy', 'error': e.toString()};
    }
  }

  /// Get OpenAI API Key
  Future<String?> getOpenAIApiKey() async {
    final config = await getConfig();
    return config['openai_api_key'] as String?;
  }

  /// Set OpenAI API Key
  Future<void> setOpenAIApiKey(String apiKey) async {
    await updateConfig({
      'openai_api_key': apiKey,
      'openai_api_key_last_updated': FieldValue.serverTimestamp(),
    });
  }

  /// Get OpenAI API Key last updated timestamp
  Future<DateTime?> getOpenAIApiKeyLastUpdated() async {
    final config = await getConfig();
    final ts = config['openai_api_key_last_updated'];
    if (ts is Timestamp) return ts.toDate();
    if (ts is String) return DateTime.tryParse(ts);
    return null;
  }
}

// Riverpod providers for dynamic configuration
final dynamicConfigServiceProvider = Provider<DynamicConfigService>((ref) {
  return DynamicConfigService();
});

final configProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(dynamicConfigServiceProvider);
  return service.getConfig();
});

final supabaseUrlProvider = FutureProvider<String>((ref) async {
  final service = ref.read(dynamicConfigServiceProvider);
  return service.getSupabaseUrl();
});

final supabaseAnonKeyProvider = FutureProvider<String>((ref) async {
  final service = ref.read(dynamicConfigServiceProvider);
  return service.getSupabaseAnonKey();
});

final supabaseServiceRoleKeyProvider = FutureProvider<String>((ref) async {
  final service = ref.read(dynamicConfigServiceProvider);
  return service.getSupabaseServiceRoleKey();
});

final expiryConfigProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.read(dynamicConfigServiceProvider);
  return service.getExpiryConfig();
});

import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/dynamic_config_service.dart';

/// Utility class to initialize dynamic configuration in Firestore
class ConfigInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final DynamicConfigService _configService = DynamicConfigService();

  /// Initialize the default configuration in Firestore
  static Future<void> initializeDefaultConfig() async {
    try {
      print('🚀 [CONFIG INIT] Starting configuration initialization...');

      await _configService.initializeDefaultConfig();

      print('✅ [CONFIG INIT] Default configuration initialized successfully');

      // Verify the configuration was created
      final config = await _configService.getConfig();
      print('📋 [CONFIG INIT] Configuration keys: ${config.keys.toList()}');
    } catch (e) {
      print('❌ [CONFIG INIT] Failed to initialize configuration: $e');
      throw Exception('Configuration initialization failed: $e');
    }
  }

  /// Update specific configuration values
  static Future<void> updateConfigValues(Map<String, dynamic> updates) async {
    try {
      print('🔄 [CONFIG INIT] Updating configuration values...');

      // Ensure the configuration document exists first
      await _configService.ensureConfigExists();

      await _configService.updateConfig(updates);

      print('✅ [CONFIG INIT] Configuration updated successfully');
    } catch (e) {
      print('❌ [CONFIG INIT] Failed to update configuration: $e');
      throw Exception('Configuration update failed: $e');
    }
  }

  /// Set custom expiry times
  static Future<void> setCustomExpiryTimes({
    int? documentPreviewExpiry,
    int? documentDownloadExpiry,
    int? taskDocumentExpiry,
    int? momentsMediaExpiry,
    int? uploadUrlExpiry,
    int? defaultExpiry,
  }) async {
    try {
      print('⏰ [CONFIG INIT] Setting custom expiry times...');

      final updates = <String, dynamic>{};

      // Validate and add expiry times
      if (documentPreviewExpiry != null) {
        if (documentPreviewExpiry <= 0) {
          throw Exception('Document preview expiry must be greater than 0');
        }
        updates['document_preview_expiry'] = documentPreviewExpiry;
      }
      if (documentDownloadExpiry != null) {
        if (documentDownloadExpiry <= 0) {
          throw Exception('Document download expiry must be greater than 0');
        }
        updates['document_download_expiry'] = documentDownloadExpiry;
      }
      if (taskDocumentExpiry != null) {
        if (taskDocumentExpiry <= 0) {
          throw Exception('Task document expiry must be greater than 0');
        }
        updates['task_document_expiry'] = taskDocumentExpiry;
      }
      if (momentsMediaExpiry != null) {
        if (momentsMediaExpiry <= 0) {
          throw Exception('Moments media expiry must be greater than 0');
        }
        updates['moments_media_expiry'] = momentsMediaExpiry;
      }
      if (uploadUrlExpiry != null) {
        if (uploadUrlExpiry <= 0) {
          throw Exception('Upload URL expiry must be greater than 0');
        }
        updates['upload_url_expiry'] = uploadUrlExpiry;
      }
      if (defaultExpiry != null) {
        if (defaultExpiry <= 0) {
          throw Exception('Default expiry must be greater than 0');
        }
        updates['default_expiry'] = defaultExpiry;
      }

      // Check if at least one expiry time is provided
      if (updates.isEmpty) {
        throw Exception('At least one expiry time must be provided');
      }

      await updateConfigValues(updates);

      print('✅ [CONFIG INIT] Custom expiry times set successfully');
    } catch (e) {
      print('❌ [CONFIG INIT] Failed to set custom expiry times: $e');
      throw Exception('Failed to set custom expiry times: $e');
    }
  }

  /// Set Supabase keys
  static Future<void> setSupabaseKeys({
    required String url,
    required String anonKey,
    required String serviceRoleKey,
  }) async {
    try {
      print('🔑 [CONFIG INIT] Setting Supabase keys...');

      // Validate inputs
      if (url.trim().isEmpty) {
        throw Exception('Supabase URL cannot be empty');
      }
      if (anonKey.trim().isEmpty) {
        throw Exception('Supabase Anonymous Key cannot be empty');
      }
      if (serviceRoleKey.trim().isEmpty) {
        throw Exception('Supabase Service Role Key cannot be empty');
      }

      final updates = {
        'supabase_url': url.trim(),
        'supabase_anon_key': anonKey.trim(),
        'supabase_service_role_key': serviceRoleKey.trim(),
      };

      await updateConfigValues(updates);

      print('✅ [CONFIG INIT] Supabase keys set successfully');
    } catch (e) {
      print('❌ [CONFIG INIT] Failed to set Supabase keys: $e');
      throw Exception('Failed to set Supabase keys: $e');
    }
  }

  /// Verify configuration is properly set
  static Future<Map<String, dynamic>> verifyConfig() async {
    try {
      print('🔍 [CONFIG INIT] Verifying configuration...');

      // Ensure the configuration document exists
      await _configService.ensureConfigExists();

      final health = await _configService.healthCheck();
      final config = await _configService.getConfig();

      print('📊 [CONFIG INIT] Health status: ${health['status']}');
      print('📋 [CONFIG INIT] Configuration keys: ${config.keys.toList()}');

      return {
        'health': health,
        'config': config,
        'has_required_fields': health['has_required_fields'] ?? false,
      };
    } catch (e) {
      print('❌ [CONFIG INIT] Configuration verification failed: $e');
      return {
        'health': {'status': 'unhealthy', 'error': e.toString()},
        'config': {},
        'has_required_fields': false,
      };
    }
  }

  /// Clear configuration cache
  static void clearCache() {
    _configService.clearCache();
    print('🗑️ [CONFIG INIT] Configuration cache cleared');
  }

  /// Get current configuration
  static Future<Map<String, dynamic>> getCurrentConfig() async {
    try {
      // Ensure the configuration document exists
      await _configService.ensureConfigExists();

      return await _configService.getConfig();
    } catch (e) {
      print('❌ [CONFIG INIT] Failed to get current config: $e');
      // Return default config if there's an error (without FieldValue)
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
        'last_updated': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    }
  }

  /// Reset to default configuration
  static Future<void> resetToDefaults() async {
    try {
      print('🔄 [CONFIG INIT] Resetting to default configuration...');

      await initializeDefaultConfig();

      print('✅ [CONFIG INIT] Reset to defaults completed');
    } catch (e) {
      print('❌ [CONFIG INIT] Failed to reset to defaults: $e');
      throw Exception('Failed to reset to defaults: $e');
    }
  }

  /// Get OpenAI API Key
  static Future<String?> getOpenAIApiKey() async {
    return await _configService.getOpenAIApiKey();
  }

  /// Set OpenAI API Key
  static Future<void> setOpenAIApiKey(String apiKey) async {
    await _configService.setOpenAIApiKey(apiKey);
  }

  /// Get OpenAI API Key last updated timestamp
  static Future<DateTime?> getOpenAIApiKeyLastUpdated() async {
    return await _configService.getOpenAIApiKeyLastUpdated();
  }
}

import '../services/dynamic_config_service.dart';

class SupabaseConfig {
  // Static fallback values (commented out to ensure dynamic values are used)
  // static const String _fallbackUrl = 'https://jfahmudhqiozaotquakd.supabase.co';
  // static const String _fallbackAnonKey =
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmYWhtdWRocWlvemFvdHF1YWtkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAwNDAzNzgsImV4cCI6MjA2NTYxNjM3OH0.pEh2GKQ_InR13Cv5wUkHg2v2gREmxw9nK6JQaM4917Q';
  // static const String _fallbackServiceRoleKey =
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpmYWhtdWRocWlvemFvdHF1YWtkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MDA0MDM3OCwiZXhwIjoyMDY1NjE2Mzc4fQ.2tv1fZaSgdFEFoXduJd4MfKWa7VolckHFPpdRTOp3D0';

  // Service instance
  static final DynamicConfigService _configService = DynamicConfigService();

  // ============= DYNAMIC CONFIGURATION METHODS =============

  /// Get Supabase URL dynamically from Firestore
  static Future<String> get url async {
    return await _configService.getSupabaseUrl();
  }

  /// Get Supabase Anonymous Key dynamically from Firestore
  static Future<String> get anonKey async {
    return await _configService.getSupabaseAnonKey();
  }

  /// Get Supabase Service Role Key dynamically from Firestore
  static Future<String> get serviceRoleKey async {
    return await _configService.getSupabaseServiceRoleKey();
  }

  // ============= EXPIRY CONFIGURATION =============

  /// Document preview/access URLs - Dynamic expiry from Firestore
  static Future<int> get documentPreviewExpiry async {
    final expiryConfig = await _configService.getExpiryConfig();
    return expiryConfig['documentPreviewExpiry']!;
  }

  /// Document download URLs - Dynamic expiry from Firestore
  static Future<int> get documentDownloadExpiry async {
    final expiryConfig = await _configService.getExpiryConfig();
    return expiryConfig['documentDownloadExpiry']!;
  }

  /// Task document URLs - Dynamic expiry from Firestore
  static Future<int> get taskDocumentExpiry async {
    final expiryConfig = await _configService.getExpiryConfig();
    return expiryConfig['taskDocumentExpiry']!;
  }

  /// Moments/media URLs - Dynamic expiry from Firestore
  static Future<int> get momentsMediaExpiry async {
    final expiryConfig = await _configService.getExpiryConfig();
    return expiryConfig['momentsMediaExpiry']!;
  }

  /// Upload URLs - Dynamic expiry from Firestore
  static Future<int> get uploadUrlExpiry async {
    final expiryConfig = await _configService.getExpiryConfig();
    return expiryConfig['uploadUrlExpiry']!;
  }

  /// Default fallback expiry - Dynamic from Firestore
  static Future<int> get defaultExpiry async {
    final expiryConfig = await _configService.getExpiryConfig();
    return expiryConfig['defaultExpiry']!;
  }

  // ============= UTILITY METHODS =============

  /// Initialize default configuration in Firestore
  static Future<void> initializeDefaultConfig() async {
    await _configService.initializeDefaultConfig();
  }

  /// Clear configuration cache
  static void clearCache() {
    _configService.clearCache();
  }

  /// Get health status of configuration service
  static Future<Map<String, dynamic>> healthCheck() async {
    return await _configService.healthCheck();
  }

  /// Update configuration in Firestore
  static Future<void> updateConfig(Map<String, dynamic> newConfig) async {
    await _configService.updateConfig(newConfig);
  }
}

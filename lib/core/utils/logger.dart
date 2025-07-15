import 'package:flutter/foundation.dart';

/// A comprehensive logging system for the TRINIX application
///
/// This logger provides different log levels and categories to replace
/// all print statements throughout the application with a more structured
/// and configurable logging approach.
class AppLogger {
  static const String _appName = 'TRINIX';

  // Configuration
  static bool _enableBrowserConsole = false; // Control browser console output

  // Log levels
  static const String _debug = '🐛';
  static const String _info = 'ℹ️';
  static const String _success = '✅';
  static const String _warning = '⚠️';
  static const String _error = '❌';
  static const String _critical = '🚨';

  // Common categories
  static const String _auth = 'AUTH';
  static const String _router = 'ROUTER';
  static const String _provider = 'PROVIDER';
  static const String _permission = 'PERMISSION';
  static const String _docCount = 'DOC COUNT';
  static const String _upload = 'UPLOAD';
  static const String _delete = 'DELETE';
  static const String _modal = 'MODAL';
  static const String _service = 'SERVICE';
  static const String _debugCategory = 'DEBUG';
  static const String _folder = 'FOLDER FILTER';
  static const String _employee = 'EMPLOYEE';
  static const String _task = 'TASK';
  static const String _letter = 'LETTER';
  static const String _setup = 'SETUP';
  static const String _firebase = 'FIREBASE';
  static const String _supabase = 'SUPABASE';

  /// Enable or disable browser console logging
  static void setBrowserConsoleEnabled(bool enabled) {
    _enableBrowserConsole = enabled;
  }

  /// Get current browser console logging status
  static bool get browserConsoleEnabled => _enableBrowserConsole;

  /// Log a debug message
  static void debug(String category, String message) {
    _log(_debug, category, message);
  }

  /// Log an info message
  static void info(String category, String message) {
    _log(_info, category, message);
  }

  /// Log a success message
  static void success(String category, String message) {
    _log(_success, category, message);
  }

  /// Log a warning message
  static void warning(String category, String message) {
    _log(_warning, category, message);
  }

  /// Log an error message
  static void error(String category, String message) {
    _log(_error, category, message);
  }

  /// Log a critical error message
  static void critical(String category, String message) {
    _log(_critical, category, message);
  }

  /// Log with custom emoji and category
  static void custom(String emoji, String category, String message) {
    _log(emoji, category, message);
  }

  /// Internal logging method
  static void _log(String level, String category, String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final logMessage = '$level [$category] $message';

      // Only print to console if browser console logging is enabled
      if (_enableBrowserConsole) {
        print('[$_appName] $logMessage');
      }

      // TODO: In the future, you could add other logging destinations here:
      // - Send to a logging service
      // - Store in local storage
      // - Send to analytics
      // - Write to a file (for mobile/desktop)
    }
  }

  // Convenience methods for common categories

  /// Auth-related logging
  static void auth(String message) => info(_auth, message);
  static void authError(String message) => error(_auth, message);
  static void authSuccess(String message) => success(_auth, message);
  static void authWarning(String message) => warning(_auth, message);

  /// Router-related logging
  static void router(String message) => info(_router, message);
  static void routerError(String message) => error(_router, message);
  static void routerSuccess(String message) => success(_router, message);

  /// Provider-related logging
  static void provider(String message) => info(_provider, message);
  static void providerError(String message) => error(_provider, message);
  static void providerSuccess(String message) => success(_provider, message);

  /// Permission-related logging
  static void permission(String message) => info(_permission, message);
  static void permissionError(String message) => error(_permission, message);
  static void permissionSuccess(String message) =>
      success(_permission, message);

  /// Document count logging
  static void docCount(String message) => info(_docCount, message);
  static void docCountError(String message) => error(_docCount, message);
  static void docCountSuccess(String message) => success(_docCount, message);

  /// Upload-related logging
  static void upload(String message) => info(_upload, message);
  static void uploadError(String message) => error(_upload, message);
  static void uploadSuccess(String message) => success(_upload, message);

  /// Delete-related logging
  static void delete(String message) => info(_delete, message);
  static void deleteError(String message) => error(_delete, message);
  static void deleteSuccess(String message) => success(_delete, message);

  /// Modal-related logging
  static void modal(String message) => info(_modal, message);
  static void modalError(String message) => error(_modal, message);
  static void modalSuccess(String message) => success(_modal, message);

  /// Service-related logging
  static void service(String message) => info(_service, message);
  static void serviceError(String message) => error(_service, message);
  static void serviceSuccess(String message) => success(_service, message);

  /// Debug logging
  static void debugLog(String message) => debug(_debugCategory, message);

  /// Folder filter logging
  static void folderFilter(String message) => info(_folder, message);
  static void folderFilterError(String message) => error(_folder, message);
  static void folderFilterSuccess(String message) => success(_folder, message);

  /// Employee-related logging
  static void employee(String message) => info(_employee, message);
  static void employeeError(String message) => error(_employee, message);
  static void employeeSuccess(String message) => success(_employee, message);

  /// Task-related logging
  static void task(String message) => info(_task, message);
  static void taskError(String message) => error(_task, message);
  static void taskSuccess(String message) => success(_task, message);

  /// Letter-related logging
  static void letter(String message) => info(_letter, message);
  static void letterError(String message) => error(_letter, message);
  static void letterSuccess(String message) => success(_letter, message);

  /// Setup-related logging
  static void setup(String message) => info(_setup, message);
  static void setupError(String message) => error(_setup, message);
  static void setupSuccess(String message) => success(_setup, message);

  /// Firebase-related logging
  static void firebase(String message) => info(_firebase, message);
  static void firebaseError(String message) => error(_firebase, message);
  static void firebaseSuccess(String message) => success(_firebase, message);

  /// Supabase-related logging
  static void supabase(String message) => info(_supabase, message);
  static void supabaseError(String message) => error(_supabase, message);
  static void supabaseSuccess(String message) => success(_supabase, message);
}

/// Extension to make logging more convenient
extension LoggerExtension on Object {
  /// Log debug message with object context
  void logDebug(String category, String message) {
    AppLogger.debug(category, '${runtimeType}: $message');
  }

  /// Log error message with object context
  void logError(String category, String message) {
    AppLogger.error(category, '${runtimeType}: $message');
  }

  /// Log success message with object context
  void logSuccess(String category, String message) {
    AppLogger.success(category, '${runtimeType}: $message');
  }
}

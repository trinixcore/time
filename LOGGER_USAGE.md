# TRINIX Logger System

## Overview
The TRINIX application now uses a comprehensive logging system (`AppLogger`) to replace all `print` statements throughout the codebase. This provides better structure, categorization, and control over logging output.

## Location
The logger is located at: `lib/core/utils/logger.dart`

## Browser Console Logging

### Why Logs Appear in Browser Console
When running Flutter web applications, all `print()` statements are converted to `console.log()` in JavaScript and appear in the browser's developer console. This is normal behavior for Flutter web apps.

### Controlling Browser Console Output
**Browser console logging is DISABLED by default** to reduce console noise. You can control whether logs appear in the browser console:

```dart
// Enable browser console logging (for debugging)
AppLogger.setBrowserConsoleEnabled(true);

// Disable browser console logging (default)
AppLogger.setBrowserConsoleEnabled(false);

// Check current status
bool isEnabled = AppLogger.browserConsoleEnabled;
```

### When to Use Browser Console Logging
- **Development**: Enable when you need to see logs in browser dev tools
- **Production**: Keep disabled to reduce console noise
- **Debugging**: Very useful for troubleshooting issues

## Basic Usage

### Import the Logger
```dart
import '../../../core/utils/logger.dart';
```

### Basic Logging Methods
```dart
// Debug logging
AppLogger.debug('CATEGORY', 'Debug message');

// Info logging
AppLogger.info('CATEGORY', 'Info message');

// Success logging
AppLogger.success('CATEGORY', 'Success message');

// Warning logging
AppLogger.warning('CATEGORY', 'Warning message');

// Error logging
AppLogger.error('CATEGORY', 'Error message');

// Critical logging
AppLogger.critical('CATEGORY', 'Critical error message');

// Custom emoji logging
AppLogger.custom('🚨', 'CATEGORY', 'Custom message');
```

## Convenience Methods for Common Categories

### Auth-related logging
```dart
AppLogger.auth('User logged in');
AppLogger.authError('Authentication failed');
AppLogger.authSuccess('User authenticated successfully');
AppLogger.authWarning('Session expiring soon');
```

### Router-related logging
```dart
AppLogger.router('Navigating to dashboard');
AppLogger.routerError('Route not found');
AppLogger.routerSuccess('Navigation completed');
```

### Provider-related logging
```dart
AppLogger.provider('Provider state updated');
AppLogger.providerError('Provider error occurred');
AppLogger.providerSuccess('Provider initialized');
```

### Permission-related logging
```dart
AppLogger.permission('Checking user permissions');
AppLogger.permissionError('Permission denied');
AppLogger.permissionSuccess('Permission granted');
```

### Document count logging
```dart
AppLogger.docCount('Calculating document count');
AppLogger.docCountError('Failed to count documents');
AppLogger.docCountSuccess('Document count completed');
```

### Upload-related logging
```dart
AppLogger.upload('Starting file upload');
AppLogger.uploadError('Upload failed');
AppLogger.uploadSuccess('Upload completed');
```

### Delete-related logging
```dart
AppLogger.delete('Deleting item');
AppLogger.deleteError('Delete failed');
AppLogger.deleteSuccess('Delete completed');
```

### Modal-related logging
```dart
AppLogger.modal('Opening modal');
AppLogger.modalError('Modal error');
AppLogger.modalSuccess('Modal closed');
```

### Service-related logging
```dart
AppLogger.service('Service call initiated');
AppLogger.serviceError('Service error');
AppLogger.serviceSuccess('Service completed');
```

### Debug logging
```dart
AppLogger.debugLog('Debug information');
```

### Folder filter logging
```dart
AppLogger.folderFilter('Filtering folders');
AppLogger.folderFilterError('Folder filter error');
AppLogger.folderFilterSuccess('Folder filter completed');
```

### Employee-related logging
```dart
AppLogger.employee('Loading employee data');
AppLogger.employeeError('Employee data error');
AppLogger.employeeSuccess('Employee data loaded');
```

### Task-related logging
```dart
AppLogger.task('Creating task');
AppLogger.taskError('Task creation failed');
AppLogger.taskSuccess('Task created');
```

### Letter-related logging
```dart
AppLogger.letter('Generating letter');
AppLogger.letterError('Letter generation failed');
AppLogger.letterSuccess('Letter generated');
```

### Setup-related logging
```dart
AppLogger.setup('Initializing setup');
AppLogger.setupError('Setup failed');
AppLogger.setupSuccess('Setup completed');
```

### Firebase-related logging
```dart
AppLogger.firebase('Firebase operation');
AppLogger.firebaseError('Firebase error');
AppLogger.firebaseSuccess('Firebase success');
```

### Supabase-related logging
```dart
AppLogger.supabase('Supabase operation');
AppLogger.supabaseError('Supabase error');
AppLogger.supabaseSuccess('Supabase success');
```

## Object Extension Usage

You can also use the extension methods on any object:

```dart
class MyClass {
  void someMethod() {
    this.logDebug('CATEGORY', 'Debug message with object context');
    this.logError('CATEGORY', 'Error message with object context');
    this.logSuccess('CATEGORY', 'Success message with object context');
  }
}
```

## Migration Guide

### Before (print statements)
```dart
print('❌ [DOC COUNT] User not authenticated');
print('🔍 [DOC COUNT] Calculating count for folder: $folderPath');
print('✅ [DOC COUNT] User has canViewAll - counting all documents');
print('❌ [DOC COUNT] Error getting document count: $e');
```

### After (AppLogger)
```dart
AppLogger.docCountError('User not authenticated');
AppLogger.docCount('Calculating count for folder: $folderPath');
AppLogger.docCountSuccess('User has canViewAll - counting all documents');
AppLogger.docCountError('Error getting document count: $e');
```

## Benefits

1. **Structured Logging**: All logs are categorized and have consistent formatting
2. **Debug Mode Only**: Logs only appear in debug mode (`kDebugMode`)
3. **Easy Filtering**: Can easily filter logs by category or level
4. **Consistent Format**: All logs follow the same format: `[TRINIX] 🐛 [CATEGORY] message`
5. **Type Safety**: Compile-time checking for method names
6. **Extensible**: Easy to add new categories or log levels
7. **Browser Console Control**: Can enable/disable browser console output (disabled by default)

## Log Output Format
```
[TRINIX] 🐛 [DEBUG] Debug message
[TRINIX] ℹ️ [INFO] Info message
[TRINIX] ✅ [SUCCESS] Success message
[TRINIX] ⚠️ [WARNING] Warning message
[TRINIX] ❌ [ERROR] Error message
[TRINIX] 🚨 [CRITICAL] Critical error message
```

## Files to Update

The following files contain print statements that should be migrated:

1. `lib/features/documents/ui/my_documents_page.dart` ✅ (Updated)
2. `lib/shared/providers/page_access_providers.dart`
3. `lib/shared/providers/auth_providers.dart`
4. `lib/features/letters/widgets/letter_preview_edit_modal.dart`
5. `lib/features/employees/presentation/pages/employee_details_page.dart`
6. `lib/core/router/app_router.dart`
7. `lib/core/services/permission_management_service.dart` ✅ (Updated)
8. `lib/core/services/page_access_service.dart` ✅ (Updated)
9. `lib/features/documents/providers/document_providers.dart` ✅ (Updated)

## Next Steps

1. Import the logger in each file that needs it
2. Replace print statements with appropriate AppLogger methods
3. Test the application to ensure logs appear correctly
4. Gradually migrate all files to use the new logger system
5. Browser console logging is disabled by default - enable only when needed for debugging 
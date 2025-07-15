import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Performance optimization providers with improved caching
class PerformanceManager {
  static const Duration cacheTimeout = Duration(
    minutes: 3,
  ); // Reduced cache time
  static const Duration refreshDebounce = Duration(
    milliseconds: 300,
  ); // Faster debounce

  // Cache timestamps and data
  static final Map<String, DateTime> _cacheTimestamps = {};
  static final Map<String, dynamic> _cachedData = {};

  // Check if cache is valid
  static bool isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < cacheTimeout;
  }

  // Get cached data
  static T? getCachedData<T>(String key) {
    if (isCacheValid(key)) {
      return _cachedData[key] as T?;
    }
    return null;
  }

  // Set cached data
  static void setCachedData(String key, dynamic data) {
    _cachedData[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  // Clear cache
  static void clearCache([String? key]) {
    if (key != null) {
      _cacheTimestamps.remove(key);
      _cachedData.remove(key);
    } else {
      _cacheTimestamps.clear();
      _cachedData.clear();
    }
  }
}

// Global refresh notifier with debouncing
final globalRefreshProvider =
    StateNotifierProvider<GlobalRefreshNotifier, Map<String, int>>((ref) {
      return GlobalRefreshNotifier();
    });

class GlobalRefreshNotifier extends StateNotifier<Map<String, int>> {
  GlobalRefreshNotifier() : super({});
  final Map<String, Timer?> _debounceTimers = {};

  void refreshData(String key) {
    // Cancel existing timer
    _debounceTimers[key]?.cancel();

    // Set new debounced timer
    _debounceTimers[key] = Timer(PerformanceManager.refreshDebounce, () {
      state = {...state, key: (state[key] ?? 0) + 1};
      PerformanceManager.clearCache(key);
    });
  }

  void refreshAll() {
    // Cancel all timers
    for (final timer in _debounceTimers.values) {
      timer?.cancel();
    }
    _debounceTimers.clear();

    final newState = <String, int>{};
    for (final key in state.keys) {
      newState[key] = (state[key] ?? 0) + 1;
    }
    state = newState;
    PerformanceManager.clearCache();
  }

  @override
  void dispose() {
    for (final timer in _debounceTimers.values) {
      timer?.cancel();
    }
    _debounceTimers.clear();
    super.dispose();
  }
}

// Optimized users data provider with better caching
final optimizedUsersDataProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  // Watch for refresh signals
  ref.watch(globalRefreshProvider.select((state) => state['users'] ?? 0));

  const cacheKey = 'users_data';

  // Try to get cached data first
  final cachedData = PerformanceManager.getCachedData<Map<String, dynamic>>(
    cacheKey,
  );
  if (cachedData != null) {
    return {...cachedData, 'cached': true};
  }

  try {
    // Optimized queries with smaller limits for faster loading
    final activeUsersQuery = FirebaseFirestore.instance
        .collection('users')
        .where('isActive', isEqualTo: true)
        .limit(100); // Reduced limit for faster loading

    final terminatedUsersQuery = FirebaseFirestore.instance
        .collection('users')
        .where('isActive', isEqualTo: false)
        .limit(50); // Load terminated users

    final pendingUsersQuery = FirebaseFirestore.instance
        .collection('pending_users')
        .limit(50); // Reduced limit

    // Execute queries in parallel with timeout
    final results = await Future.wait([
      activeUsersQuery.get(),
      terminatedUsersQuery.get(),
      pendingUsersQuery.get(),
    ]).timeout(const Duration(seconds: 8)); // Reduced timeout

    final activeSnapshot = results[0];
    final terminatedSnapshot = results[1];
    final pendingSnapshot = results[2];

    // Process data efficiently
    final activeDocs = activeSnapshot.docs;
    final terminatedDocs = terminatedSnapshot.docs;
    final pendingDocs = pendingSnapshot.docs;

    final resultData = {
      'active': activeDocs,
      'terminated': terminatedDocs,
      'pending': pendingDocs,
      'activeCount': activeDocs.length,
      'terminatedCount': terminatedDocs.length,
      'pendingCount': pendingDocs.length,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'cached': false,
    };

    // Cache the result
    PerformanceManager.setCachedData(cacheKey, resultData);

    return resultData;
  } catch (e) {
    // Return empty data on error to prevent app crashes
    return {
      'active': <QueryDocumentSnapshot>[],
      'terminated': <QueryDocumentSnapshot>[],
      'pending': <QueryDocumentSnapshot>[],
      'activeCount': 0,
      'terminatedCount': 0,
      'pendingCount': 0,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'error': e.toString(),
      'cached': false,
    };
  }
});

// Optimized employees data provider
final optimizedEmployeesDataProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  // Watch for refresh signals
  ref.watch(globalRefreshProvider.select((state) => state['employees'] ?? 0));

  const cacheKey = 'employees_data';

  // Try to get cached data first
  final cachedData = PerformanceManager.getCachedData<Map<String, dynamic>>(
    cacheKey,
  );
  if (cachedData != null) {
    return {...cachedData, 'cached': true};
  }

  try {
    // Optimized query with smaller limit
    final employeesQuery = FirebaseFirestore.instance
        .collection('employees')
        .where('status', isEqualTo: 'active')
        .limit(150); // Reduced limit for faster loading

    final snapshot = await employeesQuery.get().timeout(
      const Duration(seconds: 8),
    );

    final employeeDocs = snapshot.docs;

    final resultData = {
      'employees': employeeDocs,
      'count': employeeDocs.length,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'cached': false,
    };

    // Cache the result
    PerformanceManager.setCachedData(cacheKey, resultData);

    return resultData;
  } catch (e) {
    // Return empty data on error
    return {
      'employees': <QueryDocumentSnapshot>[],
      'count': 0,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'error': e.toString(),
      'cached': false,
    };
  }
});

// Navigation refresh helper with better action handling
class NavigationRefreshHelper {
  static void refreshAfterAction(WidgetRef ref, String action) {
    final notifier = ref.read(globalRefreshProvider.notifier);

    switch (action) {
      case 'user_created':
      case 'user_updated':
      case 'user_deleted':
      case 'user_activated':
      case 'user_deactivated':
      case 'user_terminated':
      case 'user_reactivated':
        notifier.refreshData('users');
        break;
      case 'employee_created':
      case 'employee_updated':
      case 'employee_deleted':
        notifier.refreshData('employees');
        break;
      case 'profile_updated':
        notifier.refreshData('users');
        notifier.refreshData('employees');
        break;
      case 'hierarchy_updated':
        notifier.refreshData('users');
        notifier.refreshData('hierarchy');
        break;
      default:
        // Only refresh specific data, not everything
        notifier.refreshData('users');
    }
  }

  static void refreshSpecific(WidgetRef ref, List<String> keys) {
    final notifier = ref.read(globalRefreshProvider.notifier);
    for (final key in keys) {
      notifier.refreshData(key);
    }
  }
}

// Debounced refresh provider for UI interactions
final debouncedRefreshProvider =
    StateNotifierProvider<DebouncedRefreshNotifier, int>((ref) {
      return DebouncedRefreshNotifier();
    });

class DebouncedRefreshNotifier extends StateNotifier<int> {
  DebouncedRefreshNotifier() : super(0);
  Timer? _debounceTimer;

  void requestRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      state = state + 1;
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

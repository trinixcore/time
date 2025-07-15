import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  static final Logger _logger = Logger();

  // Cache for frequently accessed data
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _logger.i('Firebase initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Firebase: $e');
      rethrow;
    }
  }

  bool _isCacheValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  T? _getCachedData<T>(String key) {
    if (_isCacheValid(key)) {
      return _cache[key] as T?;
    }
    return null;
  }

  void _setCachedData(String key, dynamic data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  Future<bool> isSetupCompleted() async {
    const cacheKey = 'setup_completed';

    // Check cache first
    final cached = _getCachedData<bool>(cacheKey);
    if (cached != null) return cached;

    try {
      final doc = await firestore
          .doc('setup/completed')
          .get()
          .timeout(const Duration(seconds: 5));
      final result = doc.exists && doc.data()?['completed'] == true;

      // Cache the result
      _setCachedData(cacheKey, result);
      return result;
    } catch (e) {
      _logger.e('Error checking setup completion: $e');
      // Cache false result to avoid repeated failures
      _setCachedData(cacheKey, false);
      return false;
    }
  }

  Future<void> markSetupCompleted() async {
    try {
      await firestore
          .doc('setup/completed')
          .set({'completed': true, 'completedAt': FieldValue.serverTimestamp()})
          .timeout(const Duration(seconds: 10));

      // Update cache
      _setCachedData('setup_completed', true);
      _logger.i('Setup marked as completed');
    } catch (e) {
      _logger.e('Error marking setup as completed: $e');
      rethrow;
    }
  }

  Future<bool> hasAnyUsers() async {
    const cacheKey = 'has_users';

    // Check cache first
    final cached = _getCachedData<bool>(cacheKey);
    if (cached != null) return cached;

    try {
      final users = await firestore
          .collection('users')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      final result = users.docs.isNotEmpty;

      // Cache the result
      _setCachedData(cacheKey, result);
      return result;
    } catch (e) {
      _logger.e('Error checking for existing users: $e');
      // Cache true to fail safe - assume users exist
      _setCachedData(cacheKey, true);
      return true;
    }
  }

  // Clear cache when needed
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  // Clear specific cache entry
  static void clearCacheEntry(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../enums/user_role.dart';
import '../enums/employee_status.dart';
import 'firebase_service.dart';
import 'employee_folder_service.dart';
import 'dart:math' as math;
import 'dart:async';
import 'audit_log_service.dart';
import '../utils/audit_log_context.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final EmployeeFolderService _employeeFolderService = EmployeeFolderService();
  static final Logger _logger = Logger();

  // Presence tracking
  Timer? _presenceTimer;
  bool _isAppActive = true;

  FirebaseAuth get _auth => _firebaseService.auth;
  FirebaseFirestore get _firestore => _firebaseService.firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Initialize presence tracking
  void initializePresence() {
    _startPresenceTimer();
  }

  /// Start presence timer to update user status every 30 seconds
  void _startPresenceTimer() {
    _presenceTimer?.cancel();
    _presenceTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isAppActive && currentUser != null) {
        _updatePresence();
      }
    });
  }

  /// Update user presence in Firestore
  Future<void> _updatePresence() async {
    try {
      final user = currentUser;
      if (user == null) return;

      await _firestore.collection('user_status').doc(user.uid).set({
        'status': 'online',
        'lastActive': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'email': user.email,
        'displayName': user.displayName,
      }, SetOptions(merge: true));
    } catch (e) {
      _logger.e('Failed to update presence: $e');
    }
  }

  /// Mark app as paused (user inactive)
  void onAppPaused() {
    _isAppActive = false;
    _markUserAway();
  }

  /// Mark app as resumed (user active)
  void onAppResumed() {
    _isAppActive = true;
    _updatePresence();
  }

  /// Mark user as away when app is paused
  Future<void> _markUserAway() async {
    try {
      final user = currentUser;
      if (user == null) return;

      await _firestore.collection('user_status').doc(user.uid).update({
        'status': 'away',
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Failed to mark user away: $e');
    }
  }

  /// Cleanup presence timer
  void dispose() {
    _presenceTimer?.cancel();
  }

  /// Cleanup stale online users (mark as offline after 2 minutes of inactivity)
  Future<void> cleanupStaleUsers() async {
    try {
      final twoMinutesAgo = DateTime.now().subtract(const Duration(minutes: 2));
      final staleUsers =
          await _firestore
              .collection('user_status')
              .where('status', isEqualTo: 'online')
              .where('lastSeen', isLessThan: Timestamp.fromDate(twoMinutesAgo))
              .get();

      final batch = _firestore.batch();
      for (final doc in staleUsers.docs) {
        batch.update(doc.reference, {
          'status': 'offline',
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (staleUsers.docs.isNotEmpty) {
        _logger.i('Cleaned up ${staleUsers.docs.length} stale online users');
      }
    } catch (e) {
      _logger.e('Failed to cleanup stale users: $e');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Signing in user: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        await AuditLogService().logEvent(
          action: 'LOGIN',
          userEmail: email,
          status: 'failure',
          errorMessage: 'No user returned from FirebaseAuth',
          ipAddress: await AuditLogContext().getIpAddress(),
          location: await AuditLogContext().getLocation(),
          sessionId: AuditLogContext().getSessionId(),
        );
        throw Exception('Failed to sign in');
      }

      // Get user model from Firestore
      final userModel = await getCurrentUserModel();
      if (userModel == null) {
        await AuditLogService().logEvent(
          action: 'LOGIN',
          userId: user.uid,
          userEmail: email,
          status: 'failure',
          errorMessage: 'User data not found',
          ipAddress: await AuditLogContext().getIpAddress(),
          location: await AuditLogContext().getLocation(),
          sessionId: AuditLogContext().getSessionId(),
        );
        throw Exception('User data not found');
      }

      // Check if user is active
      if (!userModel.isActive) {
        await AuditLogService().logEvent(
          action: 'LOGIN',
          userId: user.uid,
          userEmail: email,
          status: 'denied',
          errorMessage: 'Account is deactivated',
          ipAddress: await AuditLogContext().getIpAddress(),
          location: await AuditLogContext().getLocation(),
          sessionId: AuditLogContext().getSessionId(),
        );
        await signOut();
        throw Exception(
          'Account is deactivated. Please contact administrator.',
        );
      }

      // Update user_status collection for online tracking
      await _firestore.collection('user_status').doc(user.uid).set({
        'status': 'online',
        'lastLogin': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'email': user.email,
        'displayName': user.displayName,
      }, SetOptions(merge: true));

      // Initialize presence tracking
      initializePresence();

      await AuditLogService().logEvent(
        action: 'LOGIN',
        userId: user.uid,
        userName: user.displayName,
        userEmail: user.email,
        userRole: userModel.role.value,
        status: 'success',
        ipAddress: await AuditLogContext().getIpAddress(),
        location: await AuditLogContext().getLocation(),
        sessionId: AuditLogContext().getSessionId(),
      );
      _logger.i('User signed in successfully: ${user.uid}');
      return userModel;
    } catch (e) {
      await AuditLogService().logEvent(
        action: 'LOGIN',
        userEmail: email,
        status: 'failure',
        errorMessage: e.toString(),
      );
      _logger.e('Failed to sign in: $e');
      rethrow;
    }
  }

  /// Register new user (only by Super Admin or HR) - Creates user in Firestore only
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    required String createdBy,
    String? phoneNumber,
    String? department,
    String? designation,
    String? reportingManagerId,
    String? hiringManagerId,
    String? candidateId,
  }) async {
    try {
      _logger.i('Registering new user: $email with role: $role');

      // Validate that only authorized roles can create users
      final currentUserModel = await getCurrentUserModel();
      if (currentUserModel == null ||
          (!currentUserModel.isSuperAdmin && !currentUserModel.isAdmin)) {
        throw Exception('Unauthorized to create users');
      }

      // Generate employee ID for all users
      final employeeId = await _generateEmployeeId();

      // Generate a temporary UID for Firestore storage
      final tempUid =
          'pending_${DateTime.now().millisecondsSinceEpoch}_${employeeId}';

      // Create UserModel (stored in Firestore, not Firebase Auth yet)
      final now = DateTime.now();
      final userModel = UserModel(
        uid: tempUid,
        email: email,
        displayName: displayName,
        role: role,
        createdAt: now,
        updatedAt: now,
        isActive: true,
        mfaEnabled: false,
        createdBy: createdBy,
        phoneNumber: phoneNumber,
        department: department,
        employeeId: employeeId,
        candidateId: candidateId,
      );

      // Save to Firestore in 'pending_users' collection using tempUid as document ID
      // This prevents overwrites when multiple users are created simultaneously
      await _firestore.collection('pending_users').doc(tempUid).set({
        ...userModel.toJson(),
        'temporaryPassword': password, // Store temporarily for first login
        'isFirstLogin': true,
        'credentialsShared': false,
        'credentialsSharedAt': null,
        'credentialsSharedBy': null,
        'designation': designation,
        'reportingManagerId': reportingManagerId,
        'hiringManagerId': hiringManagerId,
        'candidateId': candidateId,
      });

      // Create Employee record if role is employee
      if (role == UserRole.employee) {
        await _createEmployeeRecord(userModel, employeeId);
      }

      // 🔥 CREATE EMPLOYEE FOLDER STRUCTURE AUTOMATICALLY
      try {
        _logger.i(
          'Creating employee folder structure for: $employeeId - $displayName',
        );

        final folderResult = await _employeeFolderService
            .createEmployeeFolderStructure(
              employeeId: employeeId,
              fullName: displayName,
              createdBy: createdBy,
              createdByName: currentUserModel.displayName ?? 'System Admin',
              userId: tempUid,
            );

        _logger.i(
          'Employee folder structure created successfully: ${folderResult['success']}',
        );
        _logger.i(
          'Created ${folderResult['folderCount']} folders for employee: $employeeId',
        );

        // Log folder creation success in the user creation audit
        await _logAuthAction(currentUserModel.uid, 'EMPLOYEE_FOLDERS_CREATED', {
          'newUserEmail': email,
          'newUserId': tempUid,
          'employeeId': employeeId,
          'folderCreationSuccess': folderResult['success'],
          'foldersCreated': folderResult['folderCount'],
          'employeeFolderPath': folderResult['employeeFolderPath'],
        });
      } catch (folderError) {
        _logger.e('Failed to create employee folders: $folderError');

        // Log folder creation failure but don't fail user creation
        await _logAuthAction(currentUserModel.uid, 'EMPLOYEE_FOLDERS_FAILED', {
          'newUserEmail': email,
          'newUserId': tempUid,
          'employeeId': employeeId,
          'folderCreationError': folderError.toString(),
        });

        // Note: We don't throw here as user creation should succeed even if folder creation fails
        _logger.w(
          'User created successfully but folder creation failed. Folders can be created later.',
        );
      }

      // Log user creation
      await _logAuthAction(currentUserModel.uid, 'USER_CREATED', {
        'newUserEmail': email,
        'newUserRole': role.name,
        'newUserId': tempUid,
        'employeeId': employeeId,
        'status': 'pending_activation',
        'department': department,
        'designation': designation,
        'reportingManagerId': reportingManagerId,
        'hiringManagerId': hiringManagerId,
        'candidateId': candidateId,
      });

      await AuditLogService().logEvent(
        action: 'REGISTER_USER',
        userEmail: email,
        userName: displayName,
        userRole: role.value,
        status: 'success',
        details: {
          'createdBy': createdBy,
          'department': department,
          'designation': designation,
          'reportingManagerId': reportingManagerId,
          'hiringManagerId': hiringManagerId,
          'candidateId': candidateId,
        },
      );
      _logger.i(
        'User registered successfully: $tempUid with employee ID: $employeeId (pending activation)',
      );
      return userModel;
    } catch (e) {
      await AuditLogService().logEvent(
        action: 'REGISTER_USER',
        userEmail: email,
        userName: displayName,
        userRole: role.value,
        status: 'failure',
        errorMessage: e.toString(),
      );
      _logger.e('Failed to register user: $e');
      rethrow;
    }
  }

  /// Sign in with employee ID and password (for employees)
  Future<UserModel> signInWithEmployeeId({
    required String employeeId,
    required String password,
  }) async {
    try {
      _logger.i('Signing in user with employee ID: $employeeId');

      // First check if user exists in pending_users (not activated yet)
      final pendingQuery =
          await _firestore
              .collection('pending_users')
              .where('employeeId', isEqualTo: employeeId)
              .limit(1)
              .get();

      if (pendingQuery.docs.isNotEmpty) {
        final pendingDoc = pendingQuery.docs.first;
        final pendingData = pendingDoc.data();
        final storedPassword = pendingData['temporaryPassword'] as String?;

        if (storedPassword != password) {
          throw Exception('Invalid credentials');
        }

        // Create Firebase Auth account for first-time login
        final email = pendingData['email'] as String;
        final displayName = pendingData['displayName'] as String;

        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = userCredential.user;
        if (user == null) {
          throw Exception('Failed to create Firebase Auth account');
        }

        await user.updateDisplayName(displayName);

        // Create UserModel with real Firebase UID
        final userModel = UserModel.fromJson({...pendingData, 'uid': user.uid});

        // Move from pending_users to users collection
        // Preserve all additional fields from pending_users
        final userDataForFirestore = {
          ...userModel.toJson(),
          // Preserve additional fields that aren't part of UserModel
          'reportingManagerId': pendingData['reportingManagerId'],
          'hiringManagerId': pendingData['hiringManagerId'],
          'designation': pendingData['designation'],
          'isFirstLogin': true,
          'activatedAt': DateTime.now().toIso8601String(),
        };

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userDataForFirestore);

        // Remove from pending_users using the document ID
        await _firestore
            .collection('pending_users')
            .doc(pendingDoc.id)
            .delete();

        // Log first login
        await _logAuthAction(user.uid, 'FIRST_LOGIN', {
          'employeeId': employeeId,
          'activatedAt': DateTime.now().toIso8601String(),
        });

        _logger.i('User activated and signed in: ${user.uid}');
        return userModel;
      }

      // Check if user exists in regular users collection
      final usersQuery =
          await _firestore
              .collection('users')
              .where('employeeId', isEqualTo: employeeId)
              .limit(1)
              .get();

      if (usersQuery.docs.isEmpty) {
        throw Exception('Employee ID not found');
      }

      final userDoc = usersQuery.docs.first;
      final userData = userDoc.data();
      final userModel = UserModel.fromJson(userData);

      // Check if user is active
      if (!userModel.isActive) {
        throw Exception(
          'Account is deactivated. Please contact administrator.',
        );
      }

      // Sign in with email and password using Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to sign in');
      }

      // Update last login
      await _firestore.collection('users').doc(user.uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      await _logAuthAction(user.uid, 'EMPLOYEE_LOGIN', {
        'employeeId': employeeId,
        'loginMethod': 'employeeId',
      });

      _logger.i('Employee signed in successfully: ${user.uid}');
      return userModel;
    } catch (e) {
      _logger.e('Failed to sign in with employee ID: $e');
      rethrow;
    }
  }

  /// Mark credentials as shared (for tracking)
  Future<void> markCredentialsShared({
    required String employeeId,
    required String sharedBy,
  }) async {
    try {
      // Find the pending user by employeeId field
      final pendingQuery =
          await _firestore
              .collection('pending_users')
              .where('employeeId', isEqualTo: employeeId)
              .limit(1)
              .get();

      if (pendingQuery.docs.isEmpty) {
        throw Exception('Pending user with employee ID $employeeId not found');
      }

      final pendingDoc = pendingQuery.docs.first;

      await _firestore.collection('pending_users').doc(pendingDoc.id).update({
        'credentialsShared': true,
        'credentialsSharedAt': FieldValue.serverTimestamp(),
        'credentialsSharedBy': sharedBy,
      });

      await _logAuthAction(sharedBy, 'CREDENTIALS_SHARED', {
        'targetEmployeeId': employeeId,
        'sharedAt': DateTime.now().toIso8601String(),
      });

      _logger.i('Credentials marked as shared for employee: $employeeId');
    } catch (e) {
      _logger.e('Failed to mark credentials as shared: $e');
      rethrow;
    }
  }

  /// Generate unique employee ID: TRX{year}{6-digit sequence}
  Future<String> _generateEmployeeId() async {
    try {
      final year = DateTime.now().year;
      final prefix = 'TRX$year';

      // Get the last employee ID for this year from both users and pending_users collections
      final usersQuery =
          await _firestore
              .collection('users')
              .where('employeeId', isGreaterThanOrEqualTo: prefix)
              .where('employeeId', isLessThan: 'TRX${year + 1}')
              .orderBy('employeeId', descending: true)
              .limit(1)
              .get();

      final pendingUsersQuery =
          await _firestore
              .collection('pending_users')
              .where('employeeId', isGreaterThanOrEqualTo: prefix)
              .where('employeeId', isLessThan: 'TRX${year + 1}')
              .orderBy('employeeId', descending: true)
              .limit(1)
              .get();

      int nextSequence = 1;

      // Check the highest sequence from users collection
      if (usersQuery.docs.isNotEmpty) {
        final lastEmployeeId =
            usersQuery.docs.first.data()['employeeId'] as String?;
        if (lastEmployeeId != null && lastEmployeeId.startsWith(prefix)) {
          final sequencePart = lastEmployeeId.substring(prefix.length);
          final lastSequence = int.tryParse(sequencePart) ?? 0;
          nextSequence = math.max(nextSequence, lastSequence + 1);
        }
      }

      // Check the highest sequence from pending_users collection
      if (pendingUsersQuery.docs.isNotEmpty) {
        final lastEmployeeId =
            pendingUsersQuery.docs.first.data()['employeeId'] as String?;
        if (lastEmployeeId != null && lastEmployeeId.startsWith(prefix)) {
          final sequencePart = lastEmployeeId.substring(prefix.length);
          final lastSequence = int.tryParse(sequencePart) ?? 0;
          nextSequence = math.max(nextSequence, lastSequence + 1);
        }
      }

      // Generate the employee ID and ensure it's unique across both collections
      String employeeId;
      bool isUnique = false;
      int attempts = 0;
      const maxAttempts = 10;

      do {
        employeeId = '$prefix${nextSequence.toString().padLeft(6, '0')}';

        // Check if this ID already exists in either collection
        final existsInUsers =
            await _firestore
                .collection('users')
                .where('employeeId', isEqualTo: employeeId)
                .limit(1)
                .get();

        final existsInPending =
            await _firestore
                .collection('pending_users')
                .where('employeeId', isEqualTo: employeeId)
                .limit(1)
                .get();

        isUnique = existsInUsers.docs.isEmpty && existsInPending.docs.isEmpty;

        if (!isUnique) {
          nextSequence++;
          attempts++;
          if (attempts >= maxAttempts) {
            throw Exception(
              'Failed to generate unique employee ID after $maxAttempts attempts',
            );
          }
        }
      } while (!isUnique);

      _logger.i('Generated unique employee ID: $employeeId');
      return employeeId;
    } catch (e) {
      _logger.e('Failed to generate employee ID: $e');
      rethrow;
    }
  }

  /// Create employee record in employees collection
  Future<void> _createEmployeeRecord(
    UserModel userModel,
    String employeeId,
  ) async {
    try {
      final employeeData = {
        'id': userModel.uid,
        'userId': userModel.uid,
        'employeeId': employeeId,
        'firstName': userModel.displayName?.split(' ').first ?? '',
        'lastName': userModel.displayName?.split(' ').skip(1).join(' ') ?? '',
        'email': userModel.email,
        'role': userModel.role.value,
        'status': EmployeeStatus.active.value,
        'phoneNumber': userModel.phoneNumber,
        'department': userModel.department,
        'createdAt': userModel.createdAt.toIso8601String(),
        'updatedAt': userModel.updatedAt.toIso8601String(),
        'createdBy': userModel.createdBy,
      };

      await _firestore
          .collection('employees')
          .doc(userModel.uid)
          .set(employeeData);

      _logger.i('Employee record created: $employeeId');
    } catch (e) {
      _logger.e('Failed to create employee record: $e');
      // Don't rethrow - user creation should still succeed
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.i('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      await AuditLogService().logEvent(
        action: 'PASSWORD_RESET_EMAIL',
        userEmail: email,
        status: 'success',
      );
      _logger.i('Password reset email sent successfully');
    } catch (e) {
      await AuditLogService().logEvent(
        action: 'PASSWORD_RESET_EMAIL',
        userEmail: email,
        status: 'failure',
        errorMessage: e.toString(),
      );
      _logger.e('Failed to send password reset email: $e');
      rethrow;
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      await user.updatePassword(newPassword);

      // Update timestamp in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await AuditLogService().logEvent(
        action: 'PASSWORD_UPDATED',
        userId: user.uid,
        userName: user.displayName,
        userEmail: user.email,
        status: 'success',
      );
      await _logAuthAction(user.uid, 'PASSWORD_UPDATED', {});
      _logger.i('Password updated successfully');
    } catch (e) {
      await AuditLogService().logEvent(
        action: 'PASSWORD_UPDATED',
        status: 'failure',
        errorMessage: e.toString(),
      );
      _logger.e('Failed to update password: $e');
      rethrow;
    }
  }

  /// Verify current user's password by re-authentication
  Future<void> verifyCurrentPassword(String email, String password) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Create credential for re-authentication
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Re-authenticate the user
      await user.reauthenticateWithCredential(credential);

      _logger.i('Password verification successful for user: ${user.uid}');
    } catch (e) {
      _logger.e('Password verification failed: $e');
      rethrow;
    }
  }

  /// Update user profile (first-time setup)
  Future<UserModel> updateUserProfile({
    required String displayName,
    String? phoneNumber,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      // Update Firebase Auth display name
      await user.updateDisplayName(displayName);

      // Split displayName into firstName and lastName
      final nameParts = displayName.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Update Firestore document
      final updateData = <String, dynamic>{
        'displayName': displayName,
        'firstName': firstName,
        'lastName': lastName,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (phoneNumber != null) {
        updateData['phoneNumber'] = phoneNumber;
      }

      if (additionalData != null) {
        // Map designation to position for UserModel compatibility
        final mappedData = Map<String, dynamic>.from(additionalData);
        if (mappedData.containsKey('designation')) {
          mappedData['position'] = mappedData['designation'];
          // Keep designation for backward compatibility
        }

        // Map emergencyContactPhone to emergencyContact for compatibility
        if (mappedData.containsKey('emergencyContactPhone')) {
          mappedData['emergencyContact'] = mappedData['emergencyContactPhone'];
          // Keep emergencyContactPhone for backward compatibility
        }

        updateData.addAll(mappedData);
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);

      // Wait a moment for Firestore to update
      await Future.delayed(const Duration(milliseconds: 500));

      // Get updated user model
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        throw Exception('User document not found after update');
      }

      final userModel = UserModel.fromJson(userDoc.data()!);

      await AuditLogService().logEvent(
        action: 'PROFILE_UPDATED',
        userId: user.uid,
        userName: displayName,
        userEmail: user.email,
        status: 'success',
        details: {'phoneNumber': phoneNumber, ...?additionalData},
      );
      _logger.i('User profile updated successfully');
      return userModel;
    } catch (e) {
      await AuditLogService().logEvent(
        action: 'PROFILE_UPDATED',
        status: 'failure',
        errorMessage: e.toString(),
      );
      _logger.e('Failed to update user profile: $e');
      rethrow;
    }
  }

  /// Create Super-Admin user during first-run setup
  Future<UserModel> createSuperAdmin({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _logger.i('Creating Super-Admin user: $email');

      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Update display name
      await user.updateDisplayName(displayName);

      // Generate employee ID for super admin
      final employeeId = await _generateEmployeeId();

      // Create UserModel
      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: UserRole.sa,
        createdAt: now,
        updatedAt: now,
        isActive: true,
        mfaEnabled: false,
        createdBy: 'system',
        employeeId: employeeId,
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());

      // Create backup super admin placeholder
      await _createBackupSuperAdmin();

      // Log super admin creation
      await _logAuthAction(user.uid, 'SUPER_ADMIN_CREATED', {
        'email': email,
        'displayName': displayName,
        'employeeId': employeeId,
      });

      _logger.i(
        'Super-Admin created successfully: ${user.uid} with employee ID: $employeeId',
      );
      return userModel;
    } catch (e) {
      _logger.e('Failed to create Super-Admin: $e');
      rethrow;
    }
  }

  /// Create backup super admin placeholder (inactive)
  Future<void> _createBackupSuperAdmin() async {
    try {
      final backupId =
          'backup_super_admin_${DateTime.now().millisecondsSinceEpoch}';
      final backupUser = UserModel(
        uid: backupId,
        email: 'backup@company.com', // TODO: Replace with actual backup email
        displayName: 'Backup Super Admin',
        role: UserRole.sa,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: false, // Inactive by default
        mfaEnabled: false,
        createdBy: 'system',
      );

      await _firestore
          .collection('users')
          .doc(backupId)
          .set(backupUser.toJson());
      _logger.i('Backup Super-Admin placeholder created');
    } catch (e) {
      _logger.e('Failed to create backup Super-Admin: $e');
      // Don't rethrow - this is not critical for setup
    }
  }

  /// Force MFA enrollment after first login
  Future<void> enrollMFA() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No authenticated user');

      // TODO: Implement MFA enrollment using Firebase Auth
      // This is a placeholder for MFA implementation
      _logger.i('MFA enrollment initiated for user: ${user.uid}');

      // Update user model to reflect MFA status
      await _firestore.collection('users').doc(user.uid).update({
        'mfaEnabled': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _logAuthAction(user.uid, 'MFA_ENROLLED', {
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.e('Failed to enroll MFA: $e');
      rethrow;
    }
  }

  /// Get current user model from Firestore
  Future<UserModel?> getCurrentUserModel() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      // First check the users collection
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      }

      // If not found in users, check pending_users by email
      final pendingQuery =
          await _firestore
              .collection('pending_users')
              .where('email', isEqualTo: user.email)
              .limit(1)
              .get();

      if (pendingQuery.docs.isNotEmpty) {
        final pendingData = pendingQuery.docs.first.data();
        // Create a UserModel with the actual Firebase Auth UID
        final userData = Map<String, dynamic>.from(pendingData);
        userData['uid'] = user.uid; // Use actual Firebase Auth UID
        return UserModel.fromJson(userData);
      }

      return null;
    } catch (e) {
      _logger.e('Failed to get current user model: $e');
      return null;
    }
  }

  /// Get all users from Firestore
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      _logger.e('Failed to get all users: $e');
      return [];
    }
  }

  /// Check if user has required role
  Future<bool> hasRole(UserRole requiredRole) async {
    try {
      final userModel = await getCurrentUserModel();
      if (userModel == null) return false;

      return userModel.role == requiredRole;
    } catch (e) {
      _logger.e('Failed to check user role: $e');
      return false;
    }
  }

  /// Check if user has any of the required roles
  Future<bool> hasAnyRole(List<UserRole> requiredRoles) async {
    try {
      final userModel = await getCurrentUserModel();
      if (userModel == null) return false;

      return requiredRoles.contains(userModel.role);
    } catch (e) {
      _logger.e('Failed to check user roles: $e');
      return false;
    }
  }

  /// Validate password strength
  static bool isPasswordStrong(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 digit, 1 special char
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return regex.hasMatch(password);
  }

  /// Get password strength score (0-4)
  static int getPasswordStrength(String password) {
    int score = 0;

    if (password.length >= 8) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[@$!%*?&]').hasMatch(password)) score++;

    return score;
  }

  /// Log authentication actions for audit trail
  Future<void> _logAuthAction(
    String uid,
    String action,
    Map<String, dynamic> details,
  ) async {
    try {
      final timestamp = DateTime.now();
      await _firestore
          .collection('logs')
          .doc('auth')
          .collection(uid)
          .doc(timestamp.millisecondsSinceEpoch.toString())
          .set({
            'action': action,
            'details': details,
            'timestamp': FieldValue.serverTimestamp(),
            'uid': uid,
          });
    } catch (e) {
      _logger.e('Failed to log auth action: $e');
      // Don't rethrow - logging failure shouldn't break the main flow
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      final user = currentUser;
      if (user != null) {
        await AuditLogService().logEvent(
          action: 'LOGOUT',
          userId: user.uid,
          userName: user.displayName,
          userEmail: user.email,
          status: 'success',
          ipAddress: await AuditLogContext().getIpAddress(),
          location: await AuditLogContext().getLocation(),
          sessionId: AuditLogContext().getSessionId(),
        );
        await _logAuthAction(user.uid, 'SIGN_OUT', {});
        dispose();
        await _firestore.collection('user_status').doc(user.uid).set({
          'status': 'offline',
          'lastLogout': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
          'userId': user.uid,
          'email': user.email,
          'displayName': user.displayName,
        }, SetOptions(merge: true));
      }
      await _auth.signOut();
      _logger.i('User signed out successfully');
    } catch (e) {
      await AuditLogService().logEvent(
        action: 'LOGOUT',
        status: 'failure',
        errorMessage: e.toString(),
        ipAddress: await AuditLogContext().getIpAddress(),
        location: await AuditLogContext().getLocation(),
        sessionId: AuditLogContext().getSessionId(),
      );
      _logger.e('Failed to sign out: $e');
      rethrow;
    }
  }

  /// Get all departments from Firestore
  Future<List<String>> getDepartments() async {
    try {
      final doc =
          await _firestore.collection('system_data').doc('departments').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['list'] ?? []);
      }
      return [];
    } catch (e) {
      _logger.e('Failed to get departments: $e');
      return [];
    }
  }

  /// Get all designations from Firestore
  Future<List<String>> getDesignations() async {
    try {
      final doc =
          await _firestore.collection('system_data').doc('designations').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['list'] ?? []);
      }
      return [];
    } catch (e) {
      _logger.e('Failed to get designations: $e');
      return [];
    }
  }

  /// Get all active users for manager selection
  Future<List<Map<String, dynamic>>> getActiveUsersForSelection() async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('isActive', isEqualTo: true)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': data['displayName'] ?? data['name'] ?? 'Unknown User',
          'displayName': data['displayName'] ?? data['name'] ?? 'Unknown User',
          'email': data['email'] ?? '',
          'employeeId': data['employeeId'] ?? '',
          'department': data['department'] ?? '',
          'role': data['role'] ?? '',
        };
      }).toList();
    } catch (e) {
      _logger.e('Failed to get active users: $e');
      return [];
    }
  }

  /// Initialize system data collections
  Future<void> initializeSystemData() async {
    try {
      // Initialize departments
      await _firestore.collection('system_data').doc('departments').set({
        'list': [
          // Core Business Departments
          'Information Technology',
          'Engineering',
          'Human Resources',
          'Finance & Accounting',
          'Finance',
          'Sales & Marketing',
          'Sales',
          'Marketing',
          'Operations',
          'Customer Service',
          'Customer Support',
          'Research & Development',
          'Quality Assurance',
          'Administration',
          'Legal',

          // Technology & Product
          'IT',
          'Product Management',
          'Data & Analytics',
          'DevOps',
          'Security',
          'Infrastructure',

          // Business Support
          'Business Development',
          'Strategy & Planning',
          'Procurement',
          'Facilities',
          'Communications',
          'Public Relations',

          // Specialized Departments
          'Training & Development',
          'Compliance',
          'Risk Management',
          'Internal Audit',
          'Project Management Office',
          'Business Intelligence',
          'User Experience',
          'Design',
          'Content & Documentation',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Initialize designations - comprehensive list including all hierarchy levels
      await _firestore.collection('system_data').doc('designations').set({
        'list': [
          // C-Level Executives
          'CEO',
          'CTO',
          'CFO',
          'CHRO',
          'COO',
          'CMO',

          // Senior Leadership
          'Vice President',
          'Senior Vice President',
          'Executive Vice President',
          'Director',
          'Senior Director',
          'Associate Director',

          // Management Levels
          'General Manager',
          'Senior Manager',
          'Manager',
          'Assistant Manager',
          'Deputy Manager',

          // Team Leadership
          'Team Lead',
          'Technical Lead',
          'Lead Developer',
          'Project Manager',
          'Product Manager',
          'Program Manager',

          // Senior Professionals
          'Senior Executive',
          'Senior Software Engineer',
          'Senior Consultant',
          'Senior Analyst',
          'Senior Associate',

          // Mid-Level Professionals
          'Executive',
          'Software Engineer',
          'Business Analyst',
          'Data Analyst',
          'QA Engineer',
          'DevOps Engineer',
          'UI/UX Designer',
          'Consultant',
          'Specialist',

          // Junior Professionals
          'Associate',
          'Junior Associate',
          'Junior Software Engineer',
          'Junior Analyst',
          'Junior Executive',

          // Department Specific Roles
          'HR Manager',
          'HR Executive',
          'Finance Manager',
          'Accountant',
          'Sales Manager',
          'Sales Executive',
          'Marketing Manager',
          'Marketing Executive',
          'Operations Manager',
          'Customer Support Executive',
          'Customer Success Manager',

          // Entry Level & Training
          'Trainee',
          'Intern',
          'Graduate Trainee',
          'Management Trainee',

          // Support & Administrative
          'Administrative Assistant',
          'Executive Assistant',
          'Office Manager',
          'Coordinator',
          'Administrator',
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Mark setup as completed
      await FirebaseService().markSetupCompleted();

      _logger.i(
        'System data initialized successfully and setup marked as completed',
      );
    } catch (e) {
      _logger.e('Failed to initialize system data: $e');
      rethrow;
    }
  }
}

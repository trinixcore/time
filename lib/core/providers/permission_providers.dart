import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/permission_config_model.dart';
import '../enums/user_role.dart';
import '../services/permission_management_service.dart';

/// Provider for getting permission configuration for a role
final permissionConfigProvider =
    FutureProvider.family<PermissionConfigModel?, UserRole>((ref, role) async {
      final permissionService = PermissionManagementService();
      return await permissionService.getPermissionConfig(role);
    });

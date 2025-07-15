import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../models/employee.dart';
import '../enums/user_role.dart';
import '../constants/firestore_paths.dart';
import 'firebase_service.dart';
import 'audit_log_service.dart';

/// Represents a node in the organizational hierarchy
class HierarchyNode {
  final String id;
  final String name;
  final String email;
  final String designation;
  final UserRole role;
  final String? department;
  final String? profileImageUrl;
  final String? managerId;
  final List<HierarchyNode> directReports;
  final int level;
  final Map<String, dynamic> metadata;

  HierarchyNode({
    required this.id,
    required this.name,
    required this.email,
    required this.designation,
    required this.role,
    this.department,
    this.profileImageUrl,
    this.managerId,
    this.directReports = const [],
    required this.level,
    this.metadata = const {},
  });

  factory HierarchyNode.fromEmployee(Employee employee, {int level = 0}) {
    return HierarchyNode(
      id: employee.id,
      name: employee.fullName,
      email: employee.email,
      designation: employee.designation ?? 'Associate',
      role: employee.role,
      department: employee.department,
      profileImageUrl: employee.profileImageUrl,
      managerId: employee.reportingManagerId,
      level: level,
      metadata: {
        'employeeId': employee.employeeId,
        'joiningDate': employee.joiningDate?.toIso8601String(),
        'status': employee.status.value,
      },
    );
  }

  factory HierarchyNode.fromUserModel(UserModel user, {int level = 0}) {
    return HierarchyNode(
      id: user.uid,
      name: user.displayName,
      email: user.email,
      designation: user.position ?? 'Associate',
      role: user.role,
      department: user.department,
      profileImageUrl: user.photoUrl,
      managerId: null, // UserModel doesn't have managerId field
      level: level,
      metadata: {
        'createdAt': user.createdAt.toIso8601String(),
        'lastLogin': user.lastLoginAt?.toIso8601String(),
        'isActive': user.isActive,
      },
    );
  }

  HierarchyNode copyWith({
    String? id,
    String? name,
    String? email,
    String? designation,
    UserRole? role,
    String? department,
    String? profileImageUrl,
    String? managerId,
    List<HierarchyNode>? directReports,
    int? level,
    Map<String, dynamic>? metadata,
  }) {
    return HierarchyNode(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      designation: designation ?? this.designation,
      role: role ?? this.role,
      department: department ?? this.department,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      managerId: managerId ?? this.managerId,
      directReports: directReports ?? this.directReports,
      level: level ?? this.level,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'designation': designation,
      'role': role.value,
      'department': department,
      'profileImageUrl': profileImageUrl,
      'managerId': managerId,
      'directReports': directReports.map((node) => node.toJson()).toList(),
      'level': level,
      'metadata': metadata,
    };
  }
}

/// Represents the complete organizational hierarchy
class OrganizationalHierarchy {
  final List<HierarchyNode> rootNodes;
  final Map<String, HierarchyNode> nodeMap;
  final int totalEmployees;
  final int maxDepth;
  final DateTime lastUpdated;

  OrganizationalHierarchy({
    required this.rootNodes,
    required this.nodeMap,
    required this.totalEmployees,
    required this.maxDepth,
    required this.lastUpdated,
  });

  /// Get all nodes at a specific level
  List<HierarchyNode> getNodesAtLevel(int level) {
    return nodeMap.values.where((node) => node.level == level).toList();
  }

  /// Get all nodes in a specific department
  List<HierarchyNode> getNodesByDepartment(String department) {
    return nodeMap.values
        .where((node) => node.department == department)
        .toList();
  }

  /// Get all nodes with a specific designation
  List<HierarchyNode> getNodesByDesignation(String designation) {
    return nodeMap.values
        .where((node) => node.designation == designation)
        .toList();
  }

  /// Get the reporting chain for a specific employee
  List<HierarchyNode> getReportingChain(String employeeId) {
    final chain = <HierarchyNode>[];
    HierarchyNode? current = nodeMap[employeeId];

    while (current != null) {
      chain.add(current);
      current = current.managerId != null ? nodeMap[current.managerId!] : null;
    }

    return chain;
  }

  /// Get all subordinates for a specific manager
  List<HierarchyNode> getAllSubordinates(String managerId) {
    final subordinates = <HierarchyNode>[];
    final manager = nodeMap[managerId];

    if (manager != null) {
      _collectSubordinates(manager, subordinates);
    }

    return subordinates;
  }

  void _collectSubordinates(
    HierarchyNode node,
    List<HierarchyNode> subordinates,
  ) {
    for (final directReport in node.directReports) {
      subordinates.add(directReport);
      _collectSubordinates(directReport, subordinates);
    }
  }
}

class HierarchyService {
  static final HierarchyService _instance = HierarchyService._internal();
  factory HierarchyService() => _instance;
  HierarchyService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  static final Logger _logger = Logger();

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  /// Get the complete organizational hierarchy
  Future<OrganizationalHierarchy> getOrganizationalHierarchy() async {
    try {
      _logger.i('Fetching organizational hierarchy...');

      // Get all employees
      final employeesSnapshot =
          await _firestore
              .collection(FirestorePaths.employees)
              .where('status', whereIn: ['active', 'on_leave'])
              .get();

      final employees =
          employeesSnapshot.docs
              .map((doc) => Employee.fromFirestore(doc.data()))
              .toList();

      _logger.i('Found ${employees.length} active employees');

      // Build hierarchy
      final hierarchy = _buildHierarchy(employees);

      _logger.i(
        'Built hierarchy with ${hierarchy.rootNodes.length} root nodes',
      );

      return hierarchy;
    } catch (e) {
      _logger.e('Failed to get organizational hierarchy: $e');
      rethrow;
    }
  }

  /// Get hierarchy for a specific employee (their position in the org chart)
  Future<Map<String, dynamic>> getEmployeeHierarchy(String employeeId) async {
    try {
      _logger.i('Fetching hierarchy for employee: $employeeId');

      // Get the target employee
      final employeeDoc =
          await _firestore
              .collection(FirestorePaths.employees)
              .doc(employeeId)
              .get();

      if (!employeeDoc.exists) {
        throw Exception('Employee not found');
      }

      final employee = Employee.fromFirestore(employeeDoc.data()!);

      // Get manager hierarchy (upward)
      final managerChain = await _getManagerChain(employee);

      // Get direct reports (downward)
      final directReports = await _getDirectReports(employeeId);

      // Get peers (same manager)
      final peers = await _getPeers(employee);

      return {
        'employee': _employeeToHierarchyData(employee),
        'managerChain': managerChain,
        'directReports': directReports,
        'peers': peers,
        'totalSubordinates': await _getTotalSubordinates(employeeId),
      };
    } catch (e) {
      _logger.e('Failed to get employee hierarchy: $e');
      rethrow;
    }
  }

  /// Get department hierarchy
  Future<OrganizationalHierarchy> getDepartmentHierarchy(
    String department,
  ) async {
    try {
      _logger.i('Fetching hierarchy for department: $department');

      final employeesSnapshot =
          await _firestore
              .collection(FirestorePaths.employees)
              .where('department', isEqualTo: department)
              .where('status', whereIn: ['active', 'on_leave'])
              .get();

      final employees =
          employeesSnapshot.docs
              .map((doc) => Employee.fromFirestore(doc.data()))
              .toList();

      return _buildHierarchy(employees);
    } catch (e) {
      _logger.e('Failed to get department hierarchy: $e');
      rethrow;
    }
  }

  /// Get hierarchy by designation level
  Future<List<HierarchyNode>> getHierarchyByDesignation(
    String designation,
  ) async {
    try {
      _logger.i('Fetching hierarchy for designation: $designation');

      final employeesSnapshot =
          await _firestore
              .collection(FirestorePaths.employees)
              .where('designation', isEqualTo: designation)
              .where('status', whereIn: ['active', 'on_leave'])
              .get();

      final employees =
          employeesSnapshot.docs
              .map((doc) => Employee.fromFirestore(doc.data()))
              .toList();

      return employees
          .map((employee) => HierarchyNode.fromEmployee(employee))
          .toList();
    } catch (e) {
      _logger.e('Failed to get hierarchy by designation: $e');
      rethrow;
    }
  }

  /// Update reporting relationship
  Future<void> updateReportingRelationship({
    required String employeeId,
    String? newManagerId,
  }) async {
    try {
      _logger.i(
        'Updating reporting relationship for $employeeId to $newManagerId',
      );

      // Get current employee data for audit logging
      final currentEmployeeDoc =
          await _firestore
              .collection(FirestorePaths.employees)
              .doc(employeeId)
              .get();

      if (!currentEmployeeDoc.exists) {
        throw Exception('Employee not found');
      }

      final currentEmployee = Employee.fromFirestore(
        currentEmployeeDoc.data()!,
      );
      final oldManagerId = currentEmployee.reportingManagerId;

      // Validate the new reporting relationship
      if (newManagerId != null) {
        await _validateReportingRelationship(employeeId, newManagerId);
      }

      // Get new manager data for audit logging
      Map<String, dynamic>? newManagerData;
      if (newManagerId != null) {
        final newManagerDoc =
            await _firestore
                .collection(FirestorePaths.employees)
                .doc(newManagerId)
                .get();
        if (newManagerDoc.exists) {
          newManagerData = newManagerDoc.data();
        }
      }

      // Update the employee's manager
      await _firestore
          .collection(FirestorePaths.employees)
          .doc(employeeId)
          .update({
            'reportingManagerId': newManagerId,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Audit log for reporting relationship update
      await AuditLogService().logEvent(
        action: 'HIERARCHY_REPORTING_RELATIONSHIP_UPDATE',
        userId: 'system', // This is typically done by HR/Admin
        userName: 'System',
        userEmail: 'system@company.com',
        status: 'success',
        targetType: 'employee',
        targetId: employeeId,
        details: {
          'employeeId': employeeId,
          'employeeName': currentEmployee.fullName,
          'employeeEmail': currentEmployee.email,
          'oldManagerId': oldManagerId,
          'newManagerId': newManagerId,
          'oldManagerName': oldManagerId != null ? 'Previous Manager' : 'None',
          'newManagerName': newManagerData?['fullName'] ?? 'New Manager',
          'changeType':
              oldManagerId == null
                  ? 'initial_assignment'
                  : newManagerId == null
                  ? 'removal'
                  : 'reassignment',
        },
      );

      _logger.i('Successfully updated reporting relationship');
    } catch (e) {
      // Audit log for failed reporting relationship update
      await AuditLogService().logEvent(
        action: 'HIERARCHY_REPORTING_RELATIONSHIP_UPDATE',
        userId: 'system',
        userName: 'System',
        userEmail: 'system@company.com',
        status: 'failed',
        targetType: 'employee',
        targetId: employeeId,
        details: {
          'employeeId': employeeId,
          'newManagerId': newManagerId,
          'error': e.toString(),
        },
      );
      _logger.e('Failed to update reporting relationship: $e');
      rethrow;
    }
  }

  /// Get organization statistics
  Future<Map<String, dynamic>> getOrganizationStats() async {
    try {
      _logger.i('Fetching organization statistics...');

      final employeesSnapshot =
          await _firestore
              .collection(FirestorePaths.employees)
              .where('status', whereIn: ['active', 'on_leave'])
              .get();

      final employees =
          employeesSnapshot.docs
              .map((doc) => Employee.fromFirestore(doc.data()))
              .toList();

      // Calculate statistics
      final stats = <String, dynamic>{};

      // Total employees
      stats['totalEmployees'] = employees.length;

      // By designation
      final designationCounts = <String, int>{};
      for (final employee in employees) {
        final designation = employee.designation ?? 'Unknown';
        designationCounts[designation] =
            (designationCounts[designation] ?? 0) + 1;
      }
      stats['byDesignation'] = designationCounts;

      // By department
      final departmentCounts = <String, int>{};
      for (final employee in employees) {
        final department = employee.department ?? 'Unknown';
        departmentCounts[department] = (departmentCounts[department] ?? 0) + 1;
      }
      stats['byDepartment'] = departmentCounts;

      // By role
      final roleCounts = <String, int>{};
      for (final employee in employees) {
        final role = employee.role.displayName;
        roleCounts[role] = (roleCounts[role] ?? 0) + 1;
      }
      stats['byRole'] = roleCounts;

      // Hierarchy depth
      final hierarchy = _buildHierarchy(employees);
      stats['maxHierarchyDepth'] = hierarchy.maxDepth;
      stats['rootNodes'] = hierarchy.rootNodes.length;

      return stats;
    } catch (e) {
      _logger.e('Failed to get organization stats: $e');
      rethrow;
    }
  }

  /// Private helper methods

  OrganizationalHierarchy _buildHierarchy(List<Employee> employees) {
    final nodeMap = <String, HierarchyNode>{};
    final rootNodes = <HierarchyNode>[];

    // Create nodes
    for (final employee in employees) {
      nodeMap[employee.id] = HierarchyNode.fromEmployee(employee);
    }

    // Build parent-child relationships
    for (final employee in employees) {
      final node = nodeMap[employee.id]!;

      if (employee.reportingManagerId != null &&
          nodeMap.containsKey(employee.reportingManagerId!)) {
        final manager = nodeMap[employee.reportingManagerId!]!;
        final updatedDirectReports = List<HierarchyNode>.from(
          manager.directReports,
        )..add(node);
        nodeMap[employee.reportingManagerId!] = manager.copyWith(
          directReports: updatedDirectReports,
        );
      } else {
        rootNodes.add(node);
      }
    }

    // Calculate levels
    _calculateLevels(rootNodes, nodeMap);

    // Calculate max depth
    int maxDepth = 0;
    for (final node in nodeMap.values) {
      if (node.level > maxDepth) {
        maxDepth = node.level;
      }
    }

    return OrganizationalHierarchy(
      rootNodes: rootNodes,
      nodeMap: nodeMap,
      totalEmployees: employees.length,
      maxDepth: maxDepth,
      lastUpdated: DateTime.now(),
    );
  }

  void _calculateLevels(
    List<HierarchyNode> nodes,
    Map<String, HierarchyNode> nodeMap, [
    int level = 0,
  ]) {
    for (final node in nodes) {
      final updatedNode = node.copyWith(level: level);
      nodeMap[node.id] = updatedNode;
      _calculateLevels(updatedNode.directReports, nodeMap, level + 1);
    }
  }

  Future<List<Map<String, dynamic>>> _getManagerChain(Employee employee) async {
    final chain = <Map<String, dynamic>>[];
    String? currentManagerId = employee.reportingManagerId;

    while (currentManagerId != null) {
      final managerDoc =
          await _firestore
              .collection(FirestorePaths.employees)
              .doc(currentManagerId)
              .get();

      if (!managerDoc.exists) break;

      final manager = Employee.fromFirestore(managerDoc.data()!);
      chain.add(_employeeToHierarchyData(manager));
      currentManagerId = manager.reportingManagerId;
    }

    return chain;
  }

  Future<List<Map<String, dynamic>>> _getDirectReports(String managerId) async {
    final reportsSnapshot =
        await _firestore
            .collection(FirestorePaths.employees)
            .where('reportingManagerId', isEqualTo: managerId)
            .where('status', whereIn: ['active', 'on_leave'])
            .get();

    return reportsSnapshot.docs
        .map(
          (doc) => _employeeToHierarchyData(Employee.fromFirestore(doc.data())),
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getPeers(Employee employee) async {
    if (employee.reportingManagerId == null) return [];

    final peersSnapshot =
        await _firestore
            .collection(FirestorePaths.employees)
            .where('reportingManagerId', isEqualTo: employee.reportingManagerId)
            .where('status', whereIn: ['active', 'on_leave'])
            .get();

    return peersSnapshot.docs
        .where((doc) => doc.id != employee.id)
        .map(
          (doc) => _employeeToHierarchyData(Employee.fromFirestore(doc.data())),
        )
        .toList();
  }

  Future<int> _getTotalSubordinates(String managerId) async {
    final directReports = await _getDirectReports(managerId);
    int total = directReports.length;

    for (final report in directReports) {
      total += await _getTotalSubordinates(report['id']);
    }

    return total;
  }

  Future<void> _validateReportingRelationship(
    String employeeId,
    String managerId,
  ) async {
    // Check if manager exists
    final managerDoc =
        await _firestore
            .collection(FirestorePaths.employees)
            .doc(managerId)
            .get();

    if (!managerDoc.exists) {
      throw Exception('Manager not found');
    }

    // Check for circular reporting (employee cannot report to their subordinate)
    final subordinates = await _getAllSubordinateIds(employeeId);
    if (subordinates.contains(managerId)) {
      throw Exception('Circular reporting relationship detected');
    }
  }

  Future<Set<String>> _getAllSubordinateIds(String managerId) async {
    final subordinates = <String>{};
    final directReports = await _getDirectReports(managerId);

    for (final report in directReports) {
      final reportId = report['id'] as String;
      subordinates.add(reportId);
      subordinates.addAll(await _getAllSubordinateIds(reportId));
    }

    return subordinates;
  }

  Map<String, dynamic> _employeeToHierarchyData(Employee employee) {
    return {
      'id': employee.id,
      'employeeId': employee.employeeId,
      'displayName': employee.fullName,
      'email': employee.email,
      'role': employee.role.displayName,
      'designation': employee.designation ?? 'Unknown',
      'department': employee.department,
      'profileImageUrl': employee.profileImageUrl,
      'managerId': employee.reportingManagerId,
      'joiningDate': employee.joiningDate?.toIso8601String(),
      'status': employee.status.displayName,
    };
  }

  /// Build hierarchy from UserModel list (for org chart)
  List<HierarchyNode> buildHierarchy(List<UserModel> users) {
    final nodeMap = <String, HierarchyNode>{};
    final rootNodes = <HierarchyNode>[];

    // Create nodes from UserModel
    for (final user in users) {
      nodeMap[user.uid] = HierarchyNode.fromUserModel(user);
    }

    // Since UserModel doesn't have managerId, we'll return all as root nodes
    // This is a simplified version - in a real implementation, you'd need
    // to add managerId to UserModel or use Employee model instead
    rootNodes.addAll(nodeMap.values);

    return rootNodes;
  }
}

// Riverpod provider for HierarchyService
final hierarchyServiceProvider = Provider<HierarchyService>((ref) {
  return HierarchyService();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/task_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/task_model.dart';
import '../../../core/models/task_comment_model.dart';
import '../../../core/models/task_time_log_model.dart';
import '../../../core/models/project.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/enums/priority_level.dart';
import '../../../core/enums/project_priority.dart';
import '../../../shared/providers/auth_providers.dart';
import 'package:logger/logger.dart';
import '../../../core/services/audit_log_service.dart';

part 'task_providers.g.dart';

final Logger _logger = Logger();

/// Helper function to convert PriorityLevel to ProjectPriority
ProjectPriority _convertPriorityLevel(PriorityLevel priority) {
  switch (priority) {
    case PriorityLevel.low:
      return ProjectPriority.low;
    case PriorityLevel.medium:
      return ProjectPriority.medium;
    case PriorityLevel.high:
      return ProjectPriority.high;
    case PriorityLevel.urgent:
      return ProjectPriority
          .high; // Map urgent to high since ProjectPriority doesn't have urgent
    case PriorityLevel.critical:
      return ProjectPriority.critical;
  }
}

// Task Service Provider
@riverpod
TaskService taskService(TaskServiceRef ref) {
  return TaskService();
}

// Auth Service Provider
@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}

// Active Users Provider
@riverpod
Future<List<Map<String, dynamic>>> activeUsers(ActiveUsersRef ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getActiveUsersForSelection();
}

// Task Categories Provider
@riverpod
List<String> taskCategories(TaskCategoriesRef ref) {
  return [
    'Development',
    'Design',
    'Testing',
    'Documentation',
    'Research',
    'Meeting',
    'Review',
    'Bug Fix',
    'Feature',
    'Enhancement',
    'Maintenance',
    'Support',
    'Training',
    'Planning',
    'Analysis',
    'Other',
  ];
}

// Departments Provider
@riverpod
Future<List<String>> departments(DepartmentsRef ref) async {
  final taskService = ref.watch(taskServiceProvider);
  return await taskService.getDepartments();
}

// Projects by Department Provider
@riverpod
Future<List<Project>> projectsByDepartment(
  ProjectsByDepartmentRef ref,
  String departmentId,
) async {
  final taskService = ref.watch(taskServiceProvider);
  return await taskService.getProjectsByDepartment(departmentId);
}

// All Tasks Provider
@riverpod
Future<List<TaskModel>> allTasks(AllTasksRef ref) async {
  final taskService = ref.watch(taskServiceProvider);
  return await taskService.getTasks();
}

// Tasks by Department Provider
@riverpod
Future<List<TaskModel>> tasksByDepartment(
  TasksByDepartmentRef ref,
  String departmentId,
) async {
  final taskService = ref.watch(taskServiceProvider);
  return await taskService.getTasks(departmentId: departmentId);
}

// Tasks by Project Provider
@riverpod
Future<List<TaskModel>> tasksByProject(
  TasksByProjectRef ref,
  String projectId,
) async {
  final taskService = ref.watch(taskServiceProvider);
  return await taskService.getTasks(projectId: projectId);
}

// My Tasks Provider (tasks visible to current user)
@riverpod
Future<List<TaskModel>> myTasks(MyTasksRef ref) async {
  final taskService = ref.watch(taskServiceProvider);
  final currentUser = await ref.watch(currentUserProvider.future);

  if (currentUser == null) return [];

  // Get all tasks and filter by visibility
  final allTasks = await taskService.getTasks();

  return allTasks.where((task) {
    // User can see task if they are:
    // 1. The creator
    // 2. The assignee
    // 3. In the watchers/observers list
    return task.createdBy == currentUser.uid ||
        task.assignedTo == currentUser.uid ||
        task.watchers.contains(currentUser.uid);
  }).toList();
}

// User Accessible Tasks Provider (with visibility controls)
@riverpod
Future<List<TaskModel>> userAccessibleTasks(
  UserAccessibleTasksRef ref, {
  String? departmentId,
  String? projectId,
  TaskStatus? status,
  PriorityLevel? priority,
  bool? isOverdue,
  String? searchQuery,
}) async {
  final taskService = ref.watch(taskServiceProvider);
  final currentUser = await ref.watch(currentUserProvider.future);

  if (currentUser == null) return [];

  // Get all tasks with filters
  final allTasks = await taskService.getTasks(
    departmentId: departmentId,
    projectId: projectId,
    status: status,
    priority: priority,
    isOverdue: isOverdue,
    searchQuery: searchQuery,
  );

  // Filter by visibility - user can see task if they are:
  // 1. The creator
  // 2. The assignee
  // 3. In the watchers/observers list
  return allTasks.where((task) {
    return task.createdBy == currentUser.uid ||
        task.assignedTo == currentUser.uid ||
        task.watchers.contains(currentUser.uid);
  }).toList();
}

// Task by ID Provider
@riverpod
Future<TaskModel?> taskById(TaskByIdRef ref, String taskId) async {
  final taskService = ref.watch(taskServiceProvider);
  return await taskService.getTaskById(taskId);
}

// Task Comments Provider
@riverpod
Future<List<TaskCommentModel>> taskComments(
  TaskCommentsRef ref,
  String taskId,
) async {
  final taskService = ref.watch(taskServiceProvider);
  return await taskService.getTaskComments(taskId);
}

// Task Time Logs Provider
@riverpod
Future<List<TaskTimeLogModel>> taskTimeLogs(
  TaskTimeLogsRef ref,
  String taskId,
) async {
  final taskService = ref.watch(taskServiceProvider);
  return await taskService.getTaskTimeLogs(taskId);
}

// Task Analytics Provider
@riverpod
Future<Map<String, dynamic>> taskAnalytics(
  TaskAnalyticsRef ref, {
  String? departmentId,
  String? projectId,
  String? assignedTo,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final taskService = ref.watch(taskServiceProvider);
  return await taskService.getTaskAnalytics(
    departmentId: departmentId,
    projectId: projectId,
    assignedTo: assignedTo,
    startDate: startDate,
    endDate: endDate,
  );
}

// Filtered Tasks Provider (with visibility controls)
@riverpod
Future<List<TaskModel>> filteredTasks(
  FilteredTasksRef ref, {
  String? departmentId,
  String? projectId,
  String? assignedTo,
  TaskStatus? status,
  PriorityLevel? priority,
  bool? isOverdue,
  String? searchQuery,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final taskService = ref.watch(taskServiceProvider);
  final currentUser = await ref.watch(currentUserProvider.future);

  if (currentUser == null) return [];

  // Get all tasks with filters
  final allTasks = await taskService.getTasks(
    departmentId: departmentId,
    projectId: projectId,
    assignedTo: assignedTo,
    status: status,
    priority: priority,
    isOverdue: isOverdue,
    searchQuery: searchQuery,
  );

  // Filter by visibility and creation date
  return allTasks.where((task) {
    final visible =
        task.createdBy == currentUser.uid ||
        task.assignedTo == currentUser.uid ||
        task.watchers.contains(currentUser.uid);
    if (!visible) return false;
    if (startDate != null && endDate != null) {
      final created = task.createdAt;
      if (created.isBefore(startDate) || created.isAfter(endDate)) {
        return false;
      }
    }
    return true;
  }).toList();
}

// Task Statistics Provider
@riverpod
Future<Map<String, int>> taskStatistics(TaskStatisticsRef ref) async {
  final tasks = await ref.watch(myTasksProvider.future);

  return {
    'total': tasks.length,
    'todo': tasks.where((t) => t.status.isTodo).length,
    'inProgress': tasks.where((t) => t.status.isInProgress).length,
    'completed': tasks.where((t) => t.status.isCompleted).length,
    'overdue': tasks.where((t) => t.isOverdue).length,
  };
}

// My Task Statistics Provider
@riverpod
Future<Map<String, int>> myTaskStatistics(MyTaskStatisticsRef ref) async {
  final tasks = await ref.watch(myTasksProvider.future);

  return {
    'total': tasks.length,
    'todo': tasks.where((t) => t.status.isTodo).length,
    'inProgress': tasks.where((t) => t.status.isInProgress).length,
    'completed': tasks.where((t) => t.status.isCompleted).length,
    'overdue': tasks.where((t) => t.isOverdue).length,
  };
}

// Task Creation Provider
@riverpod
class TaskCreation extends _$TaskCreation {
  @override
  FutureOr<void> build() {}

  Future<TaskModel?> createTask({
    required String title,
    required String description,
    required PriorityLevel priority,
    required DateTime dueDate,
    required String departmentId,
    required String projectId,
    required String assignedTo,
    String? category,
    List<String>? tags,
    int? estimatedHours,
    String? parentTaskId,
    List<String>? dependencies,
    List<String>? watchers, // Add watchers parameter
  }) async {
    // Don't set loading state if already loading
    if (state.isLoading) return null;

    state = const AsyncValue.loading();

    try {
      final taskService = ref.read(taskServiceProvider);
      final currentUser = await ref.read(currentUserProvider.future);

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final task = await taskService.createTask(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        departmentId: departmentId,
        projectId: projectId,
        assignedTo: assignedTo,
        createdBy: currentUser.uid,
        category: category,
        tags: tags,
        estimatedHours: estimatedHours,
        parentTaskId: parentTaskId,
        dependencies: dependencies,
        watchers: watchers, // Pass watchers to service
      );

      // Audit log for task creation
      await AuditLogService().logEvent(
        action: 'TASK_CREATE',
        userId: currentUser.uid,
        userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
        userEmail: currentUser.email,
        status: 'success',
        targetType: 'task',
        targetId: task.id,
        details: {
          'taskTitle': task.title,
          'taskDescription': task.description,
          'taskPriority': priority.value,
          'taskDueDate': dueDate.toIso8601String(),
          'taskDepartmentId': departmentId,
          'taskProjectId': projectId,
          'taskAssignedTo': assignedTo,
          'taskCategory': category,
          'taskTags': tags,
          'taskEstimatedHours': estimatedHours,
          'taskParentTaskId': parentTaskId,
          'taskDependencies': dependencies,
          'taskWatchers': watchers,
        },
      );

      // Invalidate related providers
      ref.invalidate(allTasksProvider);
      ref.invalidate(filteredTasksProvider);
      ref.invalidate(taskStatisticsProvider);
      ref.invalidate(myTasksProvider);
      ref.invalidate(myTaskStatisticsProvider);
      ref.invalidate(userAccessibleTasksProvider);

      // Only set state if not already completed
      if (!state.hasValue && !state.hasError) {
        state = const AsyncValue.data(null);
      }
      return task;
    } catch (error, stackTrace) {
      // Only set error state if not already completed
      if (!state.hasValue && !state.hasError) {
        state = AsyncValue.error(error, stackTrace);
      }
      return null;
    }
  }
}

// Project Creation Provider
@riverpod
class ProjectCreation extends _$ProjectCreation {
  @override
  FutureOr<void> build() {}

  Future<Project?> createProject({
    required String name,
    required String description,
    required String departmentId,
    required String managerId,
    DateTime? startDate,
    DateTime? endDate,
    ProjectPriority priority = ProjectPriority.medium,
  }) async {
    // Don't set loading state if already loading
    if (state.isLoading) return null;

    state = const AsyncValue.loading();

    try {
      final taskService = ref.read(taskServiceProvider);
      final currentUser = await ref.read(currentUserProvider.future);

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final project = await taskService.createProject(
        name: name,
        description: description,
        departmentId: departmentId,
        managerId: managerId,
        createdBy: currentUser.uid,
        startDate: startDate,
        endDate: endDate,
        priority: priority,
      );

      // Invalidate projects provider for this department
      ref.invalidate(projectsByDepartmentProvider(departmentId));

      // Only set state if not already completed
      if (!state.hasValue && !state.hasError) {
        state = const AsyncValue.data(null);
      }
      return project;
    } catch (error, stackTrace) {
      // Only set error state if not already completed
      if (!state.hasValue && !state.hasError) {
        state = AsyncValue.error(error, stackTrace);
      }
      return null;
    }
  }
}

// Task Status Update Provider
@riverpod
class TaskStatusUpdate extends _$TaskStatusUpdate {
  @override
  FutureOr<void> build() {}

  Future<bool> updateStatus(String taskId, TaskStatus newStatus) async {
    state = const AsyncValue.loading();

    try {
      final taskService = ref.read(taskServiceProvider);
      final currentUser = await ref.read(currentUserProvider.future);

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final success = await taskService.updateTaskStatus(taskId, newStatus);

      if (success) {
        // Audit log for task status update
        await AuditLogService().logEvent(
          action: 'TASK_STATUS_UPDATE',
          userId: currentUser.uid,
          userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
          userEmail: currentUser.email,
          status: 'success',
          targetType: 'task',
          targetId: taskId,
          details: {'newStatus': newStatus.value},
        );

        // Invalidate related providers
        ref.invalidate(allTasksProvider);
        ref.invalidate(filteredTasksProvider);
        ref.invalidate(taskStatisticsProvider);
        ref.invalidate(myTasksProvider);
        ref.invalidate(myTaskStatisticsProvider);
        ref.invalidate(userAccessibleTasksProvider);
        ref.invalidate(taskByIdProvider(taskId));
      }

      state = const AsyncValue.data(null);
      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

// Task Time Tracking Provider (for logging time and updating progress)
@riverpod
class TaskTimeTracking extends _$TaskTimeTracking {
  @override
  FutureOr<void> build() {}

  /// Log time worked manually for a task
  Future<bool> logTimeWorked({
    required String taskId,
    required int hoursWorked,
    required String description,
    DateTime? workDate,
  }) async {
    if (state.isLoading) return false;

    try {
      final taskService = ref.read(taskServiceProvider);
      final authService = ref.read(authServiceProvider);
      final currentUser = authService.currentUser;

      if (currentUser == null) return false;

      final success = await taskService.logTimeWorked(
        taskId: taskId,
        userId: currentUser.uid,
        userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
        hoursWorked: hoursWorked,
        description: description,
        workDate: workDate,
      );

      if (success) {
        // Audit log for task time logging
        await AuditLogService().logEvent(
          action: 'TASK_TIME_LOG',
          userId: currentUser.uid,
          userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
          userEmail: currentUser.email,
          status: 'success',
          targetType: 'task',
          targetId: taskId,
          details: {
            'hoursWorked': hoursWorked,
            'description': description,
            'workDate': workDate?.toIso8601String(),
          },
        );

        // Refresh the task data
        ref.invalidate(taskByIdProvider(taskId));
        ref.invalidate(taskTimeLogsProvider(taskId));
      }

      return success;
    } catch (e) {
      _logger.e('Failed to log time worked: $e');
      return false;
    }
  }

  /// Update task progress
  Future<bool> updateProgress({
    required String taskId,
    required int progressPercentage,
    String? notes,
  }) async {
    if (state.isLoading) return false;

    try {
      final taskService = ref.read(taskServiceProvider);
      final currentUser = await ref.read(currentUserProvider.future);

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final success = await taskService.updateProgress(
        taskId: taskId,
        progressPercentage: progressPercentage,
        notes: notes,
      );

      if (success) {
        // Audit log for task progress update
        await AuditLogService().logEvent(
          action: 'TASK_PROGRESS_UPDATE',
          userId: currentUser.uid,
          userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
          userEmail: currentUser.email,
          status: 'success',
          targetType: 'task',
          targetId: taskId,
          details: {'progressPercentage': progressPercentage, 'notes': notes},
        );

        // Refresh the task data
        ref.invalidate(taskByIdProvider(taskId));
        ref.invalidate(taskCommentsProvider(taskId));
      }

      return success;
    } catch (e) {
      _logger.e('Failed to update progress: $e');
      return false;
    }
  }
}

// Comment Creation Provider
@riverpod
class CommentCreation extends _$CommentCreation {
  @override
  FutureOr<void> build() {}

  Future<TaskCommentModel?> addComment({
    required String taskId,
    required String content,
    String? parentCommentId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final taskService = ref.read(taskServiceProvider);
      final currentUser = await ref.read(currentUserProvider.future);

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final comment = await taskService.addComment(
        taskId: taskId,
        content: content,
        authorId: currentUser.uid,
        authorName: currentUser.displayName ?? 'Unknown User',
        parentCommentId: parentCommentId,
      );

      if (comment != null) {
        // Audit log for task comment creation
        await AuditLogService().logEvent(
          action: 'TASK_COMMENT_ADD',
          userId: currentUser.uid,
          userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
          userEmail: currentUser.email,
          status: 'success',
          targetType: 'task',
          targetId: taskId,
          details: {
            'commentId': comment.id,
            'commentContent': content,
            'parentCommentId': parentCommentId,
          },
        );

        // Invalidate comments
        ref.invalidate(taskCommentsProvider(taskId));
      }

      state = const AsyncValue.data(null);
      return comment;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
}

// Task Watchers Management Provider
@riverpod
class TaskWatchersManagement extends _$TaskWatchersManagement {
  @override
  FutureOr<void> build() {}

  Future<bool> addWatcher(String taskId, String userId) async {
    state = const AsyncValue.loading();

    try {
      final taskService = ref.read(taskServiceProvider);
      final success = await taskService.addTaskWatcher(taskId, userId);

      if (success) {
        // Invalidate related providers
        ref.invalidate(taskByIdProvider(taskId));
        ref.invalidate(myTasksProvider);
        ref.invalidate(userAccessibleTasksProvider);
      }

      state = const AsyncValue.data(null);
      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> removeWatcher(String taskId, String userId) async {
    state = const AsyncValue.loading();

    try {
      final taskService = ref.read(taskServiceProvider);
      final success = await taskService.removeTaskWatcher(taskId, userId);

      if (success) {
        // Invalidate related providers
        ref.invalidate(taskByIdProvider(taskId));
        ref.invalidate(myTasksProvider);
        ref.invalidate(userAccessibleTasksProvider);
      }

      state = const AsyncValue.data(null);
      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

// Task Access Check Provider
@riverpod
Future<bool> canAccessTask(CanAccessTaskRef ref, String taskId) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  final task = await ref.watch(taskByIdProvider(taskId).future);

  if (currentUser == null || task == null) return false;

  // User can access task if they are:
  // 1. The creator
  // 2. The assignee
  // 3. In the watchers/observers list
  return task.createdBy == currentUser.uid ||
      task.assignedTo == currentUser.uid ||
      task.watchers.contains(currentUser.uid);
}

// Task Assignee Update Provider
@riverpod
class TaskAssigneeUpdate extends _$TaskAssigneeUpdate {
  @override
  FutureOr<void> build() {}

  Future<bool> updateAssignee(String taskId, String newAssigneeId) async {
    state = const AsyncValue.loading();
    try {
      final taskService = ref.read(taskServiceProvider);
      final currentUser = await ref.read(currentUserProvider.future);

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final success = await taskService.updateTask(taskId, {
        'assignedTo': newAssigneeId,
      });

      if (success) {
        // Audit log for task assignment update
        await AuditLogService().logEvent(
          action: 'TASK_ASSIGNMENT_UPDATE',
          userId: currentUser.uid,
          userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
          userEmail: currentUser.email,
          status: 'success',
          targetType: 'task',
          targetId: taskId,
          details: {'newAssigneeId': newAssigneeId},
        );

        ref.invalidate(taskByIdProvider(taskId));
        ref.invalidate(allTasksProvider);
        ref.invalidate(filteredTasksProvider);
        ref.invalidate(myTasksProvider);
        ref.invalidate(userAccessibleTasksProvider);
      }
      state = const AsyncValue.data(null);
      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

// Task Delete Provider
@riverpod
class TaskDelete extends _$TaskDelete {
  @override
  FutureOr<void> build() {}

  Future<bool> deleteTask(String taskId) async {
    state = const AsyncValue.loading();
    try {
      final taskService = ref.read(taskServiceProvider);
      final currentUser = await ref.read(currentUserProvider.future);

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final success = await taskService.deleteTask(taskId);
      if (success) {
        // Audit log for task deletion
        await AuditLogService().logEvent(
          action: 'TASK_DELETE',
          userId: currentUser.uid,
          userName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
          userEmail: currentUser.email,
          status: 'success',
          targetType: 'task',
          targetId: taskId,
          details: {'deletionMethod': 'permanent'},
        );

        ref.invalidate(taskByIdProvider(taskId));
        ref.invalidate(allTasksProvider);
        ref.invalidate(filteredTasksProvider);
        ref.invalidate(myTasksProvider);
        ref.invalidate(userAccessibleTasksProvider);
        state = const AsyncValue.data(null);
        return true;
      } else {
        state = AsyncValue.error('Failed to delete task', StackTrace.current);
        return false;
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}

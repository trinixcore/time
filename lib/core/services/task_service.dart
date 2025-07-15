import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/task_model.dart';
import '../models/task_comment_model.dart';
import '../models/task_time_log_model.dart';
import '../models/project.dart';
import '../enums/task_status.dart';
import '../enums/priority_level.dart';
import '../enums/project_status.dart';
import '../enums/project_priority.dart';
import 'firebase_service.dart';
import 'task_document_service.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  static final Logger _logger = Logger();

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  // Collection references
  CollectionReference get _tasksCollection => _firestore.collection('tasks');
  CollectionReference get _projectsCollection =>
      _firestore.collection('projects');
  CollectionReference get _departmentsCollection =>
      _firestore.collection('departments');
  CollectionReference get _systemDataCollection =>
      _firestore.collection('system_data');

  /// Get all departments from system_data
  Future<List<String>> getDepartments() async {
    try {
      final doc = await _systemDataCollection.doc('departments').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final departments = List<String>.from(data['list'] ?? []);
        return departments;
      }
      return [];
    } catch (e) {
      _logger.e('Failed to get departments: $e');
      return [];
    }
  }

  /// Get projects by department
  Future<List<Project>> getProjectsByDepartment(String departmentId) async {
    try {
      final query =
          await _projectsCollection
              .where('departmentId', isEqualTo: departmentId)
              .orderBy('name')
              .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Project.fromFirestore({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      _logger.e('Failed to get projects by department: $e');
      return [];
    }
  }

  /// Create a new project
  Future<Project> createProject({
    required String name,
    required String description,
    required String departmentId,
    required String managerId,
    required String createdBy,
    DateTime? startDate,
    DateTime? endDate,
    ProjectPriority priority = ProjectPriority.medium,
  }) async {
    try {
      final now = DateTime.now();
      final project = Project(
        id: '', // Will be set by Firestore
        name: name,
        description: description,
        status: ProjectStatus.planning,
        priority: priority,
        managerId: managerId,
        startDate: startDate ?? now,
        endDate: endDate,
        departmentId: departmentId,
        createdAt: now,
        updatedAt: now,
        createdById: createdBy,
      );

      final docRef = await _projectsCollection.add(project.toFirestore());

      // Update the project with the generated ID
      final createdProject = project.copyWith(id: docRef.id);
      await docRef.update({'id': docRef.id});

      _logger.i('Project created successfully: ${docRef.id}');
      return createdProject;
    } catch (e) {
      _logger.e('Failed to create project: $e');
      rethrow;
    }
  }

  /// Create a new task
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required PriorityLevel priority,
    required DateTime dueDate,
    required String departmentId,
    required String projectId,
    required String assignedTo,
    required String createdBy,
    String? category,
    List<String>? tags,
    int? estimatedHours,
    String? parentTaskId,
    List<String>? dependencies,
    List<String>? watchers,
  }) async {
    try {
      final now = DateTime.now();
      final task = TaskModel(
        id: '', // Will be set by Firestore
        title: title,
        description: description,
        priority: priority,
        status: TaskStatus.todo,
        dueDate: dueDate,
        departmentId: departmentId,
        projectId: projectId,
        assignedTo: assignedTo,
        createdBy: createdBy,
        category: category,
        tags: tags ?? [],
        watchers: watchers ?? [],
        estimatedHours: estimatedHours ?? 0,
        parentTaskId: parentTaskId,
        dependencies: dependencies ?? [],
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _tasksCollection.add(task.toFirestore());

      // Update the task with the generated ID
      final createdTask = task.copyWith(id: docRef.id);
      await docRef.update({'id': docRef.id});

      // Update parent task if this is a sub-task
      if (parentTaskId != null) {
        await _updateParentTaskSubTasks(parentTaskId, docRef.id, true);
      }

      _logger.i('Task created successfully: ${docRef.id}');
      return createdTask;
    } catch (e) {
      _logger.e('Failed to create task: $e');
      rethrow;
    }
  }

  /// Get all tasks with optional filters
  Future<List<TaskModel>> getTasks({
    String? departmentId,
    String? projectId,
    String? assignedTo,
    TaskStatus? status,
    PriorityLevel? priority,
    bool? isOverdue,
    String? searchQuery,
    int limit = 50,
  }) async {
    try {
      Query query = _tasksCollection;

      // Apply filters
      if (departmentId != null) {
        query = query.where('departmentId', isEqualTo: departmentId);
      }
      if (projectId != null) {
        query = query.where('projectId', isEqualTo: projectId);
      }
      if (assignedTo != null) {
        query = query.where('assignedTo', isEqualTo: assignedTo);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.value);
      }
      if (priority != null) {
        query = query.where('priority', isEqualTo: priority.value);
      }

      // Order by due date
      query = query.orderBy('dueDate', descending: false);

      final querySnapshot = await query.limit(limit).get();

      List<TaskModel> tasks =
          querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Convert Firestore Timestamps to DateTime objects for existing data
            final convertedData = Map<String, dynamic>.from(data);

            // Handle updatedAt field
            if (convertedData['updatedAt'] is Timestamp) {
              convertedData['updatedAt'] =
                  (convertedData['updatedAt'] as Timestamp)
                      .toDate()
                      .toIso8601String();
            }

            // Handle createdAt field
            if (convertedData['createdAt'] is Timestamp) {
              convertedData['createdAt'] =
                  (convertedData['createdAt'] as Timestamp)
                      .toDate()
                      .toIso8601String();
            }

            // Handle dueDate field
            if (convertedData['dueDate'] is Timestamp) {
              convertedData['dueDate'] =
                  (convertedData['dueDate'] as Timestamp)
                      .toDate()
                      .toIso8601String();
            }

            // Handle completedAt field
            if (convertedData['completedAt'] is Timestamp) {
              convertedData['completedAt'] =
                  (convertedData['completedAt'] as Timestamp)
                      .toDate()
                      .toIso8601String();
            }

            // Handle lastProgressUpdate field
            if (convertedData['lastProgressUpdate'] is Timestamp) {
              convertedData['lastProgressUpdate'] =
                  (convertedData['lastProgressUpdate'] as Timestamp)
                      .toDate()
                      .toIso8601String();
            }

            return TaskModel.fromFirestore({...convertedData, 'id': doc.id});
          }).toList();

      // Apply additional filters that can't be done in Firestore
      if (isOverdue != null) {
        tasks = tasks.where((task) => task.isOverdue == isOverdue).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        tasks =
            tasks
                .where(
                  (task) =>
                      task.title.toLowerCase().contains(query) ||
                      task.description.toLowerCase().contains(query) ||
                      task.category?.toLowerCase().contains(query) == true,
                )
                .toList();
      }

      return tasks;
    } catch (e) {
      _logger.e('Failed to get tasks: $e');
      return [];
    }
  }

  /// Get a single task by ID
  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      final doc = await _tasksCollection.doc(taskId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Firestore Timestamps to DateTime objects for existing data
        final convertedData = Map<String, dynamic>.from(data);

        // Handle updatedAt field
        if (convertedData['updatedAt'] is Timestamp) {
          convertedData['updatedAt'] =
              (convertedData['updatedAt'] as Timestamp)
                  .toDate()
                  .toIso8601String();
        }

        // Handle createdAt field
        if (convertedData['createdAt'] is Timestamp) {
          convertedData['createdAt'] =
              (convertedData['createdAt'] as Timestamp)
                  .toDate()
                  .toIso8601String();
        }

        // Handle dueDate field
        if (convertedData['dueDate'] is Timestamp) {
          convertedData['dueDate'] =
              (convertedData['dueDate'] as Timestamp)
                  .toDate()
                  .toIso8601String();
        }

        // Handle completedAt field
        if (convertedData['completedAt'] is Timestamp) {
          convertedData['completedAt'] =
              (convertedData['completedAt'] as Timestamp)
                  .toDate()
                  .toIso8601String();
        }

        // Handle lastProgressUpdate field
        if (convertedData['lastProgressUpdate'] is Timestamp) {
          convertedData['lastProgressUpdate'] =
              (convertedData['lastProgressUpdate'] as Timestamp)
                  .toDate()
                  .toIso8601String();
        }

        return TaskModel.fromFirestore({...convertedData, 'id': doc.id});
      }
      return null;
    } catch (e) {
      _logger.e('Failed to get task by ID: $e');
      return null;
    }
  }

  /// Update task status
  Future<bool> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      await _tasksCollection.doc(taskId).update({
        'status': newStatus.value,
        'updatedAt': FieldValue.serverTimestamp(),
        if (newStatus.isCompleted) 'completedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Task status updated: $taskId -> ${newStatus.value}');
      return true;
    } catch (e) {
      _logger.e('Failed to update task status: $e');
      return false;
    }
  }

  /// Update task
  Future<bool> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _tasksCollection.doc(taskId).update(updates);

      _logger.i('Task updated: $taskId');
      return true;
    } catch (e) {
      _logger.e('Failed to update task: $e');
      return false;
    }
  }

  /// Delete task
  Future<bool> deleteTask(String taskId) async {
    try {
      // Get task to check for sub-tasks
      final task = await getTaskById(taskId);
      if (task == null) return false;

      // Update parent task if this is a sub-task
      if (task.parentTaskId != null) {
        await _updateParentTaskSubTasks(task.parentTaskId!, taskId, false);
      }

      // Delete all associated documents from Supabase and Firestore
      try {
        final taskDocumentService = TaskDocumentService();
        await taskDocumentService.deleteAllTaskDocuments(taskId);
        _logger.i('Task documents deleted for task: $taskId');
      } catch (e) {
        _logger.w('Failed to delete task documents for task $taskId: $e');
        // Continue with task deletion even if document deletion fails
      }

      // Delete sub-collections (comments, time logs)
      try {
        await _deleteSubCollections(taskId);
        _logger.i('Task sub-collections deleted for task: $taskId');
      } catch (e) {
        _logger.w('Failed to delete sub-collections for task $taskId: $e');
        // Continue with task deletion even if sub-collection deletion fails
      }

      // Delete the task
      await _tasksCollection.doc(taskId).delete();

      _logger.i('Task deleted: $taskId');
      return true;
    } catch (e) {
      _logger.e('Failed to delete task: $e');
      return false;
    }
  }

  /// Delete sub-collections for a task
  Future<void> _deleteSubCollections(String taskId) async {
    final taskRef = _tasksCollection.doc(taskId);

    // Delete comments
    final commentsSnapshot = await taskRef.collection('comments').get();
    final batch = _firestore.batch();
    for (final doc in commentsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete time logs
    final timeLogsSnapshot = await taskRef.collection('time_logs').get();
    for (final doc in timeLogsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Log time worked manually for a task
  Future<bool> logTimeWorked({
    required String taskId,
    required String userId,
    required String userName,
    required int hoursWorked,
    required String description,
    DateTime? workDate,
  }) async {
    try {
      final now = DateTime.now();
      final workDateTime = workDate ?? now;

      // Create time log entry
      final timeLog = TaskTimeLogModel(
        id: '', // Will be set by Firestore
        taskId: taskId,
        userId: userId,
        userName: userName,
        startTime: workDateTime,
        endTime: workDateTime.add(Duration(hours: hoursWorked)),
        description: description,
        durationMinutes: hoursWorked * 60,
        isManualEntry: true,
        createdAt: now,
        updatedAt: now,
      );

      final timeLogRef = await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('time_logs')
          .add(timeLog.toFirestore());

      // Update time log with generated ID
      await timeLogRef.update({'id': timeLogRef.id});

      // Update task with accumulated time
      await _tasksCollection.doc(taskId).update({
        'timeSpentMinutes': FieldValue.increment(hoursWorked * 60),
        'actualHours': FieldValue.increment(hoursWorked.toDouble()),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Time logged for task: $taskId - $hoursWorked hours');
      return true;
    } catch (e) {
      _logger.e('Failed to log time worked: $e');
      return false;
    }
  }

  /// Update task progress percentage
  Future<bool> updateProgress({
    required String taskId,
    required int progressPercentage,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final updates = <String, dynamic>{
        'progressPercentage': progressPercentage.clamp(0, 100),
        'lastProgressUpdate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Auto-complete task if progress reaches 100%
      if (progressPercentage >= 100) {
        updates['status'] = TaskStatus.completed.value;
        updates['completedAt'] = FieldValue.serverTimestamp();
      }

      await _tasksCollection.doc(taskId).update(updates);

      // Add a comment if notes are provided
      if (notes != null && notes.isNotEmpty) {
        await addComment(
          taskId: taskId,
          content: 'Progress updated to $progressPercentage%: $notes',
          authorId: 'system', // You might want to pass the actual user ID
          authorName: 'System',
        );
      }

      _logger.i('Progress updated for task: $taskId - $progressPercentage%');
      return true;
    } catch (e) {
      _logger.e('Failed to update progress: $e');
      return false;
    }
  }

  /// Add comment to task
  Future<TaskCommentModel?> addComment({
    required String taskId,
    required String content,
    required String authorId,
    required String authorName,
    String? parentCommentId,
  }) async {
    try {
      final now = DateTime.now();
      final comment = TaskCommentModel(
        id: '', // Will be set by Firestore
        taskId: taskId,
        content: content,
        authorId: authorId,
        authorName: authorName,
        parentCommentId: parentCommentId,
        createdAt: now,
        updatedAt: now,
      );

      final docRef = await _firestore
          .collection('tasks')
          .doc(taskId)
          .collection('comments')
          .add(comment.toFirestore());

      // Update comment with generated ID
      final createdComment = comment.copyWith(id: docRef.id);
      await docRef.update({'id': docRef.id});

      // Update parent comment if this is a reply
      if (parentCommentId != null) {
        await _updateParentCommentReplies(
          taskId,
          parentCommentId,
          docRef.id,
          true,
        );
      }

      _logger.i('Comment added to task: $taskId');
      return createdComment;
    } catch (e) {
      _logger.e('Failed to add comment: $e');
      return null;
    }
  }

  /// Get comments for a task
  Future<List<TaskCommentModel>> getTaskComments(String taskId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('tasks')
              .doc(taskId)
              .collection('comments')
              .orderBy('createdAt', descending: false)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();

        // Convert Firestore Timestamps to DateTime objects for existing data
        final convertedData = Map<String, dynamic>.from(data);

        // Handle timestamp fields
        final timestampFields = [
          'createdAt',
          'updatedAt',
          'editedAt',
          'deletedAt',
        ];
        for (final field in timestampFields) {
          if (convertedData[field] is Timestamp) {
            convertedData[field] =
                (convertedData[field] as Timestamp).toDate().toIso8601String();
          }
        }

        return TaskCommentModel.fromFirestore({...convertedData, 'id': doc.id});
      }).toList();
    } catch (e) {
      _logger.e('Failed to get task comments: $e');
      return [];
    }
  }

  /// Get time logs for a task
  Future<List<TaskTimeLogModel>> getTaskTimeLogs(String taskId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('tasks')
              .doc(taskId)
              .collection('time_logs')
              .orderBy('startTime', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();

        // Convert Firestore Timestamps to DateTime objects for existing data
        final convertedData = Map<String, dynamic>.from(data);

        // Handle timestamp fields
        final timestampFields = [
          'startTime',
          'endTime',
          'approvedAt',
          'createdAt',
          'updatedAt',
        ];
        for (final field in timestampFields) {
          if (convertedData[field] is Timestamp) {
            convertedData[field] =
                (convertedData[field] as Timestamp).toDate().toIso8601String();
          }
        }

        return TaskTimeLogModel.fromFirestore({...convertedData, 'id': doc.id});
      }).toList();
    } catch (e) {
      _logger.e('Failed to get task time logs: $e');
      return [];
    }
  }

  /// Get task analytics
  Future<Map<String, dynamic>> getTaskAnalytics({
    String? departmentId,
    String? projectId,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final tasks = await getTasks(
        departmentId: departmentId,
        projectId: projectId,
        assignedTo: assignedTo,
      );

      // Filter by date range if provided
      List<TaskModel> filteredTasks = tasks;
      if (startDate != null || endDate != null) {
        filteredTasks =
            tasks.where((task) {
              if (startDate != null && task.createdAt.isBefore(startDate))
                return false;
              if (endDate != null && task.createdAt.isAfter(endDate))
                return false;
              return true;
            }).toList();
      }

      // Calculate analytics
      final totalTasks = filteredTasks.length;
      final completedTasks = filteredTasks.where((t) => t.isCompleted).length;
      final overdueTasks = filteredTasks.where((t) => t.isOverdue).length;
      final inProgressTasks = filteredTasks.where((t) => t.isInProgress).length;
      final pendingTasks = filteredTasks.where((t) => t.status.isTodo).length;

      final completionRate =
          totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0;
      final overdueRate =
          totalTasks > 0 ? (overdueTasks / totalTasks * 100) : 0.0;

      // Time tracking analytics
      final totalEstimatedHours = filteredTasks.fold<int>(
        0,
        (sum, task) => sum + task.estimatedHours,
      );
      final totalActualHours = filteredTasks.fold<int>(
        0,
        (sum, task) => sum + task.actualHours,
      );

      // Priority distribution
      final priorityDistribution = <String, int>{};
      for (final task in filteredTasks) {
        final priority = task.priority.displayName;
        priorityDistribution[priority] =
            (priorityDistribution[priority] ?? 0) + 1;
      }

      // Status distribution
      final statusDistribution = <String, int>{};
      for (final task in filteredTasks) {
        final status = task.status.displayName;
        statusDistribution[status] = (statusDistribution[status] ?? 0) + 1;
      }

      return {
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'overdueTasks': overdueTasks,
        'inProgressTasks': inProgressTasks,
        'pendingTasks': pendingTasks,
        'completionRate': completionRate,
        'overdueRate': overdueRate,
        'totalEstimatedHours': totalEstimatedHours,
        'totalActualHours': totalActualHours,
        'priorityDistribution': priorityDistribution,
        'statusDistribution': statusDistribution,
      };
    } catch (e) {
      _logger.e('Failed to get task analytics: $e');
      return {};
    }
  }

  // Helper methods
  Future<void> _updateParentTaskSubTasks(
    String parentTaskId,
    String subTaskId,
    bool add,
  ) async {
    try {
      final parentDoc = await _tasksCollection.doc(parentTaskId).get();
      if (parentDoc.exists) {
        final data = parentDoc.data() as Map<String, dynamic>;
        List<String> subTasks = List<String>.from(data['subTaskIds'] ?? []);

        if (add) {
          if (!subTasks.contains(subTaskId)) {
            subTasks.add(subTaskId);
          }
        } else {
          subTasks.remove(subTaskId);
        }

        await _tasksCollection.doc(parentTaskId).update({
          'subTaskIds': subTasks,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      _logger.e('Failed to update parent task sub-tasks: $e');
    }
  }

  Future<void> _updateParentCommentReplies(
    String taskId,
    String parentCommentId,
    String replyId,
    bool add,
  ) async {
    try {
      final parentDoc =
          await _firestore
              .collection('tasks')
              .doc(taskId)
              .collection('comments')
              .doc(parentCommentId)
              .get();

      if (parentDoc.exists) {
        final data = parentDoc.data() as Map<String, dynamic>;
        List<String> replies = List<String>.from(data['replies'] ?? []);

        if (add) {
          if (!replies.contains(replyId)) {
            replies.add(replyId);
          }
        } else {
          replies.remove(replyId);
        }

        await parentDoc.reference.update({
          'replies': replies,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      _logger.e('Failed to update parent comment replies: $e');
    }
  }

  /// Add watcher to task
  Future<bool> addTaskWatcher(String taskId, String userId) async {
    try {
      final taskDoc = await _tasksCollection.doc(taskId).get();
      if (!taskDoc.exists) return false;

      final data = taskDoc.data() as Map<String, dynamic>;
      List<String> watchers = List<String>.from(data['watchers'] ?? []);

      if (!watchers.contains(userId)) {
        watchers.add(userId);
        await _tasksCollection.doc(taskId).update({
          'watchers': watchers,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _logger.i('Watcher added to task: $taskId -> $userId');
      return true;
    } catch (e) {
      _logger.e('Failed to add task watcher: $e');
      return false;
    }
  }

  /// Remove watcher from task
  Future<bool> removeTaskWatcher(String taskId, String userId) async {
    try {
      final taskDoc = await _tasksCollection.doc(taskId).get();
      if (!taskDoc.exists) return false;

      final data = taskDoc.data() as Map<String, dynamic>;
      List<String> watchers = List<String>.from(data['watchers'] ?? []);

      if (watchers.contains(userId)) {
        watchers.remove(userId);
        await _tasksCollection.doc(taskId).update({
          'watchers': watchers,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _logger.i('Watcher removed from task: $taskId -> $userId');
      return true;
    } catch (e) {
      _logger.e('Failed to remove task watcher: $e');
      return false;
    }
  }
}

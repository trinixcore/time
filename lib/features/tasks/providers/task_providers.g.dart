// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskServiceHash() => r'8d1649184b632adb62a16369ef350740ac6c6eef';

/// See also [taskService].
@ProviderFor(taskService)
final taskServiceProvider = AutoDisposeProvider<TaskService>.internal(
  taskService,
  name: r'taskServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$taskServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskServiceRef = AutoDisposeProviderRef<TaskService>;
String _$authServiceHash() => r'e771c719cfb4bd87b7f15fc6722ef9f56a9844e4';

/// See also [authService].
@ProviderFor(authService)
final authServiceProvider = AutoDisposeProvider<AuthService>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = AutoDisposeProviderRef<AuthService>;
String _$activeUsersHash() => r'17e6db253c7ecaaab0c0d3ffe14eab6a578fdc92';

/// See also [activeUsers].
@ProviderFor(activeUsers)
final activeUsersProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      activeUsers,
      name: r'activeUsersProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$activeUsersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveUsersRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$taskCategoriesHash() => r'9f00d2b00e9851feca55e71d23578e509877904c';

/// See also [taskCategories].
@ProviderFor(taskCategories)
final taskCategoriesProvider = AutoDisposeProvider<List<String>>.internal(
  taskCategories,
  name: r'taskCategoriesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$taskCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskCategoriesRef = AutoDisposeProviderRef<List<String>>;
String _$departmentsHash() => r'bc2ac15fb01ccc564dc8a2f1aa2c5a9cb6b84d8e';

/// See also [departments].
@ProviderFor(departments)
final departmentsProvider = AutoDisposeFutureProvider<List<String>>.internal(
  departments,
  name: r'departmentsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$departmentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DepartmentsRef = AutoDisposeFutureProviderRef<List<String>>;
String _$projectsByDepartmentHash() =>
    r'84b28ff466c9b823443755b359e262f084c77d19';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [projectsByDepartment].
@ProviderFor(projectsByDepartment)
const projectsByDepartmentProvider = ProjectsByDepartmentFamily();

/// See also [projectsByDepartment].
class ProjectsByDepartmentFamily extends Family<AsyncValue<List<Project>>> {
  /// See also [projectsByDepartment].
  const ProjectsByDepartmentFamily();

  /// See also [projectsByDepartment].
  ProjectsByDepartmentProvider call(String departmentId) {
    return ProjectsByDepartmentProvider(departmentId);
  }

  @override
  ProjectsByDepartmentProvider getProviderOverride(
    covariant ProjectsByDepartmentProvider provider,
  ) {
    return call(provider.departmentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectsByDepartmentProvider';
}

/// See also [projectsByDepartment].
class ProjectsByDepartmentProvider
    extends AutoDisposeFutureProvider<List<Project>> {
  /// See also [projectsByDepartment].
  ProjectsByDepartmentProvider(String departmentId)
    : this._internal(
        (ref) =>
            projectsByDepartment(ref as ProjectsByDepartmentRef, departmentId),
        from: projectsByDepartmentProvider,
        name: r'projectsByDepartmentProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$projectsByDepartmentHash,
        dependencies: ProjectsByDepartmentFamily._dependencies,
        allTransitiveDependencies:
            ProjectsByDepartmentFamily._allTransitiveDependencies,
        departmentId: departmentId,
      );

  ProjectsByDepartmentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.departmentId,
  }) : super.internal();

  final String departmentId;

  @override
  Override overrideWith(
    FutureOr<List<Project>> Function(ProjectsByDepartmentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProjectsByDepartmentProvider._internal(
        (ref) => create(ref as ProjectsByDepartmentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        departmentId: departmentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Project>> createElement() {
    return _ProjectsByDepartmentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectsByDepartmentProvider &&
        other.departmentId == departmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, departmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectsByDepartmentRef on AutoDisposeFutureProviderRef<List<Project>> {
  /// The parameter `departmentId` of this provider.
  String get departmentId;
}

class _ProjectsByDepartmentProviderElement
    extends AutoDisposeFutureProviderElement<List<Project>>
    with ProjectsByDepartmentRef {
  _ProjectsByDepartmentProviderElement(super.provider);

  @override
  String get departmentId =>
      (origin as ProjectsByDepartmentProvider).departmentId;
}

String _$allTasksHash() => r'd26b8135f8a9c79ccb0583d68857df08ba29e767';

/// See also [allTasks].
@ProviderFor(allTasks)
final allTasksProvider = AutoDisposeFutureProvider<List<TaskModel>>.internal(
  allTasks,
  name: r'allTasksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllTasksRef = AutoDisposeFutureProviderRef<List<TaskModel>>;
String _$tasksByDepartmentHash() => r'bb42acf1cfe3f1f26c25fc727e8f95a0f2d31bab';

/// See also [tasksByDepartment].
@ProviderFor(tasksByDepartment)
const tasksByDepartmentProvider = TasksByDepartmentFamily();

/// See also [tasksByDepartment].
class TasksByDepartmentFamily extends Family<AsyncValue<List<TaskModel>>> {
  /// See also [tasksByDepartment].
  const TasksByDepartmentFamily();

  /// See also [tasksByDepartment].
  TasksByDepartmentProvider call(String departmentId) {
    return TasksByDepartmentProvider(departmentId);
  }

  @override
  TasksByDepartmentProvider getProviderOverride(
    covariant TasksByDepartmentProvider provider,
  ) {
    return call(provider.departmentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tasksByDepartmentProvider';
}

/// See also [tasksByDepartment].
class TasksByDepartmentProvider
    extends AutoDisposeFutureProvider<List<TaskModel>> {
  /// See also [tasksByDepartment].
  TasksByDepartmentProvider(String departmentId)
    : this._internal(
        (ref) => tasksByDepartment(ref as TasksByDepartmentRef, departmentId),
        from: tasksByDepartmentProvider,
        name: r'tasksByDepartmentProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$tasksByDepartmentHash,
        dependencies: TasksByDepartmentFamily._dependencies,
        allTransitiveDependencies:
            TasksByDepartmentFamily._allTransitiveDependencies,
        departmentId: departmentId,
      );

  TasksByDepartmentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.departmentId,
  }) : super.internal();

  final String departmentId;

  @override
  Override overrideWith(
    FutureOr<List<TaskModel>> Function(TasksByDepartmentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksByDepartmentProvider._internal(
        (ref) => create(ref as TasksByDepartmentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        departmentId: departmentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TaskModel>> createElement() {
    return _TasksByDepartmentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksByDepartmentProvider &&
        other.departmentId == departmentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, departmentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TasksByDepartmentRef on AutoDisposeFutureProviderRef<List<TaskModel>> {
  /// The parameter `departmentId` of this provider.
  String get departmentId;
}

class _TasksByDepartmentProviderElement
    extends AutoDisposeFutureProviderElement<List<TaskModel>>
    with TasksByDepartmentRef {
  _TasksByDepartmentProviderElement(super.provider);

  @override
  String get departmentId => (origin as TasksByDepartmentProvider).departmentId;
}

String _$tasksByProjectHash() => r'fa6ee099994acc1ea7b1315e534b4fdf2077158a';

/// See also [tasksByProject].
@ProviderFor(tasksByProject)
const tasksByProjectProvider = TasksByProjectFamily();

/// See also [tasksByProject].
class TasksByProjectFamily extends Family<AsyncValue<List<TaskModel>>> {
  /// See also [tasksByProject].
  const TasksByProjectFamily();

  /// See also [tasksByProject].
  TasksByProjectProvider call(String projectId) {
    return TasksByProjectProvider(projectId);
  }

  @override
  TasksByProjectProvider getProviderOverride(
    covariant TasksByProjectProvider provider,
  ) {
    return call(provider.projectId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tasksByProjectProvider';
}

/// See also [tasksByProject].
class TasksByProjectProvider
    extends AutoDisposeFutureProvider<List<TaskModel>> {
  /// See also [tasksByProject].
  TasksByProjectProvider(String projectId)
    : this._internal(
        (ref) => tasksByProject(ref as TasksByProjectRef, projectId),
        from: tasksByProjectProvider,
        name: r'tasksByProjectProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$tasksByProjectHash,
        dependencies: TasksByProjectFamily._dependencies,
        allTransitiveDependencies:
            TasksByProjectFamily._allTransitiveDependencies,
        projectId: projectId,
      );

  TasksByProjectProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final String projectId;

  @override
  Override overrideWith(
    FutureOr<List<TaskModel>> Function(TasksByProjectRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksByProjectProvider._internal(
        (ref) => create(ref as TasksByProjectRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TaskModel>> createElement() {
    return _TasksByProjectProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksByProjectProvider && other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TasksByProjectRef on AutoDisposeFutureProviderRef<List<TaskModel>> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _TasksByProjectProviderElement
    extends AutoDisposeFutureProviderElement<List<TaskModel>>
    with TasksByProjectRef {
  _TasksByProjectProviderElement(super.provider);

  @override
  String get projectId => (origin as TasksByProjectProvider).projectId;
}

String _$myTasksHash() => r'00364cdaafa04a159ed70c324cab18c2e312d33d';

/// See also [myTasks].
@ProviderFor(myTasks)
final myTasksProvider = AutoDisposeFutureProvider<List<TaskModel>>.internal(
  myTasks,
  name: r'myTasksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyTasksRef = AutoDisposeFutureProviderRef<List<TaskModel>>;
String _$userAccessibleTasksHash() =>
    r'35415b64cec90eb0e5aea7bf7c3cd87a29ad8f12';

/// See also [userAccessibleTasks].
@ProviderFor(userAccessibleTasks)
const userAccessibleTasksProvider = UserAccessibleTasksFamily();

/// See also [userAccessibleTasks].
class UserAccessibleTasksFamily extends Family<AsyncValue<List<TaskModel>>> {
  /// See also [userAccessibleTasks].
  const UserAccessibleTasksFamily();

  /// See also [userAccessibleTasks].
  UserAccessibleTasksProvider call({
    String? departmentId,
    String? projectId,
    TaskStatus? status,
    PriorityLevel? priority,
    bool? isOverdue,
    String? searchQuery,
  }) {
    return UserAccessibleTasksProvider(
      departmentId: departmentId,
      projectId: projectId,
      status: status,
      priority: priority,
      isOverdue: isOverdue,
      searchQuery: searchQuery,
    );
  }

  @override
  UserAccessibleTasksProvider getProviderOverride(
    covariant UserAccessibleTasksProvider provider,
  ) {
    return call(
      departmentId: provider.departmentId,
      projectId: provider.projectId,
      status: provider.status,
      priority: provider.priority,
      isOverdue: provider.isOverdue,
      searchQuery: provider.searchQuery,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userAccessibleTasksProvider';
}

/// See also [userAccessibleTasks].
class UserAccessibleTasksProvider
    extends AutoDisposeFutureProvider<List<TaskModel>> {
  /// See also [userAccessibleTasks].
  UserAccessibleTasksProvider({
    String? departmentId,
    String? projectId,
    TaskStatus? status,
    PriorityLevel? priority,
    bool? isOverdue,
    String? searchQuery,
  }) : this._internal(
         (ref) => userAccessibleTasks(
           ref as UserAccessibleTasksRef,
           departmentId: departmentId,
           projectId: projectId,
           status: status,
           priority: priority,
           isOverdue: isOverdue,
           searchQuery: searchQuery,
         ),
         from: userAccessibleTasksProvider,
         name: r'userAccessibleTasksProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$userAccessibleTasksHash,
         dependencies: UserAccessibleTasksFamily._dependencies,
         allTransitiveDependencies:
             UserAccessibleTasksFamily._allTransitiveDependencies,
         departmentId: departmentId,
         projectId: projectId,
         status: status,
         priority: priority,
         isOverdue: isOverdue,
         searchQuery: searchQuery,
       );

  UserAccessibleTasksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.departmentId,
    required this.projectId,
    required this.status,
    required this.priority,
    required this.isOverdue,
    required this.searchQuery,
  }) : super.internal();

  final String? departmentId;
  final String? projectId;
  final TaskStatus? status;
  final PriorityLevel? priority;
  final bool? isOverdue;
  final String? searchQuery;

  @override
  Override overrideWith(
    FutureOr<List<TaskModel>> Function(UserAccessibleTasksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserAccessibleTasksProvider._internal(
        (ref) => create(ref as UserAccessibleTasksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        departmentId: departmentId,
        projectId: projectId,
        status: status,
        priority: priority,
        isOverdue: isOverdue,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TaskModel>> createElement() {
    return _UserAccessibleTasksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserAccessibleTasksProvider &&
        other.departmentId == departmentId &&
        other.projectId == projectId &&
        other.status == status &&
        other.priority == priority &&
        other.isOverdue == isOverdue &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, departmentId.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, priority.hashCode);
    hash = _SystemHash.combine(hash, isOverdue.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserAccessibleTasksRef on AutoDisposeFutureProviderRef<List<TaskModel>> {
  /// The parameter `departmentId` of this provider.
  String? get departmentId;

  /// The parameter `projectId` of this provider.
  String? get projectId;

  /// The parameter `status` of this provider.
  TaskStatus? get status;

  /// The parameter `priority` of this provider.
  PriorityLevel? get priority;

  /// The parameter `isOverdue` of this provider.
  bool? get isOverdue;

  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;
}

class _UserAccessibleTasksProviderElement
    extends AutoDisposeFutureProviderElement<List<TaskModel>>
    with UserAccessibleTasksRef {
  _UserAccessibleTasksProviderElement(super.provider);

  @override
  String? get departmentId =>
      (origin as UserAccessibleTasksProvider).departmentId;
  @override
  String? get projectId => (origin as UserAccessibleTasksProvider).projectId;
  @override
  TaskStatus? get status => (origin as UserAccessibleTasksProvider).status;
  @override
  PriorityLevel? get priority =>
      (origin as UserAccessibleTasksProvider).priority;
  @override
  bool? get isOverdue => (origin as UserAccessibleTasksProvider).isOverdue;
  @override
  String? get searchQuery =>
      (origin as UserAccessibleTasksProvider).searchQuery;
}

String _$taskByIdHash() => r'5be75e0e28d41110b677cf7d22c7354b9edfcb91';

/// See also [taskById].
@ProviderFor(taskById)
const taskByIdProvider = TaskByIdFamily();

/// See also [taskById].
class TaskByIdFamily extends Family<AsyncValue<TaskModel?>> {
  /// See also [taskById].
  const TaskByIdFamily();

  /// See also [taskById].
  TaskByIdProvider call(String taskId) {
    return TaskByIdProvider(taskId);
  }

  @override
  TaskByIdProvider getProviderOverride(covariant TaskByIdProvider provider) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskByIdProvider';
}

/// See also [taskById].
class TaskByIdProvider extends AutoDisposeFutureProvider<TaskModel?> {
  /// See also [taskById].
  TaskByIdProvider(String taskId)
    : this._internal(
        (ref) => taskById(ref as TaskByIdRef, taskId),
        from: taskByIdProvider,
        name: r'taskByIdProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$taskByIdHash,
        dependencies: TaskByIdFamily._dependencies,
        allTransitiveDependencies: TaskByIdFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  TaskByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final String taskId;

  @override
  Override overrideWith(
    FutureOr<TaskModel?> Function(TaskByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskByIdProvider._internal(
        (ref) => create(ref as TaskByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TaskModel?> createElement() {
    return _TaskByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskByIdProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskByIdRef on AutoDisposeFutureProviderRef<TaskModel?> {
  /// The parameter `taskId` of this provider.
  String get taskId;
}

class _TaskByIdProviderElement
    extends AutoDisposeFutureProviderElement<TaskModel?>
    with TaskByIdRef {
  _TaskByIdProviderElement(super.provider);

  @override
  String get taskId => (origin as TaskByIdProvider).taskId;
}

String _$taskCommentsHash() => r'ed9b71ed5a5df750d305b3913a7df2fab009cdea';

/// See also [taskComments].
@ProviderFor(taskComments)
const taskCommentsProvider = TaskCommentsFamily();

/// See also [taskComments].
class TaskCommentsFamily extends Family<AsyncValue<List<TaskCommentModel>>> {
  /// See also [taskComments].
  const TaskCommentsFamily();

  /// See also [taskComments].
  TaskCommentsProvider call(String taskId) {
    return TaskCommentsProvider(taskId);
  }

  @override
  TaskCommentsProvider getProviderOverride(
    covariant TaskCommentsProvider provider,
  ) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskCommentsProvider';
}

/// See also [taskComments].
class TaskCommentsProvider
    extends AutoDisposeFutureProvider<List<TaskCommentModel>> {
  /// See also [taskComments].
  TaskCommentsProvider(String taskId)
    : this._internal(
        (ref) => taskComments(ref as TaskCommentsRef, taskId),
        from: taskCommentsProvider,
        name: r'taskCommentsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$taskCommentsHash,
        dependencies: TaskCommentsFamily._dependencies,
        allTransitiveDependencies:
            TaskCommentsFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  TaskCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final String taskId;

  @override
  Override overrideWith(
    FutureOr<List<TaskCommentModel>> Function(TaskCommentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskCommentsProvider._internal(
        (ref) => create(ref as TaskCommentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TaskCommentModel>> createElement() {
    return _TaskCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskCommentsProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskCommentsRef on AutoDisposeFutureProviderRef<List<TaskCommentModel>> {
  /// The parameter `taskId` of this provider.
  String get taskId;
}

class _TaskCommentsProviderElement
    extends AutoDisposeFutureProviderElement<List<TaskCommentModel>>
    with TaskCommentsRef {
  _TaskCommentsProviderElement(super.provider);

  @override
  String get taskId => (origin as TaskCommentsProvider).taskId;
}

String _$taskTimeLogsHash() => r'7a21ea76d23213bf92e39674e7243ebed32737f5';

/// See also [taskTimeLogs].
@ProviderFor(taskTimeLogs)
const taskTimeLogsProvider = TaskTimeLogsFamily();

/// See also [taskTimeLogs].
class TaskTimeLogsFamily extends Family<AsyncValue<List<TaskTimeLogModel>>> {
  /// See also [taskTimeLogs].
  const TaskTimeLogsFamily();

  /// See also [taskTimeLogs].
  TaskTimeLogsProvider call(String taskId) {
    return TaskTimeLogsProvider(taskId);
  }

  @override
  TaskTimeLogsProvider getProviderOverride(
    covariant TaskTimeLogsProvider provider,
  ) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskTimeLogsProvider';
}

/// See also [taskTimeLogs].
class TaskTimeLogsProvider
    extends AutoDisposeFutureProvider<List<TaskTimeLogModel>> {
  /// See also [taskTimeLogs].
  TaskTimeLogsProvider(String taskId)
    : this._internal(
        (ref) => taskTimeLogs(ref as TaskTimeLogsRef, taskId),
        from: taskTimeLogsProvider,
        name: r'taskTimeLogsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$taskTimeLogsHash,
        dependencies: TaskTimeLogsFamily._dependencies,
        allTransitiveDependencies:
            TaskTimeLogsFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  TaskTimeLogsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final String taskId;

  @override
  Override overrideWith(
    FutureOr<List<TaskTimeLogModel>> Function(TaskTimeLogsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskTimeLogsProvider._internal(
        (ref) => create(ref as TaskTimeLogsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TaskTimeLogModel>> createElement() {
    return _TaskTimeLogsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskTimeLogsProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskTimeLogsRef on AutoDisposeFutureProviderRef<List<TaskTimeLogModel>> {
  /// The parameter `taskId` of this provider.
  String get taskId;
}

class _TaskTimeLogsProviderElement
    extends AutoDisposeFutureProviderElement<List<TaskTimeLogModel>>
    with TaskTimeLogsRef {
  _TaskTimeLogsProviderElement(super.provider);

  @override
  String get taskId => (origin as TaskTimeLogsProvider).taskId;
}

String _$taskAnalyticsHash() => r'7cb25c031690878762278cf52899b8582d5e2682';

/// See also [taskAnalytics].
@ProviderFor(taskAnalytics)
const taskAnalyticsProvider = TaskAnalyticsFamily();

/// See also [taskAnalytics].
class TaskAnalyticsFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [taskAnalytics].
  const TaskAnalyticsFamily();

  /// See also [taskAnalytics].
  TaskAnalyticsProvider call({
    String? departmentId,
    String? projectId,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TaskAnalyticsProvider(
      departmentId: departmentId,
      projectId: projectId,
      assignedTo: assignedTo,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  TaskAnalyticsProvider getProviderOverride(
    covariant TaskAnalyticsProvider provider,
  ) {
    return call(
      departmentId: provider.departmentId,
      projectId: provider.projectId,
      assignedTo: provider.assignedTo,
      startDate: provider.startDate,
      endDate: provider.endDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskAnalyticsProvider';
}

/// See also [taskAnalytics].
class TaskAnalyticsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [taskAnalytics].
  TaskAnalyticsProvider({
    String? departmentId,
    String? projectId,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
         (ref) => taskAnalytics(
           ref as TaskAnalyticsRef,
           departmentId: departmentId,
           projectId: projectId,
           assignedTo: assignedTo,
           startDate: startDate,
           endDate: endDate,
         ),
         from: taskAnalyticsProvider,
         name: r'taskAnalyticsProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$taskAnalyticsHash,
         dependencies: TaskAnalyticsFamily._dependencies,
         allTransitiveDependencies:
             TaskAnalyticsFamily._allTransitiveDependencies,
         departmentId: departmentId,
         projectId: projectId,
         assignedTo: assignedTo,
         startDate: startDate,
         endDate: endDate,
       );

  TaskAnalyticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.departmentId,
    required this.projectId,
    required this.assignedTo,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String? departmentId;
  final String? projectId;
  final String? assignedTo;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(TaskAnalyticsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskAnalyticsProvider._internal(
        (ref) => create(ref as TaskAnalyticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        departmentId: departmentId,
        projectId: projectId,
        assignedTo: assignedTo,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _TaskAnalyticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskAnalyticsProvider &&
        other.departmentId == departmentId &&
        other.projectId == projectId &&
        other.assignedTo == assignedTo &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, departmentId.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);
    hash = _SystemHash.combine(hash, assignedTo.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskAnalyticsRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `departmentId` of this provider.
  String? get departmentId;

  /// The parameter `projectId` of this provider.
  String? get projectId;

  /// The parameter `assignedTo` of this provider.
  String? get assignedTo;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _TaskAnalyticsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with TaskAnalyticsRef {
  _TaskAnalyticsProviderElement(super.provider);

  @override
  String? get departmentId => (origin as TaskAnalyticsProvider).departmentId;
  @override
  String? get projectId => (origin as TaskAnalyticsProvider).projectId;
  @override
  String? get assignedTo => (origin as TaskAnalyticsProvider).assignedTo;
  @override
  DateTime? get startDate => (origin as TaskAnalyticsProvider).startDate;
  @override
  DateTime? get endDate => (origin as TaskAnalyticsProvider).endDate;
}

String _$filteredTasksHash() => r'f05d179aa4aa4745e7b23a9b4733341b9a6d6b4c';

/// See also [filteredTasks].
@ProviderFor(filteredTasks)
const filteredTasksProvider = FilteredTasksFamily();

/// See also [filteredTasks].
class FilteredTasksFamily extends Family<AsyncValue<List<TaskModel>>> {
  /// See also [filteredTasks].
  const FilteredTasksFamily();

  /// See also [filteredTasks].
  FilteredTasksProvider call({
    String? departmentId,
    String? projectId,
    String? assignedTo,
    TaskStatus? status,
    PriorityLevel? priority,
    bool? isOverdue,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return FilteredTasksProvider(
      departmentId: departmentId,
      projectId: projectId,
      assignedTo: assignedTo,
      status: status,
      priority: priority,
      isOverdue: isOverdue,
      searchQuery: searchQuery,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  FilteredTasksProvider getProviderOverride(
    covariant FilteredTasksProvider provider,
  ) {
    return call(
      departmentId: provider.departmentId,
      projectId: provider.projectId,
      assignedTo: provider.assignedTo,
      status: provider.status,
      priority: provider.priority,
      isOverdue: provider.isOverdue,
      searchQuery: provider.searchQuery,
      startDate: provider.startDate,
      endDate: provider.endDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredTasksProvider';
}

/// See also [filteredTasks].
class FilteredTasksProvider extends AutoDisposeFutureProvider<List<TaskModel>> {
  /// See also [filteredTasks].
  FilteredTasksProvider({
    String? departmentId,
    String? projectId,
    String? assignedTo,
    TaskStatus? status,
    PriorityLevel? priority,
    bool? isOverdue,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
         (ref) => filteredTasks(
           ref as FilteredTasksRef,
           departmentId: departmentId,
           projectId: projectId,
           assignedTo: assignedTo,
           status: status,
           priority: priority,
           isOverdue: isOverdue,
           searchQuery: searchQuery,
           startDate: startDate,
           endDate: endDate,
         ),
         from: filteredTasksProvider,
         name: r'filteredTasksProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$filteredTasksHash,
         dependencies: FilteredTasksFamily._dependencies,
         allTransitiveDependencies:
             FilteredTasksFamily._allTransitiveDependencies,
         departmentId: departmentId,
         projectId: projectId,
         assignedTo: assignedTo,
         status: status,
         priority: priority,
         isOverdue: isOverdue,
         searchQuery: searchQuery,
         startDate: startDate,
         endDate: endDate,
       );

  FilteredTasksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.departmentId,
    required this.projectId,
    required this.assignedTo,
    required this.status,
    required this.priority,
    required this.isOverdue,
    required this.searchQuery,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String? departmentId;
  final String? projectId;
  final String? assignedTo;
  final TaskStatus? status;
  final PriorityLevel? priority;
  final bool? isOverdue;
  final String? searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<List<TaskModel>> Function(FilteredTasksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredTasksProvider._internal(
        (ref) => create(ref as FilteredTasksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        departmentId: departmentId,
        projectId: projectId,
        assignedTo: assignedTo,
        status: status,
        priority: priority,
        isOverdue: isOverdue,
        searchQuery: searchQuery,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TaskModel>> createElement() {
    return _FilteredTasksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredTasksProvider &&
        other.departmentId == departmentId &&
        other.projectId == projectId &&
        other.assignedTo == assignedTo &&
        other.status == status &&
        other.priority == priority &&
        other.isOverdue == isOverdue &&
        other.searchQuery == searchQuery &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, departmentId.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);
    hash = _SystemHash.combine(hash, assignedTo.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);
    hash = _SystemHash.combine(hash, priority.hashCode);
    hash = _SystemHash.combine(hash, isOverdue.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredTasksRef on AutoDisposeFutureProviderRef<List<TaskModel>> {
  /// The parameter `departmentId` of this provider.
  String? get departmentId;

  /// The parameter `projectId` of this provider.
  String? get projectId;

  /// The parameter `assignedTo` of this provider.
  String? get assignedTo;

  /// The parameter `status` of this provider.
  TaskStatus? get status;

  /// The parameter `priority` of this provider.
  PriorityLevel? get priority;

  /// The parameter `isOverdue` of this provider.
  bool? get isOverdue;

  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _FilteredTasksProviderElement
    extends AutoDisposeFutureProviderElement<List<TaskModel>>
    with FilteredTasksRef {
  _FilteredTasksProviderElement(super.provider);

  @override
  String? get departmentId => (origin as FilteredTasksProvider).departmentId;
  @override
  String? get projectId => (origin as FilteredTasksProvider).projectId;
  @override
  String? get assignedTo => (origin as FilteredTasksProvider).assignedTo;
  @override
  TaskStatus? get status => (origin as FilteredTasksProvider).status;
  @override
  PriorityLevel? get priority => (origin as FilteredTasksProvider).priority;
  @override
  bool? get isOverdue => (origin as FilteredTasksProvider).isOverdue;
  @override
  String? get searchQuery => (origin as FilteredTasksProvider).searchQuery;
  @override
  DateTime? get startDate => (origin as FilteredTasksProvider).startDate;
  @override
  DateTime? get endDate => (origin as FilteredTasksProvider).endDate;
}

String _$taskStatisticsHash() => r'af610e51b406e8095f1dca6db20ae2674050cbbb';

/// See also [taskStatistics].
@ProviderFor(taskStatistics)
final taskStatisticsProvider =
    AutoDisposeFutureProvider<Map<String, int>>.internal(
      taskStatistics,
      name: r'taskStatisticsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$taskStatisticsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TaskStatisticsRef = AutoDisposeFutureProviderRef<Map<String, int>>;
String _$myTaskStatisticsHash() => r'b62e95a8681909c05371eb4684afed5194c6d82e';

/// See also [myTaskStatistics].
@ProviderFor(myTaskStatistics)
final myTaskStatisticsProvider =
    AutoDisposeFutureProvider<Map<String, int>>.internal(
      myTaskStatistics,
      name: r'myTaskStatisticsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$myTaskStatisticsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyTaskStatisticsRef = AutoDisposeFutureProviderRef<Map<String, int>>;
String _$canAccessTaskHash() => r'9616c7ef713f0c1f4ddcec59166ae3be9f2dc28b';

/// See also [canAccessTask].
@ProviderFor(canAccessTask)
const canAccessTaskProvider = CanAccessTaskFamily();

/// See also [canAccessTask].
class CanAccessTaskFamily extends Family<AsyncValue<bool>> {
  /// See also [canAccessTask].
  const CanAccessTaskFamily();

  /// See also [canAccessTask].
  CanAccessTaskProvider call(String taskId) {
    return CanAccessTaskProvider(taskId);
  }

  @override
  CanAccessTaskProvider getProviderOverride(
    covariant CanAccessTaskProvider provider,
  ) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'canAccessTaskProvider';
}

/// See also [canAccessTask].
class CanAccessTaskProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [canAccessTask].
  CanAccessTaskProvider(String taskId)
    : this._internal(
        (ref) => canAccessTask(ref as CanAccessTaskRef, taskId),
        from: canAccessTaskProvider,
        name: r'canAccessTaskProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$canAccessTaskHash,
        dependencies: CanAccessTaskFamily._dependencies,
        allTransitiveDependencies:
            CanAccessTaskFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  CanAccessTaskProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final String taskId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(CanAccessTaskRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CanAccessTaskProvider._internal(
        (ref) => create(ref as CanAccessTaskRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _CanAccessTaskProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CanAccessTaskProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CanAccessTaskRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `taskId` of this provider.
  String get taskId;
}

class _CanAccessTaskProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with CanAccessTaskRef {
  _CanAccessTaskProviderElement(super.provider);

  @override
  String get taskId => (origin as CanAccessTaskProvider).taskId;
}

String _$taskCreationHash() => r'd12f983f73230dd7bb428e3f905bde9886fd4c3f';

/// See also [TaskCreation].
@ProviderFor(TaskCreation)
final taskCreationProvider =
    AutoDisposeAsyncNotifierProvider<TaskCreation, void>.internal(
      TaskCreation.new,
      name: r'taskCreationProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$taskCreationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskCreation = AutoDisposeAsyncNotifier<void>;
String _$projectCreationHash() => r'fc205b62fb7be085f665499fde143829c6ec1978';

/// See also [ProjectCreation].
@ProviderFor(ProjectCreation)
final projectCreationProvider =
    AutoDisposeAsyncNotifierProvider<ProjectCreation, void>.internal(
      ProjectCreation.new,
      name: r'projectCreationProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$projectCreationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProjectCreation = AutoDisposeAsyncNotifier<void>;
String _$taskStatusUpdateHash() => r'8aa30e03e23c81149e393492782218d63d5f9bd9';

/// See also [TaskStatusUpdate].
@ProviderFor(TaskStatusUpdate)
final taskStatusUpdateProvider =
    AutoDisposeAsyncNotifierProvider<TaskStatusUpdate, void>.internal(
      TaskStatusUpdate.new,
      name: r'taskStatusUpdateProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$taskStatusUpdateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskStatusUpdate = AutoDisposeAsyncNotifier<void>;
String _$taskTimeTrackingHash() => r'579d7637bee0724b224dc7e7070b8935f58a306a';

/// See also [TaskTimeTracking].
@ProviderFor(TaskTimeTracking)
final taskTimeTrackingProvider =
    AutoDisposeAsyncNotifierProvider<TaskTimeTracking, void>.internal(
      TaskTimeTracking.new,
      name: r'taskTimeTrackingProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$taskTimeTrackingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskTimeTracking = AutoDisposeAsyncNotifier<void>;
String _$commentCreationHash() => r'a7c0e5dcbb7389a11a0be0f159f34e5b21227c69';

/// See also [CommentCreation].
@ProviderFor(CommentCreation)
final commentCreationProvider =
    AutoDisposeAsyncNotifierProvider<CommentCreation, void>.internal(
      CommentCreation.new,
      name: r'commentCreationProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$commentCreationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommentCreation = AutoDisposeAsyncNotifier<void>;
String _$taskWatchersManagementHash() =>
    r'07a6904d2cbf9440ee6d9e7d8f75347efb0ccadb';

/// See also [TaskWatchersManagement].
@ProviderFor(TaskWatchersManagement)
final taskWatchersManagementProvider =
    AutoDisposeAsyncNotifierProvider<TaskWatchersManagement, void>.internal(
      TaskWatchersManagement.new,
      name: r'taskWatchersManagementProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$taskWatchersManagementHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskWatchersManagement = AutoDisposeAsyncNotifier<void>;
String _$taskAssigneeUpdateHash() =>
    r'24e0bddb4679d70611dd5e97e650530dc0fd1c71';

/// See also [TaskAssigneeUpdate].
@ProviderFor(TaskAssigneeUpdate)
final taskAssigneeUpdateProvider =
    AutoDisposeAsyncNotifierProvider<TaskAssigneeUpdate, void>.internal(
      TaskAssigneeUpdate.new,
      name: r'taskAssigneeUpdateProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$taskAssigneeUpdateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskAssigneeUpdate = AutoDisposeAsyncNotifier<void>;
String _$taskDeleteHash() => r'6da99530853c49eaad37e995c1ba1c731d5f10f1';

/// See also [TaskDelete].
@ProviderFor(TaskDelete)
final taskDeleteProvider =
    AutoDisposeAsyncNotifierProvider<TaskDelete, void>.internal(
      TaskDelete.new,
      name: r'taskDeleteProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$taskDeleteHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskDelete = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

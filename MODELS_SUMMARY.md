# Super-Admin Bootstrap System - Models Summary

This document provides a comprehensive overview of all the data models and enums created for the Time Management System's Super-Admin Bootstrap functionality.

## Core Models

### 1. User Model (`lib/core/models/user.dart`)
**Purpose**: Represents system users with authentication and role management capabilities.

**Key Features**:
- Immutable data structure using `freezed`
- Role-based access control (Super Admin, Admin, Employee)
- Profile management with avatar support
- Account status tracking (active, inactive, suspended)
- Comprehensive user permissions system
- Firebase integration with custom serialization

**Key Methods**:
- `isSuperAdmin`, `isAdmin`, `isEmployee` - Role checking
- `canManageUsers`, `canViewReports`, `canManageProjects` - Permission checking
- `activate()`, `deactivate()`, `suspend()` - Status management
- `updateProfile()`, `updateRole()` - Profile management

### 2. Employee Model (`lib/core/models/employee.dart`)
**Purpose**: Extended employee information beyond basic user data.

**Key Features**:
- Employee-specific fields (employee ID, department, manager)
- Skills and certifications tracking
- Employment status management
- Salary and benefits information
- Performance tracking capabilities

**Key Methods**:
- `fullName`, `displayName` - Name formatting
- `isWorking`, `isOnLeave` - Status checking
- `addSkill()`, `removeSkill()` - Skills management
- `updateSalary()`, `updateDepartment()` - Profile updates

### 3. Task Model (`lib/core/models/task.dart`)
**Purpose**: Task management with comprehensive tracking and workflow support.

**Key Features**:
- Task hierarchy with parent-child relationships
- Priority and status management
- Time tracking integration
- Progress monitoring
- Dependency management
- Tag and attachment support

**Key Methods**:
- `isOverdue`, `isDueSoon` - Time-based checks
- `updateStatus()`, `updateProgress()` - Workflow management
- `addTag()`, `addAttachment()` - Content management
- `addDependency()`, `removeDependency()` - Dependency tracking

### 4. Project Model (`lib/core/models/project.dart`)
**Purpose**: Project management with team collaboration and budget tracking.

**Key Features**:
- Project lifecycle management
- Team member assignment
- Budget tracking and utilization
- Progress monitoring with health scoring
- Client and department association
- Custom fields support

**Key Methods**:
- `isOverdue`, `isDueSoon`, `isOnTrack` - Status checking
- `healthScore` - Project health calculation
- `addTeamMember()`, `removeTeamMember()` - Team management
- `updateBudget()`, `updateProgress()` - Project updates

### 5. Leave Request Model (`lib/core/models/leave_request.dart`)
**Purpose**: Leave management with approval workflow.

**Key Features**:
- Leave type and duration tracking
- Approval workflow with comments
- Half-day and emergency leave support
- Working days calculation
- Attachment support for documentation

**Key Methods**:
- `isActive`, `isUpcoming`, `isPast` - Time-based status
- `approve()`, `reject()`, `cancel()` - Workflow actions
- `calculatedTotalDays`, `workingDays` - Duration calculations
- `canBeCancelled`, `canBeModified` - Permission checks

### 6. Department Model (`lib/core/models/department.dart`)
**Purpose**: Organizational structure with hierarchical department management.

**Key Features**:
- Hierarchical department structure
- Employee assignment and management
- Budget tracking per department
- Manager assignment
- Contact information management

**Key Methods**:
- `getHierarchyLevel()`, `getDepartmentPath()` - Hierarchy navigation
- `getTotalEmployeeCount()` - Recursive employee counting
- `addEmployee()`, `removeEmployee()` - Staff management
- `updateBudget()`, `updateManager()` - Department updates

### 7. Time Entry Model (`lib/core/models/time_entry.dart`)
**Purpose**: Time tracking with comprehensive reporting capabilities.

**Key Features**:
- Start/stop time tracking
- Manual time entry support
- Approval workflow
- Overtime calculation
- Project and task association
- Location tracking

**Key Methods**:
- `stop()`, `resume()` - Time tracking controls
- `isOvertime`, `overtimeHours` - Overtime calculations
- `approve()`, `unapprove()` - Approval workflow
- `overlapsWith()` - Conflict detection

## Enums

### 1. UserRole (`lib/core/enums/user_role.dart`)
- `superAdmin`, `admin`, `employee`
- Permission checking methods
- Role hierarchy support

### 2. UserStatus (`lib/core/enums/user_status.dart`)
- `active`, `inactive`, `suspended`, `pending`
- Status transition validation
- UI color and icon mapping

### 3. TaskStatus (`lib/core/enums/task_status.dart`)
- `todo`, `inProgress`, `review`, `completed`, `cancelled`
- Workflow state management
- Progress tracking support

### 4. TaskPriority (`lib/core/enums/task_priority.dart`)
- `low`, `medium`, `high`, `critical`
- Priority-based sorting
- Visual indicators for UI

### 5. LeaveStatus (`lib/core/enums/leave_status.dart`)
- `pending`, `approved`, `rejected`, `cancelled`
- Approval workflow states
- Action permissions per status

### 6. ProjectStatus (`lib/core/enums/project_status.dart`)
- `planning`, `active`, `onHold`, `completed`, `cancelled`
- Project lifecycle management
- Status-based permissions

### 7. ProjectPriority (`lib/core/enums/project_priority.dart`)
- `low`, `medium`, `high`, `critical`
- Priority-based resource allocation
- Visual priority indicators

## Key Features Across All Models

### 1. Immutability
- All models use `freezed` for immutable data structures
- Copy-with functionality for updates
- Type safety and null safety

### 2. Firebase Integration
- Custom `toFirestore()` and `fromFirestore()` methods
- Enum serialization handling
- Optimized for Firestore document structure

### 3. JSON Serialization
- Automatic JSON serialization with `json_annotation`
- Generated `fromJson()` and `toJson()` methods
- API integration ready

### 4. Validation and Business Logic
- Built-in validation rules
- Business logic encapsulation
- Consistent error handling

### 5. Extensibility
- Custom fields support in most models
- Metadata fields for future extensions
- Plugin-friendly architecture

### 6. Audit Trail
- `createdAt`, `updatedAt` timestamps
- `createdById` tracking
- Change history support

## Usage Examples

### Creating a Super Admin User
```dart
final superAdmin = User(
  id: 'user_123',
  email: 'admin@company.com',
  firstName: 'John',
  lastName: 'Doe',
  role: UserRole.superAdmin,
  status: UserStatus.active,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### Managing Project Team
```dart
final project = Project(
  id: 'proj_123',
  name: 'Mobile App Development',
  description: 'New mobile application',
  status: ProjectStatus.active,
  priority: ProjectPriority.high,
  managerId: 'user_123',
  startDate: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final updatedProject = project
  .addTeamMember('emp_456')
  .updateProgress(25);
```

### Time Tracking Workflow
```dart
// Start time tracking
final timeEntry = TimeEntry(
  id: 'time_123',
  employeeId: 'emp_456',
  taskId: 'task_789',
  startTime: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Stop time tracking
final completedEntry = timeEntry.stop();

// Approve time entry
final approvedEntry = completedEntry.approve('manager_123');
```

## Testing

All models include comprehensive unit tests covering:
- Model creation and validation
- Business logic methods
- Enum functionality
- Edge cases and error conditions

Run tests with:
```bash
flutter test test/unit/user_role_test.dart
```

## Code Generation

Models use code generation for:
- Freezed immutable classes
- JSON serialization
- Type-safe copying

Generate code with:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Next Steps

1. **Service Layer**: Implement Firebase services for each model
2. **State Management**: Add Riverpod providers for state management
3. **UI Components**: Create reusable widgets for each model
4. **API Integration**: Add REST API support alongside Firebase
5. **Validation**: Implement form validation using the validation rules
6. **Permissions**: Create permission-based UI components
7. **Reporting**: Add analytics and reporting capabilities
8. **Notifications**: Implement real-time notifications
9. **Offline Support**: Add offline-first capabilities
10. **Testing**: Expand test coverage with integration tests

This comprehensive model system provides a solid foundation for the Super-Admin Bootstrap functionality, ensuring type safety, maintainability, and scalability for the time management system. 
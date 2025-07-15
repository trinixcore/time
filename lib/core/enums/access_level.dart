/// Access level enumeration
enum AccessLevel {
  none('none', 'No Access', 0),
  read('read', 'Read Only', 10),
  write('write', 'Read & Write', 20),
  admin('admin', 'Admin Access', 30),
  owner('owner', 'Owner Access', 40);

  const AccessLevel(this.value, this.displayName, this.level);

  final String value;
  final String displayName;
  final int level;

  /// Create AccessLevel from string value
  static AccessLevel fromString(String value) {
    return AccessLevel.values.firstWhere(
      (access) => access.value == value,
      orElse: () => throw ArgumentError('Invalid access level: $value'),
    );
  }

  /// Check if this access level has equal or higher permissions than another
  bool hasLevelOrAbove(AccessLevel other) => level >= other.level;

  /// Check if this access level has lower permissions than another
  bool hasLevelBelow(AccessLevel other) => level < other.level;

  // Convenience getters
  bool get isNone => this == AccessLevel.none;
  bool get isRead => this == AccessLevel.read;
  bool get isWrite => this == AccessLevel.write;
  bool get isAdmin => this == AccessLevel.admin;
  bool get isOwner => this == AccessLevel.owner;

  // Permission checks
  bool get canRead => level >= AccessLevel.read.level;
  bool get canWrite => level >= AccessLevel.write.level;
  bool get canAdminister => level >= AccessLevel.admin.level;
  bool get canOwn => level >= AccessLevel.owner.level;
  bool get canDelete => level >= AccessLevel.write.level;
  bool get canShare => level >= AccessLevel.admin.level;
  bool get canManagePermissions => level >= AccessLevel.owner.level;

  // Get all access levels at or below this level
  List<AccessLevel> getAccessLevelsAtOrBelow() {
    return AccessLevel.values.where((access) => access.level <= level).toList();
  }

  // Get all access levels above this level
  List<AccessLevel> getAccessLevelsAbove() {
    return AccessLevel.values.where((access) => access.level > level).toList();
  }
}

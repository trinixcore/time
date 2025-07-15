// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentManagementServiceHash() =>
    r'b2fdcba8cfbdbf8a5c16f7b4b636ff3556f4411b';

/// See also [documentManagementService].
@ProviderFor(documentManagementService)
final documentManagementServiceProvider =
    AutoDisposeProvider<DocumentManagementService>.internal(
      documentManagementService,
      name: r'documentManagementServiceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$documentManagementServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DocumentManagementServiceRef =
    AutoDisposeProviderRef<DocumentManagementService>;
String _$firebaseDocumentServiceHash() =>
    r'91163388e4c1575db4cb6058b94e7919cdaf800d';

/// See also [firebaseDocumentService].
@ProviderFor(firebaseDocumentService)
final firebaseDocumentServiceProvider =
    AutoDisposeProvider<FirebaseDocumentService>.internal(
      firebaseDocumentService,
      name: r'firebaseDocumentServiceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$firebaseDocumentServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseDocumentServiceRef =
    AutoDisposeProviderRef<FirebaseDocumentService>;
String _$documentsHash() => r'd18231bebc9a2bc04324463fbd74b061cb22d430';

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

/// See also [documents].
@ProviderFor(documents)
const documentsProvider = DocumentsFamily();

/// See also [documents].
class DocumentsFamily extends Family<AsyncValue<List<DocumentModel>>> {
  /// See also [documents].
  const DocumentsFamily();

  /// See also [documents].
  DocumentsProvider call(DocumentQuery query) {
    return DocumentsProvider(query);
  }

  @override
  DocumentsProvider getProviderOverride(covariant DocumentsProvider provider) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentsProvider';
}

/// See also [documents].
class DocumentsProvider extends AutoDisposeStreamProvider<List<DocumentModel>> {
  /// See also [documents].
  DocumentsProvider(DocumentQuery query)
    : this._internal(
        (ref) => documents(ref as DocumentsRef, query),
        from: documentsProvider,
        name: r'documentsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$documentsHash,
        dependencies: DocumentsFamily._dependencies,
        allTransitiveDependencies: DocumentsFamily._allTransitiveDependencies,
        query: query,
      );

  DocumentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final DocumentQuery query;

  @override
  Override overrideWith(
    Stream<List<DocumentModel>> Function(DocumentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentsProvider._internal(
        (ref) => create(ref as DocumentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<DocumentModel>> createElement() {
    return _DocumentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentsRef on AutoDisposeStreamProviderRef<List<DocumentModel>> {
  /// The parameter `query` of this provider.
  DocumentQuery get query;
}

class _DocumentsProviderElement
    extends AutoDisposeStreamProviderElement<List<DocumentModel>>
    with DocumentsRef {
  _DocumentsProviderElement(super.provider);

  @override
  DocumentQuery get query => (origin as DocumentsProvider).query;
}

String _$foldersHash() => r'4d9872245dbb11246bf7fa7992683170ccfc77bc';

/// See also [folders].
@ProviderFor(folders)
const foldersProvider = FoldersFamily();

/// See also [folders].
class FoldersFamily extends Family<AsyncValue<List<FolderModel>>> {
  /// See also [folders].
  const FoldersFamily();

  /// See also [folders].
  FoldersProvider call(FolderQuery query) {
    return FoldersProvider(query);
  }

  @override
  FoldersProvider getProviderOverride(covariant FoldersProvider provider) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'foldersProvider';
}

/// See also [folders].
class FoldersProvider extends AutoDisposeStreamProvider<List<FolderModel>> {
  /// See also [folders].
  FoldersProvider(FolderQuery query)
    : this._internal(
        (ref) => folders(ref as FoldersRef, query),
        from: foldersProvider,
        name: r'foldersProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$foldersHash,
        dependencies: FoldersFamily._dependencies,
        allTransitiveDependencies: FoldersFamily._allTransitiveDependencies,
        query: query,
      );

  FoldersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final FolderQuery query;

  @override
  Override overrideWith(
    Stream<List<FolderModel>> Function(FoldersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FoldersProvider._internal(
        (ref) => create(ref as FoldersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<FolderModel>> createElement() {
    return _FoldersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FoldersProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FoldersRef on AutoDisposeStreamProviderRef<List<FolderModel>> {
  /// The parameter `query` of this provider.
  FolderQuery get query;
}

class _FoldersProviderElement
    extends AutoDisposeStreamProviderElement<List<FolderModel>>
    with FoldersRef {
  _FoldersProviderElement(super.provider);

  @override
  FolderQuery get query => (origin as FoldersProvider).query;
}

String _$documentHash() => r'9947daa292c45d386c10ff9c8f998888e8d3facc';

/// See also [document].
@ProviderFor(document)
const documentProvider = DocumentFamily();

/// See also [document].
class DocumentFamily extends Family<AsyncValue<DocumentModel?>> {
  /// See also [document].
  const DocumentFamily();

  /// See also [document].
  DocumentProvider call(String documentId) {
    return DocumentProvider(documentId);
  }

  @override
  DocumentProvider getProviderOverride(covariant DocumentProvider provider) {
    return call(provider.documentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentProvider';
}

/// See also [document].
class DocumentProvider extends AutoDisposeFutureProvider<DocumentModel?> {
  /// See also [document].
  DocumentProvider(String documentId)
    : this._internal(
        (ref) => document(ref as DocumentRef, documentId),
        from: documentProvider,
        name: r'documentProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$documentHash,
        dependencies: DocumentFamily._dependencies,
        allTransitiveDependencies: DocumentFamily._allTransitiveDependencies,
        documentId: documentId,
      );

  DocumentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.documentId,
  }) : super.internal();

  final String documentId;

  @override
  Override overrideWith(
    FutureOr<DocumentModel?> Function(DocumentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentProvider._internal(
        (ref) => create(ref as DocumentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        documentId: documentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DocumentModel?> createElement() {
    return _DocumentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentProvider && other.documentId == documentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, documentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentRef on AutoDisposeFutureProviderRef<DocumentModel?> {
  /// The parameter `documentId` of this provider.
  String get documentId;
}

class _DocumentProviderElement
    extends AutoDisposeFutureProviderElement<DocumentModel?>
    with DocumentRef {
  _DocumentProviderElement(super.provider);

  @override
  String get documentId => (origin as DocumentProvider).documentId;
}

String _$folderHash() => r'16d7b56c4bde17400fbd1695aa5731bd1c1045fc';

/// See also [folder].
@ProviderFor(folder)
const folderProvider = FolderFamily();

/// See also [folder].
class FolderFamily extends Family<AsyncValue<FolderModel?>> {
  /// See also [folder].
  const FolderFamily();

  /// See also [folder].
  FolderProvider call(String folderId) {
    return FolderProvider(folderId);
  }

  @override
  FolderProvider getProviderOverride(covariant FolderProvider provider) {
    return call(provider.folderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'folderProvider';
}

/// See also [folder].
class FolderProvider extends AutoDisposeFutureProvider<FolderModel?> {
  /// See also [folder].
  FolderProvider(String folderId)
    : this._internal(
        (ref) => folder(ref as FolderRef, folderId),
        from: folderProvider,
        name: r'folderProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product') ? null : _$folderHash,
        dependencies: FolderFamily._dependencies,
        allTransitiveDependencies: FolderFamily._allTransitiveDependencies,
        folderId: folderId,
      );

  FolderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.folderId,
  }) : super.internal();

  final String folderId;

  @override
  Override overrideWith(
    FutureOr<FolderModel?> Function(FolderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FolderProvider._internal(
        (ref) => create(ref as FolderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        folderId: folderId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FolderModel?> createElement() {
    return _FolderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderProvider && other.folderId == folderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FolderRef on AutoDisposeFutureProviderRef<FolderModel?> {
  /// The parameter `folderId` of this provider.
  String get folderId;
}

class _FolderProviderElement
    extends AutoDisposeFutureProviderElement<FolderModel?>
    with FolderRef {
  _FolderProviderElement(super.provider);

  @override
  String get folderId => (origin as FolderProvider).folderId;
}

String _$documentStatisticsHash() =>
    r'96d618afc5bac7c96ef1b5eee5c23dde99c5da15';

/// See also [documentStatistics].
@ProviderFor(documentStatistics)
const documentStatisticsProvider = DocumentStatisticsFamily();

/// See also [documentStatistics].
class DocumentStatisticsFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// See also [documentStatistics].
  const DocumentStatisticsFamily();

  /// See also [documentStatistics].
  DocumentStatisticsProvider call({DocumentCategory? category}) {
    return DocumentStatisticsProvider(category: category);
  }

  @override
  DocumentStatisticsProvider getProviderOverride(
    covariant DocumentStatisticsProvider provider,
  ) {
    return call(category: provider.category);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentStatisticsProvider';
}

/// See also [documentStatistics].
class DocumentStatisticsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// See also [documentStatistics].
  DocumentStatisticsProvider({DocumentCategory? category})
    : this._internal(
        (ref) => documentStatistics(
          ref as DocumentStatisticsRef,
          category: category,
        ),
        from: documentStatisticsProvider,
        name: r'documentStatisticsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$documentStatisticsHash,
        dependencies: DocumentStatisticsFamily._dependencies,
        allTransitiveDependencies:
            DocumentStatisticsFamily._allTransitiveDependencies,
        category: category,
      );

  DocumentStatisticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final DocumentCategory? category;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(DocumentStatisticsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentStatisticsProvider._internal(
        (ref) => create(ref as DocumentStatisticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _DocumentStatisticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentStatisticsProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentStatisticsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `category` of this provider.
  DocumentCategory? get category;
}

class _DocumentStatisticsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with DocumentStatisticsRef {
  _DocumentStatisticsProviderElement(super.provider);

  @override
  DocumentCategory? get category =>
      (origin as DocumentStatisticsProvider).category;
}

String _$canUploadToEmployeeFolderHash() =>
    r'c6ac41a773ca41aa4e28a275408d060ef0a85f1f';

/// See also [canUploadToEmployeeFolder].
@ProviderFor(canUploadToEmployeeFolder)
const canUploadToEmployeeFolderProvider = CanUploadToEmployeeFolderFamily();

/// See also [canUploadToEmployeeFolder].
class CanUploadToEmployeeFolderFamily extends Family<AsyncValue<bool>> {
  /// See also [canUploadToEmployeeFolder].
  const CanUploadToEmployeeFolderFamily();

  /// See also [canUploadToEmployeeFolder].
  CanUploadToEmployeeFolderProvider call(
    UserRole role,
    String folderCode,
    String folderName,
  ) {
    return CanUploadToEmployeeFolderProvider(role, folderCode, folderName);
  }

  @override
  CanUploadToEmployeeFolderProvider getProviderOverride(
    covariant CanUploadToEmployeeFolderProvider provider,
  ) {
    return call(provider.role, provider.folderCode, provider.folderName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'canUploadToEmployeeFolderProvider';
}

/// See also [canUploadToEmployeeFolder].
class CanUploadToEmployeeFolderProvider
    extends AutoDisposeFutureProvider<bool> {
  /// See also [canUploadToEmployeeFolder].
  CanUploadToEmployeeFolderProvider(
    UserRole role,
    String folderCode,
    String folderName,
  ) : this._internal(
        (ref) => canUploadToEmployeeFolder(
          ref as CanUploadToEmployeeFolderRef,
          role,
          folderCode,
          folderName,
        ),
        from: canUploadToEmployeeFolderProvider,
        name: r'canUploadToEmployeeFolderProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$canUploadToEmployeeFolderHash,
        dependencies: CanUploadToEmployeeFolderFamily._dependencies,
        allTransitiveDependencies:
            CanUploadToEmployeeFolderFamily._allTransitiveDependencies,
        role: role,
        folderCode: folderCode,
        folderName: folderName,
      );

  CanUploadToEmployeeFolderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.role,
    required this.folderCode,
    required this.folderName,
  }) : super.internal();

  final UserRole role;
  final String folderCode;
  final String folderName;

  @override
  Override overrideWith(
    FutureOr<bool> Function(CanUploadToEmployeeFolderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CanUploadToEmployeeFolderProvider._internal(
        (ref) => create(ref as CanUploadToEmployeeFolderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        role: role,
        folderCode: folderCode,
        folderName: folderName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _CanUploadToEmployeeFolderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CanUploadToEmployeeFolderProvider &&
        other.role == role &&
        other.folderCode == folderCode &&
        other.folderName == folderName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, role.hashCode);
    hash = _SystemHash.combine(hash, folderCode.hashCode);
    hash = _SystemHash.combine(hash, folderName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CanUploadToEmployeeFolderRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `role` of this provider.
  UserRole get role;

  /// The parameter `folderCode` of this provider.
  String get folderCode;

  /// The parameter `folderName` of this provider.
  String get folderName;
}

class _CanUploadToEmployeeFolderProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with CanUploadToEmployeeFolderRef {
  _CanUploadToEmployeeFolderProviderElement(super.provider);

  @override
  UserRole get role => (origin as CanUploadToEmployeeFolderProvider).role;
  @override
  String get folderCode =>
      (origin as CanUploadToEmployeeFolderProvider).folderCode;
  @override
  String get folderName =>
      (origin as CanUploadToEmployeeFolderProvider).folderName;
}

String _$canViewEmployeeFolderHash() =>
    r'a32d0965247cf8493fc2f2e2d45ad8f8b7ab97e4';

/// See also [canViewEmployeeFolder].
@ProviderFor(canViewEmployeeFolder)
const canViewEmployeeFolderProvider = CanViewEmployeeFolderFamily();

/// See also [canViewEmployeeFolder].
class CanViewEmployeeFolderFamily extends Family<AsyncValue<bool>> {
  /// See also [canViewEmployeeFolder].
  const CanViewEmployeeFolderFamily();

  /// See also [canViewEmployeeFolder].
  CanViewEmployeeFolderProvider call(
    UserRole role,
    String folderCode,
    String folderName, {
    String? currentUserEmployeeId,
    String? targetEmployeeId,
  }) {
    return CanViewEmployeeFolderProvider(
      role,
      folderCode,
      folderName,
      currentUserEmployeeId: currentUserEmployeeId,
      targetEmployeeId: targetEmployeeId,
    );
  }

  @override
  CanViewEmployeeFolderProvider getProviderOverride(
    covariant CanViewEmployeeFolderProvider provider,
  ) {
    return call(
      provider.role,
      provider.folderCode,
      provider.folderName,
      currentUserEmployeeId: provider.currentUserEmployeeId,
      targetEmployeeId: provider.targetEmployeeId,
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
  String? get name => r'canViewEmployeeFolderProvider';
}

/// See also [canViewEmployeeFolder].
class CanViewEmployeeFolderProvider extends AutoDisposeFutureProvider<bool> {
  /// See also [canViewEmployeeFolder].
  CanViewEmployeeFolderProvider(
    UserRole role,
    String folderCode,
    String folderName, {
    String? currentUserEmployeeId,
    String? targetEmployeeId,
  }) : this._internal(
         (ref) => canViewEmployeeFolder(
           ref as CanViewEmployeeFolderRef,
           role,
           folderCode,
           folderName,
           currentUserEmployeeId: currentUserEmployeeId,
           targetEmployeeId: targetEmployeeId,
         ),
         from: canViewEmployeeFolderProvider,
         name: r'canViewEmployeeFolderProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$canViewEmployeeFolderHash,
         dependencies: CanViewEmployeeFolderFamily._dependencies,
         allTransitiveDependencies:
             CanViewEmployeeFolderFamily._allTransitiveDependencies,
         role: role,
         folderCode: folderCode,
         folderName: folderName,
         currentUserEmployeeId: currentUserEmployeeId,
         targetEmployeeId: targetEmployeeId,
       );

  CanViewEmployeeFolderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.role,
    required this.folderCode,
    required this.folderName,
    required this.currentUserEmployeeId,
    required this.targetEmployeeId,
  }) : super.internal();

  final UserRole role;
  final String folderCode;
  final String folderName;
  final String? currentUserEmployeeId;
  final String? targetEmployeeId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(CanViewEmployeeFolderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CanViewEmployeeFolderProvider._internal(
        (ref) => create(ref as CanViewEmployeeFolderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        role: role,
        folderCode: folderCode,
        folderName: folderName,
        currentUserEmployeeId: currentUserEmployeeId,
        targetEmployeeId: targetEmployeeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _CanViewEmployeeFolderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CanViewEmployeeFolderProvider &&
        other.role == role &&
        other.folderCode == folderCode &&
        other.folderName == folderName &&
        other.currentUserEmployeeId == currentUserEmployeeId &&
        other.targetEmployeeId == targetEmployeeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, role.hashCode);
    hash = _SystemHash.combine(hash, folderCode.hashCode);
    hash = _SystemHash.combine(hash, folderName.hashCode);
    hash = _SystemHash.combine(hash, currentUserEmployeeId.hashCode);
    hash = _SystemHash.combine(hash, targetEmployeeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CanViewEmployeeFolderRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `role` of this provider.
  UserRole get role;

  /// The parameter `folderCode` of this provider.
  String get folderCode;

  /// The parameter `folderName` of this provider.
  String get folderName;

  /// The parameter `currentUserEmployeeId` of this provider.
  String? get currentUserEmployeeId;

  /// The parameter `targetEmployeeId` of this provider.
  String? get targetEmployeeId;
}

class _CanViewEmployeeFolderProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with CanViewEmployeeFolderRef {
  _CanViewEmployeeFolderProviderElement(super.provider);

  @override
  UserRole get role => (origin as CanViewEmployeeFolderProvider).role;
  @override
  String get folderCode => (origin as CanViewEmployeeFolderProvider).folderCode;
  @override
  String get folderName => (origin as CanViewEmployeeFolderProvider).folderName;
  @override
  String? get currentUserEmployeeId =>
      (origin as CanViewEmployeeFolderProvider).currentUserEmployeeId;
  @override
  String? get targetEmployeeId =>
      (origin as CanViewEmployeeFolderProvider).targetEmployeeId;
}

String _$canDeleteFromEmployeeFolderHash() =>
    r'40e83ee5b5f7d4b0767462e194f70ca1b02d1ac9';

/// See also [canDeleteFromEmployeeFolder].
@ProviderFor(canDeleteFromEmployeeFolder)
const canDeleteFromEmployeeFolderProvider = CanDeleteFromEmployeeFolderFamily();

/// See also [canDeleteFromEmployeeFolder].
class CanDeleteFromEmployeeFolderFamily extends Family<AsyncValue<bool>> {
  /// See also [canDeleteFromEmployeeFolder].
  const CanDeleteFromEmployeeFolderFamily();

  /// See also [canDeleteFromEmployeeFolder].
  CanDeleteFromEmployeeFolderProvider call(
    UserRole role,
    String folderCode,
    String folderName,
  ) {
    return CanDeleteFromEmployeeFolderProvider(role, folderCode, folderName);
  }

  @override
  CanDeleteFromEmployeeFolderProvider getProviderOverride(
    covariant CanDeleteFromEmployeeFolderProvider provider,
  ) {
    return call(provider.role, provider.folderCode, provider.folderName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'canDeleteFromEmployeeFolderProvider';
}

/// See also [canDeleteFromEmployeeFolder].
class CanDeleteFromEmployeeFolderProvider
    extends AutoDisposeFutureProvider<bool> {
  /// See also [canDeleteFromEmployeeFolder].
  CanDeleteFromEmployeeFolderProvider(
    UserRole role,
    String folderCode,
    String folderName,
  ) : this._internal(
        (ref) => canDeleteFromEmployeeFolder(
          ref as CanDeleteFromEmployeeFolderRef,
          role,
          folderCode,
          folderName,
        ),
        from: canDeleteFromEmployeeFolderProvider,
        name: r'canDeleteFromEmployeeFolderProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$canDeleteFromEmployeeFolderHash,
        dependencies: CanDeleteFromEmployeeFolderFamily._dependencies,
        allTransitiveDependencies:
            CanDeleteFromEmployeeFolderFamily._allTransitiveDependencies,
        role: role,
        folderCode: folderCode,
        folderName: folderName,
      );

  CanDeleteFromEmployeeFolderProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.role,
    required this.folderCode,
    required this.folderName,
  }) : super.internal();

  final UserRole role;
  final String folderCode;
  final String folderName;

  @override
  Override overrideWith(
    FutureOr<bool> Function(CanDeleteFromEmployeeFolderRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CanDeleteFromEmployeeFolderProvider._internal(
        (ref) => create(ref as CanDeleteFromEmployeeFolderRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        role: role,
        folderCode: folderCode,
        folderName: folderName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _CanDeleteFromEmployeeFolderProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CanDeleteFromEmployeeFolderProvider &&
        other.role == role &&
        other.folderCode == folderCode &&
        other.folderName == folderName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, role.hashCode);
    hash = _SystemHash.combine(hash, folderCode.hashCode);
    hash = _SystemHash.combine(hash, folderName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CanDeleteFromEmployeeFolderRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `role` of this provider.
  UserRole get role;

  /// The parameter `folderCode` of this provider.
  String get folderCode;

  /// The parameter `folderName` of this provider.
  String get folderName;
}

class _CanDeleteFromEmployeeFolderProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with CanDeleteFromEmployeeFolderRef {
  _CanDeleteFromEmployeeFolderProviderElement(super.provider);

  @override
  UserRole get role => (origin as CanDeleteFromEmployeeFolderProvider).role;
  @override
  String get folderCode =>
      (origin as CanDeleteFromEmployeeFolderProvider).folderCode;
  @override
  String get folderName =>
      (origin as CanDeleteFromEmployeeFolderProvider).folderName;
}

String _$uploadDocumentHash() => r'ab482ac2fa74bf14eaeee3153c2ccca26db22ad6';

/// See also [UploadDocument].
@ProviderFor(UploadDocument)
final uploadDocumentProvider = AutoDisposeNotifierProvider<
  UploadDocument,
  AsyncValue<DocumentModel?>
>.internal(
  UploadDocument.new,
  name: r'uploadDocumentProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$uploadDocumentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UploadDocument = AutoDisposeNotifier<AsyncValue<DocumentModel?>>;
String _$createFolderHash() => r'458b1e8ea0909dddb2ec0ce4159413619c5ac56d';

/// See also [CreateFolder].
@ProviderFor(CreateFolder)
final createFolderProvider = AutoDisposeNotifierProvider<
  CreateFolder,
  AsyncValue<FolderModel?>
>.internal(
  CreateFolder.new,
  name: r'createFolderProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$createFolderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CreateFolder = AutoDisposeNotifier<AsyncValue<FolderModel?>>;
String _$documentActionsHash() => r'db029b3921c630585af725de45650d24f5098139';

/// See also [DocumentActions].
@ProviderFor(DocumentActions)
final documentActionsProvider =
    AutoDisposeNotifierProvider<DocumentActions, AsyncValue<String?>>.internal(
      DocumentActions.new,
      name: r'documentActionsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$documentActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DocumentActions = AutoDisposeNotifier<AsyncValue<String?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

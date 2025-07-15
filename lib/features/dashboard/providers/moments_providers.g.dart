// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moments_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$momentsServiceHash() => r'a832a865a4743828ba29e9a25a890ffea770518b';

/// See also [momentsService].
@ProviderFor(momentsService)
final momentsServiceProvider = AutoDisposeProvider<MomentsService>.internal(
  momentsService,
  name: r'momentsServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$momentsServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MomentsServiceRef = AutoDisposeProviderRef<MomentsService>;
String _$activeMomentMediaHash() => r'b54461a66663349b5504fffe7c6ff5a4674d0a50';

/// See also [activeMomentMedia].
@ProviderFor(activeMomentMedia)
final activeMomentMediaProvider =
    AutoDisposeFutureProvider<List<MomentMedia>>.internal(
      activeMomentMedia,
      name: r'activeMomentMediaProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$activeMomentMediaHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveMomentMediaRef = AutoDisposeFutureProviderRef<List<MomentMedia>>;
String _$activeAnnouncementsHash() =>
    r'183ed45056dafddca25f4d04dac679d730e802a2';

/// See also [activeAnnouncements].
@ProviderFor(activeAnnouncements)
final activeAnnouncementsProvider =
    AutoDisposeFutureProvider<List<Announcement>>.internal(
      activeAnnouncements,
      name: r'activeAnnouncementsProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$activeAnnouncementsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveAnnouncementsRef =
    AutoDisposeFutureProviderRef<List<Announcement>>;
String _$momentMediaUploadHash() => r'2823105873afeb05deb58a3cdf0b3a98c3238676';

/// See also [MomentMediaUpload].
@ProviderFor(MomentMediaUpload)
final momentMediaUploadProvider =
    AutoDisposeAsyncNotifierProvider<MomentMediaUpload, void>.internal(
      MomentMediaUpload.new,
      name: r'momentMediaUploadProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$momentMediaUploadHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MomentMediaUpload = AutoDisposeAsyncNotifier<void>;
String _$momentMediaDeleteHash() => r'9b0f03b9893e560f070d19fa63d42508a49abcd5';

/// See also [MomentMediaDelete].
@ProviderFor(MomentMediaDelete)
final momentMediaDeleteProvider =
    AutoDisposeAsyncNotifierProvider<MomentMediaDelete, void>.internal(
      MomentMediaDelete.new,
      name: r'momentMediaDeleteProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$momentMediaDeleteHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MomentMediaDelete = AutoDisposeAsyncNotifier<void>;
String _$announcementCreateHash() =>
    r'886e73c13093e8ac74a85ea4ec162a0afd5cd692';

/// See also [AnnouncementCreate].
@ProviderFor(AnnouncementCreate)
final announcementCreateProvider =
    AutoDisposeAsyncNotifierProvider<AnnouncementCreate, void>.internal(
      AnnouncementCreate.new,
      name: r'announcementCreateProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$announcementCreateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AnnouncementCreate = AutoDisposeAsyncNotifier<void>;
String _$announcementUpdateHash() =>
    r'45c66e2455f2f3093312559fc6588393ade4665c';

/// See also [AnnouncementUpdate].
@ProviderFor(AnnouncementUpdate)
final announcementUpdateProvider =
    AutoDisposeAsyncNotifierProvider<AnnouncementUpdate, void>.internal(
      AnnouncementUpdate.new,
      name: r'announcementUpdateProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$announcementUpdateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AnnouncementUpdate = AutoDisposeAsyncNotifier<void>;
String _$announcementDeleteHash() =>
    r'8e654f79e9bbaba5cdd3b799357a2f057b76f706';

/// See also [AnnouncementDelete].
@ProviderFor(AnnouncementDelete)
final announcementDeleteProvider =
    AutoDisposeAsyncNotifierProvider<AnnouncementDelete, void>.internal(
      AnnouncementDelete.new,
      name: r'announcementDeleteProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$announcementDeleteHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AnnouncementDelete = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:time/core/services/auth_service.dart';
import 'package:time/shared/providers/auth_providers.dart';
import 'package:time/core/enums/user_role.dart';
import 'package:time/core/router/app_router.dart';
import 'package:time/core/models/user_model.dart';

void main() {
  group('Route Guard Tests', () {
    late ProviderContainer container;
    late GoRouter router;

    setUp(() {
      container = ProviderContainer();
      router = container.read(goRouterProvider);
    });

    tearDown(() {
      container.dispose();
    });

    group('Setup Redirect Logic', () {
      test(
        'should redirect to setup when no users exist and setup not completed',
        () async {
          // Mock providers to return setup required state
          container = ProviderContainer(
            overrides: [
              shouldShowSetupProvider.overrideWith(
                (ref) => const AsyncValue.data(true),
              ),
              authStateProvider.overrideWith((ref) => Stream.value(null)),
            ],
          );

          router = container.read(goRouterProvider);

          // Test redirect from root
          final location =
              router.routerDelegate.currentConfiguration.uri.toString();
          expect(location, contains('/setup-super-admin'));
        },
      );

      test('should not redirect to setup when users exist', () async {
        container = ProviderContainer(
          overrides: [
            shouldShowSetupProvider.overrideWith(
              (ref) => const AsyncValue.data(false),
            ),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );

        router = container.read(goRouterProvider);

        // Should redirect to login instead
        final location =
            router.routerDelegate.currentConfiguration.uri.toString();
        expect(location, contains('/login'));
      });
    });

    group('Authentication Redirect Logic', () {
      test('should redirect unauthenticated users to login', () async {
        container = ProviderContainer(
          overrides: [
            shouldShowSetupProvider.overrideWith(
              (ref) => const AsyncValue.data(false),
            ),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
        );

        router = container.read(goRouterProvider);

        // Try to access protected route
        router.go('/dashboard');

        final location =
            router.routerDelegate.currentConfiguration.uri.toString();
        expect(location, contains('/login'));
      });

      test(
        'should redirect authenticated users away from auth pages',
        () async {
          final mockUser = UserModel(
            uid: 'test-uid',
            email: 'test@example.com',
            displayName: 'Test User',
            role: UserRole.employee,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            mfaEnabled: false,
            createdBy: 'system',
          );

          container = ProviderContainer(
            overrides: [
              shouldShowSetupProvider.overrideWith(
                (ref) => const AsyncValue.data(false),
              ),
              currentUserProvider.overrideWith((ref) => Future.value(mockUser)),
            ],
          );

          router = container.read(goRouterProvider);

          // Try to access login page while authenticated
          router.go('/login');

          final location =
              router.routerDelegate.currentConfiguration.uri.toString();
          expect(location, contains('/dashboard'));
        },
      );
    });

    group('Profile Completion Redirect Logic', () {
      test(
        'should redirect to profile setup when displayName is missing',
        () async {
          final incompleteUser = UserModel(
            uid: 'test-uid',
            email: 'test@example.com',
            displayName:
                '', // Empty display name to simulate missing/incomplete profile
            role: UserRole.employee,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            mfaEnabled: false,
            createdBy: 'system',
          );

          container = ProviderContainer(
            overrides: [
              shouldShowSetupProvider.overrideWith(
                (ref) => const AsyncValue.data(false),
              ),
              currentUserProvider.overrideWith(
                (ref) => Future.value(incompleteUser),
              ),
            ],
          );

          router = container.read(goRouterProvider);

          // Try to access dashboard with incomplete profile
          router.go('/dashboard');

          final location =
              router.routerDelegate.currentConfiguration.uri.toString();
          expect(location, contains('/first-time-profile'));
        },
      );

      test(
        'should redirect to profile setup when displayName is empty',
        () async {
          final incompleteUser = UserModel(
            uid: 'test-uid',
            email: 'test@example.com',
            displayName: '', // Empty display name - testing incomplete profile
            role: UserRole.employee,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            mfaEnabled: false,
            createdBy: 'system',
          );

          container = ProviderContainer(
            overrides: [
              shouldShowSetupProvider.overrideWith(
                (ref) => const AsyncValue.data(false),
              ),
              currentUserProvider.overrideWith(
                (ref) => Future.value(incompleteUser),
              ),
            ],
          );

          router = container.read(goRouterProvider);

          router.go('/dashboard');

          final location =
              router.routerDelegate.currentConfiguration.uri.toString();
          expect(location, contains('/first-time-profile'));
        },
      );

      test(
        'should allow access to dashboard when profile is complete',
        () async {
          final completeUser = UserModel(
            uid: 'test-uid',
            email: 'test@example.com',
            displayName: 'Complete User',
            role: UserRole.employee,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
            mfaEnabled: false,
            createdBy: 'system',
          );

          container = ProviderContainer(
            overrides: [
              shouldShowSetupProvider.overrideWith(
                (ref) => const AsyncValue.data(false),
              ),
              currentUserProvider.overrideWith(
                (ref) => Future.value(completeUser),
              ),
            ],
          );

          router = container.read(goRouterProvider);

          router.go('/dashboard');

          final location =
              router.routerDelegate.currentConfiguration.uri.toString();
          expect(location, contains('/dashboard'));
        },
      );
    });

    group('Role-based Access Control', () {
      test('should allow super admin access to all routes', () async {
        final superAdmin = UserModel(
          uid: 'super-admin-uid',
          email: 'admin@example.com',
          displayName: 'Super Admin',
          role: UserRole.superAdmin,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          mfaEnabled: false,
          createdBy: 'system',
        );

        container = ProviderContainer(
          overrides: [
            shouldShowSetupProvider.overrideWith(
              (ref) => const AsyncValue.data(false),
            ),
            currentUserProvider.overrideWith((ref) => Future.value(superAdmin)),
          ],
        );

        router = container.read(goRouterProvider);

        // Super admin should access dashboard
        router.go('/dashboard');
        final location =
            router.routerDelegate.currentConfiguration.uri.toString();
        expect(location, contains('/dashboard'));
      });

      test('should restrict employee access to admin routes', () async {
        final employee = UserModel(
          uid: 'employee-uid',
          email: 'employee@example.com',
          displayName: 'Employee User',
          role: UserRole.employee,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          mfaEnabled: false,
          createdBy: 'system',
        );

        container = ProviderContainer(
          overrides: [
            shouldShowSetupProvider.overrideWith(
              (ref) => const AsyncValue.data(false),
            ),
            currentUserProvider.overrideWith((ref) => Future.value(employee)),
          ],
        );

        // Test role-based access providers
        final canManageUsers = await container.read(
          canManageUsersProvider.future,
        );
        final canManageSystem = await container.read(
          canManageSystemProvider.future,
        );
        final isSuperAdmin = await container.read(isSuperAdminProvider.future);

        expect(canManageUsers, false);
        expect(canManageSystem, false);
        expect(isSuperAdmin, false);
      });
    });

    group('Loading State Handling', () {
      test('should stay on loading page when providers are loading', () async {
        container = ProviderContainer(
          overrides: [
            shouldShowSetupProvider.overrideWith(
              (ref) => const AsyncValue.loading(),
            ),
            authStateProvider.overrideWith(
              (ref) => Stream.value(null).asyncMap<User?>((event) async {
                await Future.delayed(const Duration(seconds: 1));
                return event as User?;
              }),
            ),
          ],
        );

        router = container.read(goRouterProvider);

        // Should stay on loading page while providers are loading
        final location =
            router.routerDelegate.currentConfiguration.uri.toString();
        expect(location, contains('/loading'));
      });
    });

    group('Error Handling', () {
      test('should handle provider errors gracefully', () async {
        container = ProviderContainer(
          overrides: [
            shouldShowSetupProvider.overrideWith(
              (ref) =>
                  AsyncValue.error('Setup check failed', StackTrace.current),
            ),
            authStateProvider.overrideWith(
              (ref) => Stream.error('Auth check failed'),
            ),
          ],
        );

        router = container.read(goRouterProvider);

        // Should redirect to login on error
        final location =
            router.routerDelegate.currentConfiguration.uri.toString();
        expect(location, anyOf(contains('/login'), contains('/loading')));
      });
    });
  });
}

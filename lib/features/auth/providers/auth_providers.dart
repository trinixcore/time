import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  return FirebaseAuth.instance.currentUser;
}

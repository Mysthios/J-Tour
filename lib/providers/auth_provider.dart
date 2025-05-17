import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:j_tour/models/user_model.dart';
import 'package:j_tour/services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth state provider
final authStateProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authServiceProvider).userStream;
});

// Current user provider
final currentUserProvider = FutureProvider<UserModel?>((ref) {
  return ref.watch(authServiceProvider).getCurrentUser();
});

// Is admin provider
final isAdminProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.maybeWhen(
    data: (user) => user?.role == 'admin',
    orElse: () => false,
  );
});

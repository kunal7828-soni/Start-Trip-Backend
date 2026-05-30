import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'global_providers.dart';

/// Models all discrete states representing application login sessions.
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

/// Authentication state manager bridging UI changes to the AuthRepository.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthInitial()) {
    _checkActiveSession();
  }

  /// Initial startup session retrieval
  Future<void> _checkActiveSession() async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
    } catch (e) {
      state = AuthError('Session retrieval failed: ${e.toString()}');
    }
  }

  /// Trigger SignIn credential operations
  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.signIn(email: email, password: password);
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const AuthError('Login failed: User record empty.');
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Trigger registration operations
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        phoneNumber: phoneNumber,
      );
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const AuthError('Registration failed: User record empty.');
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  /// Terminate active session
  Future<void> logout() async {
    state = const AuthLoading();
    await _authRepository.signOut();
    state = const Unauthenticated();
  }
}

/// Dynamic global authorization session provider.
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../config/supabase/supabase_config.dart';
import '../core/errors/exceptions.dart';
import '../core/utils/logger.dart';
import '../models/user_model.dart';

/// Contract definition for the Auth Repository.
abstract class AuthRepository {
  Future<UserModel?> signIn({required String email, required String password});
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
  });
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get onAuthStateChanged;
}

/// Firebase and Supabase coordinated Auth Repository Implementation.
class AuthRepositoryImpl implements AuthRepository {
  final firebase.FirebaseAuth _firebaseAuth;
  final supabase.SupabaseClient _supabaseClient;

  AuthRepositoryImpl({
    firebase.FirebaseAuth? firebaseAuth,
    supabase.SupabaseClient? supabaseClient,
  })  : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        _supabaseClient = supabaseClient ?? SupabaseConfig.client;

  @override
  Stream<UserModel?> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserFromDatabase(firebaseUser.uid);
    });
  }

  @override
  Future<UserModel?> signIn({required String email, required String password}) async {
    try {
      final credentials = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credentials.user == null) {
        throw const AuthException('SignIn failed: User is null.');
      }

      return await _getUserFromDatabase(credentials.user!.uid);
    } on firebase.FirebaseAuthException catch (e) {
      AppLogger.e('Firebase Auth Login Exception', e);
      throw AuthException(e.message ?? 'Authentication failed');
    } catch (e) {
      AppLogger.e('General Login Error', e);
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
  }) async {
    try {
      // 1. Register User inside Firebase Auth Console
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credentials.user;
      if (firebaseUser == null) {
        throw const AuthException('Registration failed: User is null.');
      }

      // 2. Synchronize details with the relational users table on Supabase
      final newUser = UserModel(
        id: firebaseUser.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        phoneNumber: phoneNumber?.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      await _supabaseClient.from('users').insert(newUser.toMap());

      // If user is a worker, insert profile row in the specialized workers table
      if (role == UserRole.worker) {
        await _supabaseClient.from('workers').insert({
          'id': firebaseUser.uid,
          'service_type': 'general',
          'is_active': false,
        });
      }

      return newUser;
    } on firebase.FirebaseAuthException catch (e) {
      AppLogger.e('Firebase Auth Registration Exception', e);
      throw AuthException(e.message ?? 'Registration failed');
    } catch (e) {
      AppLogger.e('Supabase relational Sync Exception during SignUp', e);
      // Rollback Firebase user registration if Supabase sync fails to keep integrity
      await _firebaseAuth.currentUser?.delete();
      throw AuthException('Sync error during signup: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _supabaseClient.auth.signOut();
    } catch (e) {
      AppLogger.e('Logout exception', e);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return await _getUserFromDatabase(firebaseUser.uid);
  }

  /// Retrieve full profile and permissions roles from our unified PostgreSQL table.
  Future<UserModel?> _getUserFromDatabase(String uid) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response == null) {
        AppLogger.w('Relational profile not found for authenticated Firebase UID: $uid');
        return null;
      }

      return UserModel.fromMap(response);
    } catch (e) {
      AppLogger.e('Failed to fetch user mapping from PostgreSQL database', e);
      return null;
    }
  }
}

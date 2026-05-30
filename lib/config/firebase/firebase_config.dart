import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../env/env_config.dart';
import '../../core/utils/logger.dart';

/// Integration manager for Firebase services (Auth, Firestore, Cloud Functions).
class FirebaseConfig {
  FirebaseConfig._();

  /// Establishes early connection setups to the Firebase Cloud console.
  static Future<void> init() async {
    try {
      // Load custom platform parameters or fallback to web configuration
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: AppEnv.firebaseApiKey,
          appId: AppEnv.firebaseAppId,
          messagingSenderId: AppEnv.firebaseMessagingSenderId,
          projectId: AppEnv.firebaseProjectId,
        ),
      );
      AppLogger.i('Firebase Console core services initialized successfully.');
    } catch (e) {
      AppLogger.e('CRITICAL ERROR: Failed to configure Firebase application context', e);
      // Fail-silent in development testing, or raise standard exceptions
      if (!kDebugMode) {
        rethrow;
      }
    }
  }
}

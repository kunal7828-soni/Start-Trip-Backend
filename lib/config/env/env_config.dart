import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment variables configuration and validation manager for Trip Buddy.
class AppEnv {
  AppEnv._();

  /// Initialize environment configuration from the assets bundled `.env` file.
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      _validate();
    } catch (e) {
      if (kDebugMode) {
        print('Warning: Failed to load .env file. Falling back to platform environment variables or default stubs.');
      }
    }
  }

  /// Internal validation checks to ensure critical parameters exist.
  static void _validate() {
    final criticalKeys = [
      'FIREBASE_API_KEY',
      'FIREBASE_APP_ID',
      'FIREBASE_PROJECT_ID',
      'SUPABASE_URL',
      'SUPABASE_ANON_KEY',
      'GOOGLE_MAPS_API_KEY',
    ];

    for (final key in criticalKeys) {
      assert(
        dotenv.env[key] != null && dotenv.env[key]!.isNotEmpty,
        'CRITICAL ENVIRONMENT CONFIGURATION ERROR: "$key" is not configured in your .env file.',
      );
    }
  }

  /// Current application environment (development, production, testing).
  static String get environment => dotenv.env['APP_ENV'] ?? 'development';

  /// Check if the application is currently running in development mode.
  static bool get isDevelopment => environment == 'development';

  /// Firebase credentials
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  /// Supabase credentials
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Google Maps APIs
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// API endpoints
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://api.tripbuddy.com/v1';
}

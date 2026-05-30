import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env_config.dart';
import '../../core/utils/logger.dart';

/// Integration manager for Supabase services and remote PostgreSQL access.
class SupabaseConfig {
  SupabaseConfig._();

  /// Initialize the Supabase Flutter client.
  /// Pulls secure parameters from our runtime environment loader.
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: AppEnv.supabaseUrl,
        anonKey: AppEnv.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      AppLogger.i('Supabase Client and Relational Gateway initialized successfully.');
    } catch (e) {
      AppLogger.e('CRITICAL ERROR: Failed to establish Supabase connection link', e);
      rethrow;
    }
  }

  /// Exposed instance shortcut for direct queries.
  static SupabaseClient get client => Supabase.instance.client;
}

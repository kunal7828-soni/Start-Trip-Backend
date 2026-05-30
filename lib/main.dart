import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/env/env_config.dart';
import 'config/firebase/firebase_config.dart';
import 'config/routes/app_routes.dart';
import 'config/supabase/supabase_config.dart';
import 'core/theme/app_theme.dart';

import 'providers/theme_provider.dart';

void main() async {
  // 1. Ensure widgets infrastructure is fully bound before service initializations
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load secure environment variables (.env files)
  await AppEnv.init();

  // 3. Connect SDK instances to Firebase cloud projects
  await FirebaseConfig.init();

  // 4. Connect SDK instances to Supabase PostgreSQL database
  await SupabaseConfig.init();

  // 5. Fire up the application inside a Riverpod ProviderScope for dependency injection
  runApp(
    const ProviderScope(
      child: TripBuddyApp(),
    ),
  );
}

class TripBuddyApp extends ConsumerWidget {
  const TripBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeThemeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Trip Buddy',
      debugShowCheckedModeBanner: false,
      
      // Bind our premium responsive Material 3 design systems
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: activeThemeMode,
      
      // Attach declarative router configurations
      routerConfig: AppRouter.router,
    );
  }
}

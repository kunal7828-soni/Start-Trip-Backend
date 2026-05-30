import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/main_layout.dart';
import '../../core/widgets/worker_layout.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/home/screens/home_dashboard.dart';
import '../../features/transport/screens/transport_search_screen.dart';
import '../../features/home/screens/saved_trips_screen.dart';
import '../../features/maps/screens/nearby_places_screen.dart';
import '../../features/maps/screens/maps_preview_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/worker/screens/worker_dashboard.dart';
import '../../features/worker/screens/assigned_trips_screen.dart';
import '../../features/worker/screens/notifications_screen.dart';
import '../../features/worker/screens/worker_profile_screen.dart';
import 'route_names.dart';

/// Redesigned router engine mapping layouts, redirects, and shells.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Navigation error: ${state.error?.message}'),
      ),
    ),
    routes: [
      // 1. Onboarding & Authentication sequences (AuthLayout handled locally per screen)
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // 2. Traveler Flow Shell wrapping pages inside MainLayout (collapsible drawer + bottom bar)
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: RouteNames.home,
            builder: (context, state) => const HomeDashboard(),
          ),
          GoRoute(
            path: '/search-trip',
            name: RouteNames.railway, // Reuse previous route mappings
            builder: (context, state) => const TransportSearchScreen(),
          ),
          GoRoute(
            path: '/nearby-places',
            builder: (context, state) => const NearbyPlacesScreen(),
          ),
          GoRoute(
            path: '/saved-trips',
            builder: (context, state) => const SavedTripsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/maps-preview',
            name: RouteNames.maps,
            builder: (context, state) => const MapsPreviewScreen(),
          ),
        ],
      ),

      // 3. Worker Flow Shell wrapping pages inside WorkerLayout (workforce bottom bar)
      ShellRoute(
        builder: (context, state, child) {
          return WorkerLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/worker-dashboard',
            name: RouteNames.worker,
            builder: (context, state) => const WorkerDashboard(),
          ),
          GoRoute(
            path: '/worker-trips',
            builder: (context, state) => const AssignedTripsScreen(),
          ),
          GoRoute(
            path: '/worker-notifications',
            builder: (context, state) => const WorkerNotificationsScreen(),
          ),
          GoRoute(
            path: '/worker-profile',
            builder: (context, state) => const WorkerProfileScreen(),
          ),
        ],
      ),
    ],
  );
}

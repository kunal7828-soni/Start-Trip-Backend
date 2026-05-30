/// App-wide string constants for Trip Buddy.
class AppStrings {
  AppStrings._();

  static const String appName = 'Trip Buddy';
  static const String slogan = 'Your Smart Travel Assistant';

  // Authentication
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to explore custom travel routes and worker connections';
  static const String signupTitle = 'Create Account';
  static const String signupSubtitle = 'Register today and start mapping your next journey';
  static const String roleUser = 'Traveler';
  static const String roleWorker = 'Travel Partner / Worker';

  // Navigation
  static const String navHome = 'Home';
  static const String navTrips = 'My Trips';
  static const String navMaps = 'Explore Map';
  static const String navWorker = 'Workforce';
  static const String navProfile = 'Profile';

  // Errors
  static const String errNetwork = 'Connection timed out. Please check your network and try again.';
  static const String errUnauthorized = 'Invalid credentials or expired session. Please sign in again.';
  static const String errUnknown = 'An unexpected error occurred. Our team has been notified.';
}

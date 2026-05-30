/// Base class for all domain-level failures within the application.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Representing connectivity failures or timeout problems.
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No Internet connection. Please check your network.'])
      : super(message);
}

/// Representing cloud database or PostgreSQL remote execution issues.
class ServerFailure extends Failure {
  const ServerFailure([String message = 'A server error occurred. Please try again later.'])
      : super(message);
}

/// Representing login, signup, roles permissions, or session issues.
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

/// Representing invalid parameter structures or failed local cache retrieval.
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Failed to load local cached information.'])
      : super(message);
}

/// Default fallback failure type.
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unexpected error occurred.']) : super(message);
}

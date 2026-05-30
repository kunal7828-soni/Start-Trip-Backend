import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/services/location_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/database_repository.dart';

/// Dependency Injection provider for our custom Dio Client wrapper.
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Geolocation service provider injection.
final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

/// Authenticator controller repository provider.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// PostgreSQL query repository provider.
final databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  return DatabaseRepositoryImpl();
});

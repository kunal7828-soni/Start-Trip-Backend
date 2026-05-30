import 'package:dio/dio.dart';
import '../../config/env/env_config.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';

/// Configured HTTP client wrapper utilizing the Dio networking library.
/// Integrates dynamic headers, request mapping, and robust timeouts.
class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio() {
    _dio
      ..options.baseUrl = AppEnv.apiBaseUrl
      ..options.connectTimeout = const Duration(seconds: 15)
      ..options.receiveTimeout = const Duration(seconds: 15)
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
      ..interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (object) => AppLogger.d(object.toString()),
      ))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            // Placeholder: Retrieve current Firebase Auth ID Token or Supabase Access Token dynamically
            const String? activeToken = null; // Can be injected via AuthProvider
            if (activeToken != null) {
              options.headers['Authorization'] = 'Bearer $activeToken';
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) {
            AppLogger.e('DIO HTTP ERROR: ${e.message}', e, e.stackTrace);
            return handler.next(e);
          },
        ),
      );
  }

  Dio get instance => _dio;

  /// Helper GET implementation.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Helper POST implementation.
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Map DioExceptions onto standard custom exceptions.
  Exception _handleDioError(DioException error) {
    String errorMessage = 'A connection error occurred. Please try again.';
    int? statusCode = error.response?.statusCode;

    if (error.response != null && error.response?.data != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('message')) {
        errorMessage = data['message'].toString();
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Connection timed out. Please check your internet connection.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No internet connection detected.';
          break;
        default:
          errorMessage = 'Unexpected client error occurred.';
      }
    }

    return ServerException(message: errorMessage, statusCode: statusCode);
  }
}

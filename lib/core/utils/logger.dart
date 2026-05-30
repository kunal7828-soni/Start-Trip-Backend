import 'package:logger/logger.dart';
import '../../config/env/env_config.dart';

/// App-wide consolidated logging interface.
/// Prevents sensitive information leakage in production environments.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    filter: ProductionFilter(), // Custom filter can be configured
  );

  /// Log debug messages (only in development).
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppEnv.isDevelopment) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log informational messages.
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning messages.
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log critical errors.
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

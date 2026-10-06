import 'package:flutter/foundation.dart';

/// Production-safe application logger that suppresses sensitive output in release mode
class AppLogger {
  AppLogger._();

  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[DEBUG] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('Stack: $stackTrace');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }

  static void warning(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[WARNING] $message');
      if (error != null) debugPrint('Error: $error');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    // In production, send to crash reporting service like Sentry or Firebase Crashlytics
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('Error: $error');
    if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
  }
}

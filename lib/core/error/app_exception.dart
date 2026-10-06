/// Base class for application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network connection failure.',
    super.code = 'NETWORK_ERROR',
    super.details,
  });
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code = 'SERVER_ERROR',
    this.statusCode,
    super.details,
  });
}

class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed or session expired.',
    super.code = 'UNAUTHORIZED',
    super.details,
  });
}

class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.details,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.details,
  });
}

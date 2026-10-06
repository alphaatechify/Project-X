import 'package:equatable/equatable.dart';
import 'app_exception.dart';

/// Base class for Failure objects presented to UI layers
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];

  factory Failure.fromException(Object exception) {
    if (exception is AppException) {
      return ServerFailure(message: exception.message, code: exception.code);
    }
    return UnknownFailure(message: exception.toString());
  }
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection. Please check your network settings.'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication required. Please sign in.'});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred. Please try again.'});
}

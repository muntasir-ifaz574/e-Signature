import 'package:equatable/equatable.dart';

/// Abstract base class for all failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Failure when there's a server error
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred. Please try again later.',
    super.code,
  });
}

/// Failure when there's no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
  });
}

/// Failure when cache operation fails
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to load cached data.',
    super.code,
  });
}

/// Failure when authentication fails
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    super.message = 'Invalid credentials. Please try again.',
    super.code,
  });
}

/// Failure when user is not authorized
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'You are not authorized to perform this action.',
    super.code,
  });
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({
    super.message = 'Validation failed.',
    super.code,
    this.errors,
  });

  @override
  List<Object?> get props => [message, code, errors];
}

/// Failure when resource not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found.', super.code});
}

/// Failure when request times out
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timeout. Please try again.',
    super.code,
  });
}

/// Failure when parsing data fails
class ParsingFailure extends Failure {
  const ParsingFailure({super.message = 'Failed to process data.', super.code});
}

/// Generic failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
  });
}

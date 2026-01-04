/// Base exception class for all custom exceptions
class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when there's a server error
class ServerException extends AppException {
  ServerException({super.message = 'Server error occurred', super.code});
}

/// Exception thrown when there's a network/connection error
class NetworkException extends AppException {
  NetworkException({super.message = 'No internet connection', super.code});
}

/// Exception thrown when there's a cache error
class CacheException extends AppException {
  CacheException({super.message = 'Cache error occurred', super.code});
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  AuthenticationException({
    super.message = 'Authentication failed',
    super.code,
  });
}

/// Exception thrown when authorization fails
class UnauthorizedException extends AppException {
  UnauthorizedException({super.message = 'Unauthorized access', super.code});
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, String>? errors;

  ValidationException({
    super.message = 'Validation failed',
    super.code,
    this.errors,
  });
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  NotFoundException({super.message = 'Resource not found', super.code});
}

/// Exception thrown when request times out
class TimeoutException extends AppException {
  TimeoutException({super.message = 'Request timeout', super.code});
}

/// Exception thrown when there's a parsing error
class ParsingException extends AppException {
  ParsingException({super.message = 'Failed to parse data', super.code});
}

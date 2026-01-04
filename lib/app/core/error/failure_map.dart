import 'exceptions.dart';
import 'failures.dart';

/// Utility that converts any [AppException] into a corresponding [Failure].
class FailureMapper {
  static Failure mapExceptionToFailure(AppException exception) {
    if (exception is ServerException) {
      return ServerFailure(message: exception.message, code: exception.code);
    } else if (exception is NetworkException) {
      return NetworkFailure(message: exception.message, code: exception.code);
    } else if (exception is CacheException) {
      return CacheFailure(message: exception.message, code: exception.code);
    } else if (exception is AuthenticationException) {
      return AuthenticationFailure(message: exception.message, code: exception.code);
    } else if (exception is UnauthorizedException) {
      return UnauthorizedFailure(message: exception.message, code: exception.code);
    } else if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        code: exception.code,
        errors: exception.errors,
      );
    } else if (exception is NotFoundException) {
      return NotFoundFailure(message: exception.message, code: exception.code);
    } else if (exception is TimeoutException) {
      return TimeoutFailure(message: exception.message, code: exception.code);
    } else if (exception is ParsingException) {
      return ParsingFailure(message: exception.message, code: exception.code);
    } else {
      return UnexpectedFailure(
        message: exception.message,
        code: exception.code,
      );
    }
  }
}

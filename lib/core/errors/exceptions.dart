/// Base class for all API related exceptions
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => '$runtimeType: $message (status: $statusCode)';
}

/// Thrown when there is no internet connection
class NetworkException extends ApiException {
  NetworkException([super.message = 'No internet connection']);
}

/// Thrown when request times out
class TimeoutException extends ApiException {
  TimeoutException([super.message = 'Request timed out']);
}

/// Thrown for 400 errors (bad request)
class BadRequestException extends ApiException {
  BadRequestException(super.message, {super.data})
      : super(statusCode: 400);
}

/// Thrown for 401 errors (unauthorized)
class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message, {super.data})
      : super(statusCode: 401);
}

/// Thrown for 403 errors (forbidden)
class ForbiddenException extends ApiException {
  ForbiddenException(super.message, {super.data})
      : super(statusCode: 403);
}

/// Thrown for 404 errors (not found)
class NotFoundException extends ApiException {
  NotFoundException(super.message, {super.data})
      : super(statusCode: 404);
}

/// Thrown for 409 errors (conflict)
class ConflictException extends ApiException {
  ConflictException(super.message, {super.data})
      : super(statusCode: 409);
}

/// Thrown for 422 errors (validation failed)
class ValidationException extends ApiException {
  ValidationException(super.message, {super.data})
      : super(statusCode: 422);
}

/// Thrown for 500 errors (server error)
class ServerException extends ApiException {
  ServerException(super.message, {super.data})
      : super(statusCode: 500);
}

/// Thrown for any other unexpected error
class UnknownApiException extends ApiException {
  UnknownApiException(super.message, {super.data});
}
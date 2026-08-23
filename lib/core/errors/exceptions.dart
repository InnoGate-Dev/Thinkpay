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
  NetworkException([String message = 'No internet connection'])
      : super(message);
}

/// Thrown when request times out
class TimeoutException extends ApiException {
  TimeoutException([String message = 'Request timed out'])
      : super(message);
}

/// Thrown for 400 errors (bad request)
class BadRequestException extends ApiException {
  BadRequestException(String message, {dynamic data})
      : super(message, statusCode: 400, data: data);
}

/// Thrown for 401 errors (unauthorized)
class UnauthorizedException extends ApiException {
  UnauthorizedException(String message, {dynamic data})
      : super(message, statusCode: 401, data: data);
}

/// Thrown for 403 errors (forbidden)
class ForbiddenException extends ApiException {
  ForbiddenException(String message, {dynamic data})
      : super(message, statusCode: 403, data: data);
}

/// Thrown for 404 errors (not found)
class NotFoundException extends ApiException {
  NotFoundException(String message, {dynamic data})
      : super(message, statusCode: 404, data: data);
}

/// Thrown for 409 errors (conflict)
class ConflictException extends ApiException {
  ConflictException(String message, {dynamic data})
      : super(message, statusCode: 409, data: data);
}

/// Thrown for 422 errors (validation failed)
class ValidationException extends ApiException {
  ValidationException(String message, {dynamic data})
      : super(message, statusCode: 422, data: data);
}

/// Thrown for 500 errors (server error)
class ServerException extends ApiException {
  ServerException(String message, {dynamic data})
      : super(message, statusCode: 500, data: data);
}

/// Thrown for any other unexpected error
class UnknownApiException extends ApiException {
  UnknownApiException(String message, {dynamic data})
      : super(message, data: data);
}
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
<<<<<<< HEAD
  NetworkException([super.message = 'No internet connection']);
=======
  NetworkException([String message = 'No internet connection'])
      : super(message);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}

/// Thrown when request times out
class TimeoutException extends ApiException {
<<<<<<< HEAD
  TimeoutException([super.message = 'Request timed out']);
=======
  TimeoutException([String message = 'Request timed out'])
      : super(message);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}

/// Thrown for 400 errors (bad request)
class BadRequestException extends ApiException {
<<<<<<< HEAD
  BadRequestException(super.message, {super.data})
      : super(statusCode: 400);
=======
  BadRequestException(String message, {dynamic data})
      : super(message, statusCode: 400, data: data);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}

/// Thrown for 401 errors (unauthorized)
class UnauthorizedException extends ApiException {
<<<<<<< HEAD
  UnauthorizedException(super.message, {super.data})
      : super(statusCode: 401);
=======
  UnauthorizedException(String message, {dynamic data})
      : super(message, statusCode: 401, data: data);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}

/// Thrown for 403 errors (forbidden)
class ForbiddenException extends ApiException {
<<<<<<< HEAD
  ForbiddenException(super.message, {super.data})
      : super(statusCode: 403);
=======
  ForbiddenException(String message, {dynamic data})
      : super(message, statusCode: 403, data: data);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}

/// Thrown for 404 errors (not found)
class NotFoundException extends ApiException {
<<<<<<< HEAD
  NotFoundException(super.message, {super.data})
      : super(statusCode: 404);
=======
  NotFoundException(String message, {dynamic data})
      : super(message, statusCode: 404, data: data);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}

/// Thrown for 409 errors (conflict)
class ConflictException extends ApiException {
<<<<<<< HEAD
  ConflictException(super.message, {super.data})
      : super(statusCode: 409);
=======
  ConflictException(String message, {dynamic data})
      : super(message, statusCode: 409, data: data);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}

/// Thrown for 422 errors (validation failed)
class ValidationException extends ApiException {
<<<<<<< HEAD
  ValidationException(super.message, {super.data})
      : super(statusCode: 422);
=======
  ValidationException(String message, {dynamic data})
      : super(message, statusCode: 422, data: data);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}

/// Thrown for 500 errors (server error)
class ServerException extends ApiException {
<<<<<<< HEAD
  ServerException(super.message, {super.data})
      : super(statusCode: 500);
=======
  ServerException(String message, {dynamic data})
      : super(message, statusCode: 500, data: data);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}

/// Thrown for any other unexpected error
class UnknownApiException extends ApiException {
<<<<<<< HEAD
  UnknownApiException(super.message, {super.data});
=======
  UnknownApiException(String message, {dynamic data})
      : super(message, data: data);
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
}
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../errors/exceptions.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger();
  final TokenStorage _tokenStorage = TokenStorage();

  ApiClient({String baseUrl = ''}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i(
            'REQUEST[${options.method}] => PATH: ${options.uri}\n'
                'HEADERS: ${options.headers}\n'
                'BODY: ${options.data}',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.uri}\n'
                'DATA: ${response.data}',
          );
          handler.next(response);
        },
        onError: (DioException e, handler) {
          _logger.e(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.uri}\n'
                'MESSAGE: ${e.message}\n'
                'DATA: ${e.response?.data}',
          );
          handler.next(e);
        },
      ),
    );

    // Optional: Add token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Maps DioException to custom ApiException
  ApiException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final message = _extractErrorMessage(data);
        switch (statusCode) {
          case 400:
            return BadRequestException(message, data: data);
          case 401:
            return UnauthorizedException(message, data: data);
          case 403:
            return ForbiddenException(message, data: data);
          case 404:
            return NotFoundException(message, data: data);
          case 409:
            return ConflictException(message, data: data);
          case 422:
            return ValidationException(message, data: data);
          case 500:
          case 501:
          case 502:
          case 503:
            return ServerException(message, data: data);
          default:
            return UnknownApiException(
              'Unexpected error with status $statusCode',
              data: data,
            );
        }
      case DioExceptionType.cancel:
        return UnknownApiException('Request cancelled');
      default:
        return UnknownApiException(e.message ?? 'Unknown error');
    }
  }

  /// Extract error message from response body (assuming JSON with 'message' field)
  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data.containsKey('error')) {
        return data['error'].toString();
      }
    }
    return 'Something went wrong';
  }

  /// Generic GET request
  Future<dynamic> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownApiException(e.toString());
    }
  }

  /// Generic POST request
  Future<dynamic> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
<<<<<<< HEAD
      print("SENDING POST REQUEST");
=======
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
<<<<<<< HEAD
      print("POST RESPONSE => $response");
=======
>>>>>>> 7f6af26f56c35ce219fd0a1e9bebf8d9a6be70f7
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownApiException(e.toString());
    }
  }

  /// Generic PUT request
  Future<dynamic> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownApiException(e.toString());
    }
  }

  /// Generic DELETE request
  Future<dynamic> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownApiException(e.toString());
    }
  }

  /// Generic PATCH request
  Future<dynamic> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownApiException(e.toString());
    }
  }
}
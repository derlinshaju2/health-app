import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_exception.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) async {
        // Handle errors
        if (error.response != null) {
          final statusCode = error.response!.statusCode;

          // Handle token expiration
          if (statusCode == 401) {
            // Clear token and redirect to login
            await clearAuthToken();
            // You might want to navigate to login screen here
          }

          // Create API exception
          final apiException = ApiException.fromResponse(error.response!);
          return handler.reject(DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            error: apiException,
          ));
        }

        // Network error
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          return handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: ApiException('Connection timeout. Please check your internet connection.'),
          ));
        }

        return handler.next(error);
      },
    ));
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  // Set auth token
  Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Clear auth token
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
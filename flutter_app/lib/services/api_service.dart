import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

/// Centralized API service class for making HTTP requests
/// Handles authentication, errors, timeouts, and token management
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Dio get dio => _dio;

  // Private constructor
  ApiService._internal() {
    _dio = Dio();
    _setupDio();
  }

  /// Setup Dio instance with interceptors and configuration
  void _setupDio() {
    // Base options
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    );

    // Add interceptors
    _dio.interceptors.clear();
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }

  /// Initialize the service (call this in main() before runApp())
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadStoredToken();
  }

  /// Load stored JWT token from secure storage
  Future<void> _loadStoredToken() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Silent error handling
    }
  }

  /// Store JWT token in secure storage
  Future<void> _storeToken(String token) async {
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } catch (e) {
      rethrow;
    }
  }

  /// Clear stored token (for logout)
  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      _dio.options.headers.remove('Authorization');
    } catch (e) {
      // Silent error handling
    }
  }

  /// Authentication interceptor - adds token to requests
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 errors - token expired
        if (error.response?.statusCode == 401) {
          await clearToken();
        }

        return handler.next(error);
      },
    );
  }

  /// Logging interceptor - minimal logging for performance
  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    );
  }

  /// Error interceptor - handles errors centrally
  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // Handle different error types
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          // Timeout errors
          return handler.next(DioException(
            requestOptions: error.requestOptions,
            error: error.error,
            type: DioExceptionType.receiveTimeout,
            response: error.response,
          ));
        } else if (error.type == DioExceptionType.badResponse) {
          // HTTP error responses
          return handler.next(error);
        } else {
          // Other errors
          return handler.next(error);
        }
      },
    );
  }

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse<T>.fromJson(response.data);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// Handle errors and convert to ApiResponse
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      final dioError = error as DioException;

      if (dioError.type == DioExceptionType.connectionTimeout) {
        return ApiResponse<T>.error(
          'Connection timeout',
          'Please check your internet connection and try again.',
        );
      } else if (dioError.type == DioExceptionType.receiveTimeout) {
        return ApiResponse<T>.error(
          'Response timeout',
          'Server is taking too long to respond. Please try again.',
        );
      } else if (dioError.type == DioExceptionType.badResponse) {
        final response = dioError.response;
        final statusCode = response?.statusCode ?? 0;

        if (statusCode == 401) {
          return ApiResponse<T>.error(
            'Authentication failed',
            'Your session has expired. Please login again.',
          );
        } else if (statusCode == 404) {
          return ApiResponse<T>.error(
            'Not found',
            'The requested resource was not found.',
          );
        } else if (statusCode >= 500) {
          return ApiResponse<T>.error(
            'Server error',
            'The server is experiencing issues. Please try again later.',
          );
        } else if (statusCode >= 400) {
          // Client error
          final message = response?.data?['message'] ?? 'Bad request';
          return ApiResponse<T>.error(
            'Request failed',
            message,
          );
        } else {
          return ApiResponse<T>.error(
            'Request failed',
            'An unexpected error occurred. Please try again.',
          );
        }
      } else if (dioError.type == DioExceptionType.cancel) {
        return ApiResponse<T>.error(
          'Request cancelled',
          'The request was cancelled.',
        );
      } else {
        return ApiResponse<T>.error(
          'Network error',
          'A network error occurred. Please check your connection.',
        );
      }
    } else if (error is SocketException) {
      return ApiResponse<T>.error(
        'Network error',
        'Unable to reach the server. Please check your internet connection.',
      );
    } else {
      return ApiResponse<T>.error(
        'Unexpected error',
        'An unexpected error occurred. Please try again.',
      );
    }

    return ApiResponse<T>.error(
      'Unknown error',
      'An unknown error occurred. Please try again.',
    );
  }

  // ==================== AUTHENTICATION APIS ====================

  /// User registration
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final data = {
      'email': email,
      'password': password,
      'profile': {'name': name}
    };

    final response = await post<Map<String, dynamic>>(
      '${ApiConfig.auth}/register',
      data: data,
    );

    if (response.status == 'success' && response.data != null) {
      // Store token if present
      final data = response.data;
      if (data != null && data.containsKey('data')) {
        final token = data['data']?['token'];
        if (token != null) {
          await _storeToken(token);
        }
      }
    }

    return response;
  }

  /// User login
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final data = {
      'email': email,
      'password': password,
    };

    final response = await post<Map<String, dynamic>>(
      '${ApiConfig.auth}/login',
      data: data,
    );

    if (response.status == 'success' && response.data != null) {
      // Store token
      final data = response.data;
      if (data != null && data.containsKey('data')) {
        final token = data['data']?['token'];
        if (token != null) {
          await _storeToken(token);

          // Store user data
          final userData = data['data']?['user'];
          if (userData != null && _prefs != null) {
            await _prefs!.setString('user_data', userData.toString());
          }
        }
      }
    }

    return response;
  }

  /// User logout
  Future<void> logout() async {
    await clearToken();
    if (_prefs != null) {
      await _prefs!.clear();
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated =>
    _dio.options.headers.containsKey('Authorization');

  // ==================== HEALTH METRICS APIS ====================

  /// Add health metrics
  Future<ApiResponse<Map<String, dynamic>>> addHealthMetrics({
    Map<String, dynamic>? bloodPressure,
    int? bloodSugar,
    Map<String, dynamic>? cholesterol,
    String? notes,
  }) async {
    final data = {};

    if (bloodPressure != null) {
      data['bloodPressure'] = bloodPressure;
    }
    if (bloodSugar != null) {
      data['bloodSugar'] = bloodSugar;
    }
    if (cholesterol != null) {
      data['cholesterol'] = cholesterol;
    }
    if (notes != null) {
      data['notes'] = notes;
    }

    return post<Map<String, dynamic>>(
      '${ApiConfig.metrics}/add',
      data: data,
    );
  }

  /// Get health metrics history
  Future<ApiResponse<Map<String, dynamic>>> getHealthMetricsHistory({
    int limit = 50,
    int skip = 0,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, dynamic>{
      'limit': limit.toString(),
      'skip': skip.toString(),
    };

    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return get<Map<String, dynamic>>(
      '${ApiConfig.metrics}/history',
      queryParameters: params,
    );
  }

  /// Get latest health metrics
  Future<ApiResponse<Map<String, dynamic>>> getLatestHealthMetrics() async {
    return get<Map<String, dynamic>>(
      '${ApiConfig.metrics}/latest',
    );
  }

  /// Get health metrics analytics
  Future<ApiResponse<Map<String, dynamic>>> getHealthMetricsAnalytics({
    int days = 30,
  }) async {
    return get<Map<String, dynamic>>(
      '${ApiConfig.metrics}/analytics',
      queryParameters: {'days': days.toString()},
    );
  }

  // ==================== DISEASE PREDICTION APIS ====================

  /// Get disease risk prediction
  Future<ApiResponse<Map<String, dynamic>>> getDiseasePrediction({
    Map<String, dynamic>? bloodPressure,
    int? bloodSugar,
    double? bmi,
    Map<String, dynamic>? cholesterol,
  }) async {
    final data = <String, dynamic>{};

    if (bloodPressure != null) {
      data['bloodPressure'] = bloodPressure;
    }
    if (bloodSugar != null) {
      data['bloodSugar'] = bloodSugar;
    }
    if (bmi != null) {
      data['bmi'] = bmi;
    }
    if (cholesterol != null) {
      data['cholesterol'] = cholesterol;
    }

    return post<Map<String, dynamic>>(
      '${ApiConfig.predictions}',
      data: data,
    );
  }

  // ==================== DIET RECOMMENDATION APIS ====================

  /// Get diet recommendations
  Future<ApiResponse<Map<String, dynamic>>> getDietRecommendations({
    required double bmi,
    int age = 30,
    String gender = 'male',
    String goal = 'maintenance',
  }) async {
    return get<Map<String, dynamic>>(
      '${ApiConfig.diet}',
      queryParameters: {
        'bmi': bmi.toString(),
        'age': age.toString(),
        'gender': gender,
        'goal': goal,
      },
    );
  }

  /// Get meal plan
  Future<ApiResponse<Map<String, dynamic>>> getMealPlan({
    required double bmi,
    String gender = 'male',
    String goal = 'maintenance',
  }) async {
    return get<Map<String, dynamic>>(
      '${ApiConfig.diet}/meal-plan',
      queryParameters: {
        'bmi': bmi.toString(),
        'gender': gender,
        'goal': goal,
      },
    );
  }

  // ==================== YOGA RECOMMENDATION APIS ====================

  /// Get yoga recommendations
  Future<ApiResponse<Map<String, dynamic>>> getYogaRecommendations({
    String fitnessLevel = 'beginner',
    int age = 30,
    String goal = 'general',
  }) async {
    return get<Map<String, dynamic>>(
      '${ApiConfig.yoga}',
      queryParameters: {
        'fitnessLevel': fitnessLevel,
        'age': age.toString(),
        'goal': goal,
      },
    );
  }

  /// Get yoga routine
  Future<ApiResponse<Map<String, dynamic>>> getYogaRoutine({
    String fitnessLevel = 'beginner',
    String goal = 'general',
  }) async {
    return get<Map<String, dynamic>>(
      '${ApiConfig.yoga}/routine',
      queryParameters: {
        'fitnessLevel': fitnessLevel,
        'goal': goal,
      },
    );
  }

  // ==================== PROGRESS TRACKING APIS ====================

  /// Log daily progress
  Future<ApiResponse<Map<String, dynamic>>> logProgress({
    Map<String, dynamic>? diet,
    Map<String, dynamic>? yoga,
    Map<String, dynamic>? wellness,
  }) async {
    final data = <String, dynamic>{};

    if (diet != null) data['diet'] = diet;
    if (yoga != null) data['yoga'] = yoga;
    if (wellness != null) data['wellness'] = wellness;

    return post<Map<String, dynamic>>(
      ApiConfig.progress,
      data: data,
    );
  }

  /// Get progress history
  Future<ApiResponse<Map<String, dynamic>>> getProgressHistory({
    int limit = 30,
    String? startDate,
    String? endDate,
  }) async {
    final params = <String, dynamic>{
      'limit': limit.toString(),
    };

    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    return get<Map<String, dynamic>>(
      ApiConfig.progress,
      queryParameters: params,
    );
  }

  /// Get today's progress
  Future<ApiResponse<Map<String, dynamic>>> getTodayProgress() async {
    return get<Map<String, dynamic>>(
      '${ApiConfig.progress}/today',
    );
  }

  /// Get progress statistics
  Future<ApiResponse<Map<String, dynamic>>> getProgressStatistics({
    int days = 30,
  }) async {
    return get<Map<String, dynamic>>(
      '${ApiConfig.progress}/statistics',
      queryParameters: {'days': days.toString()},
    );
  }

  /// Get achievements
  Future<ApiResponse<Map<String, dynamic>>> getAchievements() async {
    return get<Map<String, dynamic>>(
      '${ApiConfig.progress}/achievements',
    );
  }
}
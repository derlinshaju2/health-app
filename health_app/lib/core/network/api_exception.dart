import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromResponse(Response response) {
    String message;
    final statusCode = response.statusCode;

    try {
      final data = response.data as Map<String, dynamic>;
      message = data['message'] ?? 'An error occurred';
    } catch (e) {
      message = 'An error occurred';
    }

    // Provide user-friendly messages based on status code
    switch (statusCode) {
      case 400:
        message = 'Invalid request. Please check your input.';
        break;
      case 401:
        message = 'Unauthorized. Please login again.';
        break;
      case 403:
        message = 'Access denied.';
        break;
      case 404:
        message = 'Resource not found.';
        break;
      case 500:
        message = 'Server error. Please try again later.';
        break;
      case 503:
        message = 'Service unavailable. Please try again later.';
        break;
      default:
        if (statusCode != null && statusCode >= 500) {
          message = 'Server error. Please try again later.';
        } else if (statusCode != null && statusCode >= 400) {
          message = 'Client error. Please check your request.';
        }
    }

    return ApiException(message, statusCode: statusCode);
  }

  @override
  String toString() => message;
}
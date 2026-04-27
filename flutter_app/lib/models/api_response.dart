/// Generic API Response wrapper
class ApiResponse<T> {
  final String status;
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.status,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      status: json['status'] ?? 'unknown',
      message: json['message'],
      data: json['data'] as T?,
      error: json['error'],
    );
  }

  factory ApiResponse.error(String title, String message) {
    return ApiResponse<T>(
      status: 'error',
      message: title,
      error: message,
    );
  }

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
      'error': error,
    };
  }
}

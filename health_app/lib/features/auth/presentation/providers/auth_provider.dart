import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  User? _user;
  String? _token;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  User? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  // Check authentication status
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiClient.getAuthToken();
      if (token != null) {
        _token = token;
        await _fetchUserProfile();
      } else {
        _user = null;
        _token = null;
      }
    } catch (e) {
      _user = null;
      _token = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        _token = data['token'];
        _user = User.fromJson(data['user']);

        // Save token
        await _apiClient.setAuthToken(_token!);

        _errorMessage = null;
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(
    String email,
    String password, {
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          if (name != null) 'profile': {'name': name}
        },
      );

      if (response.statusCode == 201) {
        final data = response.data['data'];
        _token = data['token'];
        _user = User.fromJson(data['user']);

        // Save token
        await _apiClient.setAuthToken(_token!);

        _errorMessage = null;
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      // Ignore logout error
    } finally {
      _user = null;
      _token = null;
      await _apiClient.clearAuthToken();
      notifyListeners();
    }
  }

  // Fetch user profile
  Future<void> _fetchUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.getProfile);
      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['data']['user']);
      }
    } catch (e) {
      // Handle error
      debugPrint('Error fetching user profile: $e');
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.put(
        ApiConstants.updateProfile,
        data: {'profile': profileData},
      );

      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['data']['user']);
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Profile update failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
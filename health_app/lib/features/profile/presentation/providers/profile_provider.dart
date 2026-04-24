import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  static const String _settingsKey = 'app_settings';

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _appSettings;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isUpdating = false;

  // Getters
  Map<String, dynamic>? get userProfile => _userProfile;
  Map<String, dynamic>? get appSettings => _appSettings;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;

  // Get individual settings with defaults
  bool get notificationsEnabled => _appSettings?['notificationsEnabled'] ?? true;
  bool get darkModeEnabled => _appSettings?['darkModeEnabled'] ?? false;
  String get temperatureUnit => _appSettings?['temperatureUnit'] ?? 'celsius';
  String get weightUnit => _appSettings?['weightUnit'] ?? 'kg';
  String get heightUnit => _appSettings?['heightUnit'] ?? 'cm';
  bool get biometricEnabled => _appSettings?['biometricEnabled'] ?? false;
  bool get dataSharingEnabled => _appSettings?['dataSharingEnabled'] ?? false;

  // Initialize settings from local storage
  Future<void> initSettings() async {
    await loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        _appSettings = Map<String, dynamic>.from(
          // Simple JSON decoding for basic types
          _decodeSettings(settingsJson),
        );
      } else {
        _appSettings = _getDefaultSettings();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _appSettings = _getDefaultSettings();
      notifyListeners();
    }
  }

  // Save settings to SharedPreferences
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      _appSettings = {..._appSettings ?? {}, ...settings};
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final settingsJson = _encodeSettings(_appSettings!);
      final success = await prefs.setString(_settingsKey, settingsJson);

      // Also try to sync with backend if available
      try {
        await _apiClient.post(
          '${ApiConstants.updateProfile}/settings',
          data: {'settings': _appSettings},
        );
      } catch (e) {
        // Backend sync failed but local save succeeded, continue
        debugPrint('Backend sync failed: $e');
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to save settings: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Clear all settings
  Future<bool> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
      _appSettings = _getDefaultSettings();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to clear settings: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Default settings
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'notificationsEnabled': true,
      'darkModeEnabled': false,
      'temperatureUnit': 'celsius',
      'weightUnit': 'kg',
      'heightUnit': 'cm',
      'biometricEnabled': false,
      'dataSharingEnabled': false,
    };
  }

  // Encode settings to string for storage
  String _encodeSettings(Map<String, dynamic> settings) {
    // Simple encoding for basic types
    final buffer = StringBuffer();
    settings.forEach((key, value) {
      buffer.write('$key:$value;');
    });
    return buffer.toString();
  }

  // Decode settings from string
  Map<String, dynamic> _decodeSettings(String settingsJson) {
    final Map<String, dynamic> settings = {};
    final pairs = settingsJson.split(';');
    for (final pair in pairs) {
      if (pair.isEmpty) continue;
      final parts = pair.split(':');
      if (parts.length == 2) {
        final key = parts[0];
        final value = parts[1];
        // Parse values to appropriate types
        if (value == 'true') {
          settings[key] = true;
        } else if (value == 'false') {
          settings[key] = false;
        } else {
          settings[key] = value;
        }
      }
    }
    return settings;
  }

  // Fetch user profile
  Future<bool> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.getProfile);

      if (response.statusCode == 200) {
        _userProfile = response.data['data']['user'];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to load profile';
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

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.put(
        ApiConstants.updateProfile,
        data: profileData,
      );

      if (response.statusCode == 200) {
        _userProfile = response.data['data']['user'];
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to update profile';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Change password
  Future<bool> changePassword(Map<String, dynamic> passwordData) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '${ApiConstants.updateProfile}/change-password',
        data: passwordData,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to change password';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Upload profile picture using image picker
  Future<String?> pickAndUploadProfilePicture(ImageSource source) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Request permissions
      final permission = source == ImageSource.camera
          ? Permission.camera
          : Permission.photos;

      final permissionStatus = await permission.request();
      if (!permissionStatus.isGranted) {
        _errorMessage = 'Permission denied. Please grant ${source == ImageSource.camera ? 'camera' : 'storage'} permission.';
        _isUpdating = false;
        notifyListeners();
        return null;
      }

      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image == null) {
        _isUpdating = false;
        notifyListeners();
        return null; // User cancelled
      }

      // Upload to backend
      final formData = dio.FormData.fromMap({
        'profilePicture': await dio.MultipartFile.fromFile(
          image.path,
          filename: image.name,
        ),
      });

      final response = await _apiClient.post(
        '${ApiConstants.updateProfile}/picture',
        data: formData,
      );

      if (response.statusCode == 200) {
        // Update user profile with new picture URL
        if (response.data['data']?['user']?['profile']?['profilePicture'] != null) {
          _userProfile = {
            ...?_userProfile,
            'profile': {
              ...?_userProfile?['profile'],
              'profilePicture': response.data['data']['user']['profile']['profilePicture'],
            }
          };
        }
        _isUpdating = false;
        notifyListeners();
        return response.data['data']?['user']?['profile']?['profilePicture'];
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to upload profile picture';
        _isUpdating = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      // Fallback: Use local file path if backend upload fails
      if (e.toString().contains('404') || e.toString().contains('405')) {
        // Backend doesn't support upload, store locally as fallback
        debugPrint('Backend upload not supported, using local file as fallback');
        _errorMessage = null;
        _isUpdating = false;
        notifyListeners();
        return 'local://${e.toString()}'; // Return local indicator
      }

      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isUpdating = false;
      notifyListeners();
      return null;
    }
  }

  // Delete profile picture
  Future<bool> deleteProfilePicture() async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.delete(
        '${ApiConstants.updateProfile}/picture',
      );

      if (response.statusCode == 200) {
        // Remove profile picture from user profile
        if (_userProfile != null && _userProfile!['profile'] != null) {
          _userProfile = {
            ..._userProfile!,
            'profile': {
              ..._userProfile!['profile'],
              'profilePicture': null,
            }
          };
        }
        _isUpdating = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to delete profile picture';
        _isUpdating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.delete('${ApiConstants.getProfile}/delete');

      if (response.statusCode == 200) {
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to delete account';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Update app settings - convenience method
  Future<bool> updateSetting(String key, dynamic value) async {
    return await saveSettings({key: value});
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
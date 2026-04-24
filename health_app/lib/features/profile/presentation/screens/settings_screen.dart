import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.initSettings();
    setState(() {}); // Refresh UI with loaded settings
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // General Settings
          _buildSectionHeader('General'),
          const SizedBox(height: 8),
          _buildDarkModeSetting(),
          _buildLanguageSetting(),
          _buildThemeSetting(),

          const SizedBox(height: 24),

          // Notification Settings
          _buildSectionHeader('Notifications'),
          const SizedBox(height: 8),
          _buildNotificationSetting(),
          _buildNotificationPreferences(),

          const SizedBox(height: 24),

          // Privacy Settings
          _buildSectionHeader('Privacy'),
          const SizedBox(height: 8),
          _buildLocationSetting(),
          _buildDataPrivacySetting(),
          _buildSecuritySetting(),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          const SizedBox(height: 8),
          _buildAppInfoSetting(),
          _buildTermsSetting(),
          _buildPrivacyPolicySetting(),

          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionHeader('Danger Zone'),
          const SizedBox(height: 8),
          _buildClearDataSetting(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDarkModeSetting() {
    final profileProvider = context.watch<ProfileProvider>();
    return _buildSettingCard(
      'Dark Mode',
      'Enable dark theme for the app',
      trailing: Switch(
        value: profileProvider.darkModeEnabled,
        onChanged: (value) async {
          final success = await profileProvider.updateSetting('darkModeEnabled', value);
          if (success && mounted) {
            setState(() {}); // Refresh UI
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dark mode setting saved'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return _buildSettingCard(
      'Language',
      _selectedLanguage,
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 'English', child: Text('English')),
          DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
          DropdownMenuItem(value: 'French', child: Text('French')),
          DropdownMenuItem(value: 'German', child: Text('German')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedLanguage = value!;
          });
          _showFeatureComingSoon('Language change');
        },
      ),
    );
  }

  Widget _buildThemeSetting() {
    return _buildSettingCard(
      'Theme',
      _selectedTheme,
      trailing: DropdownButton<String>(
        value: _selectedTheme,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: 'System', child: Text('System Default')),
          DropdownMenuItem(value: 'Light', child: Text('Light')),
          DropdownMenuItem(value: 'Dark', child: Text('Dark')),
        ],
        onChanged: (value) {
          setState(() {
            _selectedTheme = value!;
          });
          _showRestartMessage();
        },
      ),
    );
  }

  Widget _buildNotificationSetting() {
    final profileProvider = context.watch<ProfileProvider>();
    return _buildSettingCard(
      'Push Notifications',
      'Enable/disable push notifications',
      trailing: Switch(
        value: profileProvider.notificationsEnabled,
        onChanged: (value) async {
          final success = await profileProvider.updateSetting('notificationsEnabled', value);
          if (success && mounted) {
            setState(() {}); // Refresh UI
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value ? 'Notifications enabled' : 'Notifications disabled'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildNotificationPreferences() {
    return _buildSettingCard(
      'Notification Preferences',
      'Customize notification settings',
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        onPressed: () => _showFeatureComingSoon('Notification preferences'),
      ),
    );
  }

  Widget _buildLocationSetting() {
    return _buildSettingCard(
      'Location Services',
      'Allow app to access your location',
      trailing: Switch(
        value: _locationEnabled,
        onChanged: (value) {
          setState(() {
            _locationEnabled = value;
          });
        },
      ),
    );
  }

  Widget _buildDataPrivacySetting() {
    return _buildSettingCard(
      'Data Privacy',
      'Manage your data and privacy settings',
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        onPressed: () => _showFeatureComingSoon('Data privacy settings'),
      ),
    );
  }

  Widget _buildSecuritySetting() {
    return _buildSettingCard(
      'Security',
      'Password, authentication settings',
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        onPressed: () => _showFeatureComingSoon('Security settings'),
      ),
    );
  }

  Widget _buildAppInfoSetting() {
    return _buildSettingCard(
      'App Info',
      'Version 1.0.0',
      trailing: IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () => _showAppInfoDialog(),
      ),
    );
  }

  Widget _buildTermsSetting() {
    return _buildSettingCard(
      'Terms of Service',
      'Read our terms and conditions',
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        onPressed: () => _showFeatureComingSoon('Terms of Service'),
      ),
    );
  }

  Widget _buildPrivacyPolicySetting() {
    return _buildSettingCard(
      'Privacy Policy',
      'Read our privacy policy',
      trailing: IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        onPressed: () => _showFeatureComingSoon('Privacy Policy'),
      ),
    );
  }

  Widget _buildClearDataSetting() {
    return _buildSettingCard(
      'Clear App Data',
      'Clear all local app data',
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () => _showClearDataDialog(),
      ),
      isDestructive: true,
    );
  }

  Widget _buildSettingCard(
    String title,
    String subtitle, {
    required Widget trailing,
    bool isDestructive = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Monitor'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Build: 2024.04.22'),
            SizedBox(height: 16),
            Text(
              'AI-Driven Health Monitoring Application',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your personal health companion with AI-powered disease prediction and personalized wellness recommendations.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    final profileProvider = context.read<ProfileProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Data'),
        content: const Text(
          'This will clear all local app data including cached information and preferences. Your account and server data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await profileProvider.clearSettings();
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Local data cleared successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  setState(() {}); // Refresh UI
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(profileProvider.errorMessage ?? 'Failed to clear data'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _showRestartMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please restart the app for changes to take effect'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
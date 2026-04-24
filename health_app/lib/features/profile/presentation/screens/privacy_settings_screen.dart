import 'package:flutter/material.dart';
import '../../../../core/themes/colors.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _dataCollectionEnabled = true;
  bool _analyticsEnabled = true;
  bool _personalizedAds = false;
  bool _shareDataWithPartners = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Data Collection Section
          _buildSectionHeader('Data Collection'),
          const SizedBox(height: 8),
          _buildPrivacyCard(
            'Data Collection',
            'Allow us to collect anonymous usage data to improve the app',
            _dataCollectionEnabled,
            (value) => setState(() => _dataCollectionEnabled = value),
          ),
          _buildPrivacyCard(
            'Analytics',
            'Help us understand how you use the app',
            _analyticsEnabled,
            (value) => setState(() => _analyticsEnabled = value),
          ),

          const SizedBox(height: 24),

          // Personalization Section
          _buildSectionHeader('Personalization'),
          const SizedBox(height: 8),
          _buildPrivacyCard(
            'Personalized Ads',
            'Show ads based on your interests',
            _personalizedAds,
            (value) => setState(() => _personalizedAds = value),
          ),
          _buildPrivacyCard(
            'Share Data with Partners',
            'Share anonymous data with trusted partners',
            _shareDataWithPartners,
            (value) => setState(() => _shareDataWithPartners = value),
          ),

          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionHeader('Data Management'),
          const SizedBox(height: 8),
          _buildDataManagementCard(),

          const SizedBox(height: 24),

          // Privacy Policy Info
          _buildPrivacyPolicyInfo(),
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

  Widget _buildPrivacyCard(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDataManagementCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download My Data'),
            subtitle: Text('Get a copy of your data', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            onTap: () => _showFeatureComingSoon('Data download'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text('Request Data Deletion', style: TextStyle(color: Colors.red)),
            subtitle: Text('Permanently delete your account data', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            onTap: () => _showDataDeletionDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Your Privacy Matters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'We are committed to protecting your personal information and privacy. '
              'You can control what data you share with us and how it\'s used.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _showFeatureComingSoon('Full Privacy Policy'),
              child: const Text('Read Full Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDataDeletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Data Deletion'),
        content: const Text(
          'This will start the process to permanently delete your account and all associated data. '
          'This action cannot be undone. Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement data deletion request
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data deletion request submitted'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
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
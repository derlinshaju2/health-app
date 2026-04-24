import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/themes/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileProvider.userProfile == null
              ? _buildEmptyState()
              : _buildProfileContent(profileProvider, authProvider),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No profile data',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(ProfileProvider profileProvider, AuthProvider authProvider) {
    final user = profileProvider.userProfile!;
    final profile = user['profile'] ?? {};

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            _buildProfileHeader(user, profile, profileProvider),
            const SizedBox(height: 20),

            // Personal Information Card
            _buildPersonalInfoCard(profile),
            const SizedBox(height: 20),

            // Health Information Card
            _buildHealthInfoCard(profile),
            const SizedBox(height: 20),

            // Account Actions Card
            _buildAccountActionsCard(profileProvider, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> user, Map<String, dynamic> profile, ProfileProvider profileProvider) {
    final name = profile['name'] ?? 'User';
    final email = user['email'] ?? 'No email';
    final bmi = profile['bmi']?.toString() ?? 'N/A';
    final activityLevel = profile['activityLevel'] ?? 'Unknown';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () => _showImageSourceBottomSheet(profileProvider),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // User Name
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // User Email
            Text(
              email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat('BMI', bmi, Icons.monitor_weight),
                _buildQuickStat('Activity', activityLevel, Icons.directions_run),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard(Map<String, dynamic> profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _showEditProfileDialog(profile),
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', profile['name'] ?? 'Not set'),
            const SizedBox(height: 12),
            _buildInfoRow('Age', '${profile['age'] ?? 'Not set'} years'),
            const SizedBox(height: 12),
            _buildInfoRow('Gender', profile['gender'] ?? 'Not set'),
            const SizedBox(height: 12),
            _buildInfoRow('Height', '${profile['height'] ?? 'Not set'} cm'),
            const SizedBox(height: 12),
            _buildInfoRow('Weight', '${profile['weight'] ?? 'Not set'} kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInfoCard(Map<String, dynamic> profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('BMI', profile['bmi']?.toString() ?? 'Not set'),
            const SizedBox(height: 12),
            _buildInfoRow('Activity Level', profile['activityLevel'] ?? 'Not set'),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Medical Conditions',
              profile['medicalConditions']?.isNotEmpty ?? false
                  ? profile['medicalConditions'].join(', ')
                  : 'None reported',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Allergies',
              profile['allergies']?.isNotEmpty ?? false
                  ? profile['allergies'].join(', ')
                  : 'None reported',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActionsCard(ProfileProvider profileProvider, AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Change Password',
              Icons.lock,
              AppColors.primary,
              () => _showChangePasswordDialog(),
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Privacy Settings',
              Icons.privacy_tip,
              AppColors.secondary,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Help & Support',
              Icons.help,
              AppColors.accent,
              () {
                _showFeatureComingSoon('Help & Support');
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              'Logout',
              Icons.logout,
              Colors.red,
              () => _showLogoutDialog(authProvider),
              isDestructive: true,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Delete Account',
              Icons.delete_forever,
              Colors.red,
              () => _showDeleteAccountDialog(profileProvider, authProvider),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(isDestructive ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(isDestructive ? 0.3 : 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? Colors.red : color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(Map<String, dynamic> profile) {
    _showFeatureComingSoon('Profile editing');
  }

  void _showImageSourceBottomSheet(ProfileProvider profileProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await _uploadProfilePicture(
                    profileProvider,
                    ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.secondary),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  await _uploadProfilePicture(
                    profileProvider,
                    ImageSource.gallery,
                  );
                },
              ),
              if (profileProvider.userProfile?['profile']?['profilePicture'] != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _removeProfilePicture(profileProvider);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture(
    ProfileProvider profileProvider,
    ImageSource source,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading profile picture...'),
              ],
            ),
          ),
        ),
      ),
    );

    final imageUrl = await profileProvider.pickAndUploadProfilePicture(source);

    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (imageUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() {}); // Refresh UI
      } else if (profileProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeProfilePicture(ProfileProvider profileProvider) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Photo'),
        content: const Text('Are you sure you want to remove your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Removing profile picture...'),
                ],
              ),
            ),
          ),
        ),
      );

      final success = await profileProvider.deleteProfilePicture();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture removed successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          setState(() {}); // Refresh UI
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(profileProvider.errorMessage ?? 'Failed to remove profile picture'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showChangePasswordDialog() {
    _showFeatureComingSoon('Password change');
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(ProfileProvider profileProvider, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await profileProvider.deleteAccount();
              if (success && mounted) {
                await authProvider.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              } else if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(profileProvider.errorMessage ?? 'Failed to delete account'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
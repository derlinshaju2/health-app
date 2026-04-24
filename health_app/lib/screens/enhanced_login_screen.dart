import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/shadcn_theme.dart';
import '../../../core/components/shadcn_card.dart';
import '../../../core/components/shadcn_input.dart';
import '../../../core/components/shadcn_dialog.dart';
import '../../../core/components/shadcn_badge.dart';
import '../../auth/presentation/providers/auth_provider.dart';

/// Enhanced Login Screen with Shadcn-style Components
class EnhancedLoginScreen extends StatefulWidget {
  const EnhancedLoginScreen({super.key});

  @override
  State<EnhancedLoginScreen> createState() => _EnhancedLoginScreenState();
}

class _EnhancedLoginScreenState extends State<EnhancedLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (mounted) {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'Login failed';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShadcnTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and Header
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // Welcome Card
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),

                    // Error Alert
                    if (_errorMessage != null) _buildErrorAlert(),

                    // Email Input
                    ShadcnInput(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      errorText: _emailController.text.isEmpty && _errorMessage != null
                          ? 'Email is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    ShadcnInput(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: Icons.visibility_outlined,
                      errorText: _passwordController.text.isEmpty && _errorMessage != null
                          ? 'Password is required'
                          : null,
                    ),
                    const SizedBox(height: 8),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showForgotPasswordDialog(),
                        child: Text(
                          'Forgot password?',
                          style: ShadcnTheme.small.copyWith(
                            color: ShadcnTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    ShadcnButton(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                      variant: ShadcnButtonVariant.primary,
                      size: ShadcnButtonSize.large,
                      fullWidth: true,
                      isLoading: _isLoading,
                      icon: Icons.login,
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    const ShadcnSeparator(label: 'OR'),
                    const SizedBox(height: 16),

                    // Register Button
                    ShadcnButton(
                      text: 'Create Account',
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      variant: ShadcnButtonVariant.outline,
                      size: ShadcnButtonSize.large,
                      fullWidth: true,
                      icon: Icons.person_add,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: ShadcnTheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.health_and_safety,
            size: 40,
            color: ShadcnTheme.primary,
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Text(
          'Health Monitor',
          style: ShadcnTheme.h2.copyWith(
            color: ShadcnTheme.foregroundColor,
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'AI-Powered Health Monitoring',
          style: ShadcnTheme.body.copyWith(
            color: ShadcnTheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return ShadcnCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: ShadcnTheme.h4.copyWith(
                        color: ShadcnTheme.foregroundColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your credentials to access your health dashboard',
                      style: ShadcnTheme.small.copyWith(
                        color: ShadcnTheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              ShadcnBadge(
                label: 'v2.0',
                variant: ShadcnBadgeVariant.secondary,
                icon: Icons.new_releases,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorAlert() {
    return ShadcnAlert(
      title: 'Login Failed',
      description: _errorMessage,
      variant: ShadcnAlertVariant.destructive,
      icon: Icons.error_outline,
    );
  }

  void _showForgotPasswordDialog() {
    ShadcnDialog.show(
      context: context,
      title: 'Reset Password',
      description: 'Enter your email address and we\'ll send you a link to reset your password.',
      icon: Icons.lock_reset,
      content: ShadcnInput(
        hint: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
        prefixIcon: Icons.email_outlined,
      ),
      actions: [
        ShadcnButton(
          text: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
          variant: ShadcnButtonVariant.ghost,
        ),
        ShadcnButton(
          text: 'Send Link',
          onPressed: () {
            Navigator.of(context).pop();
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Password reset link sent!',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                backgroundColor: ShadcnTheme.healthExcellent,
              ),
            );
          },
          variant: ShadcnButtonVariant.primary,
        ),
      ],
    );
  }
}

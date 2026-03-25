import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class ChangePasswordScreenEnhanced extends StatefulWidget {
  const ChangePasswordScreenEnhanced({super.key});

  @override
  State<ChangePasswordScreenEnhanced> createState() =>
      _ChangePasswordScreenEnhancedState();
}

class _ChangePasswordScreenEnhancedState
    extends State<ChangePasswordScreenEnhanced> {
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackbar('Password changed successfully');
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          _showErrorSnackbar(
            authProvider.errorMessage ?? 'Failed to change password',
          );
        }
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Must contain lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Must contain a number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Change Password',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.bgDark, AppTheme.bgCard],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.bgLight, Color(0xFFE8E8F0)],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Animated background sphere
                Align(
                  alignment: Alignment.bottomRight,
                  child: Transform.translate(
                    offset: const Offset(80, 120),
                    child:
                        Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.accentOrange.withValues(
                                      alpha: 0.2,
                                    ),
                                    AppTheme.accentPink.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .scale(
                              duration: 4000.ms,
                              begin: const Offset(1, 1),
                              end: const Offset(1.15, 1.15),
                            )
                            .then()
                            .scale(
                              duration: 4000.ms,
                              begin: const Offset(1.15, 1.15),
                              end: const Offset(1, 1),
                            ),
                  ),
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 24),
                Text(
                  'Update Your Password',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.textPrimaryLight,
                  ),
                ).animate().slideX(begin: -1.0, end: 0.0, duration: 600.ms),
                const SizedBox(height: 8),
                Text(
                  'Enter your current password and choose a new one',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondaryLight,
                  ),
                ).animate().slideX(
                  begin: -1.0,
                  end: 0.0,
                  duration: 700.ms,
                  delay: 100.ms,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Current password
                      Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return TextFormField(
                                controller: _currentPasswordController,
                                obscureText: !authProvider.isPasswordVisible,
                                decoration: _buildInputDecoration(
                                  'Current password',
                                  Icons.lock_outlined,
                                  isDark,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      authProvider.isPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppTheme.accentPurple,
                                    ),
                                    onPressed:
                                        authProvider.togglePasswordVisibility,
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Current password is required';
                                  }
                                  return null;
                                },
                              );
                            },
                          )
                          .animate()
                          .slideX(
                            begin: -1.0,
                            end: 0.0,
                            duration: 600.ms,
                            delay: 150.ms,
                          )
                          .fadeIn(duration: 600.ms),
                      const SizedBox(height: 20),
                      // New password
                      Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return TextFormField(
                                controller: _newPasswordController,
                                obscureText: !authProvider.isPasswordVisible,
                                decoration: _buildInputDecoration(
                                  'New password',
                                  Icons.lock_outlined,
                                  isDark,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      authProvider.isPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppTheme.accentPurple,
                                    ),
                                    onPressed:
                                        authProvider.togglePasswordVisibility,
                                  ),
                                ),
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'New password is required';
                                  }
                                  return _validatePassword(value ?? '');
                                },
                                onChanged: (value) {
                                  setState(() {});
                                },
                              );
                            },
                          )
                          .animate()
                          .slideX(
                            begin: -1.0,
                            end: 0.0,
                            duration: 600.ms,
                            delay: 250.ms,
                          )
                          .fadeIn(duration: 600.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Password must contain uppercase, lowercase, and number',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppTheme.textSecondary
                              : AppTheme.textSecondaryLight,
                        ),
                      ).animate().fadeIn(duration: 600.ms, delay: 250.ms),
                      const SizedBox(height: 20),
                      // Confirm new password
                      TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: _buildInputDecoration(
                              'Confirm new password',
                              Icons.lock_outlined,
                              isDark,
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please confirm your new password';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          )
                          .animate()
                          .slideX(
                            begin: -1.0,
                            end: 0.0,
                            duration: 600.ms,
                            delay: 350.ms,
                          )
                          .fadeIn(duration: 600.ms),
                      const SizedBox(height: 32),
                      // Info box
                      Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.accentBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.accentBlue.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outlined,
                                  color: AppTheme.accentBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'You\'ll need to sign in again after changing your password',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppTheme.accentBlue),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .slideX(
                            begin: -1.0,
                            end: 0.0,
                            duration: 600.ms,
                            delay: 450.ms,
                          )
                          .fadeIn(duration: 600.ms),
                      const SizedBox(height: 32),
                      // Update button
                      Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleChangePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentPurple,
                                    disabledBackgroundColor: Colors.grey[400],
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppTheme.textPrimary,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'Update Password',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                ),
                              );
                            },
                          )
                          .animate()
                          .slideY(duration: 600.ms, delay: 500.ms)
                          .fadeIn(duration: 600.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hintText,
    IconData prefixIcon,
    bool isDark, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: isDark ? AppTheme.textMuted : AppTheme.textSecondaryLight,
      ),
      prefixIcon: Icon(prefixIcon, color: AppTheme.accentPurple),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? AppTheme.bgCardLight : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.accentPurple, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? AppTheme.accentPurple.withValues(alpha: 0.3)
              : AppTheme.accentPurple.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.accentPurple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

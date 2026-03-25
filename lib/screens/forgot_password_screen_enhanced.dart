import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen_enhanced.dart';

class ForgotPasswordScreenEnhanced extends StatefulWidget {
  const ForgotPasswordScreenEnhanced({super.key});

  @override
  State<ForgotPasswordScreenEnhanced> createState() =>
      _ForgotPasswordScreenEnhancedState();
}

class _ForgotPasswordScreenEnhancedState
    extends State<ForgotPasswordScreenEnhanced> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.resetPassword(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        if (success) {
          setState(() {
            _emailSent = true;
          });
        } else {
          _showErrorSnackbar(
            authProvider.errorMessage ?? 'Failed to send reset email',
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (_emailSent) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreenEnhanced(),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
            ),
            onPressed: () {
              if (_emailSent) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreenEnhanced(),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
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
            child: _emailSent
                ? _buildSuccessView(isDark)
                : _buildResetView(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildResetView(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Animated background sphere
          Align(
            alignment: Alignment.topRight,
            child: Transform.translate(
              offset: const Offset(60, -40),
              child:
                  Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentCyan.withValues(alpha: 0.3),
                              AppTheme.accentBlue.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
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
            'Reset Password',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
            ),
          ).animate().slideX(begin: -1.0, end: 0.0, duration: 600.ms),
          const SizedBox(height: 8),
          Text(
            'Enter your email address and we\'ll send you a link to reset your password',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
          const SizedBox(height: 40),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration(
                        'Email address',
                        Icons.email_outlined,
                        isDark,
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Email is required';
                        }
                        if (!value!.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    )
                    .animate()
                    .slideX(
                      begin: -1.0,
                      end: 0.0,
                      duration: 600.ms,
                      delay: 200.ms,
                    )
                    .fadeIn(duration: 600.ms),
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : _handleResetPassword,
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.textPrimary,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Send Reset Email',
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
                    .slideY(
                      begin: 1.0,
                      end: 0.0,
                      duration: 600.ms,
                      delay: 300.ms,
                    )
                    .fadeIn(duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated success icon
            Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentGreen.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle_outlined,
                      size: 60,
                      color: AppTheme.accentGreen,
                    ),
                  ),
                )
                .animate()
                .scale(
                  duration: 600.ms,
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                )
                .then()
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
            Text(
              'Check Your Email',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppTheme.textPrimary
                    : AppTheme.textPrimaryLight,
              ),
            ).animate().slideX(
              begin: -1.0,
              end: 0.0,
              duration: 600.ms,
              delay: 200.ms,
            ),
            const SizedBox(height: 16),
            Text(
              'We\'ve sent a password reset link to:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondaryLight,
              ),
            ).animate().slideX(
              begin: -1.0,
              end: 0.0,
              duration: 600.ms,
              delay: 300.ms,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _emailController.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.accentPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().slideX(
              begin: -1.0,
              end: 0.0,
              duration: 600.ms,
              delay: 400.ms,
            ),
            const SizedBox(height: 24),
            Text(
              'Click the link in the email to reset your password. The link will expire in 1 hour.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondaryLight,
              ),
            ).animate().slideX(
              begin: -1.0,
              end: 0.0,
              duration: 600.ms,
              delay: 500.ms,
            ),
            const SizedBox(height: 40),
            SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreenEnhanced(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentPurple,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Back to Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                )
                .animate()
                .slideY(begin: 1.0, end: 0.0, duration: 600.ms, delay: 600.ms)
                .fadeIn(duration: 600.ms),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hintText,
    IconData prefixIcon,
    bool isDark,
  ) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: isDark ? AppTheme.textMuted : AppTheme.textSecondaryLight,
      ),
      prefixIcon: Icon(prefixIcon, color: AppTheme.accentPurple),
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

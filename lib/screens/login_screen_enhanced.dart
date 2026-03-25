import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'forgot_password_screen.dart';
import 'register_screen_enhanced.dart';

class LoginScreenEnhanced extends StatefulWidget {
  const LoginScreenEnhanced({super.key});

  @override
  State<LoginScreenEnhanced> createState() => _LoginScreenEnhancedState();
}

class _LoginScreenEnhancedState extends State<LoginScreenEnhanced> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted && !success) {
        _showErrorSnackbar(authProvider.errorMessage ?? 'Login failed');
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
    return Scaffold(
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
                const SizedBox(height: 20),
                // Animated background sphere
                Align(
                  alignment: Alignment.topRight,
                  child:
                      Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.accentPurple.withValues(alpha: 0.3),
                                  AppTheme.accentBlue.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            duration: 4000.ms,
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                          )
                          .then()
                          .scale(
                            duration: 4000.ms,
                            begin: const Offset(1.1, 1.1),
                            end: const Offset(1, 1),
                          ),
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 32),
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.textPrimaryLight,
                  ),
                ).animate().slideX(begin: -1.0, end: 0.0, duration: 600.ms),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account',
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
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email field
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
                      const SizedBox(height: 16),
                      // Password field
                      Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return TextFormField(
                                controller: _passwordController,
                                obscureText: !authProvider.isPasswordVisible,
                                decoration: _buildInputDecoration(
                                  'Password',
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
                                    return 'Password is required';
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
                            delay: 300.ms,
                          )
                          .fadeIn(duration: 600.ms),
                      const SizedBox(height: 12),
                      // Remember me & Forgot password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: AppTheme.accentPurple,
                              ),
                              Text(
                                'Remember me',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(color: AppTheme.accentPurple),
                            ),
                          ),
                        ],
                      ).animate().slideX(
                        begin: -1.0,
                        end: 0.0,
                        duration: 600.ms,
                        delay: 400.ms,
                      ),
                      const SizedBox(height: 24),
                      // Login button
                      Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleLogin,
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
                                          'Sign In',
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
                            delay: 400.ms,
                          )
                          .fadeIn(duration: 600.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Sign up link
                Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegisterScreenEnhanced(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentPurple,
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .slideY(
                      begin: 1.0,
                      end: 0.0,
                      duration: 600.ms,
                      delay: 500.ms,
                    )
                    .fadeIn(duration: 600.ms),
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

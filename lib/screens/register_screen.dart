import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreedToTerms) {
        _showErrorSnackbar('Please agree to Terms & Conditions');
        return;
      }

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        username: _usernameController.text.trim(),
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackbar('Account created successfully!');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        } else {
          _showErrorSnackbar(
            authProvider.errorMessage ?? 'Registration failed',
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
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
                const SizedBox(height: 24),
                // Animated background sphere
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Transform.translate(
                    offset: const Offset(-50, 100),
                    child:
                        Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.accentBlue.withValues(alpha: 0.3),
                                    AppTheme.accentCyan.withValues(alpha: 0.1),
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
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.textPrimaryLight,
                  ),
                ).animate().slideX(begin: -1.0, end: 0.0, duration: 600.ms),
                const SizedBox(height: 8),
                Text(
                  'Join us today and start your journey',
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
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Username field
                      TextFormField(
                            controller: _usernameController,
                            decoration: _buildInputDecoration(
                              'Username',
                              Icons.person_outlined,
                              isDark,
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Username is required';
                              }
                              if (value!.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              if (value.length > 30) {
                                return 'Username must not exceed 30 characters';
                              }
                              return null;
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
                      const SizedBox(height: 16),
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
                            delay: 250.ms,
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
                                      color: AppTheme.accentGreen,
                                    ),
                                    onPressed:
                                        authProvider.togglePasswordVisibility,
                                  ),
                                ),
                                validator: _validatePassword,
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
                            delay: 350.ms,
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
                      ).animate().fadeIn(duration: 600.ms, delay: 350.ms),
                      const SizedBox(height: 16),
                      // Confirm Password field
                      TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: _buildInputDecoration(
                              'Confirm password',
                              Icons.lock_outlined,
                              isDark,
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please confirm password';
                              }
                              if (value != _passwordController.text) {
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
                            delay: 400.ms,
                          )
                          .fadeIn(duration: 600.ms),
                      const SizedBox(height: 20),
                      // Terms & Conditions
                      Row(
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreedToTerms = value ?? false;
                              });
                            },
                            activeColor: AppTheme.accentGreen,
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'I agree to '),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppTheme.accentGreen,
                                          decoration: TextDecoration.underline,
                                        ),
                                  ),
                                ],
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ).animate().slideX(
                        begin: -1.0,
                        end: 0.0,
                        duration: 600.ms,
                        delay: 500.ms,
                      ),
                      const SizedBox(height: 24),
                      // Register button
                      Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.accentGreen,
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
                                          'Create Account',
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
                            delay: 500.ms,
                          )
                          .fadeIn(duration: 600.ms),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Sign in link
                Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentGreen,
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
                      delay: 600.ms,
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
      prefixIcon: Icon(prefixIcon, color: AppTheme.accentGreen),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDark ? AppTheme.bgCardLight : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.accentGreen, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark
              ? AppTheme.accentGreen.withValues(alpha: 0.3)
              : AppTheme.accentGreen.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.accentGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

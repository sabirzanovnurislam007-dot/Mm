import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'change_password_screen_enhanced.dart';
import 'login_screen_enhanced.dart';

class AccountSettingsScreenEnhanced extends StatefulWidget {
  const AccountSettingsScreenEnhanced({super.key});

  @override
  State<AccountSettingsScreenEnhanced> createState() =>
      _AccountSettingsScreenEnhancedState();
}

class _AccountSettingsScreenEnhancedState
    extends State<AccountSettingsScreenEnhanced> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _newEmailController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _newEmailController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.read<AuthProvider>();
    _usernameController.text = authProvider.userProfile?.username ?? '';
    _emailController.text = authProvider.userProfile?.email ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _newEmailController.dispose();
    super.dispose();
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

  void _showEditUsernameDialog() {
    final tempController = TextEditingController(
      text: _usernameController.text,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.bgCard
            : Colors.white,
        title: const Text('Edit Username'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: tempController,
              decoration: InputDecoration(
                hintText: 'New username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Username required';
                }
                if (value!.length < 3) {
                  return 'At least 3 characters';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
            ),
            onPressed: () async {
              if (tempController.text.isNotEmpty &&
                  tempController.text.length >= 3) {
                Navigator.pop(context);
                final authProvider = context.read<AuthProvider>();
                final success = await authProvider.updateUsername(
                  newUsername: tempController.text.trim(),
                );
                if (mounted) {
                  if (success) {
                    _usernameController.text = tempController.text;
                    _showSuccessSnackbar('Username updated successfully');
                  } else {
                    _showErrorSnackbar(
                      authProvider.errorMessage ?? 'Failed to update username',
                    );
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog() {
    final tempController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.bgCard
            : Colors.white,
        title: const Text('Change Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: tempController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'New email address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
            ),
            onPressed: () async {
              if (tempController.text.contains('@')) {
                Navigator.pop(context);
                final authProvider = context.read<AuthProvider>();
                final success = await authProvider.changeEmail(
                  newEmail: tempController.text.trim(),
                );
                if (mounted) {
                  if (success) {
                    _emailController.text = tempController.text;
                    _showSuccessSnackbar('Email updated successfully');
                  } else {
                    _showErrorSnackbar(
                      authProvider.errorMessage ?? 'Failed to update email',
                    );
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.bgCard
            : Colors.white,
        title: const Text(
          'Delete Account',
          style: TextStyle(color: AppTheme.accentRed),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              final success = await authProvider.deleteAccount();
              if (mounted) {
                if (success) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreenEnhanced(),
                    ),
                  );
                } else {
                  _showErrorSnackbar(
                    authProvider.errorMessage ?? 'Failed to delete account',
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.bgCard
            : Colors.white,
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreenEnhanced(),
                  ),
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Account Settings',
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
                // Profile Section
                Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final initials =
                            (authProvider.userProfile?.username ?? 'U')
                                .substring(0, 1)
                                .toUpperCase();
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentGreen.withValues(alpha: 0.2),
                                AppTheme.accentBlue.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.accentGreen.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.accentGreen,
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authProvider.userProfile?.username ??
                                          'User',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? AppTheme.textPrimary
                                                : AppTheme.textPrimaryLight,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      authProvider.userProfile?.email ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: isDark
                                                ? AppTheme.textSecondary
                                                : AppTheme.textSecondaryLight,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                    .animate()
                    .slideY(duration: 600.ms, delay: 100.ms)
                    .fadeIn(duration: 600.ms),
                const SizedBox(height: 32),
                // Account Information Section
                Text(
                  'Account Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.textPrimaryLight,
                  ),
                ).animate().slideY(duration: 600.ms, delay: 150.ms),
                const SizedBox(height: 16),
                _buildAccountTile(
                  'Username',
                  _usernameController.text,
                  Icons.person_outlined,
                  () => _showEditUsernameDialog(),
                  isDark,
                  delay: 200,
                ),
                const SizedBox(height: 12),
                _buildAccountTile(
                  'Email',
                  _emailController.text,
                  Icons.email_outlined,
                  () => _showEditEmailDialog(),
                  isDark,
                  delay: 250,
                ),
                const SizedBox(height: 32),
                // Security Section
                Text(
                  'Security',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.textPrimaryLight,
                  ),
                ).animate().slideY(duration: 600.ms, delay: 300.ms),
                const SizedBox(height: 16),
                _buildSecurityTile(
                  'Change Password',
                  'Update your password',
                  Icons.lock_outlined,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ChangePasswordScreenEnhanced(),
                      ),
                    );
                  },
                  isDark,
                  delay: 350,
                ),
                const SizedBox(height: 32),
                // Actions Section
                Text(
                  'Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.textPrimaryLight,
                  ),
                ).animate().slideY(duration: 600.ms, delay: 400.ms),
                const SizedBox(height: 16),
                _buildActionTile(
                  'Sign Out',
                  'End your current session',
                  Icons.logout_outlined,
                  () => _showSignOutDialog(),
                  AppTheme.accentGreen,
                  isDark,
                  delay: 450,
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  'Delete Account',
                  'Permanently delete your account',
                  Icons.delete_outline,
                  () => _showDeleteAccountDialog(),
                  AppTheme.accentRed,
                  isDark,
                  isDestructive: true,
                  delay: 500,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile(
    String title,
    String value,
    IconData icon,
    VoidCallback onEdit,
    bool isDark, {
    required int delay,
  }) {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.bgCardLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentGreen.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.accentGreen, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppTheme.textPrimary
                            : AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.accentGreen,
                ),
                onPressed: onEdit,
              ),
            ],
          ),
        )
        .animate()
        .slideY(
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
        )
        .fadeIn(duration: 600.ms);
  }

  Widget _buildSecurityTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    required int delay,
  }) {
    return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.bgCardLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentBlue.withValues(alpha: 0.2),
            ),
          ),
          child: ListTile(
            leading: Icon(icon, color: AppTheme.accentBlue),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: onTap,
          ),
        )
        .animate()
        .slideY(
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
        )
        .fadeIn(duration: 600.ms);
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    Color color,
    bool isDark, {
    bool isDestructive = false,
    required int delay,
  }) {
    Color borderColor = isDestructive
        ? AppTheme.accentRed
        : AppTheme.accentGreen;
    return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.bgCardLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            leading: Icon(icon, color: color),
            title: Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(subtitle),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
            onTap: onTap,
          ),
        )
        .animate()
        .slideY(
          duration: 600.ms,
          delay: Duration(milliseconds: delay),
        )
        .fadeIn(duration: 600.ms);
  }
}

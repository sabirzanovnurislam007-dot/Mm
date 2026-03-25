import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';
import 'account_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  static const _nameKey = 'profile_name';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString(_nameKey) ?? '';
    });
  }

  Future<void> _saveName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _nameController.text.trim());
    if (mounted) {
      final lang = context.read<LocaleProvider>().locale.languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('save', lang)),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final lang = localeProvider.locale.languageCode;
    final currentLevel = habitProvider.userProfile.currentLevel;

    final cardColor = isDark ? AppTheme.bgCard : Colors.white;
    final sectionTextColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        title: Text(AppStrings.get('settings', lang)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── ACCOUNT ──────────────────────────────────────────────
          _SectionHeader(
            title: AppStrings.get('account', lang),
            color: sectionTextColor,
          ),
          _Card(
            isDark: isDark,
            cardColor: cardColor,
            child: Column(
              children: [
                // Avatar
                const SizedBox(height: 8),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppTheme.accentPurple.withValues(
                    alpha: 0.15,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.accentPurple,
                  ),
                ),
                const SizedBox(height: 16),
                // Name field
                TextField(
                  controller: _nameController,
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.textPrimaryLight,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    labelText: AppStrings.get('profile_name', lang),
                    hintText: AppStrings.get('profile_name_hint', lang),
                    labelStyle: TextStyle(color: AppTheme.accentPurple),
                    filled: true,
                    fillColor: isDark
                        ? AppTheme.bgCardLight
                        : AppTheme.bgCardLightAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppTheme.accentPurple,
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppTheme.accentPurple,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveName,
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(AppStrings.get('save', lang)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── FIREBASE ACCOUNT MANAGEMENT ──────────────────────────
          _SectionHeader(title: 'Account Security', color: sectionTextColor),
          _Card(
            isDark: isDark,
            cardColor: cardColor,
            child: _SettingsTile(
              icon: Icons.security,
              iconColor: AppTheme.accentBlue,
              title: 'Manage Account',
              subtitle: 'Password, email, and more',
              isDark: isDark,
              trailing: const Icon(
                Icons.chevron_right,
                color: AppTheme.accentBlue,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountSettingsScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── APPEARANCE ──────────────────────────────────────────
          _SectionHeader(
            title: AppStrings.get('appearance', lang),
            color: sectionTextColor,
          ),
          _Card(
            isDark: isDark,
            cardColor: cardColor,
            child: _SettingsTile(
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              iconColor: isDark ? AppTheme.accentBlue : AppTheme.accentOrange,
              title: AppStrings.get('dark_mode', lang),
              subtitle: AppStrings.get('dark_mode_sub', lang),
              isDark: isDark,
              trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                activeThumbColor: AppTheme.accentPurple,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── BACKGROUND THEMES (UNLOCKABLE) ────────────────────────
          _SectionHeader(
            title: lang == 'en' ? 'Background Themes' : 'Темы оформления',
            color: sectionTextColor,
          ),
          _Card(
            isDark: isDark,
            cardColor: cardColor,
            child: Column(
              children: [
                _ThemeOption(
                  id: 'solid',
                  name: lang == 'en' ? 'Default' : 'Базовая',
                  minLvl: 1,
                  currentLevel: currentLevel,
                  isDark: isDark,
                  c1: AppTheme.bgDark,
                  c2: AppTheme.bgLight,
                ),
                _ThemeOption(
                  id: 'midnight',
                  name: 'Midnight Blue',
                  minLvl: 5,
                  currentLevel: currentLevel,
                  isDark: isDark,
                  c1: const Color(0xFF0F172A),
                  c2: const Color(0xFF1E1B4B),
                ),
                _ThemeOption(
                  id: 'cyberpunk',
                  name: 'Cyberpunk',
                  minLvl: 10,
                  currentLevel: currentLevel,
                  isDark: isDark,
                  c1: const Color(0xFF2A0845),
                  c2: const Color(0xFF6441A5),
                ),
                _ThemeOption(
                  id: 'sunset',
                  name: 'Red Sunset',
                  minLvl: 15,
                  currentLevel: currentLevel,
                  isDark: isDark,
                  c1: const Color(0xFF581C87),
                  c2: const Color(0xFF9F1239),
                ),
                _ThemeOption(
                  id: 'forest',
                  name: 'Deep Forest',
                  minLvl: 20,
                  currentLevel: currentLevel,
                  isDark: isDark,
                  c1: const Color(0xFF064E3B),
                  c2: const Color(0xFF0F172A),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── LANGUAGE ─────────────────────────────────────────────
          _SectionHeader(
            title: AppStrings.get('language', lang),
            color: sectionTextColor,
          ),
          _Card(
            isDark: isDark,
            cardColor: cardColor,
            child: Column(
              children: LocaleProvider.supportedLocales.map((locale) {
                final isSelected = localeProvider.locale == locale;
                return _LanguageTile(
                  locale: locale,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => localeProvider.setLocale(locale),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ── ABOUT ─────────────────────────────────────────────────
          _SectionHeader(
            title: AppStrings.get('about', lang),
            color: sectionTextColor,
          ),
          _Card(
            isDark: isDark,
            cardColor: cardColor,
            child: _SettingsTile(
              icon: Icons.info_outline,
              iconColor: AppTheme.accentCyan,
              title: AppStrings.get('about', lang),
              subtitle: '${AppStrings.get("version", lang)}: 1.0.0',
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: color,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Widget child;
  const _Card({
    required this.isDark,
    required this.cardColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isDark,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final Locale locale;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.locale,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final flag = _flag(locale.languageCode);
    final name = LocaleProvider.localeName(locale.languageCode);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: locale.languageCode != 'ky'
                ? BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.accentPurple
                      : (isDark
                            ? AppTheme.textPrimary
                            : AppTheme.textPrimaryLight),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.accentPurple,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _flag(String code) {
    switch (code) {
      case 'ru':
        return '🇷🇺';
      case 'en':
        return '🇬🇧';
      case 'ky':
        return '🇰🇬';
      default:
        return '🌐';
    }
  }
}

class _ThemeOption extends StatelessWidget {
  final String id;
  final String name;
  final int minLvl;
  final int currentLevel;
  final bool isDark;
  final Color c1;
  final Color c2;

  const _ThemeOption({
    required this.id,
    required this.name,
    required this.minLvl,
    required this.currentLevel,
    required this.isDark,
    required this.c1,
    required this.c2,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isSelected = themeProvider.bgTheme == id;
    final isLocked = currentLevel < minLvl;
    final lang = context.watch<LocaleProvider>().locale.languageCode;

    return GestureDetector(
      onTap: isLocked ? null : () => themeProvider.setBgTheme(id),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [c1, c2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.accentPurple
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: isLocked
                  ? const Icon(Icons.lock, size: 18, color: Colors.white70)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isLocked
                          ? AppTheme.textMuted
                          : (isSelected
                                ? AppTheme.accentPurple
                                : (isDark
                                      ? AppTheme.textPrimary
                                      : AppTheme.textPrimaryLight)),
                    ),
                  ),
                  if (isLocked)
                    Text(
                      lang == 'en'
                          ? 'Unlocks at Level $minLvl'
                          : 'Откроется на $minLvl уровне',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.accentPurple,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

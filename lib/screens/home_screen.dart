import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/progress_ring.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Show 7 days starting from Mon of this week
  List<DateTime> _getWeekDays() {
    final now = DateTime.now();
    // Start from 3 days ago to show current week context
    return List.generate(7, (i) => now.subtract(Duration(days: 3 - i)));
  }

  String _greeting(String lang) {
    final hour = DateTime.now().hour;
    if (lang == 'en') {
      if (hour < 12) return 'Good morning';
      if (hour < 18) return 'Good afternoon';
      return 'Good evening';
    } else if (lang == 'ky') {
      if (hour < 12) return 'Куттуктайм';
      if (hour < 18) return 'Саламатсызбы';
      return 'Кечки саламат';
    } else {
      if (hour < 12) return 'Доброе утро';
      if (hour < 18) return 'Добрый день';
      return 'Добрый вечер';
    }
  }

  String _dayLabel(DateTime d, String lang) {
    const ru = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    const en = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    const ky = ['Дш', 'Шш', 'Шр', 'Бш', 'Жм', 'Иш', 'Жк'];
    final list = lang == 'en' ? en : lang == 'ky' ? ky : ru;
    return list[d.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C2A) : Colors.white;
    final weekDays = _getWeekDays();
    final lang = context.watch<LocaleProvider>().locale.languageCode;

    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final allHabits = provider.habits;
        final longestStreak = provider.longestStreak;
        // Find habit with longest streak for the ring label
        Habit? topHabit;
        for (final h in allHabits) {
          if (topHabit == null || h.currentStreak > topHabit.currentStreak) {
            topHabit = h;
          }
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ===== HEADER =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting(lang)},',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.get('home', lang),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Theme toggle
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, _) {
                                return GestureDetector(
                                  onTap: () => themeProvider.toggleTheme(),
                                  child: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cardColor,
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.06),
                                      ),
                                    ),
                                    child: Icon(
                                      isDark ? Icons.light_mode : Icons.dark_mode,
                                      color: isDark ? AppTheme.accentOrange : AppTheme.accentBlue,
                                      size: 18,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 10),
                            // Avatar — tap to open Settings
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.accentGreen, Color(0xFF059669)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentGreen.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.person, color: Colors.white, size: 24),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== XP / LEVEL STRIP =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: AppTheme.accentGreen, size: 13),
                              const SizedBox(width: 5),
                              Text(
                                'LVL ${provider.userProfile.currentLevel}  •  ${provider.userProfile.xp} XP',
                                style: const TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: provider.userProfile.levelProgress,
                              minHeight: 5,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06),
                              valueColor: const AlwaysStoppedAnimation(AppTheme.accentGreen),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== WEEKLY CALENDAR =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Дни повтора',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
                                child: Icon(Icons.calendar_today_outlined,
                                    size: 18,
                                    color: isDark ? AppTheme.textMuted : AppTheme.textMutedLight),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: weekDays.map((day) {
                              final isToday = day.day == DateTime.now().day &&
                                  day.month == DateTime.now().month;
                              final isSelected = day.day == _selectedDay.day &&
                                  day.month == _selectedDay.month;

                              return GestureDetector(
                                onTap: () => setState(() => _selectedDay = day),
                                child: Column(
                                  children: [
                                    Text(
                                      _dayLabel(day, lang),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isToday
                                            ? AppTheme.accentGreen
                                            : (isDark ? AppTheme.textMuted : AppTheme.textMutedLight),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 36, height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppTheme.accentGreen
                                            : (isDark
                                                ? Colors.white.withValues(alpha: 0.05)
                                                : Colors.black.withValues(alpha: 0.04)),
                                        border: isToday && !isSelected
                                            ? Border.all(color: AppTheme.accentGreen, width: 1.5)
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark ? Colors.white : AppTheme.textPrimaryLight),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.05),
                ),

                // ===== TAB BAR =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        onTap: (_) => setState(() {}),
                        labelColor: Colors.white,
                        unselectedLabelColor: isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        indicator: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.95) : Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        tabs: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              lang == 'en' ? 'Statistics' : lang == 'ky' ? 'Статистика' : 'Статистика',
                              style: TextStyle(
                                color: _tabController.index == 0
                                    ? (isDark ? AppTheme.bgDark : Colors.white)
                                    : (isDark ? AppTheme.textMuted : AppTheme.textMutedLight),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              lang == 'en' ? 'Habits' : lang == 'ky' ? 'Адаттар' : 'Привычки',
                              style: TextStyle(
                                color: _tabController.index == 1
                                    ? (isDark ? AppTheme.bgDark : Colors.white)
                                    : (isDark ? AppTheme.textMuted : AppTheme.textMutedLight),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ===== TAB CONTENT =====
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      if (_tabController.index == 0) {
                        // STATS TAB - Show STREAK RING (matches mockup)
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Лучшая серия',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                                          ),
                                        ),
                                        if (topHabit != null)
                                          Text(
                                            topHabit.name,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_horiz, color: AppTheme.textMuted),
                                      color: isDark ? AppTheme.bgCard : Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      onSelected: (value) {
                                        if (value == 'stats') {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
                                        } else if (value == 'share') {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(lang == 'en' ? 'Coming soon!' : 'Скоро появится!')),
                                          );
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'stats',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.bar_chart, size: 20),
                                              const SizedBox(width: 12),
                                              Text(lang == 'en' ? 'Full Stats' : lang == 'ky' ? 'Толук статистика' : 'Полная статистика', style: const TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'share',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.share, size: 20),
                                              const SizedBox(width: 12),
                                              Text(lang == 'en' ? 'Share Progress' : lang == 'ky' ? 'Бөлүшүү' : 'Поделиться', style: const TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                Center(
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: longestStreak > 0 ? (longestStreak / (longestStreak + 30)).clamp(0.1, 0.95) : 0.0),
                                    duration: const Duration(milliseconds: 1200),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, _) {
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Outer glow
                                          Container(
                                            width: 220,
                                            height: 220,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.accentGreen.withValues(alpha: 0.15),
                                                  blurRadius: 60,
                                                  spreadRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                          ProgressRing(
                                            progress: value,
                                            size: 210,
                                            strokeWidth: 18,
                                            color: AppTheme.accentGreen,
                                            backgroundColor: isDark
                                                ? Colors.white.withValues(alpha: 0.06)
                                                : Colors.black.withValues(alpha: 0.06),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '$longestStreak',
                                                  style: TextStyle(
                                                    fontSize: 52,
                                                    fontWeight: FontWeight.w800,
                                                    color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                                                    height: 1.0,
                                                  ),
                                                ),
                                                Text(
                                                  AppStrings.get('days', lang),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: AppTheme.textMuted,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 28),
                                // Stats row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _StatItem(
                                      value: '${provider.todayCompleted.length}/${provider.todayHabits.length}',
                                      label: AppStrings.get('today', lang),
                                      color: AppTheme.accentGreen,
                                      isDark: isDark,
                                    ),
                                    _StatItem(
                                      value: '${(provider.todayProgress * 100).toInt()}%',
                                      label: AppStrings.get('progress', lang),
                                      color: AppTheme.accentCyan,
                                      isDark: isDark,
                                    ),
                                    _StatItem(
                                      value: '${provider.habits.length}',
                                      label: AppStrings.get('total', lang),
                                      color: AppTheme.accentBlue,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),
                        );
                      } else {
                        // HABITS TAB
                        final habits = provider.todayHabits;
                        if (habits.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 60, height: 60,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppTheme.primaryGradient,
                                    ),
                                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Добавьте первую привычку',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Нажмите + внизу',
                                    style: TextStyle(color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                       lang == 'en' ? 'Habits' : lang == 'ky' ? 'Адаттар' : 'Привычки',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                                    ),
                                  ),
                                  Icon(Icons.more_horiz, color: AppTheme.textMuted),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...habits.asMap().entries.map((entry) {
                                final index = entry.key;
                                final habit = entry.value;
                                return _HabitRow(
                                  habit: habit,
                                  isDark: isDark,
                                  cardColor: cardColor,
                                  onTap: () => _handleHabitTap(context, habit, lang),
                                  onDelete: () => context.read<HabitProvider>().deleteHabit(habit.id),
                                ).animate().fadeIn(delay: (60 * index).ms).slideY(begin: 0.08);
                              }),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleHabitTap(BuildContext context, Habit habit, String lang) async {
    if (habit.isCompletedToday) {
      // Uncomplete
      context.read<HabitProvider>().toggleToday(habit.id);
      return;
    }

    // Honest Mode: Check Photo
    if (habit.requiresPhoto) {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo == null) return; // User cancelled, don't complete
    }

    if (!mounted) return;

    // Min/Max Goals
    if (habit.minDurationMinutes != null && habit.targetDurationMinutes != null) {
      final int? xpReward = await showDialog<int>(
        context: context,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppTheme.bgCard : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(lang == 'en' ? 'How did you do?' : 'Как прошло?'),
            content: Text(lang == 'en'
                ? 'Did you hit the target or just the minimum effort?'
                : 'Сделал минимум или достиг цели?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, 5),
                child: Text(
                  lang == 'en' ? 'Min (${habit.minDurationMinutes}m) -> +5 XP' : 'Минимум (${habit.minDurationMinutes}м) -> +5 XP',
                  style: const TextStyle(color: AppTheme.accentOrange),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx, 15),
                child: Text(lang == 'en' ? 'Target (${habit.targetDurationMinutes}m) -> +15 XP' : 'Цель (${habit.targetDurationMinutes}м) -> +15 XP'),
              ),
            ],
          );
        },
      );
      if (xpReward == null) return; // Cancelled
      
      if (!mounted) return;
      context.read<HabitProvider>().toggleToday(habit.id, xpReward: xpReward);
      return;
    }

    // Normal completion
    context.read<HabitProvider>().toggleToday(habit.id);
  }
}

// ===== HABIT ROW WIDGET =====
class _HabitRow extends StatelessWidget {
  final Habit habit;
  final bool isDark;
  final Color cardColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HabitRow({
    required this.habit,
    required this.isDark,
    required this.cardColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.bgCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppTheme.accentRed),
                  title: const Text('Удалить привычку'),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: habit.color.withValues(alpha: isDark ? 0.15 : 0.12),
              ),
              child: Icon(habit.category.icon, color: habit.color, size: 20),
            ),
            const SizedBox(width: 14),
            // Name & streak
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                        ),
                      ),
                      if (habit.isHardMode)
                        const Icon(Icons.bolt, size: 16, color: AppTheme.accentRed),
                      if (habit.requiresPhoto)
                        const Icon(Icons.camera_alt_outlined, size: 14, color: AppTheme.accentBlue),
                      if (habit.minDurationMinutes != null)
                        const Icon(Icons.timer_outlined, size: 14, color: AppTheme.accentGreen),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 13,
                          color: habit.currentStreak > 0 ? AppTheme.accentGreen : AppTheme.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        '${habit.currentStreak} дней',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppTheme.accentGreen : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? AppTheme.accentGreen : (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.15)),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ===== STAT ITEM =====
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

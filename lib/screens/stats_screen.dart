import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Статистика'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppTheme.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<HabitProvider>(
        builder: (context, provider, _) {
          final habits = provider.habits;
          final completed = provider.todayCompleted.length;
          final total = provider.todayHabits.length;
          final archived = provider.archivedHabits;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // Summary cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle_outline,
                            iconColor: AppTheme.accentGreen,
                            value: '$completed / $total',
                            subtitle: 'сегодня',
                            isDark: isDark,
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department,
                            iconColor: AppTheme.accentOrange,
                            value: '${provider.longestStreak}',
                            subtitle: 'дн. подряд',
                            isDark: isDark,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.trending_up,
                            iconColor: AppTheme.accentCyan,
                            value: '${habits.length}',
                            subtitle: 'активных',
                            isDark: isDark,
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.percent,
                            iconColor: AppTheme.accentBlue,
                            value: '${(provider.todayProgress * 100).toInt()}%',
                            subtitle: 'за сегодня',
                            isDark: isDark,
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                    Text('По привычкам',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            if (habits.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'Добавьте привычки,\nчтобы увидеть статистику',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                    ),
                  ),
                ),
              ),

            // Habit stats list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final habit = habits[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.bgCard.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: habit.color.withValues(alpha: 0.2),
                                ),
                                child: Icon(habit.category.icon, color: habit.color, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habit.name,
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          'Создана ${DateFormat('d MMM', 'ru').format(habit.createdAt)}',
                                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                        ),
                                        if (habit.hasDeadline) ...[
                                          const SizedBox(width: 8),
                                          Icon(Icons.schedule, size: 12, color: AppTheme.textMuted),
                                          const SizedBox(width: 2),
                                          Text(
                                            habit.deadlineFormatted,
                                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                          ),
                                        ],
                                      ],
                                    ),
                                    // Weekly rate bar
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: habit.weeklyRate,
                                        minHeight: 4,
                                        backgroundColor: isDark
                                            ? Colors.white.withValues(alpha: 0.06)
                                            : Colors.black.withValues(alpha: 0.06),
                                        valueColor: AlwaysStoppedAnimation(habit.color),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.local_fire_department, size: 14,
                                          color: habit.currentStreak > 0 ? AppTheme.accentOrange : AppTheme.textMuted),
                                      const SizedBox(width: 3),
                                      Text('${habit.currentStreak}',
                                          style: TextStyle(
                                            color: habit.currentStreak > 0 ? AppTheme.accentOrange : AppTheme.textMuted,
                                            fontWeight: FontWeight.w700, fontSize: 16,
                                          )),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text('${habit.totalCompletions} всего',
                                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                  Text('${(habit.weeklyRate * 100).toInt()}% нед.',
                                      style: TextStyle(color: habit.color, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.05);
                },
                childCount: habits.length,
              ),
            ),

            // =============== GOALS ===============
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Активные цели',
                        style: Theme.of(context).textTheme.titleLarge),
                    if (provider.activeGoals.isEmpty)
                      const Icon(Icons.stars, color: AppTheme.accentOrange, size: 24),
                  ],
                ),
              ),
            ),
            
            if (provider.activeGoals.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.bgCardLight : AppTheme.bgCardLightAlt,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.rocket_launch, color: AppTheme.accentOrange, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Нет активных целей', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              SizedBox(height: 4),
                              Text('Создайте цель, чтобы заработать бонусные XP', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
            if (provider.activeGoals.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final goal = provider.activeGoals[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentOrange.withValues(alpha: 0.1),
                              AppTheme.accentRed.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${goal.currentDays}/${goal.targetDays} дней', style: const TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppTheme.accentOrange, borderRadius: BorderRadius.circular(8)),
                                  child: const Text('ЦЕЛЬ', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(goal.title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(goal.description, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: goal.progress,
                                minHeight: 8,
                                backgroundColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
                                valueColor: const AlwaysStoppedAnimation(AppTheme.accentOrange),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  context.read<HabitProvider>().updateGoalProgress(goal.id, 1);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Прогресс цели обновлен!'), backgroundColor: AppTheme.accentOrange),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.accentOrange),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text('Отметить 1 день', style: TextStyle(color: AppTheme.accentOrange, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: provider.activeGoals.length,
                ),
              ),

            // Archived section
            if (archived.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.archive_outlined, size: 18, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      Text('Архив (${archived.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textMuted)),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final habit = archived[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(habit.category.icon, color: AppTheme.textMuted, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(habit.name,
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                            ),
                            GestureDetector(
                              onTap: () => context.read<HabitProvider>().unarchiveHabit(habit.id),
                              child: const Icon(Icons.unarchive_outlined, size: 18, color: AppTheme.accentGreen),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: archived.length,
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String subtitle;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.bgCard.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(height: 14),
              Text(value,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  )),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onArchive;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onDelete,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = habit.deadlineStatus;
    final isUrgent = status == 'urgent';
    final isFailed = status == 'failed';
    final isApproaching = status == 'approaching';

    // Цвета фона в зависимости от состояния
    Color cardBorderColor;
    List<Color> cardGradientColors;

    if (isCompleted) {
      cardBorderColor = habit.color.withValues(alpha: 0.4);
      cardGradientColors = [
        habit.color.withValues(alpha: 0.25),
        habit.color.withValues(alpha: 0.1),
      ];
    } else if (isUrgent) {
      cardBorderColor = AppTheme.accentRed.withValues(alpha: 0.6);
      cardGradientColors = [
        AppTheme.accentRed.withValues(alpha: 0.2),
        AppTheme.accentOrange.withValues(alpha: 0.1),
      ];
    } else if (isFailed) {
      cardBorderColor = AppTheme.accentRed.withValues(alpha: 0.3);
      cardGradientColors = [
        Colors.red.withValues(alpha: 0.1),
        Colors.red.withValues(alpha: 0.05),
      ];
    } else if (isApproaching) {
      cardBorderColor = AppTheme.accentOrange.withValues(alpha: 0.4);
      cardGradientColors = [
        AppTheme.accentOrange.withValues(alpha: 0.12),
        AppTheme.accentOrange.withValues(alpha: 0.05),
      ];
    } else {
      cardBorderColor = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06);
      cardGradientColors = isDark
          ? [
              AppTheme.bgCard.withValues(alpha: 0.7),
              AppTheme.bgCardLight.withValues(alpha: 0.5),
            ]
          : [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.7),
            ];
    }

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onArchive,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: cardGradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: cardBorderColor, width: 1.5),
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: habit.color.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : isUrgent
                    ? [
                        BoxShadow(
                          color: AppTheme.accentRed.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isCompleted
                                ? LinearGradient(
                                    colors: [habit.color, habit.color.withValues(alpha: 0.7)])
                                : isUrgent
                                    ? AppTheme.urgentGradient
                                    : null,
                            color: isCompleted || isUrgent
                                ? null
                                : isDark
                                    ? AppTheme.bgCardLight
                                    : AppTheme.bgCardLightAlt,
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check
                                : isUrgent
                                    ? Icons.warning_amber
                                    : habit.category.icon,
                            color: isCompleted || isUrgent
                                ? Colors.white
                                : habit.color.withValues(alpha: 0.8),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Name & info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.name,
                                style: TextStyle(
                                  color: isCompleted
                                      ? (isDark ? Colors.white : AppTheme.textPrimaryLight)
                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  decorationColor: isDark
                                      ? Colors.white.withValues(alpha: 0.4)
                                      : Colors.black.withValues(alpha: 0.3),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  // Streak
                                  Icon(
                                    Icons.local_fire_department,
                                    size: 14,
                                    color: habit.currentStreak > 0
                                        ? AppTheme.accentOrange
                                        : AppTheme.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${habit.currentStreak} дн.',
                                    style: TextStyle(
                                      color: habit.currentStreak > 0
                                          ? AppTheme.accentOrange
                                          : AppTheme.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // Priority indicator
                                  if (habit.priority == HabitPriority.high ||
                                      habit.priority == HabitPriority.critical) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      habit.priority.icon,
                                      size: 14,
                                      color: habit.priority == HabitPriority.critical
                                          ? AppTheme.accentRed
                                          : AppTheme.accentOrange,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Deadline + check
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Deadline badge
                            if (habit.hasDeadline && !isCompleted)
                              _DeadlineBadge(habit: habit),
                            if (habit.hasDeadline && !isCompleted)
                              const SizedBox(height: 6),
                            // Check circle
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isCompleted
                                    ? LinearGradient(
                                        colors: [habit.color, AppTheme.accentCyan])
                                    : null,
                                border: isCompleted
                                    ? null
                                    : Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.15)
                                            : Colors.black.withValues(alpha: 0.12),
                                        width: 2,
                                      ),
                              ),
                              child: isCompleted
                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    )
        .animate(target: isCompleted ? 1 : 0)
        .scale(begin: const Offset(1, 1), end: const Offset(0.98, 0.98), duration: 150.ms)
        .then()
        .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1), duration: 150.ms);
  }
}

class _DeadlineBadge extends StatelessWidget {
  final Habit habit;
  const _DeadlineBadge({required this.habit});

  @override
  Widget build(BuildContext context) {
    final status = habit.deadlineStatus;
    final remaining = habit.timeRemaining;

    Color bgColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'urgent':
        bgColor = AppTheme.accentRed.withValues(alpha: 0.2);
        textColor = AppTheme.accentRed;
        icon = Icons.alarm;
        if (remaining != null && remaining.inMinutes > 0) {
          text = '${remaining.inMinutes} мин!';
        } else {
          text = 'Срочно!';
        }
      case 'failed':
        bgColor = Colors.red.withValues(alpha: 0.15);
        textColor = Colors.red;
        icon = Icons.close;
        text = 'Просрочено';
      case 'approaching':
        bgColor = AppTheme.accentOrange.withValues(alpha: 0.15);
        textColor = AppTheme.accentOrange;
        icon = Icons.schedule;
        if (remaining != null) {
          text = '${remaining.inMinutes} мин.';
        } else {
          text = 'Скоро';
        }
      default:
        bgColor = AppTheme.accentBlue.withValues(alpha: 0.1);
        textColor = AppTheme.accentBlue;
        icon = Icons.schedule;
        text = habit.deadlineFormatted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

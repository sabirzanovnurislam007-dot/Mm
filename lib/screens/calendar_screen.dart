
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final PageController _pageController = PageController(initialPage: 1200);
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  static const _weekDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  static const _months = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) {
    final base = DateTime(DateTime.now().year, DateTime.now().month);
    return DateTime(base.year, base.month + (page - 1200));
  }

  List<DateTime?> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);

    // Weekday offset (Mon=1, so pad (weekday-1) nulls)
    final startPadding = first.weekday - 1;
    final days = <DateTime?>[];
    for (int i = 0; i < startPadding; i++) {
      days.add(null);
    }
    for (int d = 1; d <= last.day; d++) {
      days.add(DateTime(month.year, month.month, d));
    }
    // pad to full rows
    while (days.length % 7 != 0) {
      days.add(null);
    }
    return days;
  }

  bool _isToday(DateTime? d) {
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isSelected(DateTime? d) {
    if (d == null) return false;
    return d.year == _selectedDate.year &&
        d.month == _selectedDate.month &&
        d.day == _selectedDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.bgDark : AppTheme.bgLight;
    final cardColor = isDark ? const Color(0xFF1C1C2A) : Colors.white;

    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        // Get completed dates from all habits
        final allCompletedDates = <DateTime>{};
        for (final h in provider.habits) {
          for (final d in h.completedDates) {
            allCompletedDates.add(DateTime(d.year, d.month, d.day));
          }
        }

        final selectedHabits = provider.habits.where((h) {
          return h.completedDates.any((d) =>
              d.year == _selectedDate.year &&
              d.month == _selectedDate.month &&
              d.day == _selectedDate.day);
        }).toList();

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Календарь',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.1),
                      // Month label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                          style: const TextStyle(
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Day of week header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _weekDays.map((d) {
                      return SizedBox(
                        width: 40,
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Infinite Calendar
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      HapticFeedback.selectionClick();
                      setState(() => _focusedMonth = _monthForPage(page));
                    },
                    itemBuilder: (context, page) {
                      final month = _monthForPage(page);
                      final days = _daysInMonth(month);
                      return _buildMonthGrid(days, allCompletedDates, isDark, cardColor);
                    },
                  ),
                ),

                const SizedBox(height: 4),

                // Divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                ),

                const SizedBox(height: 16),

                // Selected date label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _selectedDate.day == DateTime.now().day &&
                            _selectedDate.month == DateTime.now().month
                        ? 'Сегодня'
                        : '${_selectedDate.day} ${_months[_selectedDate.month - 1]}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Habits completed that day
                Expanded(
                  child: selectedHabits.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_available_outlined,
                                  size: 48,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.1)),
                              const SizedBox(height: 12),
                              const Text(
                                'Нет выполненных привычек',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                          itemCount: selectedHabits.length,
                          itemBuilder: (context, i) {
                            final habit = selectedHabits[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: cardColor,
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
                                    width: 38, height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: habit.color.withValues(alpha: 0.15),
                                    ),
                                    child: Icon(habit.category.icon, color: habit.color, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      habit.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 22),
                                ],
                              ),
                            ).animate().fadeIn(delay: (50 * i).ms).slideY(begin: 0.1);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthGrid(
    List<DateTime?> days,
    Set<DateTime> completedDates,
    bool isDark,
    Color cardColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final day = days[i];
          if (day == null) return const SizedBox();

          final today = _isToday(day);
          final selected = _isSelected(day);
          final hasActivity = completedDates.contains(DateTime(day.year, day.month, day.day));

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _selectedDate = day);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? AppTheme.accentGreen
                    : today
                        ? AppTheme.accentGreen.withValues(alpha: 0.15)
                        : Colors.transparent,
                border: today && !selected
                    ? Border.all(color: AppTheme.accentGreen, width: 1.5)
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected || today ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : today
                              ? AppTheme.accentGreen
                              : (isDark ? Colors.white : AppTheme.textPrimaryLight),
                    ),
                  ),
                  if (hasActivity && !selected)
                    Positioned(
                      bottom: 5,
                      child: Container(
                        width: 5, height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

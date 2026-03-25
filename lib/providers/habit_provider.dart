import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../models/habit_goal.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class HabitProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();
  List<Habit> _habits = [];
  List<HabitGoal> _goals = [];
  UserProfile _userProfile = UserProfile();
  bool _isLoading = true;

  List<Habit> get habits => _habits.where((h) => !h.isArchived).toList();
  List<Habit> get archivedHabits => _habits.where((h) => h.isArchived).toList();
  List<HabitGoal> get activeGoals => _goals.where((g) => !g.isCompleted).toList();
  List<HabitGoal> get completedGoals => _goals.where((g) => g.isCompleted).toList();
  UserProfile get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  /// Только привычки, запланированные на сегодня
  List<Habit> get todayHabits =>
      habits.where((h) => h.isScheduledToday).toList();

  List<Habit> get todayCompleted =>
      todayHabits.where((h) => h.isCompletedToday).toList();

  double get todayProgress {
    final today = todayHabits;
    if (today.isEmpty) return 0;
    return todayCompleted.length / today.length;
  }

  int get longestStreak {
    if (habits.isEmpty) return 0;
    return habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b);
  }

  /// Привычки с приближающимся или просроченным дедлайном
  List<Habit> get urgentHabits =>
      todayHabits.where((h) {
        final s = h.deadlineStatus;
        return s == 'approaching' || s == 'urgent';
      }).toList();

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();
    _habits = await _storage.loadHabits();
    _goals = await _storage.loadGoals();
    _userProfile = await _storage.loadProfile();
    _isLoading = false;
    _scheduleAllNotifications();
    notifyListeners();
  }

  Future<void> addHabit({
    required String name,
    required HabitCategory category,
    required Color color,
    int? deadlineHour,
    int? deadlineMinute,
    int urgentMinutes = 30,
    HabitPriority priority = HabitPriority.medium,
    String? note,
    List<int>? repeatDays,
    int? minDurationMinutes,
    int? targetDurationMinutes,
    bool isHardMode = false,
    bool requiresPhoto = false,
  }) async {
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      color: color,
      deadlineHour: deadlineHour,
      deadlineMinute: deadlineMinute,
      urgentMinutes: urgentMinutes,
      priority: priority,
      note: note,
      repeatDays: repeatDays,
      minDurationMinutes: minDurationMinutes,
      targetDurationMinutes: targetDurationMinutes,
      isHardMode: isHardMode,
      requiresPhoto: requiresPhoto,
    );
    _habits.add(habit);
    _notifications.scheduleDeadlineTimers(habit);
    notifyListeners();
    await _storage.saveHabits(_habits);
  }

  Future<void> toggleToday(String habitId, {int xpReward = 10}) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<DateTime> updatedDates = List.from(habit.completedDates);
    bool justCompleted = false;

    if (habit.isCompletedToday) {
      updatedDates.removeWhere(
          (d) => d.year == now.year && d.month == now.month && d.day == now.day);
    } else {
      updatedDates.add(today);
      justCompleted = true;
      // Отменяем уведомления, если выполнено
      _notifications.cancelTimersForHabit(habit.id);
    }

    _habits[index] = habit.copyWith(completedDates: updatedDates);
    
    // Выдаем XP за выполнение
    if (justCompleted) {
      _userProfile = _userProfile.addXp(xpReward);
      await _storage.saveProfile(_userProfile);
    }

    notifyListeners();
    await _storage.saveHabits(_habits);
  }

  // ===================== GOALS =====================

  Future<void> addGoal(HabitGoal goal) async {
    _goals.add(goal);
    notifyListeners();
    await _storage.saveGoals(_goals);
  }

  Future<void> updateGoalProgress(String id, int addedDays) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    final goal = _goals[index];
    final newDays = goal.currentDays + addedDays;
    
    // Если цель достигнута:
    if (newDays >= goal.targetDays && !goal.isCompleted) {
       _userProfile = _userProfile.addXp(50); // Бонус за цель
       await _storage.saveProfile(_userProfile);
       _goals[index] = goal.copyWith(currentDays: goal.targetDays, isCompleted: true);
    } else {
       _goals[index] = goal.copyWith(currentDays: newDays);
    }

    notifyListeners();
    await _storage.saveGoals(_goals);
  }

  Future<void> claimDiaryXp() async {
    _userProfile = _userProfile.addXp(20);
    notifyListeners();
    await _storage.saveProfile(_userProfile);
  }


  Future<void> deleteHabit(String habitId) async {
    _notifications.cancelTimersForHabit(habitId);
    _habits.removeWhere((h) => h.id == habitId);
    notifyListeners();
    await _storage.saveHabits(_habits);
  }

  Future<void> archiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    _habits[index] = _habits[index].copyWith(isArchived: true);
    _notifications.cancelTimersForHabit(habitId);
    notifyListeners();
    await _storage.saveHabits(_habits);
  }

  Future<void> unarchiveHabit(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    _habits[index] = _habits[index].copyWith(isArchived: false);
    notifyListeners();
    await _storage.saveHabits(_habits);
  }

  void _scheduleAllNotifications() {
    for (final habit in todayHabits) {
      if (habit.hasDeadline && !habit.isCompletedToday) {
        _notifications.scheduleDeadlineTimers(habit);
      }
    }
  }
}

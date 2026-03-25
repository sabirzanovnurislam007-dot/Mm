import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../models/habit_goal.dart';

class StorageService {
  static const String _habitsKey = 'habits_list';
  static const String _profileKey = 'user_profile';
  static const String _goalsKey = 'goals_list';

  Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      return UserProfile.decode(profileJson);
    }
    return UserProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, profile.encode());
  }

  Future<List<HabitGoal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getStringList(_goalsKey) ?? [];
    return goalsJson.map((json) => HabitGoal.decode(json)).toList();
  }

  Future<void> saveGoals(List<HabitGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = goals.map((g) => g.encode()).toList();
    await prefs.setStringList(_goalsKey, goalsJson);
  }

  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getStringList(_habitsKey) ?? [];
    return habitsJson.map((json) => Habit.decode(json)).toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = habits.map((h) => h.encode()).toList();
    await prefs.setStringList(_habitsKey, habitsJson);
  }

  Future<void> addHabit(Habit habit) async {
    final habits = await loadHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  Future<void> updateHabit(Habit habit) async {
    final habits = await loadHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      habits[index] = habit;
      await saveHabits(habits);
    }
  }

  Future<void> deleteHabit(String id) async {
    final habits = await loadHabits();
    habits.removeWhere((h) => h.id == id);
    await saveHabits(habits);
  }
}


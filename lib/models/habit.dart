import 'dart:convert';
import 'package:flutter/material.dart';

enum HabitCategory {
  sport(Icons.fitness_center, 'Спорт'),
  health(Icons.favorite, 'Здоровье'),
  study(Icons.menu_book, 'Учёба'),
  work(Icons.work, 'Работа'),
  mindfulness(Icons.self_improvement, 'Осознанность'),
  nutrition(Icons.restaurant, 'Питание'),
  sleep(Icons.bedtime, 'Сон'),
  other(Icons.star, 'Другое');

  final IconData icon;
  final String label;
  const HabitCategory(this.icon, this.label);
}

enum HabitPriority {
  low('Низкий', Icons.arrow_downward),
  medium('Средний', Icons.remove),
  high('Высокий', Icons.arrow_upward),
  critical('Критический', Icons.priority_high);

  final String label;
  final IconData icon;
  const HabitPriority(this.label, this.icon);
}

class Habit {
  final String id;
  final String name;
  final HabitCategory category;
  final Color color;
  final List<DateTime> completedDates;
  final DateTime createdAt;
  final int? deadlineHour;       // час дедлайна (0-23)
  final int? deadlineMinute;     // минута дедлайна (0-59)
  final int urgentMinutes;       // минут на срочное выполнение после дедлайна
  final HabitPriority priority;
  final String? note;
  final List<int> repeatDays;    // дни недели (1=пн, 7=вс), пустой = каждый день
  final bool isArchived;
  final int? minDurationMinutes;
  final int? targetDurationMinutes;
  final bool isHardMode;
  final bool requiresPhoto;

  Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    List<DateTime>? completedDates,
    DateTime? createdAt,
    this.deadlineHour,
    this.deadlineMinute,
    this.urgentMinutes = 30,
    this.priority = HabitPriority.medium,
    this.note,
    List<int>? repeatDays,
    this.isArchived = false,
    this.minDurationMinutes,
    this.targetDurationMinutes,
    this.isHardMode = false,
    this.requiresPhoto = false,
  })  : completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now(),
        repeatDays = repeatDays ?? [];

  bool get hasDeadline => deadlineHour != null && deadlineMinute != null;

  String get deadlineFormatted {
    if (!hasDeadline) return '';
    return '${deadlineHour!.toString().padLeft(2, '0')}:${deadlineMinute!.toString().padLeft(2, '0')}';
  }

  /// Проверяет, нужна ли привычка сегодня (по дням недели)
  bool get isScheduledToday {
    if (repeatDays.isEmpty) return true; // каждый день
    return repeatDays.contains(DateTime.now().weekday);
  }

  bool get isCompletedToday {
    final now = DateTime.now();
    return completedDates.any((d) =>
        d.year == now.year && d.month == now.month && d.day == now.day);
  }

  /// Статус дедлайна: 'ok', 'approaching', 'overdue', 'urgent', 'failed'
  String get deadlineStatus {
    if (!hasDeadline || isCompletedToday) return 'ok';
    final now = DateTime.now();
    final deadline = DateTime(now.year, now.month, now.day, deadlineHour!, deadlineMinute!);
    final diff = deadline.difference(now);

    if (diff.isNegative) {
      // После дедлайна
      final urgentEnd = deadline.add(Duration(minutes: urgentMinutes));
      if (now.isBefore(urgentEnd)) {
        return 'urgent'; // Срочное время — ещё можно выполнить
      }
      return 'failed'; // Совсем просрочено
    }
    if (diff.inMinutes <= 30) return 'approaching'; // Скоро дедлайн
    return 'ok';
  }

  /// Оставшееся время до дедлайна (или до конца urgent периода)
  Duration? get timeRemaining {
    if (!hasDeadline || isCompletedToday) return null;
    final now = DateTime.now();
    final deadline = DateTime(now.year, now.month, now.day, deadlineHour!, deadlineMinute!);

    if (now.isBefore(deadline)) {
      return deadline.difference(now);
    }
    // В urgent периоде
    final urgentEnd = deadline.add(Duration(minutes: urgentMinutes));
    if (now.isBefore(urgentEnd)) {
      return urgentEnd.difference(now);
    }
    return Duration.zero;
  }

  int get currentStreak {
    if (completedDates.isEmpty) return 0;

    final sorted = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime check = DateTime.now();

    if (!isCompletedToday) {
      check = check.subtract(const Duration(days: 1));
    }

    for (final date in sorted) {
      if (date.year == check.year &&
          date.month == check.month &&
          date.day == check.day) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else if (date.isBefore(check)) {
        break;
      }
    }
    return streak;
  }

  int get totalCompletions => completedDates.length;

  /// Процент выполнения за последние 7 дней
  double get weeklyRate {
    final now = DateTime.now();
    int completed = 0;
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      if (completedDates.any((d) =>
          d.year == day.year && d.month == day.month && d.day == day.day)) {
        completed++;
      }
    }
    return completed / 7;
  }

  Habit copyWith({
    String? name,
    HabitCategory? category,
    Color? color,
    List<DateTime>? completedDates,
    int? deadlineHour,
    int? deadlineMinute,
    int? urgentMinutes,
    HabitPriority? priority,
    String? note,
    List<int>? repeatDays,
    bool? isArchived,
    int? minDurationMinutes,
    int? targetDurationMinutes,
    bool? isHardMode,
    bool? requiresPhoto,
    bool clearDeadline = false,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt,
      deadlineHour: clearDeadline ? null : (deadlineHour ?? this.deadlineHour),
      deadlineMinute: clearDeadline ? null : (deadlineMinute ?? this.deadlineMinute),
      urgentMinutes: urgentMinutes ?? this.urgentMinutes,
      priority: priority ?? this.priority,
      note: note ?? this.note,
      repeatDays: repeatDays ?? this.repeatDays,
      isArchived: isArchived ?? this.isArchived,
      minDurationMinutes: minDurationMinutes ?? this.minDurationMinutes,
      targetDurationMinutes: targetDurationMinutes ?? this.targetDurationMinutes,
      isHardMode: isHardMode ?? this.isHardMode,
      requiresPhoto: requiresPhoto ?? this.requiresPhoto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'color': color.toARGB32(),
      'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'deadlineHour': deadlineHour,
      'deadlineMinute': deadlineMinute,
      'urgentMinutes': urgentMinutes,
      'priority': priority.index,
      'note': note,
      'repeatDays': repeatDays,
      'isArchived': isArchived,
      'minDurationMinutes': minDurationMinutes,
      'targetDurationMinutes': targetDurationMinutes,
      'isHardMode': isHardMode,
      'requiresPhoto': requiresPhoto,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      category: HabitCategory.values[json['category'] as int],
      color: Color(json['color'] as int),
      completedDates: (json['completedDates'] as List<dynamic>)
          .map((d) => DateTime.parse(d as String))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      deadlineHour: json['deadlineHour'] as int?,
      deadlineMinute: json['deadlineMinute'] as int?,
      urgentMinutes: (json['urgentMinutes'] as int?) ?? 30,
      priority: HabitPriority.values[(json['priority'] as int?) ?? 1],
      note: json['note'] as String?,
      repeatDays: (json['repeatDays'] as List<dynamic>?)
              ?.map((d) => d as int)
              .toList() ??
          [],
      isArchived: (json['isArchived'] as bool?) ?? false,
      minDurationMinutes: json['minDurationMinutes'] as int?,
      targetDurationMinutes: json['targetDurationMinutes'] as int?,
      isHardMode: (json['isHardMode'] as bool?) ?? false,
      requiresPhoto: (json['requiresPhoto'] as bool?) ?? false,
    );
  }

  String encode() => jsonEncode(toJson());
  factory Habit.decode(String source) =>
      Habit.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

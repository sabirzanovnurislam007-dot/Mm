import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final Map<String, Timer> _deadlineTimers = {};

  Future<void> init() async {
    const initSettings = InitializationSettings(
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _plugin.initialize(initSettings);

    // Request iOS permissions
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Показать уведомление о приближении дедлайна
  Future<void> showDeadlineApproaching(Habit habit) async {
    await _plugin.show(
      habit.id.hashCode,
      '⏰ Скоро дедлайн!',
      '«${habit.name}» нужно выполнить до ${habit.deadlineFormatted}',
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Показать уведомление о том что дедлайн просрочен — СРОЧНЫЙ режим
  Future<void> showDeadlineMissed(Habit habit) async {
    await _plugin.show(
      habit.id.hashCode + 1000,
      '🚨 Дедлайн просрочен!',
      '«${habit.name}» — у вас ${habit.urgentMinutes} мин. чтобы выполнить!',
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Показать уведомление о полном провале
  Future<void> showDeadlineFailed(Habit habit) async {
    await _plugin.show(
      habit.id.hashCode + 2000,
      '❌ Не выполнено',
      '«${habit.name}» — привычка не выполнена вовремя',
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Установить таймеры для привычки с дедлайном
  void scheduleDeadlineTimers(Habit habit) {
    cancelTimersForHabit(habit.id);

    if (!habit.hasDeadline || habit.isCompletedToday) return;

    final now = DateTime.now();
    final deadline = DateTime(
        now.year, now.month, now.day, habit.deadlineHour!, habit.deadlineMinute!);

    // Приближение (за 5 минут)
    final approachTime = deadline.subtract(const Duration(minutes: 5));
    if (approachTime.isAfter(now)) {
      _deadlineTimers['${habit.id}_approach'] = Timer(
        approachTime.difference(now),
        () => showDeadlineApproaching(habit),
      );
    }

    // Дедлайн пропущен — переход в urgent
    if (deadline.isAfter(now)) {
      _deadlineTimers['${habit.id}_missed'] = Timer(
        deadline.difference(now),
        () => showDeadlineMissed(habit),
      );
    }

    // Urgent period закончился — failed
    final urgentEnd = deadline.add(Duration(minutes: habit.urgentMinutes));
    if (urgentEnd.isAfter(now)) {
      _deadlineTimers['${habit.id}_failed'] = Timer(
        urgentEnd.difference(now),
        () => showDeadlineFailed(habit),
      );
    }
  }

  void cancelTimersForHabit(String habitId) {
    _deadlineTimers.remove('${habitId}_approach')?.cancel();
    _deadlineTimers.remove('${habitId}_missed')?.cancel();
    _deadlineTimers.remove('${habitId}_failed')?.cancel();
  }

  void cancelAll() {
    for (final timer in _deadlineTimers.values) {
      timer.cancel();
    }
    _deadlineTimers.clear();
    _plugin.cancelAll();
  }
}

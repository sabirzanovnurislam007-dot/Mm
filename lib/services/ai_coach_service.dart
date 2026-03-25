import '../models/habit.dart';

/// AI insight types — determines card style and icon
enum InsightType {
  warning,   // 🔴 Risk / streak in danger
  tip,       // 💡 Actionable advice
  praise,    // 🏆 Celebrate achievement
  pattern,   // 📊 Behavior pattern detected
  challenge, // 🎯 Challenge / push harder
}

class AiInsight {
  final InsightType type;
  final String title;
  final String body;
  final String? habitName; // Related specific habit (optional)

  const AiInsight({
    required this.type,
    required this.title,
    required this.body,
    this.habitName,
  });
}

/// Analyzes habits and produces AI-style insights
class AiCoachService {
  static List<AiInsight> analyze(List<Habit> habits, String lang) {
    if (habits.isEmpty) return _emptyInsights(lang);

    final insights = <AiInsight>[];
    final now = DateTime.now();

    // ── 1. Streak warnings ──────────────────────────────────────────────────
    for (final h in habits) {
      if (h.currentStreak >= 3 && !h.isCompletedToday) {
        insights.add(AiInsight(
          type: InsightType.warning,
          title: _t(lang, 'streak_at_risk_title'),
          body: _t(lang, 'streak_at_risk_body')
              .replaceAll('{name}', h.name)
              .replaceAll('{n}', '${h.currentStreak}'),
          habitName: h.name,
        ));
      }
    }

    // ── 2. Best habit praise ─────────────────────────────────────────────────
    final bestHabits = habits.where((h) => h.weeklyRate >= 0.85).toList();
    if (bestHabits.isNotEmpty) {
      final best = bestHabits.first;
      insights.add(AiInsight(
        type: InsightType.praise,
        title: _t(lang, 'on_fire_title'),
        body: _t(lang, 'on_fire_body')
            .replaceAll('{name}', best.name)
            .replaceAll('{pct}', '${(best.weeklyRate * 100).round()}'),
        habitName: best.name,
      ));
    }

    // ── 3. Weakest habit ────────────────────────────────────────────────────
    final sorted = List<Habit>.from(habits)
      ..sort((a, b) => a.weeklyRate.compareTo(b.weeklyRate));
    final weakest = sorted.first;
    if (weakest.weeklyRate < 0.4 && weakest.totalCompletions > 1) {
      insights.add(AiInsight(
        type: InsightType.tip,
        title: _t(lang, 'struggling_title'),
        body: _t(lang, 'struggling_body')
            .replaceAll('{name}', weakest.name)
            .replaceAll('{pct}', '${(weakest.weeklyRate * 100).round()}'),
        habitName: weakest.name,
      ));
    }

    // ── 4. Category pattern ─────────────────────────────────────────────────
    final categoryMap = <HabitCategory, List<Habit>>{};
    for (final h in habits) {
      categoryMap.putIfAbsent(h.category, () => []).add(h);
    }
    final largestCategory = categoryMap.entries
        .reduce((a, b) => a.value.length >= b.value.length ? a : b);
    if (largestCategory.value.length >= 2) {
      insights.add(AiInsight(
        type: InsightType.pattern,
        title: _t(lang, 'category_pattern_title'),
        body: _t(lang, 'category_pattern_body')
            .replaceAll('{cat}', largestCategory.key.label)
            .replaceAll('{n}', '${largestCategory.value.length}'),
      ));
    }

    // ── 5. Weekend slump detection ─────────────────────────────────────────
    int weekendMisses = 0;
    int weekdayMisses = 0;
    for (final h in habits) {
      for (int i = 1; i <= 14; i++) {
        final day = now.subtract(Duration(days: i));
        final completed = h.completedDates
            .any((d) => d.year == day.year && d.month == day.month && d.day == day.day);
        if (!completed) {
          if (day.weekday == 6 || day.weekday == 7) {
            weekendMisses++;
          } else {
            weekdayMisses++;
          }
        }
      }
    }
    if (weekendMisses > weekdayMisses * 1.5 && weekendMisses > 2) {
      insights.add(AiInsight(
        type: InsightType.pattern,
        title: _t(lang, 'weekend_slump_title'),
        body: _t(lang, 'weekend_slump_body'),
      ));
    }

    // ── 6. Time of day tip ─────────────────────────────────────────────────
    final hour = now.hour;
    if (hour >= 6 && hour < 10) {
      final notDone = habits.where((h) => !h.isCompletedToday).toList();
      if (notDone.isNotEmpty) {
        insights.add(AiInsight(
          type: InsightType.tip,
          title: _t(lang, 'morning_tip_title'),
          body: _t(lang, 'morning_tip_body')
              .replaceAll('{name}', notDone.first.name),
          habitName: notDone.first.name,
        ));
      }
    } else if (hour >= 21) {
      final notDone = habits.where((h) => !h.isCompletedToday).toList();
      if (notDone.isNotEmpty) {
        insights.add(AiInsight(
          type: InsightType.warning,
          title: _t(lang, 'evening_warn_title'),
          body: _t(lang, 'evening_warn_body')
              .replaceAll('{n}', '${notDone.length}'),
        ));
      }
    }

    // ── 7. Long streak achievement ─────────────────────────────────────────
    for (final h in habits) {
      if (h.currentStreak == 7 || h.currentStreak == 14 || h.currentStreak == 21 || h.currentStreak == 30) {
        insights.add(AiInsight(
          type: InsightType.praise,
          title: _t(lang, 'milestone_title').replaceAll('{n}', '${h.currentStreak}'),
          body: _t(lang, 'milestone_body')
              .replaceAll('{name}', h.name)
              .replaceAll('{n}', '${h.currentStreak}'),
          habitName: h.name,
        ));
      }
    }

    // ── 8. Challenge if fully caught up ──────────────────────────────────
    final allDoneToday = habits.every((h) => !h.isScheduledToday || h.isCompletedToday);
    if (allDoneToday && habits.isNotEmpty) {
      insights.add(AiInsight(
        type: InsightType.challenge,
        title: _t(lang, 'all_done_title'),
        body: _t(lang, 'all_done_body'),
      ));
    }

    // ── 9. Category diversity ──────────────────────────────────────────────
    if (categoryMap.length == 1 && habits.length >= 2) {
      insights.add(AiInsight(
        type: InsightType.tip,
        title: _t(lang, 'diversity_title'),
        body: _t(lang, 'diversity_body'),
      ));
    }

    // ── 10. High priority not done ────────────────────────────────────────
    final criticalUndone = habits.where((h) =>
        h.priority == HabitPriority.critical && !h.isCompletedToday && h.isScheduledToday).toList();
    if (criticalUndone.isNotEmpty) {
      insights.add(AiInsight(
        type: InsightType.warning,
        title: _t(lang, 'critical_title'),
        body: _t(lang, 'critical_body').replaceAll('{name}', criticalUndone.first.name),
        habitName: criticalUndone.first.name,
      ));
    }

    return insights.isEmpty ? _emptyInsights(lang) : insights;
  }

  static List<AiInsight> _emptyInsights(String lang) => [
    AiInsight(
      type: InsightType.tip,
      title: _t(lang, 'empty_title'),
      body: _t(lang, 'empty_body'),
    ),
  ];

  static final _strings = <String, Map<String, String>>{
    'ru': {
      'streak_at_risk_title': '⚠️ Серия под угрозой!',
      'streak_at_risk_body': 'Привычка "{name}" имеет серию {n} дней — но ты ещё не выполнил её сегодня. Не теряй прогресс!',
      'on_fire_title': '🔥 Ты в огне!',
      'on_fire_body': '"{name}" выполняется с результатом {pct}% за эту неделю. Так держать!',
      'struggling_title': '💡 Требует внимания',
      'struggling_body': '"{name}" выполняется только на {pct}% в неделю. Попробуй уменьшить порог — начни с 5 минут.',
      'category_pattern_title': '📊 Паттерн обнаружен',
      'category_pattern_body': 'У тебя {n} привычек в категории "{cat}". Убедись, что другие сферы жизни тоже развиваются.',
      'weekend_slump_title': '📊 Слабость по выходным',
      'weekend_slump_body': 'AI зафиксировал: ты чаще пропускаешь выходными. Попробуй сделать привычки проще на Сб/Вс.',
      'morning_tip_title': '🌅 Доброе утро, действуй!',
      'morning_tip_body': 'Идеальный момент: начни с "{name}" прямо сейчас. Утренние привычки выполняются в 2× чаще.',
      'evening_warn_title': '🌙 Почти полночь',
      'evening_warn_body': 'Осталось {n} невыполненных привычек. Ещё есть время закрыть день сильно!',
      'milestone_title': '🏆 {n}-дневная серия!',
      'milestone_body': '"{name}" достигла {n} дней подряд. Ты во всего лишь 1% пользователей!',
      'all_done_title': '🎯 Всё выполнено!',
      'all_done_body': 'Ты закрыл все привычки на сегодня. Этот уровень дисциплины встречается редко — держи стандарт!',
      'diversity_title': '🌱 Разнообразь жизнь',
      'diversity_body': 'Все твои привычки в одной категории. Добавь что-то из спорта, осознанности или здоровья.',
      'critical_title': '🚨 Критическая привычка!',
      'critical_body': '"{name}" отмечена как критическая — и ещё не выполнена сегодня. Это приоритет №1.',
      'empty_title': '🤖 AI-тренер готов!',
      'empty_body': 'Добавь привычки и я начну анализировать твоё поведение, паттерны и давать персональные советы.',
    },
    'en': {
      'streak_at_risk_title': '⚠️ Streak at risk!',
      'streak_at_risk_body': '"{name}" has a {n}-day streak — but you haven\'t completed it today. Don\'t lose your progress!',
      'on_fire_title': '🔥 You\'re on fire!',
      'on_fire_body': '"{name}" is at {pct}% this week. Keep it up!',
      'struggling_title': '💡 Needs attention',
      'struggling_body': '"{name}" is only at {pct}% completion this week. Try lowering the bar — start with 5 minutes.',
      'category_pattern_title': '📊 Pattern detected',
      'category_pattern_body': 'You have {n} habits in "{cat}". Make sure other life areas are growing too.',
      'weekend_slump_title': '📊 Weekend slump',
      'weekend_slump_body': 'AI detected: you skip more on weekends. Try making habits easier on Sat/Sun.',
      'morning_tip_title': '🌅 Good morning, act now!',
      'morning_tip_body': 'Perfect moment: start with "{name}" right now. Morning habits are completed 2× more often.',
      'evening_warn_title': '🌙 Almost midnight',
      'evening_warn_body': '{n} habits still unfinished. You still have time to end the day strong!',
      'milestone_title': '🏆 {n}-day streak!',
      'milestone_body': '"{name}" just hit {n} days in a row. You\'re in the top 1% of users!',
      'all_done_title': '🎯 All done today!',
      'all_done_body': 'You completed every habit today. This level of discipline is rare — keep the standard!',
      'diversity_title': '🌱 Diversify your life',
      'diversity_body': 'All your habits are in one category. Add something from sport, mindfulness or health.',
      'critical_title': '🚨 Critical habit alert!',
      'critical_body': '"{name}" is marked critical — and not done yet today. This is priority #1.',
      'empty_title': '🤖 AI Coach is ready!',
      'empty_body': 'Add some habits and I\'ll start analyzing your behavior, patterns and give you personal advice.',
    },
    'ky': {
      'streak_at_risk_title': '⚠️ Серия коркунучта!',
      'streak_at_risk_body': '"{name}" — {n} күндүк серия, бирок бүгүн аяктаган жоксуң. Прогрессти жоготпо!',
      'on_fire_title': '🔥 Сен кыздырылдың!',
      'on_fire_body': '"{name}" бул жума {pct}% аткарылды. Улантып кет!',
      'struggling_title': '💡 Көңүл буруу керек',
      'struggling_body': '"{name}" жума сайын {pct}% гана. 5 мүнөттөн баштап көр.',
      'category_pattern_title': '📊 Паттерн табылды',
      'category_pattern_body': '"{cat}" категориясында {n} адат бар. Жашоонун башка тармактарын да өнүктүр.',
      'weekend_slump_title': '📊 Дем алыш күндөрдө алсызсың',
      'weekend_slump_body': 'AI аныктады: дем алыш күндөрү жиберип алуу жыш болот. Шейшемби/Жекшемби жеңилдет.',
      'morning_tip_title': '🌅 Эртең менен аракет кыл!',
      'morning_tip_body': '"{name}" менен азыр эле баштагын. Эртеңки адаттар 2× жыш аткарылат.',
      'evening_warn_title': '🌙 Түн жакындады',
      'evening_warn_body': '{n} адат аткарылган жок. Күндү күчтүү жабуу үчүн убакыт бар!',
      'milestone_title': '🏆 {n} күндүк серия!',
      'milestone_body': '"{name}" {n} күн катары менен. Сен эң мыктылардан бирисиң!',
      'all_done_title': '🎯 Баары аткарылды!',
      'all_done_body': 'Бүгүн бардык адаттарды жаптың. Бул тартип деңгээли сейрек жолугат!',
      'diversity_title': '🌱 Турмушту ар багытта өнүктүр',
      'diversity_body': 'Бардык адаттарың бир категорияда. Спорт, ден соолук же аң-сезимдүүлүктөн кош.',
      'critical_title': '🚨 Критикалык адат!',
      'critical_body': '"{name}" критикалык деп белгиленген — бирок бүгүн аткарылган жок. Биринчи кезек!',
      'empty_title': '🤖 AI-тренер даяр!',
      'empty_body': 'Адаттарды кош, мен жүрүм-турумду, паттерндерди талдап, жеке кеңеш беремин.',
    },
  };

  static String _t(String lang, String key) {
    return _strings[lang]?[key] ?? _strings['ru']![key] ?? key;
  }
}

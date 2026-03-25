import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/locale_provider.dart';
import '../services/ai_coach_service.dart';
import '../theme/app_theme.dart';

class AiCoachScreen extends StatelessWidget {
  const AiCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<LocaleProvider>().locale.languageCode;

    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final insights = AiCoachService.analyze(provider.habits, lang);

        return CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // AI Icon
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppTheme.accentGreen, Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentGreen.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.psychology_outlined,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang == 'en' ? 'AI Coach' : lang == 'ky' ? 'AI Тренер' : 'AI-тренер',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            Text(
                              lang == 'en'
                                  ? '${insights.length} insights today'
                                  : lang == 'ky'
                                      ? 'Бүгүн ${insights.length} кеңеш'
                                      : '${insights.length} советов сегодня',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).animate().fadeIn().slideX(begin: -0.1),

                    const SizedBox(height: 20),

                    // Summary bar
                    _SummaryBar(provider: provider, lang: lang, isDark: isDark)
                        .animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    Text(
                      lang == 'en'
                          ? 'Personal Insights'
                          : lang == 'ky'
                              ? 'Жеке кеңештер'
                              : 'Персональные советы',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Insight cards ────────────────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _InsightCard(
                    insight: insights[i],
                    isDark: isDark,
                    delay: 250 + i * 80,
                  ),
                ),
                childCount: insights.length,
              ),
            ),

            // ── AI message at bottom ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: _AiMessageBubble(lang: lang, isDark: isDark)
                    .animate().fadeIn(delay: 400.ms),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        );
      },
    );
  }
}

// ── Summary Bar ─────────────────────────────────────────────────────────────
class _SummaryBar extends StatelessWidget {
  final HabitProvider provider;
  final String lang;
  final bool isDark;

  const _SummaryBar({
    required this.provider,
    required this.lang,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = provider.todayProgress;
    final streak = provider.longestStreak;
    final total = provider.habits.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentGreen.withValues(alpha: isDark ? 0.15 : 0.08),
                AppTheme.accentCyan.withValues(alpha: isDark ? 0.08 : 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentGreen.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              // Progress bar
              Row(
                children: [
                  Text(
                    lang == 'en' ? 'Today\'s progress' : lang == 'ky' ? 'Бүгүнкү прогресс' : 'Прогресс сегодня',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: AppTheme.accentGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.07),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.accentGreen),
                ),
              ),
              const SizedBox(height: 14),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniStat(
                    value: '${provider.todayCompleted.length}/${provider.todayHabits.length}',
                    label: lang == 'en' ? 'Today' : lang == 'ky' ? 'Бүгүн' : 'Сегодня',
                    color: AppTheme.accentGreen,
                  ),
                  _MiniStat(
                    value: '$streak',
                    label: lang == 'en' ? 'Best streak' : lang == 'ky' ? 'Эң узун' : 'Рекорд',
                    color: AppTheme.accentOrange,
                  ),
                  _MiniStat(
                    value: '$total',
                    label: lang == 'en' ? 'Habits' : lang == 'ky' ? 'Адаттар' : 'Привычек',
                    color: AppTheme.accentCyan,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }
}

// ── Insight Card ─────────────────────────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final AiInsight insight;
  final bool isDark;
  final int delay;

  const _InsightCard({
    required this.insight,
    required this.isDark,
    required this.delay,
  });

  Color get _accentColor {
    return switch (insight.type) {
      InsightType.warning   => AppTheme.accentRed,
      InsightType.tip       => AppTheme.accentCyan,
      InsightType.praise    => AppTheme.accentOrange,
      InsightType.pattern   => AppTheme.accentBlue,
      InsightType.challenge => AppTheme.accentGreen,
    };
  }

  IconData get _icon {
    return switch (insight.type) {
      InsightType.warning   => Icons.warning_amber_rounded,
      InsightType.tip       => Icons.lightbulb_outline,
      InsightType.praise    => Icons.emoji_events_outlined,
      InsightType.pattern   => Icons.bar_chart_rounded,
      InsightType.challenge => Icons.flag_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _accentColor;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.bgCard.withValues(alpha: 0.75)
                : Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                ),
                child: Icon(_icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      insight.body,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    if (insight.habitName != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          insight.habitName!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.08);
  }
}

// ── AI Message Bubble ─────────────────────────────────────────────────────────
class _AiMessageBubble extends StatelessWidget {
  final String lang;
  final bool isDark;

  const _AiMessageBubble({required this.lang, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final message = lang == 'en'
        ? 'I analyze your habits daily and update insights in real time. The more you use the app, the more accurate my advice becomes.'
        : lang == 'ky'
            ? 'Мен адаттарыңды күн сайын анализдеп, кеңештерди жаңыртып турам. Колдонмону канчалык жыш колдонсоң, кеңештер ошончолук так болот.'
            : 'Я анализирую твои привычки ежедневно и обновляю инсайты в реальном времени. Чем больше ты используешь приложение — тем точнее мои советы.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentGreen.withValues(alpha: isDark ? 0.18 : 0.10),
            AppTheme.accentCyan.withValues(alpha: isDark ? 0.10 : 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.accentGreen.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.accentGreen, Color(0xFF059669)],
              ),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Coach',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.75)
                        : Colors.black.withValues(alpha: 0.65),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

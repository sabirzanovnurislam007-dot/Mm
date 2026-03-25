import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/category_chip.dart';

class AddHabitSheet extends StatefulWidget {
  const AddHabitSheet({super.key});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  HabitCategory _selectedCategory = HabitCategory.sport;
  int _selectedColorIndex = 3; // Default to green
  TimeOfDay? _deadline;
  int _urgentMinutes = 30;
  HabitPriority _priority = HabitPriority.medium;
  final Set<int> _repeatDays = {}; // пустой = каждый день
  bool _showAdvanced = false;

  // Gamification properties
  bool _enableMinMax = false;
  int _minMinutes = 5;
  int _targetMinutes = 30;
  bool _isHardMode = false;
  bool _requiresPhoto = false;

  static const _dayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addHabit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    context.read<HabitProvider>().addHabit(
          name: name,
          category: _selectedCategory,
          color: AppTheme.habitColors[_selectedColorIndex],
          deadlineHour: _deadline?.hour,
          deadlineMinute: _deadline?.minute,
          urgentMinutes: _urgentMinutes,
          priority: _priority,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
          repeatDays: _repeatDays.isNotEmpty ? _repeatDays.toList() : null,
          minDurationMinutes: _enableMinMax ? _minMinutes : null,
          targetDurationMinutes: _enableMinMax ? _targetMinutes : null,
          isHardMode: _isHardMode,
          requiresPhoto: _requiresPhoto,
        );
    Navigator.pop(context);
  }

  Future<void> _pickDeadline() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _deadline ?? const TimeOfDay(hour: 22, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.bgCard
                  : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _deadline = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<LocaleProvider>().locale.languageCode;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0D1F18).withValues(alpha: 0.97)  // dark green-tinted bg
                : const Color(0xFFF0FDF8).withValues(alpha: 0.98),  // very light green-white
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: AppTheme.accentGreen.withValues(alpha: isDark ? 0.25 : 0.18),
                width: 1.5,
              ),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(AppStrings.get('new_habit', lang),
                    style: Theme.of(context).textTheme.headlineMedium)
                    .animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),

                const SizedBox(height: 20),

                // Name input
                _buildInput(
                  controller: _nameController,
                  hint: AppStrings.get('habit_name', lang),
                  icon: _selectedCategory.icon,
                  iconColor: AppTheme.habitColors[_selectedColorIndex],
                  autofocus: true,
                  onSubmitted: (_) => _addHabit(),
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                // Categories
                _sectionLabel(context, AppStrings.get('category', lang)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: HabitCategory.values.map((cat) {
                    return CategoryChip(
                      category: cat,
                      isSelected: _selectedCategory == cat,
                      onTap: () => setState(() => _selectedCategory = cat),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Colors
                _sectionLabel(context, AppStrings.get('color', lang)),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(AppTheme.habitColors.length, (i) {
                    final color = AppTheme.habitColors[i];
                    final sel = _selectedColorIndex == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedColorIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: sel ? 36 : 32, height: sel ? 36 : 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, color: color,
                            border: sel ? Border.all(color: isDark ? Colors.white : Colors.black87, width: 2.5) : null,
                            boxShadow: sel ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12)] : [],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),

                // ===== DEADLINE =====
                _sectionLabel(context, AppStrings.get('deadline', lang)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickDeadline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.bgCardLight : AppTheme.bgCardLightAlt,
                      borderRadius: BorderRadius.circular(14),
                      border: _deadline != null
                          ? Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.5))
                          : Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: _deadline != null ? AppTheme.accentGreen : AppTheme.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _deadline != null
                                ? '${AppStrings.get('deadline_until', lang)} ${_deadline!.format(context)}'
                                : AppStrings.get('set_deadline', lang),
                            style: TextStyle(
                              color: _deadline != null
                                  ? Theme.of(context).textTheme.bodyLarge?.color
                                  : AppTheme.textMuted,
                              fontSize: 15,
                              fontWeight: _deadline != null ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (_deadline != null)
                          GestureDetector(
                            onTap: () => setState(() => _deadline = null),
                            child: Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                          ),
                      ],
                    ),
                  ),
                ),

                // Urgent minutes slider (only if deadline set)
                if (_deadline != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.alarm, size: 16, color: AppTheme.accentRed.withValues(alpha: 0.7)),
                      const SizedBox(width: 6),
                      Text(
                        '${AppStrings.get('urgent_time', lang)}: $_urgentMinutes ${AppStrings.get('min', lang)}',
                        style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                  Slider(
                    value: _urgentMinutes.toDouble(),
                    min: 5, max: 120, divisions: 23,
                    activeColor: AppTheme.accentRed,
                    label: '$_urgentMinutes ${AppStrings.get('min', lang)}',
                    onChanged: (v) => setState(() => _urgentMinutes = v.round()),
                  ),
                ],

                const SizedBox(height: 8),

                // ===== Advanced toggle =====
                GestureDetector(
                  onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                  child: Row(
                    children: [
                      Icon(
                        _showAdvanced ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.accentGreen, size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.get('advanced', lang),
                        style: TextStyle(
                          color: AppTheme.accentGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_showAdvanced) ...[
                  const SizedBox(height: 16),

                  // Priority
                  _sectionLabel(context, AppStrings.get('priority', lang)),
                  const SizedBox(height: 8),
                  Row(
                    children: HabitPriority.values.map((p) {
                      final sel = _priority == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _priority = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: sel ? AppTheme.accentGreen.withValues(alpha: 0.15) : (isDark ? AppTheme.bgCardLight : AppTheme.bgCardLightAlt),
                              border: sel ? Border.all(color: AppTheme.accentGreen.withValues(alpha: 0.5)) : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(p.icon, size: 14, color: sel ? AppTheme.accentGreen : AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Text(p.label, style: TextStyle(
                                  fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                                  color: sel ? AppTheme.accentGreen : AppTheme.textMuted,
                                )),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // Repeat days
                  _sectionLabel(context, AppStrings.get('repeat', lang)),
                  const SizedBox(height: 4),
                  Text(AppStrings.get('everyday', lang), style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final sel = _repeatDays.contains(day);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (sel) {
                            _repeatDays.remove(day);
                          } else {
                            _repeatDays.add(day);
                          }
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sel ? AppTheme.accentGreen : (isDark ? AppTheme.bgCardLight : AppTheme.bgCardLightAlt),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _dayLabels[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : AppTheme.textMuted,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // Note
                  _sectionLabel(context, AppStrings.get('note', lang)),
                  const SizedBox(height: 8),
                  _buildInput(
                    controller: _noteController,
                    hint: AppStrings.get('note_hint', lang),
                    icon: Icons.note_alt_outlined,
                    iconColor: AppTheme.textMuted,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // ── Gamification Section ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.bgCardLight : AppTheme.bgCardLightAlt,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology_alt, color: AppTheme.accentOrange, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              lang == 'en' ? 'Gamification & Mindset' : lang == 'ky' ? 'Геймификация' : 'Геймификация',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Min/Max Toggle
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(lang == 'en' ? 'Min/Max Goal' : 'Минимум/Максимум', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Text(lang == 'en' ? 'Set minimum effort to start easily' : 'Снижает барьер для старта', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          value: _enableMinMax,
                          activeThumbColor: AppTheme.accentGreen,
                          onChanged: (v) => setState(() => _enableMinMax = v),
                        ),
                        if (_enableMinMax) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Text(lang == 'en' ? 'Min: $_minMinutes m' : 'Мин: $_minMinutes м', style: const TextStyle(fontSize: 13, color: AppTheme.accentOrange)),
                              ),
                              Expanded(
                                child: Text(lang == 'en' ? 'Target: $_targetMinutes m' : 'Цель: $_targetMinutes м', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, color: AppTheme.accentGreen)),
                              ),
                            ],
                          ),
                          Slider(
                            value: _minMinutes.toDouble(),
                            min: 1, max: 60, divisions: 59,
                            activeColor: AppTheme.accentOrange,
                            onChanged: (v) {
                              setState(() {
                                _minMinutes = v.toInt();
                                if (_minMinutes > _targetMinutes) _targetMinutes = _minMinutes;
                              });
                            },
                          ),
                          Slider(
                            value: _targetMinutes.toDouble(),
                            min: 1, max: 120, divisions: 119,
                            activeColor: AppTheme.accentGreen,
                            onChanged: (v) {
                              setState(() {
                                _targetMinutes = v.toInt();
                                if (_targetMinutes < _minMinutes) _minMinutes = _targetMinutes;
                              });
                            },
                          ),
                        ],
                        
                        // No Excuses Mode
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(lang == 'en' ? 'No Excuses Mode' : 'Режим без отмазок', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.accentRed)),
                          subtitle: Text(lang == 'en' ? 'Missed deadline = XP penalty' : 'Пропуск = штраф XP', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          value: _isHardMode,
                          activeThumbColor: AppTheme.accentRed,
                          onChanged: (v) => setState(() => _isHardMode = v),
                        ),
                        
                        // Honest Mode
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(lang == 'en' ? 'Honest Mode' : 'Честный режим', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.accentBlue)),
                          subtitle: Text(lang == 'en' ? 'Requires a photo to complete' : 'Требует фото-пруф', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          value: _requiresPhoto,
                          activeThumbColor: AppTheme.accentBlue,
                          onChanged: (v) => setState(() => _requiresPhoto = v),
                        ),
                      ],
                    ),
                  ),

                ],

                const SizedBox(height: 28),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _addHabit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.accentGreen, Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(AppStrings.get('add', lang),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    bool autofocus = false,
    ValueChanged<String>? onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCardLight : AppTheme.bgCardLightAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

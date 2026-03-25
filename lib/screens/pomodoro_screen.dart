import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_ring.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int _workDuration = 25 * 60; // 25 минут
  static const int _breakDuration = 5 * 60; // 5 минут
  
  int _secondsRemaining = _workDuration;
  bool _isRunning = false;
  bool _isWorkFocus = true;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _timer?.cancel();
          HapticFeedback.heavyImpact();
          _switchMode();
        }
      });
    }
    HapticFeedback.lightImpact();
  }

  void _switchMode() {
    setState(() {
      _isWorkFocus = !_isWorkFocus;
      _secondsRemaining = _isWorkFocus ? _workDuration : _breakDuration;
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = _isWorkFocus ? _workDuration : _breakDuration;
      _isRunning = false;
    });
    HapticFeedback.mediumImpact();
  }

  String get _timeString {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final total = _isWorkFocus ? _workDuration : _breakDuration;
    return 1 - (_secondsRemaining / total);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = _isWorkFocus ? AppTheme.accentOrange : AppTheme.accentCyan;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Выбор режима (Фокус / Отдых)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.bgCard : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ModeButton(
                      title: 'Фокус',
                      isSelected: _isWorkFocus,
                      activeColor: AppTheme.accentOrange,
                      onTap: () {
                        if (!_isWorkFocus) _switchMode();
                      },
                      isDark: isDark,
                    ),
                    _ModeButton(
                      title: 'Отдых',
                      isSelected: !_isWorkFocus,
                      activeColor: AppTheme.accentCyan,
                      onTap: () {
                        if (_isWorkFocus) _switchMode();
                      },
                      isDark: isDark,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),

              const SizedBox(height: 60),

              // Таймер (Круг)
              Center(
                child: ProgressRing(
                  progress: _progress,
                  size: 280,
                  strokeWidth: 16,
                  color: primaryColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _timeString,
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isWorkFocus ? 'Концентрация' : 'Перерыв',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ).animate(target: _isRunning ? 1 : 0).fade(begin: 0.5, end: 1),
                    ],
                  ),
                ),
              ).animate().scale(delay: 100.ms),

              const SizedBox(height: 60),

              // Кнопки управления
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Сброс
                  GestureDetector(
                    onTap: _resetTimer,
                    child: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppTheme.bgCardLight : AppTheme.bgCardLightAlt,
                      ),
                      child: Icon(Icons.refresh, color: AppTheme.textMuted, size: 28),
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Плей / Пауза
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                         _isRunning ? Icons.pause : Icons.play_arrow,
                         color: Colors.white,
                         size: 40,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;
  final bool isDark;

  const _ModeButton({
    required this.title,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected 
                ? activeColor 
                : (isDark ? AppTheme.textMuted : AppTheme.textMuted),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

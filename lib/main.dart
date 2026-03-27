import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/habit_provider.dart';
import 'providers/fitness_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/add_habit_screen.dart';
import 'screens/ai_coach_screen.dart';
import 'screens/home_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const DisciplineApp());
}

class DisciplineApp extends StatefulWidget {
  const DisciplineApp({super.key});

  @override
  State<DisciplineApp> createState() => _DisciplineAppState();
}

class _DisciplineAppState extends State<DisciplineApp> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await initializeDateFormatting('ru', null);
    await NotificationService().init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color(0xFF1E1E1E), // AppTheme.bgDark
              body: Center(
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: Color(0xFF10B981), // AppTheme.accentGreen
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => HabitProvider()..loadHabits()),
            ChangeNotifierProxyProvider<HabitProvider, FitnessProvider>(
              create: (context) => FitnessProvider(habitProvider: context.read<HabitProvider>()),
              update: (context, habitProvider, previous) => previous ?? FitnessProvider(habitProvider: habitProvider),
            ),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ],
          child: Consumer2<ThemeProvider, LocaleProvider>(
            builder: (context, themeProvider, localeProvider, _) {
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarBrightness: themeProvider.isDarkMode
                      ? Brightness.dark
                      : Brightness.light,
                  statusBarIconBrightness: themeProvider.isDarkMode
                      ? Brightness.light
                      : Brightness.dark,
                ),
              );

              return MaterialApp(
                title: 'Дисциплина',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                locale: localeProvider.locale,
                supportedLocales: LocaleProvider.supportedLocales,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.isAuthenticated) {
                      return const MainShell();
                    } else {
                      return const LoginScreen();
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _prevIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AiCoachScreen(),
    CalendarScreen(),
    DiaryScreen(),
  ];

  static const _navItems = [
    (Icons.person_outline, Icons.person, 'Главная'),
    (Icons.psychology_outlined, Icons.psychology, 'AI'),
    (Icons.calendar_today_outlined, Icons.calendar_today, 'Календарь'),
    (Icons.book_outlined, Icons.book, 'Дневник'),
  ];

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.lightImpact();
    setState(() {
      _prevIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  void _showAddHabit() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<HabitProvider>(),
        child: const AddHabitSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final bgTheme = themeProvider.bgTheme;
    final goingRight = _currentIndex > _prevIndex;

    Gradient? overflowGradient;
    if (bgTheme != 'solid' && isDark) {
      switch (bgTheme) {
        case 'midnight':
          overflowGradient = const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          break;
        case 'cyberpunk':
          overflowGradient = const LinearGradient(
            colors: [Color(0xFF2A0845), Color(0xFF6441A5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          break;
        case 'forest':
          overflowGradient = const LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          break;
        case 'sunset':
          overflowGradient = const LinearGradient(
            colors: [Color(0xFF581C87), Color(0xFF9F1239)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgDark : AppTheme.bgLight,
        gradient: overflowGradient,
      ),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slideIn = Tween<Offset>(
                begin: goingRight
                    ? const Offset(0.06, 0)
                    : const Offset(-0.06, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slideIn, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _screens[_currentIndex],
            ),
          ),
        ),
        floatingActionButton: AnimatedScale(
          scale: _currentIndex == 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0), // Поднимаем чуть выше слайдера
            child: _PlusButton(onTap: _showAddHabit),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: LiquidBottomNavSlider(
          currentIndex: _currentIndex,
          isDark: isDark,
          navItems: _navItems,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}

// ── Custom Bottom Nav Bar Slider ──────────────────────────────────────────────
class LiquidBottomNavSlider extends StatefulWidget {
  final int currentIndex;
  final bool isDark;
  final List<(IconData, IconData, String)> navItems;
  final void Function(int) onTap;

  const LiquidBottomNavSlider({
    super.key,
    required this.currentIndex,
    required this.isDark,
    required this.navItems,
    required this.onTap,
  });

  @override
  State<LiquidBottomNavSlider> createState() => _LiquidBottomNavSliderState();
}

class _LiquidBottomNavSliderState extends State<LiquidBottomNavSlider> with SingleTickerProviderStateMixin {
  late double _dragPosition;
  bool _isDragging = false;
  late AnimationController _snapController;
  late Animation<double> _snapAnimation;

  @override
  void initState() {
    super.initState();
    _dragPosition = 0.0;
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _snapController.addListener(() {
      setState(() {
        _dragPosition = _snapAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    const double height = 64.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + bottomPad),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          const double thumbWidth = height; 
          final double maxDragPosition = width - thumbWidth;
          final double stepSize = widget.navItems.length > 1 
              ? maxDragPosition / (widget.navItems.length - 1)
              : maxDragPosition;

          if (!_isDragging && !_snapController.isAnimating) {
            _dragPosition = widget.currentIndex * stepSize;
          }

          final double stretchedThumbWidth = _isDragging ? thumbWidth * 1.3 : thumbWidth;
          
          double currentPos = _dragPosition;
          if (_isDragging && currentPos > width - stretchedThumbWidth) {
            currentPos = width - stretchedThumbWidth;
          }

          return GestureDetector(
            onHorizontalDragStart: (details) {
              if (_snapController.isAnimating) _snapController.stop();
              setState(() => _isDragging = true);
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragPosition += details.delta.dx;
                _dragPosition = _dragPosition.clamp(0.0, maxDragPosition);
              });
            },
            onHorizontalDragEnd: (details) {
              setState(() => _isDragging = false);
              
              final int nearestStep = (_dragPosition / stepSize).round().clamp(0, widget.navItems.length - 1);
              final double targetPosition = (nearestStep * stepSize).clamp(0.0, maxDragPosition);

              _snapAnimation = Tween<double>(
                begin: _dragPosition,
                end: targetPosition,
              ).animate(CurvedAnimation(
                parent: _snapController,
                curve: Curves.easeOutBack,
              ));

              _snapController.forward(from: 0.0);
              
              if (nearestStep != widget.currentIndex) {
                widget.onTap(nearestStep);
              }
            },
            onTapDown: (details) {
              final dx = details.localPosition.dx;
              final int nearestStep = (dx / (width / widget.navItems.length)).floor().clamp(0, widget.navItems.length - 1);
              widget.onTap(nearestStep);
            },
            child: SizedBox(
              height: height,
              width: width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(height / 2),
                child: Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? AppTheme.bgDark.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.40),
                          borderRadius: BorderRadius.circular(height / 2),
                          border: Border.all(
                            color: widget.isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : Colors.black.withValues(alpha: 0.07),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.isDark
                                  ? Colors.black.withValues(alpha: 0.25)
                                  : Colors.black.withValues(alpha: 0.08),
                              blurRadius: 32,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(widget.navItems.length, (index) {
                        return SizedBox(
                          width: thumbWidth,
                          height: height,
                          child: Icon(
                            widget.navItems[index].$1,
                            color: widget.isDark ? AppTheme.textMuted : AppTheme.textMutedLight,
                            size: 24,
                          ),
                        );
                      }),
                    ),

                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: currentPos + stretchedThumbWidth / 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.isDark 
                              ? AppTheme.accentGreen.withValues(alpha: 0.1) 
                              : AppTheme.accentGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(height / 2),
                        ),
                      ),
                    ),

                    Positioned(
                      left: currentPos,
                      top: 0,
                      bottom: 0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: stretchedThumbWidth,
                        height: height,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen,
                          borderRadius: BorderRadius.circular(height / 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGreen.withValues(alpha: 0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Builder(
                            builder: (context) {
                              final int nearestStep = (_dragPosition / stepSize).round().clamp(0, widget.navItems.length - 1);
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 150),
                                child: Icon(
                                  widget.navItems[nearestStep].$2,
                                  key: ValueKey(nearestStep),
                                  color: Colors.white,
                                  size: 26,
                                ),
                              );
                            }
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlusButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PlusButton({required this.onTap});

  @override
  State<_PlusButton> createState() => _PlusButtonState();
}

class _PlusButtonState extends State<_PlusButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(
      begin: 1,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          width: 56,
          height: 56,
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
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

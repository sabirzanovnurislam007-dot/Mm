import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_provider.dart';

class FitnessProvider extends ChangeNotifier {
  final HabitProvider habitProvider;
  
  StreamSubscription<StepCount>? _stepCountStream;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusStream;
  
  String _status = 'stopped';
  int _stepsToday = 0;
  int _targetSteps = 10000;
  
  bool _awarded5k = false;
  bool _awarded10k = false;

  FitnessProvider({required this.habitProvider}) {
    _initPedometer();
  }

  String get status => _status;
  int get stepsToday => _stepsToday;
  int get targetSteps => _targetSteps;
  double get stepProgress => (_stepsToday / _targetSteps).clamp(0.0, 1.0);

  Future<void> _initPedometer() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
      );

      _stepCountStream = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
      
      _loadState();
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';
    
    final lastDate = prefs.getString('last_step_date') ?? '';
    if (lastDate != dateKey) {
      // Это новый день
      await prefs.setString('last_step_date', dateKey);
      await prefs.remove('baseline_steps');
      await prefs.setBool('awarded_5k', false);
      await prefs.setBool('awarded_10k', false);
    }
    
    _awarded5k = prefs.getBool('awarded_5k') ?? false;
    _awarded10k = prefs.getBool('awarded_10k') ?? false;
  }

  void _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Получаем базовое значение (первое значение шагов за сегодня)
    int baseline = prefs.getInt('baseline_steps') ?? -1;
    if (baseline == -1) {
      baseline = event.steps;
      await prefs.setInt('baseline_steps', baseline);
    }

    _stepsToday = event.steps - baseline;
    
    // Проверка майлстоунов для XP
    if (_stepsToday >= 5000 && !_awarded5k) {
      _awarded5k = true;
      await prefs.setBool('awarded_5k', true);
      habitProvider.addStepXp(30); // 30 XP за 5к шагов
    }
    
    if (_stepsToday >= 10000 && !_awarded10k) {
      _awarded10k = true;
      await prefs.setBool('awarded_10k', true);
      habitProvider.addStepXp(50); // 50 XP за 10к шагов
    }

    notifyListeners();
  }

  void _onStepCountError(error) {
    _status = 'Step Count API not available';
    notifyListeners();
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    _status = event.status;
    notifyListeners();
  }

  void _onPedestrianStatusError(error) {
    _status = 'Pedestrian Status API not available';
    notifyListeners();
  }

  @override
  void dispose() {
    _stepCountStream?.cancel();
    _pedestrianStatusStream?.cancel();
    super.dispose();
  }
}

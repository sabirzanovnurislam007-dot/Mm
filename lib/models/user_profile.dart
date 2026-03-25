import 'dart:convert';

class UserProfile {
  // Firebase Auth fields
  final String uid;
  final String email;
  final String username;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Game progress fields
  final int xp;
  final int currentLevel;
  final String selectedBadge;

  UserProfile({
    this.uid = '',
    this.email = '',
    this.username = '',
    this.createdAt,
    this.updatedAt,
    this.xp = 0,
    this.currentLevel = 1,
    this.selectedBadge = '👶 Новичок',
  });

  /// Вычисляет сколько XP нужно для следующего уровня (каждый уровень +100 XP)
  int get xpForNextLevel => currentLevel * 100;

  /// Прогресс текущего уровня (от 0.0 до 1.0)
  double get levelProgress {
    final previousLevelXp = (currentLevel - 1) * 100; // Упрощенная формула
    final currentLevelProgressXp = xp - previousLevelXp;
    return (currentLevelProgressXp / (currentLevel * 100)).clamp(0.0, 1.0);
  }

  UserProfile addXp(int amount) {
    int newXp = xp + amount;
    int newLevel = currentLevel;
    String newBadge = selectedBadge;

    while (newXp >= newLevel * 100) {
      newLevel++;
    }

    // Обновляем бейдж в зависимости от уровня
    if (newLevel >= 50) {
      newBadge = '👑 Легенда';
    } else if (newLevel >= 30) {
      newBadge = '🔥 Мастер дисциплины';
    } else if (newLevel >= 20) {
      newBadge = '⚡ Викинг';
    } else if (newLevel >= 10) {
      newBadge = '⚔️ Воин';
    } else if (newLevel >= 5) {
      newBadge = '🏃‍♂️ Ученик';
    }

    return UserProfile(
      xp: newXp,
      currentLevel: newLevel,
      selectedBadge: newBadge,
    );
  }

  UserProfile removeXp(int amount) {
    int newXp = xp - amount;
    if (newXp < 0) newXp = 0;

    int newLevel = 1;
    while (newXp >= newLevel * 100) {
      newLevel++;
    }

    String newBadge = selectedBadge;
    if (newLevel >= 50) {
      newBadge = '👑 Легенда';
    } else if (newLevel >= 30) {
      newBadge = '🔥 Мастер дисциплины';
    } else if (newLevel >= 20) {
      newBadge = '⚡ Викинг';
    } else if (newLevel >= 10) {
      newBadge = '⚔️ Воин';
    } else if (newLevel >= 5) {
      newBadge = '🏃‍♂️ Ученик';
    } else {
      newBadge = '👶 Новичок';
    }

    return UserProfile(
      xp: newXp,
      currentLevel: newLevel,
      selectedBadge: newBadge,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'username': username,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'xp': xp,
    'currentLevel': currentLevel,
    'selectedBadge': selectedBadge,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    uid: json['uid'] as String? ?? '',
    email: json['email'] as String? ?? '',
    username: json['username'] as String? ?? '',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
    xp: json['xp'] as int? ?? 0,
    currentLevel: json['currentLevel'] as int? ?? 1,
    selectedBadge: json['selectedBadge'] as String? ?? '👶 Новичок',
  );

  String encode() => jsonEncode(toJson());
  factory UserProfile.decode(String source) =>
      UserProfile.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

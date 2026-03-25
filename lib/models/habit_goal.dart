import 'dart:convert';


class HabitGoal {
  final String id;
  final String title;
  final String description;
  final int targetDays;
  final int currentDays;
  final DateTime deadline;
  final bool isCompleted;

  HabitGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetDays,
    this.currentDays = 0,
    required this.deadline,
    this.isCompleted = false,
  });

  double get progress => (currentDays / targetDays).clamp(0.0, 1.0);

  HabitGoal copyWith({
    String? title,
    String? description,
    int? targetDays,
    int? currentDays,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return HabitGoal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDays: targetDays ?? this.targetDays,
      currentDays: currentDays ?? this.currentDays,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'targetDays': targetDays,
        'currentDays': currentDays,
        'deadline': deadline.toIso8601String(),
        'isCompleted': isCompleted,
      };

  factory HabitGoal.fromJson(Map<String, dynamic> json) => HabitGoal(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        targetDays: json['targetDays'] as int,
        currentDays: json['currentDays'] as int,
        deadline: DateTime.parse(json['deadline'] as String),
        isCompleted: json['isCompleted'] as bool,
      );

  String encode() => jsonEncode(toJson());
  factory HabitGoal.decode(String source) =>
      HabitGoal.fromJson(jsonDecode(source) as Map<String, dynamic>);
}

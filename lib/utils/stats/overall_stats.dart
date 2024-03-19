import 'dart:async';
import 'package:localstorage/localstorage.dart';

class OverallStats {
  int xp = 0;
  int streak = 0;
  int time = 0; // Time in seconds
  int lessonsCompleted = 0;
  DateTime? lastUpdated; // Track the last time the stats were updated
  Timer? _timer; // Timer to track time spent on the app
  static const String localStorageKey = 'overallStats';

  OverallStats({
    required this.xp,
    required this.streak,
    required this.time,
    required this.lessonsCompleted,
    this.lastUpdated,
  }) {}

  Map<String, dynamic> toJson() {
    return {
      'xp': xp,
      'streak': streak,
      'time': time,
      'lessonsCompleted': lessonsCompleted,
      'lastUpdated':
          lastUpdated?.toIso8601String(), // Convert DateTime to String
    };
  }

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      xp: json['xp'],
      streak: json['streak'],
      time: json['time'],
      lessonsCompleted: json['lessonsCompleted'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null, // Parse String to DateTime
    );
  }

  static Future<OverallStats> loadFromLocalStorage() async {
    final LocalStorage storage = LocalStorage(localStorageKey);
    await storage.ready;
    var storedData = storage.getItem('overallStats');
    if (storedData != null) {
      return OverallStats.fromJson(storedData);
    }
    return OverallStats(xp: 0, streak: 0, time: 0, lessonsCompleted: 0);
  }

  Future<void> saveToLocalStorage() async {
    final LocalStorage storage = LocalStorage(localStorageKey);
    await storage.ready;
    await storage.setItem('overallStats', toJson());
  }

  Future<void> updateScore(int score) async {
    xp += score;
    await updateStreak();
    await saveToLocalStorage();
  }

  Future<void> updateStreak() async {
    final now = DateTime.now();
    if (lastUpdated != null && lastUpdated!.difference(now).inDays == -1) {
      // If last update was yesterday
      streak++;
    } else if (lastUpdated == null ||
        lastUpdated!.difference(now).inDays < -1) {
      // If last update was more than one day ago
      streak = 1;
    }
    lastUpdated = now;
  }

  Future<void> completeLesson() async {
    xp += 10;
    lessonsCompleted++;
    await updateStreak();
    await saveToLocalStorage();
  }
}

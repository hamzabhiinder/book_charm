import 'package:localstorage/localstorage.dart';

class OverallStats {
  int xp = 0;
  int streak = 0;
  int time = 0;
  int lessonsCompleted = 0;

  OverallStats({
    required this.xp,
    required this.streak,
    required this.time,
    required this.lessonsCompleted,
  });

  Map<String, dynamic> toJson() {
    return {
      'xp': xp,
      'streak': streak,
      'time': time,
      'lessonsCompleted': lessonsCompleted,
    };
  }

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      xp: json['xp'],
      streak: json['streak'],
      time: json['time'],
      lessonsCompleted: json['lessonsCompleted'],
    );
  }

  static Future<OverallStats> loadFromLocalStorage(
      String localStorageKey) async {
    final LocalStorage storage = LocalStorage(localStorageKey);
    await storage.ready;
    var storedData = storage.getItem('overallStats');
    if (storedData != null) {
      return OverallStats.fromJson(storedData);
    }
    return OverallStats(xp: 0, streak: 0, time: 0, lessonsCompleted: 0);
  }

  Future<void> saveToLocalStorage(String localStorageKey) async {
    final LocalStorage storage = LocalStorage(localStorageKey);
    await storage.ready;
    await storage.setItem('overallStats', toJson());
  }

  void updateStats(int score) {
    xp += score; // Update XP with the current score
    lessonsCompleted++; // Increment lessons completed
    // You can add more logic for updating streak, time, etc. here if needed
  }
}

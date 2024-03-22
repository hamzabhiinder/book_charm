import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class OverallStats {
  int xp = 0;
  int streak = 0;
  int time = 0; // Time in seconds
  int lessonsCompleted = 0;
  DateTime? lastUpdated; // Track the last time the stats were updated
  List<DateTime> xpUpdates = [];
  List<int> xpChanges = [];
  List<DateTime> streakUpdates = [];
  List<int> streakChanges = [];
  List<DateTime> lessonUpdates = [];
  List<int> lessonChanges = [];
  static const String localStorageKey = 'overallStats';
  Timer? _timer;

  OverallStats({
    required this.xp,
    required this.streak,
    required this.time,
    required this.lessonsCompleted,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'xp': xp,
      'streak': streak,
      'time': time,
      'lessonsCompleted': lessonsCompleted,
      'lastUpdated':
          lastUpdated?.toIso8601String(), // Convert DateTime to String
      'xpUpdates': xpUpdates.map((date) => date.toIso8601String()).toList(),
      'xpChanges': xpChanges,
      'streakUpdates':
          streakUpdates.map((date) => date.toIso8601String()).toList(),
      'streakChanges': streakChanges,
      'lessonUpdates':
          lessonUpdates.map((date) => date.toIso8601String()).toList(),
      'lessonChanges': lessonChanges,
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
    )
      ..xpUpdates = (json['xpUpdates'] as List<dynamic>)
          .map((date) => DateTime.parse(date))
          .toList()
      ..xpChanges = (json['xpChanges'] as List<dynamic>).cast<int>()
      ..streakUpdates = (json['streakUpdates'] as List<dynamic>)
          .map((date) => DateTime.parse(date))
          .toList()
      ..streakChanges = (json['streakChanges'] as List<dynamic>).cast<int>()
      ..lessonUpdates = (json['lessonUpdates'] as List<dynamic>)
          .map((date) => DateTime.parse(date))
          .toList()
      ..lessonChanges = (json['lessonChanges'] as List<dynamic>).cast<int>();
  }

  void addStatsDataToFirestore() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      firestore.collection('Stats').doc(user.uid).set(toJson()).then((value) {
        log('Sample data added to Firestore');
      }).catchError((error) {
        log('Failed to add sample data: $error');
      });
    } else {
      log('User is not authenticated');
    }
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

  static Future<OverallStats> loadStatsData() async {
    OverallStats? statsFromFirestore;
    OverallStats? statsFromLocalStorage;
    try {
      statsFromLocalStorage = await loadFromLocalStorage();
      print('Sucee stats from firestore data');
    } catch (e) {
      print('sucee failed stats from firestore data');
    }
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot =
            await firestore.collection('Stats').doc(user.uid).get();
        if (snapshot.exists) {
          OverallStats statsFromServer =
              OverallStats.fromJson(snapshot.data() as Map<String, dynamic>);

          // Compare timestamps
          if (statsFromLocalStorage?.lastUpdated != null &&
              statsFromServer.lastUpdated != null &&
              statsFromLocalStorage!.lastUpdated!
                      .compareTo(statsFromServer.lastUpdated!) >
                  0) {
            statsFromFirestore =
                statsFromLocalStorage; // Local data is more recent
          } else {
            statsFromFirestore = statsFromServer;
          }
        }
      }
    } catch (error) {
      log('Failed to load stats data from Firestore: $error');
    }
    return statsFromFirestore ??
        statsFromLocalStorage ??
        await loadFromLocalStorage();
  }

  Future<void> saveToLocalStorage() async {
    final LocalStorage storage = LocalStorage(localStorageKey);
    await storage.ready;
    await storage.setItem('overallStats', toJson());
    try {
      addStatsDataToFirestore();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> updateScore(int score) async {
    xp += score;
    xpUpdates.add(DateTime.now());
    xpChanges.add(score);
    await updateStreak();

    await saveToLocalStorage();
  }

  Future<void> updateStreak() async {
    final now = DateTime.now();
    if (lastUpdated != null && lastUpdated!.difference(now).inDays == -1) {
      // If last update was yesterday
      streak++;
      streakUpdates.add(now);
      streakChanges.add(1);
    } else if (lastUpdated == null ||
        lastUpdated!.difference(now).inDays < -1) {
      // If last update was more than one day ago
      streak = 1;
      streakUpdates.add(now);
      streakChanges.add(1);
    }
    lastUpdated = now;
  }

  Future<void> completeLesson() async {
    xp += 10;
    lessonsCompleted++;
    xpUpdates.add(DateTime.now());
    xpChanges.add(10);
    lessonUpdates.add(DateTime.now());
    lessonChanges.add(1);
    await updateStreak();
    await saveToLocalStorage();
  }

  Map<String, dynamic> calculateLastSectionStats(String timeFrame) {
    DateTime currentTime = DateTime.now();
    DateTime startTime;

    switch (timeFrame) {
      case 'today':
        startTime =
            DateTime(currentTime.year, currentTime.month, currentTime.day);
        break;
      case 'this week':
        startTime =
            currentTime.subtract(Duration(days: currentTime.weekday - 1));
        break;
      case 'all time':
        // Set start time to the earliest possible date
        startTime = DateTime(0);
        break;
      default:
        throw ArgumentError('Invalid time frame: $timeFrame');
    }

    int xpInSection = 0;
    int streakChangesInSection = 0;
    int lessonChangesInSection = 0;

    for (int i = 0; i < xpUpdates.length; i++) {
      if (xpUpdates[i].isAfter(startTime) &&
          xpUpdates[i].isBefore(currentTime)) {
        xpInSection += xpChanges[i];
      }
    }

    for (int i = 0; i < streakUpdates.length; i++) {
      if (streakUpdates[i].isAfter(startTime) &&
          streakUpdates[i].isBefore(currentTime)) {
        streakChangesInSection += streakChanges[i];
      }
    }

    for (int i = 0; i < lessonUpdates.length; i++) {
      if (lessonUpdates[i].isAfter(startTime) &&
          lessonUpdates[i].isBefore(currentTime)) {
        lessonChangesInSection += lessonChanges[i];
      }
    }

    return {
      'xpInSection': xpInSection,
      'streakChangesInSection': streakChangesInSection,
      'lessonChangesInSection': lessonChangesInSection,
    };
  }
}
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:localstorage/localstorage.dart';

// class OverallStats {
//   int xp = 0;
//   int streak = 0;
//   int time = 0; // Time in seconds
//   int lessonsCompleted = 0;
//   DateTime? lastUpdated; // Track the last time the stats were updated
//   List<DateTime> xpUpdates = [];
//   List<int> xpChanges = [];
//   List<DateTime> streakUpdates = [];
//   List<int> streakChanges = [];
//   List<DateTime> lessonUpdates = [];
//   List<int> lessonChanges = [];
//   static const String localStorageKey = 'overallStats';
//   Timer? _timer;

//   final CollectionReference _statsCollection = FirebaseFirestore.instance.collection('overallStats');

//   OverallStats({
//     required this.xp,
//     required this.streak,
//     required this.time,
//     required this.lessonsCompleted,
//     this.lastUpdated,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'xp': xp,
//       'streak': streak,
//       'time': time,
//       'lessonsCompleted': lessonsCompleted,
//       'lastUpdated': lastUpdated?.toIso8601String(), // Convert DateTime to String
//       'xpUpdates': xpUpdates.map((date) => date.toIso8601String()).toList(),
//       'xpChanges': xpChanges,
//       'streakUpdates': streakUpdates.map((date) => date.toIso8601String()).toList(),
//       'streakChanges': streakChanges,
//       'lessonUpdates': lessonUpdates.map((date) => date.toIso8601String()).toList(),
//       'lessonChanges': lessonChanges,
//     };
//   }

//   factory OverallStats.fromJson(Map<String, dynamic> json) {
//     return OverallStats(
//       xp: json['xp'],
//       streak: json['streak'],
//       time: json['time'],
//       lessonsCompleted: json['lessonsCompleted'],
//       lastUpdated: json['lastUpdated'] != null
//           ? DateTime.parse(json['lastUpdated'])
//           : null, // Parse String to DateTime
//     )
//       ..xpUpdates = (json['xpUpdates'] as List<dynamic>).map((date) => DateTime.parse(date)).toList()
//       ..xpChanges = (json['xpChanges'] as List<dynamic>).cast<int>()
//       ..streakUpdates = (json['streakUpdates'] as List<dynamic>).map((date) => DateTime.parse(date)).toList()
//       ..streakChanges = (json['streakChanges'] as List<dynamic>).cast<int>()
//       ..lessonUpdates = (json['lessonUpdates'] as List<dynamic>).map((date) => DateTime.parse(date)).toList()
//       ..lessonChanges = (json['lessonChanges'] as List<dynamic>).cast<int>();
//   }

//   static Future<OverallStats> loadFromLocalStorage() async {
//     final LocalStorage storage = LocalStorage(localStorageKey);
//     await storage.ready;
//     var storedData = storage.getItem('overallStats');
//     if (storedData != null) {
//       return OverallStats.fromJson(storedData);
//     }
//     return OverallStats(xp: 0, streak: 0, time: 0, lessonsCompleted: 0);
//   }

//   Future<void> saveToLocalStorage() async {
//     final LocalStorage storage = LocalStorage(localStorageKey);
//     await storage.ready;
//     await storage.setItem('overallStats', toJson());
//   }

//   Future<void> saveToFirestore() async {
//     try {
//       await _statsCollection.doc(FirebaseAuth.instance.currentUser?.uid).set(toJson());
//     } catch (e) {
//       print('Error saving to Firestore: $e');
//     }
//   }

//   Future<void> startTimer() async {
//     _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
//       time++;
//       lastUpdated = DateTime.now();
//       saveToLocalStorage();
//       saveToFirestore();
//     });
//   }

//   Future<void> stopTimer() async {
//     _timer?.cancel();
//     _timer = null;
//     lastUpdated = DateTime.now();
//     saveToLocalStorage();
//     saveToFirestore();
//   }

//   Future<void> updateScore(int score) async {
//     xp += score;
//     xpUpdates.add(DateTime.now());
//     xpChanges.add(score);
//     await updateStreak();
//     await saveToLocalStorage();
//     await saveToFirestore();
//   }

//   Future<void> updateStreak() async {
//     final now = DateTime.now();
//     if (lastUpdated != null && lastUpdated!.difference(now).inDays == -1) {
//       // If last update was yesterday
//       streak++;
//       streakUpdates.add(now);
//       streakChanges.add(1);
//     } else if (lastUpdated == null || lastUpdated!.difference(now).inDays < -1) {
//       // If last update was more than one day ago
//       streak = 1;
//       streakUpdates.add(now);
//       streakChanges.add(1);
//     }
//     lastUpdated = now;
//   }

//   Future<void> completeLesson() async {
//     xp += 10;
//     lessonsCompleted++;
//     xpUpdates.add(DateTime.now());
//     xpChanges.add(10);
//     lessonUpdates.add(DateTime.now());
//     lessonChanges.add(10);
//     await updateStreak();
//     await saveToLocalStorage();
//     await saveToFirestore();
//   }

//   Map<String, dynamic> calculateLastSectionStats(String timeFrame) {
//     DateTime currentTime = DateTime.now();
//     DateTime startTime;

//     switch (timeFrame) {
//       case 'today':
//         startTime = DateTime(currentTime.year, currentTime.month, currentTime.day);
//         break;
//       case 'this week':
//         startTime = currentTime.subtract(Duration(days: currentTime.weekday - 1));
//         break;
//       case 'all time':
//         // Set start time to the earliest possible date
//         startTime = DateTime(0);
//         break;
//       default:
//         throw ArgumentError('Invalid time frame: $timeFrame');
//     }

//     int xpInSection = 0;
//     int streakChangesInSection = 0;
//     int lessonChangesInSection = 0;

//     for (int i = 0; i < xpUpdates.length; i++) {
//       if (xpUpdates[i].isAfter(startTime) && xpUpdates[i].isBefore(currentTime)) {
//         xpInSection += xpChanges[i];
//       }
//     }

//     for (int i = 0; i < streakUpdates.length; i++) {
//       if (streakUpdates[i].isAfter(startTime) && streakUpdates[i].isBefore(currentTime)) {
//         streakChangesInSection += streakChanges[i];
//       }
//     }

//     for (int i = 0; i < lessonUpdates.length; i++) {
//       if (lessonUpdates[i].isAfter(startTime) && lessonUpdates[i].isBefore(currentTime)) {
//         lessonChangesInSection += lessonChanges[i];
//       }
//     }

//     return {
//       'xpInSection': xpInSection,
//       'streakChangesInSection': streakChangesInSection,
//       'lessonChangesInSection': lessonChangesInSection,
//     };
//   }
// }

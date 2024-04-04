import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerUtils {
  static late Stopwatch _stopwatch;
  static bool _isPaused = false;
  static Map<String, Duration> updatedTimes = {};
  static List<double> calculateDurationOfPastSevenDays() {
    List<double> durations = [];
    DateTime today = DateTime.now();
    DateTime sevenDaysAgo = today.subtract(const Duration(days: 6));
    log('drt: ${updatedTimes.toString()}');
    for (int i = 0; i < 7; i++) {
      String date =
          "${sevenDaysAgo.year}-${sevenDaysAgo.month.toString().padLeft(2, '0')}-${sevenDaysAgo.day.toString().padLeft(2, '0')}";
      log('drt: ${date.toString()}');
      if (updatedTimes.containsKey(date)) {
        durations.add(updatedTimes[date]!.inMinutes.toDouble() / 10);
      } else {
        durations.add(0);
      }
      sevenDaysAgo = sevenDaysAgo.add(const Duration(days: 1));
    }
    log('drt: ${durations.toString()}');
    return durations;
  }

  static Future<void> startTimer() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final timerData = await loadScreenTimesFromFirebase(user.uid);
      log('timerData before _startTimerFromLoadedData $timerData');
      if (timerData.isNotEmpty) {
        updatedTimes = timerData;
        _startTimerFromLoadedData();
        log('timerData After _startTimerFromLoadedData $timerData');
      } else {
        _startTimerFromZero();
      }
    } else {
      _startTimerFromZero();
    }
  }

  static void _startTimerFromLoadedData() {
    _stopwatch = Stopwatch();
    _saveScreenTime().then((_) => _stopwatch.reset());

    Timer.periodic(const Duration(seconds: 50), (Timer t) {
      final user = FirebaseAuth.instance.currentUser;
      if (!_isPaused && user != null) {
        _saveScreenTime().then((_) => _stopwatch.reset());
      }
    });
    _stopwatch.start();
  }

  static void _startTimerFromZero() {
    _stopwatch = Stopwatch();
    _saveScreenTime().then((_) => _stopwatch.reset());
    Timer.periodic(const Duration(seconds: 50), (Timer t) {
      final user = FirebaseAuth.instance.currentUser;
      if (!_isPaused && user != null) {
        _saveScreenTime().then((_) => _stopwatch.reset());
      }
    });
    _stopwatch.start();
  }

  static void pauseTimer() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _isPaused = true;
    }
  }

  static void resumeTimer() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _isPaused = false;
    }
  }

  static Future<void> _saveScreenTime() async {
    final screenTimes = await loadScreenTimes();
    final String currentDate = getCurrentDateString();
    final Duration currentDuration = screenTimes[currentDate] ?? Duration.zero;
    final Duration newDuration = currentDuration + _stopwatch.elapsed;
    screenTimes[currentDate] = newDuration;
    saveScreenTimes(screenTimes);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      try {
        await FirebaseFirestore.instance
            .collection('timers')
            .doc(userId)
            .update({
          'screen_times.$currentDate': newDuration.inMilliseconds,
        });
        print('Screen time data updated in Firebase for user: $userId');
      } catch (e) {
        print('Error updating screen time data in Firebase: $e');
      }
    }
  }

  static Future<Map<String, Duration>> loadScreenTimesFromFirebase(
    String userId,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('timers')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final jsonMap = data['screen_times'] as Map<String, dynamic>?;

        if (jsonMap != null) {
          final screenTimes = jsonMap.map(
            (key, value) => MapEntry(
              key,
              Duration(milliseconds: value as int),
            ),
          );
          return screenTimes;
        }
      }
    } catch (e) {
      print('Error loading screen times from Firebase: $e');
    }
    return {};
  }

  static Future<void> saveScreenTimes(Map<String, Duration> screenTimes) async {
    updatedTimes = screenTimes;
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = screenTimes.map((key, value) {
      return MapEntry(key, value.inMilliseconds);
    });
    prefs.setString('screen_times', json.encode(jsonMap));
  }

  static Future<Map<String, Duration>> loadScreenTimes() async {
    Map<String, Duration> myData = {};
    await SharedPreferences.getInstance().then((prefs) {
      final storedData = prefs.getString('screen_times');
      log("storedData.toString $storedData");
      if (storedData != null) {
        final Map<String, dynamic>? jsonMap = json.decode(storedData);
        if (jsonMap != null) {
          myData = jsonMap.map((key, value) {
            return MapEntry(key, Duration(milliseconds: value));
          });
        }
      }
    }).catchError((error) {
      print('Error loading screen times: $error');
    });
    return myData;
  }

  static String getCurrentDateString() {
    return DateTime.now().toString().substring(0, 10);
  }

  static Duration getTotalDuration() {
    Duration totalDuration = Duration.zero;
    for (var duration in updatedTimes.values) {
      totalDuration += duration;
    }
    return totalDuration;
  }

  static Duration getDurationOfCurrentWeek() {
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    DateTime sunday = monday.add(const Duration(days: 6));
    Duration weekDuration = Duration.zero;
    updatedTimes.forEach((dateString, duration) {
      DateTime date = getDateTimeFromString(dateString);
      if (date.isAfter(monday.subtract(const Duration(days: 1))) &&
          date.isBefore(sunday.add(Duration(days: 1)))) {
        weekDuration += duration;
      }
    });
    return weekDuration;
  }

  static DateTime getDateTimeFromString(String dateString) {
    return DateTime.parse(dateString);
  }
}

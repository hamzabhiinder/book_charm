import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:book_charm/utils/stats/screenTime.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getCurrentDateString() {
  DateTime currentDate = DateTime.now();
  return '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${(currentDate.day - 1).toString().padLeft(2, '0')}';
}

DateTime getDateTimeFromString(String dateString) {
  List<String> dateParts = dateString.split('-');
  int year = int.parse(dateParts[0]);
  int month = int.parse(dateParts[1]);
  int day = int.parse(dateParts[2]);
  return DateTime(year, month, day);
}

Future<void> saveScreenTimes(Map<String, Duration> screenTimes) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonMap = screenTimes.map((key, value) {
    return MapEntry(key, value.inMilliseconds);
  });
  prefs.setString('screen_times', json.encode(jsonMap));
}

Future<Map<String, Duration>> loadScreenTimes() async {
  Map<String, Duration> myData = {};
  await SharedPreferences.getInstance().then((prefs) {
    final storedData = prefs.getString('screen_times');
    log(storedData.toString());
    if (storedData != null) {
      final Map<String, dynamic>? jsonMap = json.decode(storedData) ?? {};
      myData = jsonMap!.map((key, value) {
        return MapEntry(key, Duration(milliseconds: value));
      });
    }
  }).catchError((error) {
    print('Error loading screen times: $error');
  });
  return myData;
}

class TimerUtils {
  static late Stopwatch _stopwatch;
  static bool _isPaused = false;
  static Map<String, Duration> updatedTimes = {};
  static void startTimer() {
    _stopwatch = Stopwatch();
    _saveScreenTime().then((value) => _stopwatch.reset());
    Timer.periodic(const Duration(seconds: 50), (Timer t) {
      if (!_isPaused) {
        _saveScreenTime().then((value) => _stopwatch.reset());
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
    updatedTimes = screenTimes;
    saveScreenTimes(screenTimes);
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
}

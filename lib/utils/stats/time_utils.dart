import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

String getCurrentDateString() {
  DateTime currentDate = DateTime.now();
  return '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
}

DateTime getDateTimeFromString(String dateString) {
  List<String> dateParts = dateString.split('-');
  int year = int.parse(dateParts[0]);
  int month = int.parse(dateParts[1]);
  int day = int.parse(dateParts[2]) - 2;
  return DateTime(year, month, day);
}

// Function to load screen times from local storage
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

// Function to save screen times to local storage
Future<void> saveScreenTimes(Map<String, Duration> screenTimes) async {
  // if (screenTimes != null) return;
  final prefs = await SharedPreferences.getInstance();
  final jsonMap = screenTimes.map((key, value) {
    return MapEntry(key, value.inMilliseconds);
  });
  prefs.setString('screen_times', json.encode(jsonMap));
}

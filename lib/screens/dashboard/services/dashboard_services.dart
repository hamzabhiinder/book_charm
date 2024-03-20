import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimeTrackerService(),
      child: MaterialApp(
        home: TimeTrackerPage(),
      ),
    );
  }
}

class TimeTrackerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timeTrackerService = Provider.of<TimeTrackerService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Tracker'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CounterDisplayPage()),
            );
          },
          child: Text('Show Counter'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class CounterDisplayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final timeTrackerService = Provider.of<TimeTrackerService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter Display'),
      ),
      body: Center(
        child: Text(
          'Time Spent in App: ${formatDuration(timeTrackerService.getTimeSpentInApp())}',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
}



class TimeTrackerService with WidgetsBindingObserver, ChangeNotifier {
  late DateTime _appStartTime;
  late Timer _timer;
  Duration _timeSpentInApp = Duration.zero;
  bool _appPaused = false;
  bool _timerRunning = false;
  late SharedPreferences _prefs;

  TimeTrackerService() {
    WidgetsBinding.instance.addObserver(this);
    _initializeTimer();
  }

  Future<void> _initializeTimer() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTime = _prefs.getInt('timeSpentInApp');
    if (savedTime != null) {
      _timeSpentInApp = Duration(milliseconds: savedTime);
    }
    if (!_appPaused) {
      startTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      _resumeTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopTimer();
    super.dispose();
  }

  Future<void> _saveTimeSpentInApp() async {
    await _prefs.setInt('timeSpentInApp', _timeSpentInApp.inMilliseconds);
  }

  void startTimer({DateTime? appStartTime}) {
    _appStartTime = appStartTime ?? DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), _updateTimeSpent);
    _timerRunning = true;
  }

  void _pauseTimer() {
    if (_timerRunning) {
      _timer.cancel();
      _timerRunning = false;
      _saveTimeSpentInApp();
      _appPaused = true;
    }
  }

  void _resumeTimer() {
    if (_appPaused) {
      _appPaused = false;
      final pauseDuration = DateTime.now().difference(_appStartTime);
      final storedTime = _prefs.getInt('timeSpentInApp');
      if (storedTime != null) {
        _appStartTime =
            DateTime.now().subtract(Duration(milliseconds: storedTime));
      } else {
        _appStartTime = DateTime.now().subtract(pauseDuration);
      }
      startTimer(appStartTime: _appStartTime);
    }
  }

  void stopTimer() {
    if (_timerRunning) {
      _timer.cancel();
      _timerRunning = false;
      _saveTimeSpentInApp();
    }
  }

  Duration getTimeSpentInApp() {
    return _timeSpentInApp;
  }

  void _updateTimeSpent(Timer timer) {
    _timeSpentInApp = DateTime.now().difference(_appStartTime);
    notifyListeners(); // Notify listeners when time changes
  }
}

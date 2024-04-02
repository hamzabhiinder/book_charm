// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:book_charm/utils/stats/time_utils.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class TimeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Home')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => SecondScreen()),
//             );
//           },
//           child: Text('Open Second Screen'),
//         ),
//       ),
//     );
//   }
// }

// class SecondScreen extends StatefulWidget {
//   @override
//   _SecondScreenState createState() => _SecondScreenState();
// }

// class _SecondScreenState extends State<SecondScreen>
//     with WidgetsBindingObserver {
//   var prevTime;

//   late Timer _timer;
//   late Stopwatch _stopwatch;
//   bool _isPaused = false;
//   @override
//   void initState() {
//     super.initState();
//     _stopwatch = Stopwatch();
//     _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
//       if (!_isPaused) {
//         setState(() {});
//       }

//       loadScreenTimes().then((value) => prevTime = value);
//     });
//     _stopwatch.start();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _timer.cancel();
//     _stopwatch.stop();
//     _saveScreenTime();
//     WidgetsBinding.instance.removeObserver(this);
//   }

//   void _pauseStopwatch() {
//     if (_stopwatch.isRunning) {
//       _stopwatch.stop();
//       _isPaused = true;
//     }
//   }

//   void _resumeStopwatch() {
//     if (!_stopwatch.isRunning) {
//       _stopwatch.start();
//       _isPaused = false;
//     }
//   }

//   void _saveScreenTime() async {
//     final screenTimes = await loadScreenTimes();
//     final String currentDate = getCurrentDateString();
//     final Duration currentDuration = screenTimes[currentDate] ?? Duration.zero;
//     final Duration newDuration = currentDuration + _stopwatch.elapsed;
//     screenTimes[currentDate] = newDuration;
//     // screenTimes.remove("SecondScreen");
//     saveScreenTimes(screenTimes);
//     log("Save Screen ");
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       _pauseStopwatch();
//     } else if (state == AppLifecycleState.resumed) {
//       _resumeStopwatch();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Second Screen')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Second Screen ${_stopwatch.elapsed.inSeconds} seconds'),
//             Text(
//                 'PrevTime: ${prevTime?[getCurrentDateString()]?.inSeconds.toString() ?? '0'}'),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _pauseStopwatch,
//                   child: Text('Pause'),
//                 ),
//                 SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: _resumeStopwatch,
//                   child: Text('Resume'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

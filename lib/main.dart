import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:book_charm/firebase_options.dart';
import 'package:book_charm/games/games.dart';
import 'package:book_charm/providers/signin_provider.dart';
import 'package:book_charm/screens/authentication/services/auth1/auth_sevices1.dart';
import 'package:book_charm/screens/authentication/view/signup_screen.dart';
import 'package:book_charm/screens/authentication/view/splash_screen.dart';
import 'package:book_charm/screens/bottom_navigation/bottom_navigation.dart';
import 'package:book_charm/screens/dashboard/services/dashboard_services.dart';
import 'package:book_charm/screens/exercise/view/exercise.dart';
import 'package:book_charm/screens/games/book_reading_screen.dart';
import 'package:book_charm/screens/home/view/dictionary_screen.dart';
import 'package:book_charm/screens/home/view/downloaded_books_screen.dart';
import 'package:book_charm/screens/home/view/home_screen.dart';
import 'package:book_charm/screens/home/view/library_screen.dart';
import 'package:book_charm/screens/home/widgets/upload_book.dart';
import 'package:book_charm/screens/pdf_viewer/pdf_viewer_screen.dart';
import 'package:book_charm/utils/stats/screenTime.dart';
import 'package:book_charm/utils/stats/time_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/internet_provider.dart';
import 'screens/profile/view/profile.dart';
import 'screens/profile/view/widget/language_selector.dart';
import 'utils/show_snackBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Timer _timer;
  late Stopwatch _stopwatch;
  bool _isPaused = false;
  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(Duration(seconds: 50), (Timer t) {
      if (!_isPaused) {
        _saveScreenTime().then((value) => _stopwatch.reset());
        setState(() {});
      }
    });
    _stopwatch.start();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _stopwatch.stop();
    _saveScreenTime();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _pauseStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _isPaused = true;
    }
  }

  void _resumeStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _isPaused = false;
    }
  }

  Future<void> _saveScreenTime() async {
    final screenTimes = await loadScreenTimes();
    final String currentDate = getCurrentDateString();
    final Duration currentDuration = screenTimes[currentDate] ?? Duration.zero;
    final Duration newDuration = currentDuration + _stopwatch.elapsed;
    screenTimes[currentDate] = newDuration;
    saveScreenTimes(screenTimes);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseStopwatch();
    } else if (state == AppLifecycleState.resumed) {
      _resumeStopwatch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => SignInProvider()),
        ),
        ChangeNotifierProvider(
          create: ((context) => InternetProvider()),
        ),
        ChangeNotifierProvider(
          create: (_) => TimeTrackerService(),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider()..loadSelectedLanguage(),
        ),
        ChangeNotifierProvider(
          create: (_) => LibraryProvider()..loadJsonDataFunction(context),
        ),
        ChangeNotifierProvider(
          create: (_) => DictionaryProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UploadProvider(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
        // home: const PdfViewerScreen(),
      ),
    );
  }
}

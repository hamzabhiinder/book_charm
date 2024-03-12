import 'dart:developer';
import 'dart:io';

import 'package:book_charm/firebase_options.dart';
import 'package:book_charm/games/games.dart';
import 'package:book_charm/providers/signin_provider.dart';
import 'package:book_charm/screens/authentication/services/auth1/auth_sevices1.dart';
import 'package:book_charm/screens/authentication/view/signup_screen.dart';
import 'package:book_charm/screens/authentication/view/splash_screen.dart';
import 'package:book_charm/screens/bottom_navigation/bottom_navigation.dart';
import 'package:book_charm/screens/exercise/view/exercise.dart';
import 'package:book_charm/screens/games/book_reading_screen.dart';
import 'package:book_charm/screens/home/view/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/internet_provider.dart';
import 'screens/profile/view/profile.dart';
import 'utils/show_snackBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        home: const SplashScreen(),
        // home: const GameScreen(),
      ),
    );
  }
}

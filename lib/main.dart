import 'dart:developer';
import 'dart:io';

import 'package:book_charm/firebase_options.dart';
import 'package:book_charm/games/games.dart';
import 'package:book_charm/providers/signin_provider.dart';
import 'package:book_charm/screens/authentication/services/auth1/auth_sevices1.dart';
import 'package:book_charm/screens/authentication/view/signup_screen.dart';
import 'package:book_charm/screens/bottom_navigation/bottom_navigation.dart';
import 'package:book_charm/screens/exercise/view/exercise.dart';
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
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        home: HandleLogin(),
        // home: const GameScreen(),
      ),
    );
  }
}

class HandleLogin extends StatefulWidget {
  const HandleLogin({super.key});

  @override
  State<HandleLogin> createState() => _HandleLoginState();
}

class _HandleLoginState extends State<HandleLogin> {
  Future<bool> isUserSignedIn() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      return user != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: isUserSignedIn(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                final sp = context.read<SignInProvider>();
                sp.getDataFromSharedPreferences();

                log('user ${user.email}');
                return BottomNaigationScreen();
              } else {
                return const AuthenticationScreen();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

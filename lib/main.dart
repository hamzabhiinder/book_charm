import 'dart:developer';
import 'dart:io';

import 'package:book_charm/firebase_options.dart';
import 'package:book_charm/games/games.dart';
import 'package:book_charm/providers/signin_provider.dart';
import 'package:book_charm/screens/authentication/services/auth1/auth_sevices1.dart';
import 'package:book_charm/screens/authentication/view/signup_screen.dart';
import 'package:book_charm/screens/games/book_reading_screen.dart';
import 'package:book_charm/screens/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/internet_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const BookReadingScreen(),
        // home: const AuthenticationScreen(),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                final sp = context.read<SignInProvider>();
                sp.getDataFromSharedPreferences();
                // if (user.isEmailVerified) {
                //   devtools.log(" VERIFY EMAIL");
                //   return NotesView();
                // } else {
                //   devtools.log("NOt VERIFY EMAIL");
                //   return const VerifyEmail();
                // }
                log('user ${user.email}');
                return HomeScreen();
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

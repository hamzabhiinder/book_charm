import 'dart:async';
import 'dart:developer';

import 'package:book_charm/screens/authentication/view/signup_screen.dart';
import 'package:book_charm/screens/profile/view/widget/language_selector.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/signin_provider.dart';
import '../../bottom_navigation/bottom_navigation.dart';
import '../services/auth1/auth_sevices1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animation
    _logoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Text animation
    _textAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeIn),
      ),
    );

    // Start the animation
    _controller.forward();

    // Delay for 2 seconds and then navigate to the login screen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HandleLogin()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _logoAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0, 0.5, curve: Curves.easeIn),
                    ),
                  ),
                  child: Image.asset(
                    'assets/icons/logo1.png',
                    width: 120,
                    height: 120,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _textAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.5, 1, curve: Curves.easeIn),
                    ),
                  ),
                  child: const Text(
                    'BOOK CHARM',
                    style: TextStyle(
                      fontSize: 24,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
                final languageProvider = context.read<LanguageProvider>();
                sp.getDataFromSharedPreferences();
                languageProvider.loadSelectedLanguage();
                log('user ${user.email}  ${languageProvider.selectedLanguageName}');
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

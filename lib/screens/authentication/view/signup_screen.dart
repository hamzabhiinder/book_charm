import 'package:book_charm/providers/signin_provider.dart';
import 'package:book_charm/screens/authentication/services/authentication_service.dart';
import 'package:book_charm/utils/round_button.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: getResponsiveWidth(context, 15)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: getResponsiveHeight(context, 50),
              ),
              Row(
                // crossAxisAlignment: CrossAxisAlignment,
                children: [
                  Image.asset(
                    'assets/icons/logo1.png',
                    width: getResponsiveWidth(context, 100),
                    height: getResponsiveHeight(context, 100),
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BookCharm',
                    style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 28),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: AppColors.primaryColor,
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Register'),
                  Tab(text: 'Sign In'),
                ],
              ),
              SizedBox(
                height: getResponsiveHeight(context, 500),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    RegisterTab(),
                    SignInTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterTab extends StatelessWidget {
  RegisterTab({super.key});

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: getResponsiveWidth(context, 15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              AuthServices.signupWithEmailAndPassword(
                context,
                _nameController.text,
                _email.text,
                _password.text,
              );
            },
            child: const Text('Register'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(Icons.facebook),
              GestureDetector(
                onTap: () async {
                  AuthServices.handleFacebookAuth(context);
                },
                child: const Image(
                  image: AssetImage('assets/icons/facebook_icon.png'),
                  height: 40,
                ),
              ),

              const SizedBox(width: 20),
              GestureDetector(
                onTap: () async {
                  // FirebaseAuthMethods(FirebaseAuth.instance)
                  //     .signInWithGoogle(context);
                  AuthServices.handleGoogleSignIn(context);
                },
                child: const Image(
                  image: AssetImage('assets/icons/google_icon.png'),
                  height: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SignInTab extends StatelessWidget {
  SignInTab({super.key});

  final TextEditingController _email =
      TextEditingController(text: "hamzabhinder5@gmail.com");
  final TextEditingController _password = TextEditingController(text: '123456');
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: getResponsiveHeight(context, 60)),
          Consumer<SignInProvider>(
            builder: (context, value, child) {
              return RoundElevatedButton(
                loading: value.isSignedInLoading,
                width: MediaQuery.of(context).size.width * 0.6,
              borderRadius: 15,
                title: 'SIGN IN',
                onPress: value.isSignedInLoading
                    ? null
                    : () {
                        AuthServices.signinWithEmailAndPassword(
                          context,
                          _email.text,
                          _password.text,
                        );
                      },
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(Icons.facebook),
              GestureDetector(
                onTap: () async {
                  AuthServices.handleFacebookAuth(context);
                },
                child: const Image(
                  image: AssetImage('assets/icons/facebook_icon.png'),
                  height: 40,
                ),
              ),

              const SizedBox(width: 20),
              GestureDetector(
                onTap: () async {
                  // FirebaseAuthMethods(FirebaseAuth.instance)
                  //     .signInWithGoogle(context);
                  AuthServices.handleGoogleSignIn(context);
                },
                child: const Image(
                  image: AssetImage('assets/icons/google_icon.png'),
                  height: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

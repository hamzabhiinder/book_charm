import 'package:book_charm/providers/signin_provider.dart';
import 'package:book_charm/screens/authentication/services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      appBar: AppBar(
        toolbarHeight: kTextTabBarHeight,
        title: const Row(
          children: [
            Icon(Icons.book),
            SizedBox(width: 8),
            Text(
              'BookCharm',
              style: TextStyle(fontSize: 34),
            ),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Register'),
            Tab(text: 'Sign In'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RegisterTab(),
          SignInTab(),
        ],
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            decoration: InputDecoration(labelText: 'Password'),
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
                child: Image(
                  image: AssetImage('assets/icons/facebook_icon.png'),
                  height: 40,
                ),
              ),

              SizedBox(width: 20),
              GestureDetector(
                onTap: () async {
                  // FirebaseAuthMethods(FirebaseAuth.instance)
                  //     .signInWithGoogle(context);
                  AuthServices.handleGoogleSignIn(context);
                },
                child: Image(
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

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
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
            decoration: InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              AuthServices.signinWithEmailAndPassword(
                context,
                _email.text,
                _password.text,
              );
            },
            child: const Text('Sign In'),
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
                child: Image(
                  image: AssetImage('assets/icons/facebook_icon.png'),
                  height: 40,
                ),
              ),

              SizedBox(width: 20),
              GestureDetector(
                onTap: () async {
                  // FirebaseAuthMethods(FirebaseAuth.instance)
                  //     .signInWithGoogle(context);
                  AuthServices.handleGoogleSignIn(context);
                },
                child: Image(
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

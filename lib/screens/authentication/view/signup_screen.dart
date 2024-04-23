import 'package:book_charm/providers/signin_provider.dart';
import 'package:book_charm/screens/authentication/services/authentication_service.dart';
import 'package:book_charm/screens/authentication/view/forgot_password.dart';
import 'package:book_charm/utils/round_button.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Row(
          // crossAxisAlignment: CrossAxisAlignment,
          children: [
            Image.asset(
              'assets/icons/logo1.png',
              width: getResponsiveWidth(context, 80),
              height: getResponsiveHeight(context, 80),
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
        bottom: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: AppColors.primaryColor,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Register'),
            Tab(text: 'Sign In'),
          ],
        ),
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: getResponsiveWidth(context, 15)),
        child: TabBarView(
          controller: _tabController,
          children: [
            RegisterTab(
              formKey: _signUpFormKey,
            ),
            SignInTab(
              formKey: _signInFormKey,
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  RegisterTab({super.key, required this.formKey});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  ValueNotifier<bool> showPassword = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensures that the content moves up when the keyboard appears
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getResponsiveWidth(context, 15)),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r' '))
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Simple email regex validation
                    if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: showPassword,
                  builder: (context, isPasswordVisible, child) {
                    return TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                              onPressed: () {
                                // Toggle password visibility
                                showPassword.value = !isPasswordVisible;
                              },
                              icon: !isPasswordVisible
                                  ? Image.asset('assets/icons/hide.png',
                                      height: 20)
                                  : Image.asset('assets/icons/view.png',
                                      height: 20))),
                      obscureText: !isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password should be at least 6 characters';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                Consumer<SignInProvider>(
                  builder: (context, value, child) {
                    return RoundElevatedButton(
                      loading: value.isSignedInLoading,
                      width: MediaQuery.of(context).size.width * 0.6,
                      borderRadius: 25,
                      title: 'REGISTER',
                      onPress: value.isSignedInLoading
                          ? () {}
                          : () {
                              if (formKey.currentState?.validate() ?? false) {
                                // Form is valid; proceed with registration
                                AuthServices.signupWithEmailAndPassword(
                                  context,
                                  _nameController.text,
                                  _emailController.text,
                                  _passwordController.text,
                                );
                              }
                            },
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
          ),
        ),
      ),
    );
  }
}

class SignInTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  SignInTab({super.key, required this.formKey});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  ValueNotifier<bool> showPassword = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r' '))
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // A simple email regex validation
                  if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<bool>(
                valueListenable: showPassword,
                builder: (context, isPasswordVisible, child) {
                  return TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                            onPressed: () {
                              // Toggle password visibility
                              showPassword.value = !isPasswordVisible;
                            },
                            icon: !isPasswordVisible
                                ? Image.asset('assets/icons/hide.png',
                                    height: 20)
                                : Image.asset('assets/icons/view.png',
                                    height: 20))),
                    obscureText: !isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password should be at least 6 characters';
                      }
                      return null;
                    },
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                    onPressed: () {
                      nextScreen(context, ForgotPasswordScreen());
                    },
                    child: Text("Forgot Password?")),
              ),
              const SizedBox(height: 10),
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
                            if (formKey.currentState?.validate() ?? false) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              AuthServices.signinWithEmailAndPassword(
                                context,
                                _emailController.text,
                                _passwordController.text,
                              );
                            }
                          },
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:book_charm/entities/user_model.dart';
import 'package:book_charm/providers/internet_provider.dart';
import 'package:book_charm/screens/authentication/services/auth1/auth_exception1.dart';
import 'package:book_charm/screens/authentication/services/auth1/auth_sevices1.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/signin_provider.dart';
import '../../bottom_navigation/bottom_navigation.dart';
import '../../home/view/dictionary_screen.dart';
import '../../home/view/home_screen.dart';

class AuthServices {
  // handling google sign-in
  static Future<void> handleGoogleSignIn(BuildContext context) async {
    final signInProvider = context.read<SignInProvider>();
    final internetProvider = context.read<InternetProvider>();

    await internetProvider.checkInternetConnection();

    if (!internetProvider.hasInternet) {
      showSnackBar(context, "Check your Internet connection");

      return;
    }

    try {
      await signInProvider.signInWithGoogle();

      if (signInProvider.hasError) {
        showSnackBar(context, signInProvider.errorCode!);

        return;
      }

      // Checking whether user exists or not
      final userExists = await signInProvider.checkUserExists();

      if (userExists) {
        // User exists
        await signInProvider.getUserDataFromFirestore(signInProvider.uid!).then(
          (value) async {
            await signInProvider.saveDataToSharedPreferences();
            await signInProvider.setSignIn();
            log('user Exist data= $value');

            nextScreenReplace(context, BottomNaigationScreen());
          },
        );
        log("User Exist");
      } else {
        // User does not exist
        await signInProvider.saveDataToFirestore().then(
          (value) async {
            await signInProvider.saveDataToSharedPreferences();
            await signInProvider.setSignIn();

            nextScreenReplace(context, BottomNaigationScreen());
          },
        );
        log("save data to Firestore");
      }
    } catch (e) {
      log("Error during Google sign-in: $e error Stack ");
      showSnackBar(context, "An error occurred during sign-in");
    }
  }

  static Future handleFacebookAuth(BuildContext context) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (!ip.hasInternet) {
      showSnackBar(context, "Check your Internet connection");
      return;
    }

    try {
      await sp.signInWithFacebook();
      if (ip.hasInternet == false) {
        showSnackBar(context, "Check your Internet connection");
        return;
      }
      // Checking whether user exists or not
      final userExists = await sp.checkUserExists();

      if (userExists) {
        // User exists
        sp.getUserDataFromFirestore(sp.uid!).then(
          (value) async {
            await sp.saveDataToSharedPreferences();
            await sp.setSignIn();

            nextScreenReplace(context, BottomNaigationScreen());
          },
        );
        log("User Exist");
      } else {
        // User does not exist
        await sp.saveDataToFirestore().then(
          (value) async {
            await sp.saveDataToSharedPreferences();
            await sp.setSignIn();

            nextScreenReplace(context, BottomNaigationScreen());
          },
        );
        log("save data to Firestore");
      }
    } catch (e) {
      log("Error during Google sign-in: $e error Stack ");
      showSnackBar(context, "An error occurred during sign-in");
    }
  }

  static Future signupWithEmailAndPassword(
      BuildContext context, String name, String email, String password) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (!ip.hasInternet) {
      showSnackBar(context, "Check your Internet connection");
      return;
    }

    try {
      await AuthService.firebase().createUser(email: email, password: password);
      await sp
          .saveDataToFirestore(
              name: name,
              email: email,
              provider: "SIMPLE",
              image: '',
              uid: AuthService.firebase().currentUser?.id)
          .then(
        (value) async {
          await sp.saveDataToSharedPreferences();
          await sp.setSignIn();
          showSnackBar(context, "Successfully created");
          // nextScreenReplace(context, BottomNaigationScreen());
        },
      );
      log("save data to Firestore");
    } on WeakPasswordAuthException {
      showSnackBar(context, "Weak Password");
    } on EmailAlreadyInUseAuthException {
      showSnackBar(context, "Email is already in use");
    } on InvalidEmailAuthException {
      showSnackBar(context, " invalid- email");
    } on GenericAuthException {
      showSnackBar(context, "Failed To Registration");
    }
  }

  static Future signinWithEmailAndPassword(BuildContext context, String email, String password) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();
    sp.setSignInLoader(true);
    if (!ip.hasInternet) {
      showSnackBar(context, "Check your Internet connection");
      sp.setSignInLoader(false);

      return;
    }

    try {
      // await AuthService.firebase().logIn(email: email, password: password);
      sp.setSignInLoader(true);

      await sp.signInWithEmailAndPassword(context, email, password);
      final userExists = await sp.checkUserExists();
      if (userExists) {
        await sp.saveDataToSharedPreferences();
        await sp.setSignIn();
        sp.setSignInLoader(false);
        context.read<DictionaryProvider>().loadDictionary(context);

        // getUserData ---> dictionary firebase, stats, my books overrite
        nextScreenReplace(context, BottomNaigationScreen());
        log("USER EXIST");
      }
    } catch (e) {
      log("e ERor Auteh Sec$e");
      sp.setSignInLoader(false);
    }
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:book_charm/entities/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/authentication/services/auth1/auth_exception1.dart';
import '../screens/authentication/view/signup_screen.dart';
import '../utils/show_snackBar.dart';

class SignInProvider extends ChangeNotifier {
  // instance of firebaseauth, facebook and google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FacebookAuth facebookAuth = FacebookAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _isSignedInLoading = false;
  bool get isSignedInLoading => _isSignedInLoading;

  //hasError, errorCode, provider,uid, email, name, imageUrl
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _name;
  String? get name => _name;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  SignInProvider() {
    checkSignInUser();
  }

  setSignInLoader(bool isLoading) {
    _isSignedInLoading = isLoading;
    notifyListeners();
  }

  Future checkSignInUser() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // sign in with google
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    log('GoogleSignInAccount $googleSignInAccount');
    if (googleSignInAccount != null) {
      // executing our authentication
      try {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // signing to firebase user instance
        final User userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user!;

        // now save all values
        _name = userDetails.displayName;
        _email = userDetails.email;
        _imageUrl = userDetails.photoURL ?? '';
        _provider = "GOOGLE";
        _uid = userDetails.uid;
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  // sign in with facebook
  Future signInWithFacebook() async {
    final LoginResult result = await facebookAuth.login();
    // getting the profile
    final graphResponse = await http.get(Uri.parse(
        'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=${result.accessToken!.token}'));

    final profile = jsonDecode(graphResponse.body);
    log('profile ${profile}');
    if (result.status == LoginStatus.success) {
      try {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        await firebaseAuth.signInWithCredential(credential);
        // saving the values
        _name = profile['name'];
        _email = profile['email'] ?? '';
        _imageUrl = profile['picture']['data']['url'];
        _uid = profile['id'];
        _hasError = false;
        _provider = "FACEBOOK";
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error while trying to sign in";
            _hasError = true;
            notifyListeners();
            break;
          default:
            _errorCode = e.toString();
            _hasError = true;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  Future signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      // saving the values
      _name = name;
      _email = email;
      _imageUrl = '';
      _uid = result.user?.uid;
      _hasError = false;
      _provider = "SIMPLE";
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "weak-password":
          _errorCode = "Weak Password";
          _hasError = true;
          notifyListeners();
          break;

        case "email-already-in-use":
          _errorCode = "Email is already in use";
          _hasError = true;
          notifyListeners();

          break;

        case "invalid-email":
          _errorCode = "Invalid Email";
          _hasError = true;
          notifyListeners();

          break;

        default:
          _errorCode = "Failed To Registration";
          _hasError = true;
          break;
      }
    }
  }

  Future<bool> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      // Attempt to sign in with email and password
      final result = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      // Retrieve user data from Firestore (if necessary)
      await getUserDataFromFirestore(result.user?.uid);

      // Return true to indicate successful login
      return true;
    } on FirebaseAuthException catch (e) {
      // Log the exception for debugging purposes
      log("FirebaseAuthException: ${e.message}");

      // Display appropriate error messages based on the exception code
      switch (e.code) {
        case "user-not-found":
          showSnackBar(context, "User not found");
          break;
        case "wrong-password":
          showSnackBar(context, "Incorrect password");
          break;
        case "invalid-email":
          showSnackBar(context, "Invalid email address");
          break;
        case "invalid-credential":
          showSnackBar(context, "Invalid email and password");
          break;
        default:
          showSnackBar(context, "Authentication error");
          break;
      }

      // Return false to indicate failed login
      return false;
    }
  }

  // ENTRY FOR CLOUDFIRESTORE
  Future getUserDataFromFirestore(uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) => {
              _uid = snapshot['uid'],
              _name = snapshot['name'],
              _email = snapshot['email'],
              _imageUrl = snapshot['image_url'],
              _provider = snapshot['provider'],
            });
    log("Value ${name}");
  }

  Future saveDataToFirestore(
      {String? name,
      String? email,
      String? uid,
      String? image,
      String? provider}) async {
    if (name != null) {
      final DocumentReference r =
          FirebaseFirestore.instance.collection("users").doc(uid);
      await r.set({
        "name": name,
        "email": email,
        "uid": uid,
        "image_url": imageUrl,
        "provider": provider,
      });
    } else {
      final DocumentReference r =
          FirebaseFirestore.instance.collection("users").doc(uid);
      await r.set({
        "name": _name,
        "email": _email,
        "uid": _uid,
        "image_url": _imageUrl,
        "provider": _provider,
      });
    }
    notifyListeners();
  }

  // Future saveDataToFirestore() async {
  //   final DocumentReference r =
  //       FirebaseFirestore.instance.collection("users").doc(uid);
  //   await r.set({
  //     "name": _name,
  //     "email": _email,
  //     "uid": _uid,
  //     "image_url": _imageUrl,
  //     "provider": _provider,
  //   });

  //   notifyListeners();
  // }

  Future saveDataToSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    log('$_name , $_email, $_uid $_imageUrl ');
    await s.setString('name', _name.toString());
    await s.setString('email', _email.toString());
    await s.setString('uid', _uid.toString());
    await s.setString('image_url', _imageUrl.toString());
    await s.setString('provider', _provider!);
    _userModel = UserModel(
      email: _email ?? '',
      imageUrl: _imageUrl ?? '',
      name: _name ?? '',
      provider: _provider ?? '',
      uid: _uid ?? '',
    );
    notifyListeners();
  }

  Future getDataFromSharedPreferences() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _name = s.getString('name');
    _email = s.getString('email');
    _imageUrl = s.getString('image_url');
    _uid = s.getString('uid');
    _provider = s.getString('provider');
    _userModel = UserModel(
      email: _email ?? '',
      imageUrl: _imageUrl ?? '',
      name: _name ?? '',
      provider: _provider ?? '',
      uid: _uid ?? '',
    );

    log("Email, ${userModel?.email}");

    notifyListeners();
  }

  // checkUser exists or not in cloudfirestore
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if (snap.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  // signout
  Future userSignOut(context) async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
    await facebookAuth.logOut();

    // nextScreenReplace(context, AuthenticationScreen());
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AuthenticationScreen()), // Replace TargetScreen with your target screen
      (route) => false,
    );
    // clear all storage information
    clearStoredData();
    _isSignedIn = false;
    notifyListeners();
  }

  Future clearStoredData() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
  }

  // void phoneNumberUser(User user, email, name) {
  //   _name = name;
  //   _email = email;
  //   _imageUrl =
  //       "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png";
  //   _uid = user.phoneNumber;
  //   _provider = "PHONE";
  //   notifyListeners();
  // }
}

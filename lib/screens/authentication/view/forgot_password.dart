import 'dart:developer';

import 'package:book_charm/utils/show_snackBar.dart';
import 'package:flutter/material.dart';

import '../services/authentication_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Your Password?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10.0),
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                if (_emailController.text.isNotEmpty) {
                  AuthServices.sendPasswordReset(
                          toEmail: _emailController.text.trim())
                      .then((value) {
                    showSnackBar(context, "Check Your Email!");
                  }).onError((error, sta) {
                    log('messagee ${error}');
                    setState(() {
                      _errorMessage = error.toString();
                    });
                  });
                }
              },
              child: Text('Reset Password'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

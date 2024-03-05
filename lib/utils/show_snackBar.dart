import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFFC599FB); // #C599FB
  static const Color secondaryColor = Color(0xFFEBE5EB); // #EBE5EB
  // Add more custom colors as needed
}

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

void showOTPDialog({
  required BuildContext context,
  required TextEditingController codeController,
  required VoidCallback onPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Enter OTP"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: codeController,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Done"),
          onPressed: onPressed,
        )
      ],
    ),
  );
}

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => page));
}

double getResponsiveWidth(BuildContext context, double baseWidth) {
  double screenWidth = MediaQuery.of(context).size.width;
  return screenWidth * (baseWidth / 414); // 375 is a reference screen width
}

double getResponsiveHeight(BuildContext context, double baseHeight) {
  double screenHeight = MediaQuery.of(context).size.height;
  return (screenHeight / 812) * baseHeight;
}

double getResponsiveFontSize(BuildContext context, double baseFontSize) {
  double screenWidth = MediaQuery.of(context).size.width;
  double responsiveFontSize = screenWidth * (baseFontSize / 414.0); // 375 is a reference screen width
  return responsiveFontSize;
}

double getResponsiveRadius(BuildContext context, double baseRadius) {
  double screenWidth = MediaQuery.of(context).size.width;
  return screenWidth * (baseRadius / 414.0); // 375 is a reference screen width
}

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/signin_provider.dart';

class ProfileService {
  static void showBottomSheetWidget(BuildContext context) {
    final sp = context.read<SignInProvider>();

    TextEditingController nameController =
        TextEditingController(); // Add a text controller for the text field
    Future updateNameOnFirebase(String newName) async {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          'name': newName,
        });
        final sp = context.read<SignInProvider>();
        final SharedPreferences s = await SharedPreferences.getInstance();
        await s.setString('name', newName);
        sp.getDataFromSharedPreferences();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Name changed successfully!'),
        ));

        Navigator.of(context).pop(); // Close the bottom sheet
      } catch (e) {
        print('Error updating name: $e');
      }
    }

    showBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Change Name',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        updateNameOnFirebase(nameController.text);
                      },
                      child: const Text(
                        'Change',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the bottom sheet
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

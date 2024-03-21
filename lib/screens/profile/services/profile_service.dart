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

    TextEditingController _nameController =
        TextEditingController(); // Add a text controller for the text field
    Future _updateNameOnFirebase(String newName) async {
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
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Name',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _updateNameOnFirebase(_nameController.text);
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
        );
      },
    );
  }
}

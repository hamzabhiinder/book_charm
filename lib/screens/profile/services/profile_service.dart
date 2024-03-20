import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../providers/signin_provider.dart';

class ProfileService {
  static void showBottomSheet(BuildContext context) {
    final sp = context.read<SignInProvider>();

    TextEditingController _nameController =
        TextEditingController(); // Add a text controller for the text field
    Future<void> _updateNameOnFirebase(String newName) async {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .update({
          'name': newName,
        });
      } catch (e) {
        print('Error updating name: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add the text field for changing the name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Update Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Add the 'Change' button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the bottom sheet
                      _updateNameOnFirebase(_nameController.text);
                    },
                    child: Text('Change'),
                  ),
                  // Add the 'Cancel' button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the bottom sheet
                    },
                    child: Text('Cancel'),
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

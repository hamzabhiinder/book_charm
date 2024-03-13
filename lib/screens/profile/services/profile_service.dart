import 'package:flutter/material.dart';

class ProfileService {
  static void showBottomSheet(BuildContext context) {
  TextEditingController _nameController = TextEditingController(); // Add a text controller for the text field

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add the text field for changing the name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'New Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Add the 'Change' button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the bottom sheet
                      String newName = _nameController.text; // Get the new name from the text field
                      // Add your logic for changing the name here
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
        ),
      );
    },
  );
}

}
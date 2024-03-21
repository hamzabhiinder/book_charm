import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(
                  'https://www.kindpng.com/picc/m/252-2524695_dummy-profile-image-jpg-hd-png-download.png'),
            ),
            SizedBox(height: 20),
            Text(
              'User Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Downloaded Books',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        children: [
                          // Replace this with actual book tiles
                          ListTile(
                            title: Text('Book Title 1'),
                            subtitle: Text('Author Name'),
                          ),
                          ListTile(
                            title: Text('Book Title 2'),
                            subtitle: Text('Author Name'),
                          ),
                          // Add more ListTile widgets for other books
                        ],
                      ),
                    ),
                    // Show message if no books are downloaded
                    if (true) // Replace true with condition to check if books are empty
                      Text(
                        'No books downloaded',
                        style: TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

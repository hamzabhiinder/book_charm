import 'package:book_charm/screens/home/view/downloaded_books_screen.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String image;
  final String name;
  final String? scoreXp;
  final bool isProfileUser;
  const UserProfilePage(
      {super.key,
      required this.image,
      required this.name,
      this.scoreXp,
      this.isProfileUser = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(image ??
                  'https://www.kindpng.com/picc/m/252-2524695_dummy-profile-image-jpg-hd-png-download.png'),
            ),
            SizedBox(height: 20),
            Text(
              name ?? 'User Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            isProfileUser
                ? Expanded(child: DownloadedBooksScreen())
                : Text(
                    'score ${scoreXp}',
                    style: TextStyle(fontSize: 40),
                  ),
          ],
        ),
      ),
    );
  }
}

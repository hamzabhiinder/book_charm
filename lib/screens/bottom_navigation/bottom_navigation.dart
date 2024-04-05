import 'package:book_charm/screens/dashboard/services/dashboard_services.dart';
import 'package:book_charm/screens/exercise/view/exercise.dart';
import 'package:book_charm/screens/dashboard/view/dashboard_screen.dart';
import 'package:book_charm/screens/home/view/dictionary_screen.dart';
import 'package:book_charm/screens/home/view/downloaded_books_screen.dart';
import 'package:book_charm/screens/home/view/library_screen.dart';
import 'package:book_charm/screens/profile/view/profile.dart';
import 'package:book_charm/screens/stats/leaderboard.dart';
import 'package:flutter/material.dart';

class BottomNaigationScreen extends StatefulWidget {
  @override
  _BottomNaigationScreenState createState() => _BottomNaigationScreenState();
}

class _BottomNaigationScreenState extends State<BottomNaigationScreen> {
  int _selectedIndex = 0;
  final List<Widget> screens = [
    DashBoardScreen(),
    DictionaryScreen(),
    LibraryScreen(),
    ExerciseScreen(),
    LeaderBoardScreen()
    //ProfileScreen(),

    // DownloadedBooksScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_rounded),
            label: 'Dictionary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_camera_back),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.thumb_up_sharp),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leader Board',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.account_circle),
          //   label: 'Books',
          // ),
        ],
        selectedItemColor: const Color(0xffc599fb),
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}

import 'package:book_charm/screens/exercise/view/exercise.dart';
import 'package:book_charm/screens/home/view/dashboard_screen.dart';
import 'package:book_charm/screens/profile/view/profile.dart';
import 'package:flutter/material.dart';

class BottomNaigationScreen extends StatefulWidget {
  @override
  _BottomNaigationScreenState createState() => _BottomNaigationScreenState();
}

class _BottomNaigationScreenState extends State<BottomNaigationScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          // Add your pages here
          DashBoardScreen(),
          DictionaryScreen(),
          LibraryScreen(),
          ExerciseScreen(),
          ProfileScreen(),
        ],
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xffc599fb),
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DictionaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Dictionary Screen'));
  }
}

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Library Screen'));
  }
}

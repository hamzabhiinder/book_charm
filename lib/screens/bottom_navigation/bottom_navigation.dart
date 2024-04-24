import 'dart:developer';

import 'package:book_charm/screens/dashboard/services/dashboard_services.dart';
import 'package:book_charm/screens/exercise/view/exercise.dart';
import 'package:book_charm/screens/dashboard/view/dashboard_screen.dart';
import 'package:book_charm/screens/home/view/dictionary_screen.dart';
import 'package:book_charm/screens/home/view/downloaded_books_screen.dart';
import 'package:book_charm/screens/home/view/library_screen.dart';
import 'package:book_charm/screens/profile/view/profile.dart';
import 'package:book_charm/screens/stats/leaderboard.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:book_charm/utils/stats/overall_stats.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNaigationScreen extends StatefulWidget {
  @override
  _BottomNaigationScreenState createState() => _BottomNaigationScreenState();
}

class _BottomNaigationScreenState extends State<BottomNaigationScreen> {
  int _selectedIndex = 0;
  late OverallStats overallStats; // Declare overallStats here

  late List<Widget> screens; // Declare screens here

  @override
  void initState() {
    super.initState();
    overallStats = OverallStats(xp: 0, streak: 0, time: 0, lessonsCompleted: 0);
    OverallStats.loadStatsData().then((value) {
      setState(() {
        print("Sucees: ${value}");
        overallStats = value;
        screens[0] = DashBoardScreen(overallStats: overallStats);
      });
    });
    screens = [
      DashBoardScreen(overallStats: overallStats),
      DictionaryScreen(),
      LibraryScreen(),
      ExerciseScreen(),
      LeaderBoardScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedIconTheme: IconThemeData(color: AppColors.primaryColor),
        unselectedIconTheme: IconThemeData(color: AppColors.secondaryColor),
        onTap: (index) {
          if (index == 1)
            context.read<DictionaryProvider>().loadDictionary(context);

          if (index == 0) {
            print("Sucees: ${index}");

            OverallStats.loadStatsData().then((value) {
              setState(() {
                print("Sucees: ${value}");
                overallStats = value;
                screens[0] = DashBoardScreen(overallStats: overallStats);
                _selectedIndex = index;
              });
            });
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
              color: const Color(0xffc599fb),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/dictionary.png',
              height: 30,
            ),
            label: 'Dictionary',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/library.png',
              height: 30,
            ),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Exercises.png',
              height: 30,
            ),
            label: 'Exercises',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/leaderboard.png',
              height: 30,
            ),
            label: 'Leader Board',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.account_circle),
          //   label: 'Books',
          // ),
        ],
        selectedItemColor: const Color(0xffc599fb),
        unselectedItemColor: const Color(0xffc599fb),
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
    );
  }
}

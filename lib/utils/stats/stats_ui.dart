// Screen to display the stats
import 'package:book_charm/utils/stats/overall_stats.dart';
import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  final OverallStats overallStats;

  StatsScreen({required this.overallStats});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Stats'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('XP: ${overallStats.xp}'),
            Text('Streak: ${overallStats.streak}'),
            Text('Time: ${overallStats.time}'),
            Text('Lessons Completed: ${overallStats.lessonsCompleted}'),
          ],
        ),
      ),
    );
  }
}

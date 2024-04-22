import 'dart:developer';

import 'package:book_charm/screens/games/flip_cards_screen.dart';
import 'package:book_charm/screens/games/mcqs_screen.dart';
import 'package:book_charm/screens/games/word_matching_screen.dart';
import 'package:book_charm/utils/stats/time_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:localstorage/localstorage.dart';

import '../../../utils/fl_charts/bar_graph.dart';
import '../../../utils/show_snackBar.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  List<Map<String, String>> wordPairs = [];
  int wordsLearnedToday = 0;
  int dailyGoals = 10;
  final LocalStorage storage = LocalStorage('dictionary.json');
  Future<void> loadDictionary() async {
    await storage.ready;
    print('Storage is ready');

    var storedData = storage.getItem('wordPairs');
    print('Stored data: $storedData');

    if (storedData != null) {
      if (storedData is List<dynamic>) {
        List<Map<String, String>> castedData = [];

        for (var item in storedData) {
          if (item is Map<String, dynamic>) {
            Map<String, String> stringMap = {};

            // Convert keys and values to strings
            item.forEach((key, value) {
              stringMap[key] = value.toString();
            });

            castedData.add(stringMap);
          } else {
            print('Error: Unexpected data format in dictionary.json');
          }
        }
        setState(() {
          wordPairs =
              castedData.where((pair) => pair['islearned'] == 'true').toList();
        });
      } else {
        print('Error: Unexpected data format in dictionary.json');
      }
    }
    print('Updated wordPairs: $wordPairs');
  }

  @override
  void initState() {
    super.initState();
    loadDictionary().then((value) {
      setState(() {
        DateTime currentDate = DateTime.now().toUtc();
        wordsLearnedToday = wordPairs.where((pair) {
          DateTime learnedTime = DateTime.parse(pair['learnedTime'] ??
              DateTime.parse('2024-01-01').toIso8601String());
          return learnedTime.year == currentDate.year &&
              learnedTime.month == currentDate.month &&
              learnedTime.day == currentDate.day;
        }).length;
        log('todayWords $wordsLearnedToday $wordPairs');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kToolbarHeight - 18),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: getResponsiveWidth(context, 18)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/profile.png',
                    width: getResponsiveWidth(context, 40),
                    height: getResponsiveHeight(context, 40),
                  ),
                  Image.asset(
                    'assets/images/search.png',
                    width: getResponsiveWidth(context, 40),
                    height: getResponsiveHeight(context, 40),
                  ),
                ],
              ),
            ),
            SizedBox(height: getResponsiveHeight(context, 15)),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: getResponsiveWidth(context, 18)),
              child: Text(
                'Exercises',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: getResponsiveFontSize(context, 35),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Divider(),
            SizedBox(height: getResponsiveHeight(context, 15)),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                alignment: Alignment.topLeft,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(15), // Adjust the radius as needed
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2.0,
                  ),
                  color: const Color(0xffebe4eb),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Text(
                              'Daily Statistics for trainings',
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(context, 16),
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: getResponsiveWidth(context, 10)),
                            Text(
                              'Average Time in \nHours',
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(context, 15),
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: getResponsiveWidth(context, 10)),
                              height: getResponsiveHeight(context, 130),
                              child: MyBarGraph(
                                monthlySummary: TimerUtils
                                    .calculateDurationOfPastSevenDays(),
                                // monthlySummary: >[
                                //   5,
                                //   4,
                                //   4,
                                //   4,
                                //   4,
                                //   4,
                                //   4,
                                // ],
                              ),
                            ),
                          ],
                        )),
                    Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: getResponsiveWidth(context, 10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: getResponsiveWidth(context, 30)),
                              Text(
                                'Daily goal',
                                style: TextStyle(
                                  fontSize: getResponsiveFontSize(context, 15),
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Container(
                                height: getResponsiveHeight(context, 70),
                                // width: getResponsiveWidth(context, 100),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      8), // Adjust the radius as needed
                                  border: Border.all(
                                    color: Colors.black12,
                                    width: 2.0,
                                  ),
                                  color: const Color(0xffebe4eb),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$dailyGoals \nWord',
                                      style: TextStyle(
                                        fontSize:
                                            getResponsiveFontSize(context, 22),
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    const Icon(
                                      Icons.edit,
                                      size: 28,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: getResponsiveWidth(context, 5)),
                              Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: getResponsiveFontSize(context, 22),
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              SizedBox(height: getResponsiveWidth(context, 5)),
                              Text(
                                wordsLearnedToday.toString(),
                                style: TextStyle(
                                  fontSize: getResponsiveFontSize(context, 24),
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            ),
            SizedBox(height: getResponsiveWidth(context, 20)),
            Text(
              'Free Trainings',
              style: TextStyle(
                fontSize: getResponsiveFontSize(context, 22),
                color: const Color(0xff686868),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: getResponsiveWidth(context, 15)),
            ReusableContainer(
              title: 'MCQs Quiz',
              imagePath: 'assets/images/ic_fill.png',
              onTap: () {
                nextScreen(context, const McqsScreen());
              },
            ),
            SizedBox(height: getResponsiveWidth(context, 15)),
            ReusableContainer(
              title: 'Find matches',
              imagePath: 'assets/images/ic_match.png',
              onTap: () {
                nextScreen(context, WordMatchingScreen());
              },
            ),
            SizedBox(height: getResponsiveWidth(context, 15)),
            ReusableContainer(
              title: 'Flashcards',
              imagePath: 'assets/images/ic_flash.png',
              onTap: () {
                nextScreen(context, const FlipCardsScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReusableContainer extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const ReusableContainer({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.symmetric(
            horizontal: getResponsiveWidth(context, 15),
            vertical: getResponsiveHeight(context, 15),
          ),
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.transparent,
              width: 2.0,
            ),
            color: const Color(0xffebe4eb),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context, 20),
                  color: const Color(0xff686868),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              Image.asset(
                imagePath,
                width: getResponsiveWidth(context, 40),
                height: getResponsiveWidth(context, 35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

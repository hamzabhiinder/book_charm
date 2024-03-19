import 'package:book_charm/main.dart';
import 'package:book_charm/utils/download/download_file.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:book_charm/utils/stats/overall_stats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../providers/signin_provider.dart';
import '../widgets/custom_container.dart';
import '../widgets/cutsom_book_tile.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  OverallStats overallStats =
      OverallStats(xp: 0, streak: 0, time: 0, lessonsCompleted: 0);
  @override
  void initState() {
    super.initState();
    OverallStats.loadFromLocalStorage().then((value) {
      overallStats = value;
      print("errroe: ${overallStats.toJson()}");
    });
    _tabController = TabController(length: 3, vsync: this);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.index = index;
    });
  }

  List recommendationData = [
    {
      "imageUrl": "assets/images/a_december_to_remember.jpg",
      "bookName": "A December To Remember",
      "authorName": "Janny Bayliss"
    },
    {
      "imageUrl": "assets/images/all_the_little_bird_hearts.jpg",
      "bookName": "All The Little Bird-Hearts",
      "authorName": "Viktoria Lloyd-Barlow"
    },
    {
      "imageUrl": "assets/images/bright_lights_big_christmas.jpg",
      "bookName": "Bright Lights, Big Christmas",
      "authorName": "Mary Kay Andrews"
    },
    {
      "imageUrl": "assets/images/bright_lights_big_christmas.jpg",
      "bookName": "Bright Lights, Big Christmas",
      "authorName": "Mary Kay Andrews"
    }
  ];

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SignInProvider>();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: AppBar(
                  backgroundColor: Colors.white,
                  toolbarHeight: kToolbarHeight - 10,
                  leading: Image.asset(
                    'assets/images/profile.png',
                  ),
                  title: Text(
                    "Welcome ${sp.userModel?.name ?? "user"}",
                    style: const TextStyle(
                      color: Color(0xff686868),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              const SizedBox(height: 5),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 15),
              //   child: TextField(
              //     decoration: InputDecoration(
              //       hintText: "Search...",
              //       prefixIcon: const Icon(Icons.search),
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //     ),
              //   ),
              // ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(12)),
                child: const Column(
                  children: [
                    Text(
                      "\'Whoever guide someone to goodness,he\'ll get the reward similar to it\'",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "Sahih AlMuslim 1893 (a)",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15), // Adjust the spacing as needed
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'TODAY'),
                  Tab(text: 'WEEK'),
                  Tab(text: 'ALL'),
                ],
                onTap: (index) => _onItemTapped(index),
              ),
              SizedBox(
                height: 300,
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    // Your existing TabBarView content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomContainer(
                              url: 'assets/images/star.png',
                              title: 'XP',
                              subTitle: overallStats
                                  .calculateLastSectionStats(
                                      'today')['xpInSection']
                                  .toString(),
                            ),
                            CustomContainer(
                              url: 'assets/images/flame.png',
                              title: 'Streak',
                              subTitle: overallStats
                                  .calculateLastSectionStats(
                                      'today')['streakChangesInSection']
                                  .toString(),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CustomContainer(
                              url: 'assets/images/stopwatch.png',
                              title: 'Time',
                              subTitle: '0',
                            ),
                            CustomContainer(
                              url: 'assets/images/learning.png',
                              title: 'Lesson',
                              subTitle: overallStats
                                  .calculateLastSectionStats(
                                      'today')['lessonChangesInSection']
                                  .toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ReusableColumn(), ReusableColumn(),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  "Recommendations",
                  style: TextStyle(
                    color: Color(0xff686868),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: recommendationData.length,
                itemBuilder: (BuildContext context, int index) {
                  return CustomBookTile(
                    imageUrl: recommendationData[index]['imageUrl'],
                    bookName: recommendationData[index]['bookName'],
                    authorName: recommendationData[index]['authorName'],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReusableColumn extends StatelessWidget {
  const ReusableColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomContainer(
              url: 'assets/images/star.png',
              title: 'XP',
              subTitle: '0',
            ),
            CustomContainer(
              url: 'assets/images/flame.png',
              title: 'Streak',
              subTitle: '0',
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomContainer(
              url: 'assets/images/stopwatch.png',
              title: 'Time',
              subTitle: '0',
            ),
            CustomContainer(
              url: 'assets/images/learning.png',
              title: 'Lesson',
              subTitle: '0',
            ),
          ],
        ),
      ],
    );
  }
}

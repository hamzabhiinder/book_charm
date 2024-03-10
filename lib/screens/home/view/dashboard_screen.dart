import 'package:book_charm/main.dart';
import 'package:book_charm/utils/download/download_file.dart';
import 'package:book_charm/utils/show_snackBar.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.index = index;
    });
  }

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
                  physics: NeverScrollableScrollPhysics(),
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
                            InkWell(
                              onTap: () {
                                scrapePreTagContent(
                                  url:
                                      'https://archive.org/stream/letourdumondeenq00vernuoft/letourdumondeenq00vernuoft_djvu.txt',
                                  bookName: 'Le Tour du monde',
                                  authorName: 'Jules Verne',
                                );
                              },
                              child: CustomContainer(
                                url: 'assets/images/star.png',
                                text1: 'XP',
                                text2: '0',
                              ),
                            ),
                            CustomContainer(
                              url: 'assets/images/flame.png',
                              text1: 'Streak',
                              text2: '0',
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
                              text1: 'Time',
                              text2: '0',
                            ),
                            CustomContainer(
                              url: 'assets/images/learning.png',
                              text1: 'Lesson',
                              text2: '0',
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
              const CustomBookTile(
                url: 'assets/images/a_december_to_remember.jpg',
                text1: 'A December To\nRemember',
                text2: 'Janny Bayliss',
              ),
              const SizedBox(height: 10),
              const CustomBookTile(
                url: 'assets/images/all_the_little_bird_hearts.jpg',
                text1: 'All The Little\nBird-Hearts',
                text2: 'Viktoria Lloyd-Barlow',
              ),
              const SizedBox(height: 10),
              const CustomBookTile(
                url: 'assets/images/bright_lights_big_christmas.jpg',
                text1: 'Bright Lights, Big\nChristmas',
                text2: 'Mary Kay Andrews',
              ),
              const SizedBox(height: 10),
              const CustomBookTile(
                url: 'assets/images/bright_lights_big_christmas.jpg',
                text1: 'Bright Lights, Big\nChristmas',
                text2: 'Mary Kay Andrews',
              )
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
              text1: 'XP',
              text2: '0',
            ),
            CustomContainer(
              url: 'assets/images/flame.png',
              text1: 'Streak',
              text2: '0',
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomContainer(
              url: 'assets/images/stopwatch.png',
              text1: 'Time',
              text2: '0',
            ),
            CustomContainer(
              url: 'assets/images/learning.png',
              text1: 'Lesson',
              text2: '0',
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../utils/show_snackBar.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
          Divider(),
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
                color: Color(0xffebe4eb),
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
                              fontSize: getResponsiveFontSize(context, 18),
                              color: Color.fromARGB(255, 63, 63, 63),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: getResponsiveWidth(context, 15)),
                          Text(
                            'Average Time in \nSecond',
                            style: TextStyle(
                              fontSize: getResponsiveFontSize(context, 16),
                              color: Color.fromARGB(255, 63, 63, 63),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )),
                  Expanded(
                      flex: 2,
                      child: Container(
                        height: 100,
                        color: Colors.yellow,
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
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(15), // Adjust the radius as needed
              border: Border.all(
                color: Colors.transparent,
                width: 2.0,
              ),
              color: Color(0xffebe4eb),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fill in the blanks',
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 20),
                    color: const Color(0xff686868),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                Image.asset(
                  'assets/images/ic_fill.png',
                  width: getResponsiveWidth(context, 40),
                  height: getResponsiveWidth(context, 35),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

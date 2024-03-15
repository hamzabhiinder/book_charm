import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final String url;
  final String title;
  final String subTitle;
  const CustomContainer({
    super.key,
    required this.url,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 115,
      width: 115,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          width: 4.0,
          color: const Color(0xffc599fb),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            url,
            height: 50,
          ),
          Text(title),
          Text(subTitle),
        ],
      ),
    );
  }
}

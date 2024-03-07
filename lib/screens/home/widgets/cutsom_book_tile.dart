import 'package:book_charm/utils/show_snackBar.dart';
import 'package:flutter/material.dart';
import '../view/book_detail_page.dart';

class CustomBookTile extends StatelessWidget {
  final String url;
  final String text1;
  final String text2;

  const CustomBookTile({
    required this.url,
    required this.text1,
    required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(_buildPageRoute());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: Colors.white,
            // borderRadius: BorderRadius.circular(10.0),

            border: Border(
                bottom: BorderSide(
              color: AppColors.secondaryColor,
            ))),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(2, 7), // changes the shadow position
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  url,
                  height: 80,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text1,
                    style: const TextStyle(
                      color: Color(0xff686868),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    text2,
                    style: const TextStyle(
                      color: Color(0xff686868),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PageRouteBuilder _buildPageRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return BookDetailPage(url: url, text1: text1, text2: text2);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

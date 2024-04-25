import 'package:book_charm/utils/show_snackBar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../view/book_detail_page.dart';

class CustomBookTile extends StatelessWidget {
  final String imageUrl;
  final String bookName;
  final String authorName;
  final String downloadUrl;
  var isNetworkImage;
  String description;
  CustomBookTile(
      {required this.imageUrl,
      required this.bookName,
      required this.authorName,
      this.isNetworkImage = false,
      this.description = 'safasdf',
      required this.downloadUrl});

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
                child: isNetworkImage
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 80,
                        width: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Colors.red,
                        ),
                      )
                    : Image.asset(
                        imageUrl,
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
                    bookName,
                    style: const TextStyle(
                      color: Color(0xff686868),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    authorName,
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
        return BookDetailPage(
          url: imageUrl,
          bookName: bookName,
          authorName: authorName,
          isNetworkImage: isNetworkImage,
          description: description,
          downloadUrl: downloadUrl,
        );
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

import 'dart:developer';

import 'package:book_charm/screens/home/view/book_detail_page.dart';
import 'package:book_charm/screens/home/widgets/cutsom_book_tile.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class DownloadedBooksScreen extends StatefulWidget {
  @override
  _DownloadedBooksScreenState createState() => _DownloadedBooksScreenState();
}

class _DownloadedBooksScreenState extends State<DownloadedBooksScreen> {
  final LocalStorage storage = LocalStorage('downloadedBooks');
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> books = storage.getItem('books') ?? [];
    log('$books');
    return Scaffold(
      appBar: AppBar(
        title: Text('Downloaded Books'),
      ),
      body: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: books.length,
        itemBuilder: (BuildContext context, int index) {
          return CustomBookTile(
            imageUrl: books[index]['url'],
            bookName: books[index]['bookName'],
            authorName: books[index]['authorName'],
            isNetworkImage: true,
          );
        },
      ),
    );
  }

  PageRouteBuilder _buildPageRoute(
      imageUrl, bookName, authorName, downloadUrl) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return BookDetailPage(
          url: imageUrl,
          bookName: bookName,
          authorName: authorName,
          isLibrary: true,
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

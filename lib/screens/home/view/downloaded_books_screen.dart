import 'dart:developer';

import 'package:book_charm/screens/home/view/book_detail_page.dart';
import 'package:book_charm/screens/home/widgets/cutsom_book_tile.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:book_charm/utils/stats/overall_stats.dart';
import 'package:book_charm/utils/stats/stats_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../profile/view/widget/language_selector.dart';

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
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> books = storage.getItem('books') ?? [];
    final lang = Provider.of<LanguageProvider>(context);

    List<dynamic> filteredBooks = books
        .where(
          (element) => element['language'] == lang.selectedLanguageCode,
        )
        .toList();
    log('$filteredBooks');
    FirebaseFirestore.instance
        .collection('MyBooks')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        log('datas $data');
      }
    });

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredBooks.length,
      itemBuilder: (BuildContext context, int index) {
        return CustomBookTile(
          imageUrl: filteredBooks[index]['url'],
          bookName: filteredBooks[index]['bookName'],
          authorName: filteredBooks[index]['authorName'],
          isNetworkImage: filteredBooks[index]['url'][0] == 'a' ? false : true,
          description: filteredBooks[index]['description'] ?? '',
        );
      },
    );
  }
}

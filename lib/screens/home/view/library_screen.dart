import 'dart:convert';
import 'dart:developer';
import 'package:book_charm/screens/home/view/book_detail_page.dart';
import 'package:book_charm/screens/home/widgets/upload_book.dart';
import 'package:book_charm/screens/profile/view/widget/language_selector.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final libraryProvider =
        Provider.of<LibraryProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            nextScreen(context, UploadPage());
          },
          child: Icon(Icons.add)),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: Text('Library Screen'),
        actions: [
          // IconButton(
          //     onPressed: () {
          //       Provider.of<LibraryProvider>(context, listen: false)
          //           .fetchBooks();
          //     },
          //     icon: Icon(Icons.book))
        ],
      ),
      body: FutureBuilder(
        future: libraryProvider.loadJsonDataFunction(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else {
            return _buildLibraryContent(context);
          }
        },
      ),
    );
  }

  Widget _buildLibraryContent(BuildContext context) {
    final libraryProvider = context.watch<LibraryProvider>();
    final lang = Provider.of<LanguageProvider>(context, listen: false);

    return Consumer<LibraryProvider>(
      builder: (context, value, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: libraryProvider.categories.length,
                itemBuilder: (context, index) {
                  String category = libraryProvider.categories[index];
                  List<dynamic> books = value
                      .loadJsonData[lang.selectedLanguageName]
                      .where((book) => book['Category'] == category)
                      .toList();
                  log('books ${lang.selectedLanguageName}');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          category,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: getResponsiveHeight(
                            context, 170), // Set the height as needed
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: books.length,
                          itemBuilder: (context, bookIndex) {
                            String bookName =
                                books[bookIndex]['Name'].toString() ?? '';
                            String imageUrl =
                                books[bookIndex]['Cover'].toString() ?? '';
                            String authorName =
                                books[bookIndex]['Author'].toString() ?? '';
                            String downloadUrl =
                                books[bookIndex]['Link'].toString() ?? '';
                            String description =
                                books[bookIndex]['Description'].toString() ??
                                    '';
                            String category =
                                books[bookIndex]['Category'].toString() ?? '';
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(_buildPageRoute(
                                    imageUrl,
                                    bookName,
                                    authorName,
                                    downloadUrl,
                                    description,
                                    category));
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        getResponsiveWidth(context, 10)),
                                child: Container(
                                  alignment: Alignment.center,
                                  width: getResponsiveWidth(
                                      context, 100), // Set the width as needed
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: CachedNetworkImage(
                                          height:
                                              getResponsiveHeight(context, 100),
                                          width:
                                              getResponsiveWidth(context, 90),
                                          fit: BoxFit.cover,
                                          imageUrl: imageUrl,
                                          errorWidget: (context, url, error) =>
                                              ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Container(
                                              width: getResponsiveHeight(
                                                  context, 100),
                                              height: getResponsiveWidth(
                                                  context, 90),
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              ),
                                              child: Icon(
                                                Icons.error_outline,
                                                size: 25,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              getResponsiveHeight(context, 5)),
                                      SizedBox(
                                        width: getResponsiveWidth(context, 100),
                                        child: Text(
                                          bookName,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: getResponsiveFontSize(
                                                context, 12),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        width: getResponsiveWidth(context, 100),
                                        child: Text(
                                          authorName,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: getResponsiveFontSize(
                                                context, 11),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'My Books',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                //height: 200,
                child: FutureBuilder(
                  future: value.fetchBooks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      // List<Map<String, dynamic>> books =s
                      //     snapshot.data as List<Map<String, dynamic>>;
                      // log('booksss ${snapshot.data}');

                      List<dynamic> books =
                          ((snapshot.data?[lang.selectedLanguageCode ?? 'en'] ??
                                  []) as List<dynamic>)
                              .where((book) => book['isPublished'] == true)
                              .toList();

                      // log('books ${books.toList()}');
                      if (books.isEmpty) {
                        return const Text('No new books uploaded');
                      }
                      return SizedBox(
                        height: getResponsiveHeight(context, 170),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (books.isNotEmpty && books != null)
                              ? books.length ?? 0
                              : 0,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            // return ListTile(
                            //   title: Text(
                            //       books[0]['en'][index]['Name'] ?? 'Unnamed Book'),
                            //   subtitle: Text(books[0]['en'][index]['Author'] ??
                            //       'Unknown Author'),
                            //   // Add more fields as needed
                            // );
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(_buildPageRoute(
                                  books[index]['CoverUrl'] ?? '',
                                  books[index]['Name'] ?? '',
                                  books[index]['Author'] ?? '',
                                  books[index]['Link'] ?? '',
                                  books[index]['Description'] ?? '',
                                  books[index]['Category'] ?? '',
                                ));
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        getResponsiveWidth(context, 10)),
                                child: Container(
                                  alignment: Alignment.center,
                                  width: getResponsiveWidth(
                                      context, 100), // Set the width as needed
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: CachedNetworkImage(
                                          height:
                                              getResponsiveHeight(context, 100),
                                          width:
                                              getResponsiveWidth(context, 90),
                                          fit: BoxFit.cover,
                                          imageUrl: books[index]['CoverUrl'] ==
                                                  ""
                                              ? 'https://m.media-amazon.com/images/I/A1bwQxjFE3L._SY522_.jpg'
                                              : books[index]['CoverUrl'],
                                          errorWidget: (context, url, error) =>
                                              ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Container(
                                              width: getResponsiveHeight(
                                                  context, 100),
                                              height: getResponsiveWidth(
                                                  context, 90),
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              ),
                                              child: Icon(
                                                Icons.error_outline,
                                                size: 25,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              getResponsiveHeight(context, 5)),
                                      SizedBox(
                                        width: getResponsiveWidth(context, 100),
                                        child: Text(
                                          books[index]['Name'] ??
                                              'Unnamed Book',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: getResponsiveFontSize(
                                                context, 12),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        width: getResponsiveWidth(context, 100),
                                        child: Text(
                                          books[index]['Author'] ??
                                              'Author Book',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: getResponsiveFontSize(
                                                context, 11),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PageRouteBuilder _buildPageRoute(
      imageUrl, bookName, authorName, downloadUrl, description, category) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return BookDetailPage(
          url: imageUrl,
          bookName: bookName,
          authorName: authorName,
          isNetworkImage: true,
          downloadUrl: downloadUrl,
          description: description,
          category: category,
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

class LibraryProvider with ChangeNotifier {
  List<dynamic> categories = [];
  Map<String, dynamic> loadJsonData = {};
  String selectedLanguageName = "German";

  Future loadJsonDataFunction(BuildContext context) async {
    final language = Provider.of<LanguageProvider>(context, listen: false);
    try {
      String jsonString =
          await rootBundle.loadString('assets/data/booksData.json');
      loadJsonData = json.decode(jsonString);

      categories = loadJsonData[language.selectedLanguageName]
          .map((book) => book['Category'])
          .toSet()
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  DocumentSnapshot<Map<String, dynamic>>? querySnapshot;
  Future<Map<String, dynamic>> fetchBooks() async {
    try {
      querySnapshot = await FirebaseFirestore.instance
          .collection('books')
          .doc('upload_book')
          .get();

      print("${querySnapshot?.data()?.entries ?? ''}");
      return querySnapshot?.data() ?? {};
    } catch (e) {
      // Handle errors
      print('Error fetching books: $e');
      return {};
    }
  }
}

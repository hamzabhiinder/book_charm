import 'dart:convert';
import 'package:book_charm/screens/home/view/book_detail_page.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/data/bookFrenchData.json');
      setState(() {
        categories = json.decode(jsonString);
      });
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        title: Text('Library Screen'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String category = categories[index]['Category'];
          List<dynamic> books = categories[index]['Books'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  category,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: getResponsiveHeight(
                    context, 170), // Set the height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.length,
                  itemBuilder: (context, bookIndex) {
                    String bookName = books[bookIndex]['Name'];
                    String imageUrl = books[bookIndex]['Cover'];
                    String authorName = books[bookIndex]['Author'];
                    String downloadUrl = books[bookIndex]['StreamLink'];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(_buildPageRoute(
                            imageUrl, bookName, authorName, downloadUrl));
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: getResponsiveWidth(context, 10)),
                        child: Container(
                          alignment: Alignment.center,
                          width: getResponsiveWidth(
                              context, 100), // Set the width as needed
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: CachedNetworkImage(
                                  height: getResponsiveHeight(context, 100),
                                  width: getResponsiveWidth(context, 90),
                                  fit: BoxFit.cover,
                                  imageUrl: imageUrl,
                                  errorWidget: (context, url, error) =>
                                      ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Container(
                                        width:
                                            getResponsiveHeight(context, 100),
                                        height: getResponsiveWidth(context, 90),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                        child: Icon(
                                          Icons.error_outline,
                                          size: 25,
                                          color: Colors.red,
                                        )),
                                  ),
                                ),
                              ),
                              SizedBox(height: getResponsiveHeight(context, 5)),
                              SizedBox(
                                width: getResponsiveWidth(context, 100),
                                child: Text(
                                  bookName,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        getResponsiveFontSize(context, 12),
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
                                    fontSize:
                                        getResponsiveFontSize(context, 11),
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

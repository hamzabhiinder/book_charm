import 'dart:io';
import 'dart:ui';

import 'package:book_charm/screens/games/book_reading_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import '../../../utils/download/download_file.dart';

class BookDetailPage extends StatefulWidget {
  final String url;
  final String bookName;
  final String authorName;
  final String? downloadUrl;
  bool isLibrary;
  BookDetailPage({
    required this.url,
    required this.bookName,
    required this.authorName,
    this.isLibrary = false,
    this.downloadUrl,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  // Replace with the actual path to the book file in the device's storage
  String bookFilePath = '/path/to/book/file.txt';

  // State variable to track book availability
  bool isBookAvailable = false;

  @override
  void initState() {
    super.initState();
    checkBookAvailability();
  }

  // Function to check if the book file exists
  void checkBookAvailability() async {
    final externalDir = await getExternalStorageDirectory();

    if (externalDir == null) {
      // External storage is not available
      throw Exception('External storage not available');
    }

    final filePath = '${externalDir.path}/${widget.bookName}';
    final file = File(filePath);
    setState(() {
      isBookAvailable = File(bookFilePath).existsSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Hero(
              tag: 'bookTileHeroTag${widget.bookName}',
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: widget.isLibrary == true
                        ? CachedNetworkImageProvider(widget.url)
                        : AssetImage(widget.url) as ImageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.only(top: 40),
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: widget.isLibrary
                            ? CachedNetworkImage(
                                imageUrl: widget.url,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                widget.url,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bookName,
                  style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.authorName,
                  style: const TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
                const SizedBox(height: 16.0),
                // Chips about the book
                const Wrap(
                  spacing: 8.0,
                  children: [
                    Chip(label: Text('Fiction')),
                    Chip(label: Text('Romance')),
                    // Add more chips as needed
                  ],
                ),
                const SizedBox(height: 16.0),
                // Book details, description, etc.
                const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                  'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 16.0),

                // Download button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement your download functionality here
                      scrapePreTagContent(
                        url: widget.downloadUrl ?? '',
                        bookName: widget.bookName,
                        authorName: widget.authorName,
                      );
                      // Navigator.push(
                      //     context, MaterialPageRoute(builder: (context) => const BookReadingScreen()));
                    },
                    child: const Text('Download'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

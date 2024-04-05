import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:book_charm/screens/games/book_reading_screen.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../../utils/download/download_file.dart';

class BookDetailPage extends StatefulWidget {
  final String url;
  final String bookName;
  final String authorName;
  final String? downloadUrl;
  bool isNetworkImage;
  BookDetailPage({
    required this.url,
    required this.bookName,
    required this.authorName,
    this.isNetworkImage = false,
    this.downloadUrl,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool isLoading = false;
  bool isBookAvailable = false;
  final LocalStorage storage = LocalStorage('downloadedBooks');
// Function to add downloaded book to local storage
  void addDownloadedBook() {
    List<dynamic> downloadedBooks = storage.getItem('books') ?? [];
    log('${downloadedBooks.length} ${downloadedBooks..toString()}');

    // Check if the book is not already in the list
    bool isBookAlreadyAdded = downloadedBooks.any((book) =>
        book['bookName'] == widget.bookName &&
        book['authorName'] == widget.authorName);

    if (!isBookAlreadyAdded) {
      downloadedBooks.add({
        'bookName': widget.bookName,
        'authorName': widget.authorName,
        'filePath': '${widget.bookName}_${widget.authorName}.pdf',
        'url': widget.url,
        'downloadUrl': widget.downloadUrl,
      });

      storage.setItem('books', downloadedBooks);

      log('${downloadedBooks.length} updated the books list');
      addBooksDataToFirestore(downloadedBooks);
    }
  }

  void addBooksDataToFirestore(List<dynamic> downloadedBooks) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    // Add sample data to Firestore
    firestore
        .collection('MyBooks')
        .doc(user?.uid)
        .set({"myBooks": downloadedBooks}).then((value) {
      log('Sample data added to Firestore');
    }).catchError((error) {
      log('Failed to add sample data: $error');
    });
  }

  @override
  void initState() {
    checkBookAvailability();
    super.initState();
  }

  String? _downloadMessage;
  Future<void> checkBookAvailability() async {
    final externalDir = await getExternalStorageDirectory();

    if (externalDir == null) {
      throw Exception('External storage not available');
    }

    final filePath =
        '${externalDir.path}/Download/${widget.bookName}_${widget.authorName}.pdf';
    final file = File(filePath);

    setState(() {
      isBookAvailable = file.existsSync();
      isLoading = false;
    });
    if (isBookAvailable) {}
    log('isBookAvailable $isBookAvailable');
  }

  // Future<void> downloadPdfFile({
  //   required String url,
  //   required String bookName,
  //   required String authorName,
  // }) async {
  //   setState(() {
  //     _downloadMessage = 'Downloading...';
  //   });

  //   final extDir = await getExternalStorageDirectory();
  //   final String dirPath = '${extDir?.path}/Download';
  //   await Directory(dirPath).create(recursive: true);
  //   final String filePath = '$dirPath/${bookName}_$authorName.pdf';

  //   final http.Client client = http.Client();
  //   final http.Request request = http.Request('GET', Uri.parse(url));

  //   final http.StreamedResponse response = await client.send(request);
  //   final File file = File(filePath);
  //   int totalBytes = response.contentLength ?? 0;
  //   int downloadedBytes = 0;

  //   response.stream.listen(
  //     (List<int> chunk) {
  //       file.writeAsBytesSync(chunk, mode: FileMode.append);
  //       downloadedBytes += chunk.length;
  //       setState(() {
  //         _downloadMessage =
  //             'Downloading... ${(downloadedBytes / totalBytes * 100).toStringAsFixed(2)}%';
  //         log('Downloading... ${(downloadedBytes / totalBytes * 100).toStringAsFixed(2)}%');
  //       });
  //       showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //             title: Text("Downloading"),
  //             content: Row(
  //               children: [
  //                 Expanded(
  //                     child: LinearProgressIndicator(
  //                   value: (downloadedBytes / totalBytes),
  //                 )),
  //                 Text(
  //                     "${(downloadedBytes / totalBytes * 100).toStringAsFixed(2)}%")
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //     onDone: () {
  //       setState(() {
  //         _downloadMessage = 'Download complete. File saved to: $filePath';
  //       });
  //       log('Downloaded Successfully');
  //     },
  //     onError: (error) {
  //       setState(() {
  //         _downloadMessage = 'Error occurred while downloading file';
  //       });
  //       log('Error occurred while downloading file: $error');
  //     },
  //   );
  // }

  Future<void> downloadPdfFile(
      {required String url,
      required String bookName,
      required String authorName}) async {
    setState(() {
      _downloadMessage = 'Downloading...';
    });

    final extDir = await getExternalStorageDirectory();
    final String dirPath = '${extDir?.path}/Download';
    await Directory(dirPath).create(recursive: true);
    final String filePath =
        '$dirPath/${bookName}_$authorName.pdf'; // Change the file name as needed

    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    setState(() {
      _downloadMessage = 'Download complete. File saved to: $filePath';
    });
    log('Downloaded Successfully');
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
                    image: widget.isNetworkImage == true
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
                        padding: const EdgeInsets.only(top: 40),
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: widget.isNetworkImage
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
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
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
                    onPressed: () async {
                      // Implement your download functionality here
                      if (!isBookAvailable) {
                        setState(() {
                          isLoading = true;
                        });
                        await downloadPdfFile(
                          url: widget.downloadUrl ?? '',
                          bookName: widget.bookName,
                          authorName: widget.authorName,
                        );
                        await checkBookAvailability();
                        addDownloadedBook();
                        log('loading $isLoading');
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookReadingScreen(
                                bookName: widget.bookName,
                                authorName: widget.authorName),
                          ),
                        );
                      }
                    },
                    child: isBookAvailable
                        ? const Text('Read')
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Download'),
                              const SizedBox(width: 10),
                              isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.primaryColor),
                                    )
                                  : Container()
                            ],
                          ),
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

import 'dart:ui';

import 'package:book_charm/screens/games/book_reading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BookDetailPage extends StatelessWidget {
  final String url;
  final String text1;
  final String text2;

  const BookDetailPage({
    required this.url,
    required this.text1,
    required this.text2,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Hero(
              tag: 'bookTileHeroTag$text1',
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(url),
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
                        child: Image.asset(
                          url,
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
                  text1,
                  style: const TextStyle(
                      fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                Text(
                  text2,
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

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BookReadingScreen()));
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


// import 'dart:ui';

// import 'package:flutter/material.dart';

// class BookDetailPage extends StatelessWidget {
//   final String url;
//   final String text1;
//   final String text2;

//   const BookDetailPage(
//       {required this.url, required this.text1, required this.text2});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Book Details'),
//       ),
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Background with blur effect
//           Image.asset(
//             url,
//             fit: BoxFit.cover,
//           ),
//           Positioned.fill(
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//               child: Container(
//                 color:
//                     Colors.black.withOpacity(0.3), // Adjust opacity as needed
//               ),
//             ),
//           ),
//           // Centered book image and details
//           Center(
//             child: Hero(
//               tag:
//                   'bookTileHeroTag$text1', // Same tag as in the previous widget
//               child: Container(
//                 height: MediaQuery.of(context).size.height *
//                     0.3, // Adjust as needed
//                 width:
//                     MediaQuery.of(context).size.width * 0.5, // Adjust as needed
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8.0),
//                   child: Image.asset(
//                     url,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           // Book details
//           Positioned(
//             bottom: 16.0,
//             left: 16.0,
//             right: 16.0,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   text1,
//                   style: TextStyle(
//                       fontSize: 24.0,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//                 Text(
//                   text2,
//                   style: TextStyle(fontSize: 18.0, color: Colors.white),
//                 ),
//                 SizedBox(height: 16.0),
//                 // Add other book details, chips, download button, etc.
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

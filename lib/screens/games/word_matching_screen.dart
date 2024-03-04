import 'package:flutter/material.dart';
import 'dart:math';

List<T> shuffleCopy<T>(List<T> listToShuffle) {
  final shuffledList = List<T>.from(listToShuffle); // Create a copy
  shuffledList.shuffle(Random()); // Shuffle the copy
  return shuffledList;
}

class WordMatchingScreen extends StatefulWidget {
  @override
  _WordMatchingScreenState createState() => _WordMatchingScreenState();
}

class _WordMatchingScreenState extends State<WordMatchingScreen> {
  final List<Map<String, String>> wordPairs = [
    {'english': 'Apple', 'spanish': 'Manzana'},
    {'english': 'Banana', 'spanish': 'Plátano'},
    {'english': 'Cherry', 'spanish': 'Cereza'},
    {'english': 'Orange', 'spanish': 'Naranja'},
  ];

  @override
  Widget build(BuildContext context) {
    const wordWidth = 200.0; // Adjust this value to your desired width
    wordPairs.shuffle();
    List<Map<String, String>> shuffled = shuffleCopy(wordPairs);
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Matching Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Draggable List
            Column(
              children: wordPairs.map((pair) {
                final englishWord = pair['english'];
                return Draggable<String>(
                  data: englishWord,
                  feedback: Material(
                    child: SizedBox(
                      // Use SizedBox for fixed size
                      width: wordWidth,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.blue.withOpacity(0.7),
                        child: Text(
                          englishWord!,
                          overflow: TextOverflow.ellipsis, // Handle overflow
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Container(),
                  child: SizedBox(
                    // Use SizedBox for fixed size
                    width: wordWidth,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.all(8),
                      color: Colors.yellow,
                      child: Text(
                        englishWord,
                        overflow: TextOverflow.ellipsis, // Handle overflow
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // DragTarget List
            Column(
              children: shuffled.map((pair) {
                final spanishWord = pair['spanish'];
                return DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return SizedBox(
                      // Use SizedBox for fixed size
                      width: wordWidth,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(8),
                        color: Colors.red,
                        child: Text(
                          spanishWord!,
                          overflow: TextOverflow.ellipsis, // Handle overflow
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                  onWillAcceptWithDetails: (data) => true,
                  onAcceptWithDetails: (data) {
                    // Check if the english word matches the spanish word
                    final englishWord = wordPairs.firstWhere(
                        (pair) => pair['english'] == data.data)['spanish'];
                    if (englishWord == spanishWord) {
                      // log(data.data);
                      print("Accepted data: $data");
                      setState(() {
                        wordPairs.remove(pair); // Remove the matched pair
                      });
                    } else {
                      print("Words don't match.");
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

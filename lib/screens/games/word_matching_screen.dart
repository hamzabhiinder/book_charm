import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';

class WordMatchingScreen extends StatefulWidget {
  @override
  _WordMatchingScreenState createState() => _WordMatchingScreenState();
}

class _WordMatchingScreenState extends State<WordMatchingScreen> {
  final Random _random = Random(); // Create a Random object for shuffling

  final List<Map<String, String>> wordPairs = [
    {'english': 'Hello', 'spanish': 'Hola'},
    {'english': 'Goodbye', 'spanish': 'Adiós'},
    {'english': 'Friend', 'spanish': 'Amigo'},
    {'english': 'Family', 'spanish': 'Familia'},
    // {'english': 'Water', 'spanish': 'Agua'},
    // {'english': 'Sun', 'spanish': 'Sol'},
    // {'english': 'Moon', 'spanish': 'Luna'},
  ];
  @override
  void initState() {
    super.initState();
    wordPairs.shuffle(
        _random); // Shuffle the wordPairs list on widget initialization
  }

  @override
  Widget build(BuildContext context) {
    const wordWidth = 200.0; // Adjust this value to your desired width

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
                  onDragCompleted: () => print('completed'),
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
              children: wordPairs.map((pair) {
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
                      print(data.data);
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

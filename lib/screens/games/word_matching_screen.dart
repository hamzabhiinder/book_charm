import 'package:book_charm/utils/stats/overall_stats.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:localstorage/localstorage.dart';

class WordMatchingScreen extends StatefulWidget {
  @override
  _WordMatchingScreenState createState() => _WordMatchingScreenState();
}

class _WordMatchingScreenState extends State<WordMatchingScreen> {
  List<Map<String, String>> wordPairs = [];
  int score = 0;
  late OverallStats overallStats;
  //  =      OverallStats(xp: 0, streak: 0, time: 0, lessonsCompleted: 0);
  List<Map<String, String>> selectedWords = [];
  final LocalStorage storage = LocalStorage('dictionary.json');
  Future<void> loadDictionary() async {
    await storage.ready;
    print('Storage is ready');

    var storedData = storage.getItem('wordPairs');
    print('Stored data: $storedData');

    if (storedData != null) {
      if (storedData is List<dynamic>) {
        List<Map<String, String>> castedData = [];

        for (var item in storedData) {
          if (item is Map<String, dynamic>) {
            Map<String, String> stringMap = {};

            // Convert keys and values to strings
            item.forEach((key, value) {
              stringMap[key] = value.toString();
            });

            castedData.add(stringMap);
          } else {
            print('Error: Unexpected data format in dictionary.json');
          }
        }
        setState(() {
          wordPairs = castedData;
        });
      } else {
        print('Error: Unexpected data format in dictionary.json');
      }
    }
    print('Updated wordPairs: $wordPairs');
  }

  @override
  void initState() {
    super.initState();
    loadDictionary().then((value) {
      selectedWords = shuffleCopy(wordPairs)..shuffle();
      selectedWords = selectedWords.take(5).toList();
    });
    OverallStats.loadFromLocalStorage().then((value) => overallStats = value);
  }

  void updateScoreLocal(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        score += 5;
        try {
          overallStats.updateScore(5);
        } catch (e) {
          print(e);
        }
      } else {
        try {
          overallStats.updateScore(1);
        } catch (e) {
          print(e);
        }
        score += 1;
      }
    });
    if (selectedWords.isEmpty) {
      setState(() {
        score += 10;
        try {
          overallStats.completeLesson();
          // overallStats.updateScore(5);
        } catch (e) {
          print(e);
        }
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content:
                Text('You completed the lesson.\nYour Final Score: $score'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(
                      context); // Navigate back to the previous screen
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const wordWidth = 200.0; // Adjust this value to your desired width

    List<Map<String, String>> shuffled = shuffleCopy(selectedWords);

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
              children: selectedWords.map((pair) {
                final englishWord = pair['meaning'];
                return Draggable<String>(
                  data: englishWord,
                  feedback: Material(
                    child: SizedBox(
                      width: wordWidth,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.blue.withOpacity(0.7),
                        child: Text(
                          englishWord!,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Container(),
                  child: SizedBox(
                    width: wordWidth,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.all(8),
                      color: Colors.yellow,
                      child: Text(
                        englishWord,
                        overflow: TextOverflow.ellipsis,
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
                final spanishWord = pair['word'];
                return DragTarget<String>(
                  builder: (context, candidateData, rejectedData) {
                    return SizedBox(
                      width: wordWidth,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(8),
                        color: Colors.red,
                        child: Text(
                          spanishWord!,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                  onWillAcceptWithDetails: (data) => true,
                  onAcceptWithDetails: (data) {
                    final englishWord = wordPairs.firstWhere(
                        (pair) => pair['meaning'] == data.data)['word'];
                    if (englishWord == spanishWord) {
                      print("Accepted data: $data");
                      setState(() {
                        selectedWords.remove(pair);
                        updateScoreLocal(
                            true); // Update score for correct answer
                      });
                    } else {
                      print("Words don't match.");
                      updateScoreLocal(
                          false); // Update score for incorrect answer
                    }
                  },
                );
              }).toList(),
            ),
            Text('Score: $score'),
          ],
        ),
      ),
    );
  }
}

List<T> shuffleCopy<T>(List<T> listToShuffle) {
  final shuffledList = List<T>.from(listToShuffle);
  shuffledList.shuffle(Random());
  return shuffledList;
}

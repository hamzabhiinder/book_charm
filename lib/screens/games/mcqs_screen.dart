import 'dart:math';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class McqsScreen extends StatefulWidget {
  const McqsScreen({Key? key}) : super(key: key);

  @override
  _McqsScreenState createState() => _McqsScreenState();
}

class _McqsScreenState extends State<McqsScreen> {
  int currentIndex = 0;
  int score = 0;
  int totalXP = 0; // Added for total XP tracking
  late Map<String, String> currentWordPair;
  List<String> options = [];

  List<Map<String, String>> wordPairs = [];

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
    loadDictionary().then((_) => getNextWordPair());
  }

  void getNextWordPair() {
    currentWordPair = wordPairs[currentIndex];
    generateOptions();
  }

  void generateOptions() {
    options.clear();
    options.add(currentWordPair['spanish']!);

    // Generate two more random options
    while (options.length < 3 && wordPairs.length > 3) {
      final randomOption =
          wordPairs[Random().nextInt(wordPairs.length)]['spanish']!;
      if (!options.contains(randomOption)) {
        options.add(randomOption);
      }
    }

    options.shuffle();
  }

  void checkAnswer(String selectedOption) {
    int questionXP = 0; // XP earned for the current question

    if (selectedOption == currentWordPair['spanish']) {
      // Correct answer
      setState(() {
        score++;
        questionXP = 5; // You get 5 XP for a correct answer
      });
    } else {
      // Incorrect answer
      questionXP = 1; // You get 1 XP for an incorrect answer
    }

    totalXP += questionXP;

    if (currentIndex < wordPairs.length - 1) {
      setState(() {
        currentIndex++;
        getNextWordPair();
      });
    } else {
      totalXP += 10; // You get 10 extra XP for completing the lesson

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Congratulations!'),
            content: Text(
                'You completed the lesson.\nYour Final Score: $score \nYour Final Xp: $totalXP \n for this lesson'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCQs Quiz'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'What is the meaning of "${currentWordPair['english']}" in Spanish?',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Column(
              children: options.map((option) {
                return ElevatedButton(
                  onPressed: () => checkAnswer(option),
                  child: Text(option),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: $score',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'XP: $totalXP',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

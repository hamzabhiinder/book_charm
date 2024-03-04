import 'dart:math';
import 'package:flutter/material.dart';

class McqsScreen extends StatefulWidget {
  const McqsScreen({Key? key}) : super(key: key);

  @override
  _McqsScreenState createState() => _McqsScreenState();
}

class _McqsScreenState extends State<McqsScreen> {
  int currentIndex = 0;
  int score = 0;
  late Map<String, String> currentWordPair;
  List<String> options = [];

  List<Map<String, String>> wordPairs = [
    {'english': 'Hello', 'spanish': 'Hola'},
    {'english': 'Goodbye', 'spanish': 'Adiós'},
    {'english': 'Friend', 'spanish': 'Amigo'},
    {'english': 'Family', 'spanish': 'Familia'},
    {'english': 'Water', 'spanish': 'Agua'},
    {'english': 'Sun', 'spanish': 'Sol'},
    {'english': 'Moon', 'spanish': 'Luna'},
    {'english': 'Food', 'spanish': 'Comida'},
    {'english': 'Love', 'spanish': 'Amor'},
    {'english': 'Time', 'spanish': 'Tiempo'},
    {'english': 'Book', 'spanish': 'Libro'},
    // Add more word pairs as needed
  ];
  @override
  void initState() {
    super.initState();
    getNextWordPair();
  }

  void getNextWordPair() {
    currentWordPair = wordPairs[currentIndex];
    generateOptions();
  }

  void generateOptions() {
    options.clear();
    options.add(currentWordPair['spanish']!);

    // Generate two more random options
    while (options.length < 3) {
      final randomOption =
          wordPairs[Random().nextInt(wordPairs.length)]['spanish']!;
      if (!options.contains(randomOption)) {
        options.add(randomOption);
      }
    }

    options
        .shuffle(); // Shuffle the options so the correct answer isn't always in the same position
  }

  void checkAnswer(String selectedOption) {
    if (selectedOption == currentWordPair['spanish']) {
      // Correct answer
      setState(() {
        score++;
      });
    }

    // Move to the next question or end the quiz
    if (currentIndex < wordPairs.length - 1) {
      setState(() {
        currentIndex++;
        getNextWordPair();
      });
    } else {
      // End of quiz, you can navigate to a result screen or perform any other action
      // For simplicity, we'll just show an alert with the score
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quiz Completed'),
          content: Text('Your score: $score'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
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
          ],
        ),
      ),
    );
  }
}

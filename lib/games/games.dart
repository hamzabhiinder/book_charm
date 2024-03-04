import 'package:book_charm/screens/games/flip_cards_screen.dart';
import 'package:book_charm/screens/games/mcqs_screen.dart';
import 'package:book_charm/screens/games/word_matching_screen.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Games'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to Flip Cards game screen
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FlipCardsScreen()));
              },
              child: const Text('Flip Cards'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to Word Matching game screen
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WordMatchingScreen()));
              },
              child: const Text('Word Matching'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to MCQs game screen
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const McqsScreen()));
              },
              child: const Text('MCQs'),
            ),
          ],
        ),
      ),
    );
  }
}

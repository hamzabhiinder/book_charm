import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlipCardsScreen extends StatefulWidget {
  const FlipCardsScreen({Key? key}) : super(key: key);

  @override
  _FlipCardsScreenState createState() => _FlipCardsScreenState();
}

class _FlipCardsScreenState extends State<FlipCardsScreen> {
  List<Map<String, String>> wordPairs = [
    {'english': 'Hello', 'spanish': 'Hola'},
    {'english': 'Goodbye', 'spanish': 'Adiós'},
    // Add more word pairs as needed
  ];

  int currentIndex = 0;
  bool isCardFlipped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flip Cards Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200, // Adjust the width as needed
              height: 300, // Adjust the height as needed
              child: FlipCard(
                direction: FlipDirection.HORIZONTAL,
                onFlipDone: (isFront) {
                  setState(() {
                    isCardFlipped = isFront;
                  });
                },
                front: Container(
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      wordPairs[currentIndex]['english']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                back: Container(
                  color: Colors.grey,
                  child: Center(
                    child: Text(
                      wordPairs[currentIndex]['spanish']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Show previous word
                    if (currentIndex > 0) {
                      setState(() {
                        currentIndex--;
                        isCardFlipped = false;
                      });
                    }
                  },
                  child: const Text('Previous'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // Show next word
                    if (currentIndex < wordPairs.length - 1) {
                      setState(() {
                        currentIndex++;
                        isCardFlipped = false;
                      });
                    }
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

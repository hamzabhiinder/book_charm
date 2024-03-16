import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:localstorage/localstorage.dart';

class FlipCardsScreen extends StatefulWidget {
  const FlipCardsScreen({Key? key}) : super(key: key);

  @override
  _FlipCardsScreenState createState() => _FlipCardsScreenState();
}

class _FlipCardsScreenState extends State<FlipCardsScreen> {
  List<Map<String, String>> wordPairs = [];
  final LocalStorage storage = LocalStorage('dictionary.json');

  void loadDictionary() async {
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
    loadDictionary();
    wordPairs = wordPairs.take(10).toList();
  }

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
                      wordPairs.isNotEmpty
                          ? wordPairs[currentIndex]['meaning']!
                          : "Empty",
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
                      wordPairs.isNotEmpty
                          ? wordPairs[currentIndex]['word']!
                          : "Empty",
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

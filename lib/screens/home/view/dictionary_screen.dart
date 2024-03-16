import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
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

  Future<void> deleteWordPair(int index) async {
    setState(() {
      wordPairs.removeAt(index);
    });
    await storage.ready;
    await storage.setItem('wordPairs', wordPairs);
  }

  @override
  void initState() {
    super.initState();
    loadDictionary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dictionary'),
      ),
      body: ListView.builder(
        itemCount: wordPairs.length,
        itemBuilder: (context, index) {
          final pair = wordPairs[index];
          return ListTile(
            title: Text(pair['meaning'] ?? ''),
            subtitle: Text(pair['word'] ?? ''),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteWordPair(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

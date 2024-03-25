
import 'dart:async';
import 'dart:developer';

import 'package:book_charm/screens/profile/view/widget/language_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class DictionaryProvider extends ChangeNotifier {
  final LocalStorage storage = LocalStorage('dictionary.json');
  List<Map<String, dynamic>> _wordPairs = [];
  List<Map<String, dynamic>> get wordPairs => _wordPairs;

  DictionaryProvider() {
    loadDictionary();
  }

  Future<void> loadDictionary() async {
    await storage.ready;
    print('Storage is ready');

    var firestoreData = await getDictionaryDataFromFirestore();
    print('Firestore data: $firestoreData');

    if (firestoreData != null) {
      await storage.setItem('wordPairs', firestoreData);
      _wordPairs = firestoreData;
    } else {
      var storedData = storage.getItem('wordPairs');
      print('Stored data: $storedData');

      if (storedData != null) {
        if (storedData is List<dynamic>) {
          List<Map<String, String>> castedData = [];

          for (var item in storedData) {
            if (item is Map<String, dynamic>) {
              Map<String, String> stringMap = {};

              item.forEach((key, value) {
                stringMap[key] = value.toString();
              });

              castedData.add(stringMap);
            } else {
              print('Error: Unexpected data format in dictionary.json');
            }
          }
          _wordPairs = castedData;
        } else {
          print('Error: Unexpected data format in dictionary.json');
        }
      }
    }
    print('Updated wordPairs: $_wordPairs');
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>?> getDictionaryDataFromFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    try {
      DocumentSnapshot snapshot = await firestore.collection('Dictionary').doc(user?.uid).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        // List<Map<String, dynamic>> wordPairs = List<Map<String, dynamic>>.from(data['fr']);
        List<Map<String, dynamic>> wordPairs;

        if (data['en'] != null) {
          wordPairs = List<Map<String, dynamic>>.from(data['en']);
        } else {
          wordPairs = [];
        }
        return wordPairs;
      } else {
        log('Document does not exist');
        return [];
      }
    } catch (error) {
      log('Error retrieving data from Firestore: $error');
      return null;
    }
  }

  Future<void> deleteWordPair(int index) async {
    try {
      Map<String, dynamic> pairToDelete = _wordPairs[index];
      _wordPairs.removeAt(index);

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await firestore.collection('Dictionary').doc(user.uid).update({
          'fr': FieldValue.arrayRemove([pairToDelete])
        });
      }

      await storage.ready;
      await storage.setItem('wordPairs', _wordPairs);
      notifyListeners();
    } catch (error) {
      print('Error deleting word pair: $error');
    }
  }
}

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<DictionaryProvider>().loadDictionary();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
        actions: [
          IconButton(
              onPressed: () {
                context.read<DictionaryProvider>().loadDictionary();
              },
              icon: Icon(Icons.abc_outlined))
        ],
      ),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, _) {
          if (provider.wordPairs.isEmpty) {
            return const Center(
              child: Text("No Dictionary"),
            );
          } else {
            return ListView.builder(
              itemCount: provider.wordPairs.length,
              itemBuilder: (context, index) {
                final pair = provider.wordPairs[index];
                return ListTile(
                  title: Text(pair['meaning'] ?? ''),
                  subtitle: Text(pair['word'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          provider.deleteWordPair(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

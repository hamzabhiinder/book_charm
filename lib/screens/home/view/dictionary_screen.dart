import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  List<Map<String, dynamic>> wordPairs = [];
  final LocalStorage storage = LocalStorage('dictionary.json');

  Future<List<Map<String, dynamic>>?> getDictionaryDataFromFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    try {
      DocumentSnapshot snapshot =
          await firestore.collection('Dictionary').doc(user?.uid).get();

      // Check if the document exists
      if (snapshot.exists) {
        // Extract data from the snapshot
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> wordPairs =
            List<Map<String, dynamic>>.from(data['fr']);
        return wordPairs;
      } else {
        // Document does not exist
        log('Document does not exist');
        return [];
      }
    } catch (error) {
      log('Error retrieving data from Firestore: $error');
      return null;
    }
  }

  Future<void> loadDictionary1() async {
    await storage.ready;
    print('Storage is ready');

    // Check if data exists in Firestore
    var firestoreData = await getDictionaryDataFromFirestore();
    print('Firestore data: $firestoreData');

    if (firestoreData != null) {
      // Data exists in Firestore, save it to local storage
      await storage.setItem('wordPairs', firestoreData);
      setState(() {
        wordPairs = firestoreData;
      });
    } else {
      // Data does not exist in Firestore, load it from local storage
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
    }
    print('Updated wordPairs: $wordPairs');
  }

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
    try {
      // Get the word pair to delete from Firestore
      Map<String, dynamic> pairToDelete = wordPairs[index];

      // Remove the word pair from the local list
      wordPairs.removeAt(index);

      // Update the 'wordPairs' field in Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await firestore.collection('Dictionary').doc(user.uid).update({
          'fr': FieldValue.arrayRemove([pairToDelete])
        });
      }

      // Update the local storage
      await storage.ready;
      await storage.setItem('wordPairs', wordPairs);
      setState(() {});
    } catch (error) {
      print('Error deleting word pair: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    loadDictionary1();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
      ),
      body: wordPairs.isEmpty
          ? const Center(
              child: Text("No Dictionary "),
            )
          : ListView.builder(
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
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          log(' wordPairs ${wordPairs[0]}');
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

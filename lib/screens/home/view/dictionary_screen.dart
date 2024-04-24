import 'dart:async';
import 'dart:developer';

import 'package:book_charm/screens/profile/view/widget/language_selector.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DictionaryProvider extends ChangeNotifier {
  final LocalStorage storage = LocalStorage('dictionary.json');
  List<Map<String, dynamic>> _wordPairs = [];
  List<Map<String, dynamic>> get wordPairs => _wordPairs;

  // DictionaryProvider() {
  //   loadDictionary();
  // }
  void updateLocalStorage(List<Map<String, dynamic>> data) async {
    await storage.ready;
    await storage.setItem('wordPairs', data);
  }

  Future<void> updateFirestoreData(
      List<Map<String, dynamic>> data, BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    LanguageProvider lang =
        Provider.of<LanguageProvider>(context, listen: false);

    try {
      await firestore
          .collection('Dictionary')
          .doc(user?.uid)
          .set({lang.selectedLanguageCode: data}, SetOptions(merge: true));

      print('Firestore data updated successfully.');
    } catch (error) {
      print('Error updating Firestore data: $error');
    }
  }

  Future<void> loadDictionary(context) async {
    await storage.ready;
    print('Storage is ready');

    var firestoreData = await getDictionaryDataFromFirestore(context);
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

  void addDictionaryDataToFirestore(
      String language, List<Map<String, dynamic>> wordPairs) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    // 'Dictionary' collection se document ko get karen
    DocumentReference docRef =
        firestore.collection('Dictionary').doc(user?.uid);

    docRef.get().then((doc) {
      if (doc.exists) {
        // Agar document maujood hai to uski data ko update karen
        Map<String, dynamic>? docData = doc.data() as Map<String, dynamic>;
        if (docData != null) {
          Map<String, dynamic> data = Map.from(docData);
          data[language] = wordPairs;
          docRef.update(data).then((value) {
            log('Data updated successfully');
          }).catchError((error) {
            log('Failed to update data: $error');
          });
        }
      } else {
        // Agar document nahi maujood hai to nayi data set karen
        Map<String, dynamic> data = {language: wordPairs};
        docRef.set(data).then((value) {
          log('Data added successfully');
        }).catchError((error) {
          log('Failed to add data: $error');
        });
      }
    }).catchError((error) {
      log('Error fetching document: $error');
    });
  }

  Future<void> markWordAsLearned(
      Map<String, dynamic> pair, BuildContext context) async {
    try {
      pair['islearned'] = 'true';
      notifyListeners();

      DateTime now = DateTime.now();
      String formattedDateTime = now.toIso8601String();
      pair['learnedTime'] = formattedDateTime;
      await updateFirestoreData(wordPairs, context)
          .then((value) => updateLocalStorage(wordPairs));
      log('$wordPairs');
    } catch (e) {
      log('$e');
    }
  }

  Future<void> markWordAsUnLearned(
      Map<String, dynamic> pair, BuildContext context) async {
    try {
      pair['islearned'] = 'false';
      notifyListeners();
      await updateFirestoreData(wordPairs, context)
          .then((value) => updateLocalStorage(wordPairs));
      log('$wordPairs');
    } catch (e) {
      log('$e');
    }
  }

  Future<List<Map<String, dynamic>>?> getDictionaryDataFromFirestore(
      context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    LanguageProvider lang =
        Provider.of<LanguageProvider>(context, listen: false);
    try {
      DocumentSnapshot snapshot =
          await firestore.collection('Dictionary').doc(user?.uid).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        // List<Map<String, dynamic>> wordPairs = List<Map<String, dynamic>>.from(data['fr']);
        List<Map<String, dynamic>> wordPairs;

        if (data[lang.selectedLanguageCode] != null) {
          wordPairs =
              List<Map<String, dynamic>>.from(data[lang.selectedLanguageCode]);
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var lang = prefs.getString('selectedLanguageCode') ?? 'en';
      if (user != null) {
        await firestore.collection('Dictionary').doc(user.uid).update({
          '$lang': FieldValue.arrayRemove([pairToDelete])
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

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({Key? key}) : super(key: key);

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call your function here
    log('dict update');
  }

  @override
  void dispose() {
    super.dispose();
    log('dict update');
  }

  @override
  Widget build(BuildContext context) {
    context.read<DictionaryProvider>().loadDictionary(context).then((e) {});
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary'),
        actions: [
          // IconButton(
          //     onPressed: () {
          //       context.read<DictionaryProvider>().loadDictionary(context);
          //     },
          //     icon: Icon(Icons.abc_outlined))
        ],
      ),
      body: Consumer<DictionaryProvider>(
        builder: (context, provider, _) {
          if (provider.wordPairs.isEmpty) {
            return const Center(
              child: Text("No Dictionary"),
            );
          } else {
            var dictionary_words =
                provider.wordPairs.where((pair) => pair['islearned'] != 'true');
            var learned_words =
                provider.wordPairs.where((pair) => pair['islearned'] == 'true');
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Learning',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        // Add any other styles you want
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: dictionary_words.length,
                    itemBuilder: (context, index) {
                      final List<Map<String, dynamic>> unlearnedWordPairs =
                          dictionary_words.toList();
                      final pair = unlearnedWordPairs[index];
                      return Slidable(
                        endActionPane: ActionPane(
                          motion: BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (c) {
                                print('learned');
                                provider
                                    .markWordAsLearned(pair, context)
                                    .then((value) => setState(() {}));
                              },
                              backgroundColor:
                                  Color.fromARGB(255, 197, 153, 251),
                              foregroundColor: Colors.white,
                              // icon: Icons.delete,
                              label: "Mark as Learned",
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(pair['meaning'].toString().trim()),
                          subtitle: Text(pair['word'].toString().trim()),
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
                        ),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Learned',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        // Add any other styles you want
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: learned_words.length,
                    itemBuilder: (context, index) {
                      final List<Map<String, dynamic>> unlearnedWordPairs =
                          learned_words.toList();
                      final pair = unlearnedWordPairs[index];
                      return Slidable(
                        endActionPane: ActionPane(
                          motion: BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (c) {
                                print('learned');
                                provider
                                    .markWordAsUnLearned(pair, context)
                                    .then((value) => setState(() {}));
                              },
                              backgroundColor: Color.fromARGB(255, 253, 57, 51),
                              foregroundColor: Colors.white,
                              // icon: Icons.delete,
                              label: "Unmark as learned",
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(pair['meaning'].toString().trim()),
                          subtitle: Text(pair['word'].toString().trim()),
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
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

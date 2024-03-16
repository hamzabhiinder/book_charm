import 'dart:developer';
import 'package:book_charm/utils/download/download_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';
import 'package:localstorage/localstorage.dart';

class BookReadingScreen extends StatefulWidget {
  final String bookName;
  final String authorName;
  const BookReadingScreen(
      {super.key, required this.bookName, required this.authorName});

  @override
  State<BookReadingScreen> createState() => _BookReadingScreenState();
}

class _BookReadingScreenState extends State<BookReadingScreen> {
  String selectTextValue = '';
  String translateTextValue = '';
  final translator = GoogleTranslator();

  final LocalStorage storage = LocalStorage('dictionary.json');
  bool initialized = false;
  List<Map<String, dynamic>> wordPairs = [];

  void saveDictionary() {
    storage.setItem('wordPairs', wordPairs);
    print(wordPairs);
  }

  void addDictionaryDataToFirestore(
      String language, List<Map<String, dynamic>> wordPairs) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    // Add sample data to Firestore
    firestore.collection('Dictionary').doc(user?.uid).set({
      language: wordPairs,
    }).then((value) {
      log('Sample data added to Firestore');
    }).catchError((error) {
      log('Failed to add sample data: $error');
    });
  }

  void addWordPair(String english, String spanish) {
    if (!wordPairs.any((pair) =>
        pair['meaning'] == english.toLowerCase() &&
        pair['word'] == spanish.toLowerCase())) {
      setState(() {
        wordPairs.add(
            {'meaning': english.toLowerCase(), 'word': spanish.toLowerCase()});
        //Add to Firebase

        saveDictionary();
        addDictionaryDataToFirestore('fr', wordPairs);
      });
    } else {
      log('Word pair already exists in the dictionary.');
    }
  }

  void loadDictionary() async {
    await storage.ready;
    var storedData = storage.getItem('wordPairs');
    if (storedData != null) {
      setState(() {
        wordPairs = List<Map<String, dynamic>>.from(storedData);
      });
    }
  }

  void translateAction(String selectedText) async {
    try {
      // Replace 'es' with the language code you want to translate to
      var translatedText =
          await translator.translate(selectedText, from: 'fr', to: 'en');
      log("Translated text: $translatedText");
      selectTextValue = selectedText;
      translateTextValue = translatedText.text;
      setState(() {});
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            // height: 200,
            width: MediaQuery.of(context).size.width,
            child: Column(
              //  mainAxisSize: MainAxisSize.min,
              children: [
                Text("$selectTextValue:\n $translateTextValue"),
                // Text("Translated text: $translateTextValue"),
                TextButton(
                  onPressed: () {
                    addWordPair(selectTextValue, translateTextValue);
                    log('added to dictionary');
                  },
                  child: const Text('Add to dictionary'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      log("Error translating text: $e");
    }
    log("Translate action with text: $selectedText");
  }

  void copyAction(String selectedText) {
    Clipboard.setData(ClipboardData(text: selectedText));
    log("Copied to clipboard: $selectedText");
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void shareAction(String selectedText) {
    Share.share(selectedText, subject: 'Shared Text');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    loadDictionary();
  }

  var myText = "";

  Future<void> fetchData() async {
    try {
      var result =
          await readTextFromFile('${widget.bookName}_${widget.authorName}');

      if (result != null) {
        setState(() {
          myText = result;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //spanish

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Games'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.save))],
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SingleChildScrollView(
          child: SelectableText(
            myText,
            showCursor: true,
            //  scrollPhysics: ClampingScrollPhysics(),
            contextMenuBuilder: (context, editableTextState) =>
                AdaptiveTextSelectionToolbar(
              anchors: editableTextState.contextMenuAnchors,
              children: [
                InkWell(
                  onTap: () {
                    String selectedText = myText.substring(
                      editableTextState.textEditingValue.selection.baseOffset,
                      editableTextState.textEditingValue.selection.extentOffset,
                    );
                    log("Your custom action goes here! $selectedText");
                    translateAction(selectedText);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.translate,
                          size: 15,
                        ),
                        SizedBox(width: 4),
                        Text('Translate'),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    String selectedText = myText.substring(
                      editableTextState.textEditingValue.selection.baseOffset,
                      editableTextState.textEditingValue.selection.extentOffset,
                    );
                    // print("Your custom action goes here! $selectedText");
                    copyAction(selectedText);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy,
                          size: 15,
                        ),
                        SizedBox(width: 4),
                        Text('Copy'),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    String selectedText = myText.substring(
                      editableTextState.textEditingValue.selection.baseOffset,
                      editableTextState.textEditingValue.selection.extentOffset,
                    );
                    shareAction(selectedText);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.share,
                          size: 15,
                        ),
                        SizedBox(width: 4),
                        Text('Share'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

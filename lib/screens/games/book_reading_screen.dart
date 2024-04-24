import 'dart:developer';
import 'dart:io';
import 'package:book_charm/screens/home/view/dictionary_screen.dart';
import 'package:book_charm/utils/download/download_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
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
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
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
    _pdfViewerController = PdfViewerController();

    super.initState();
    loadPdfFilePath();
    loadDictionary();
  }

  Future<void> loadPdfFilePath() async {
    try {
      final Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir == null) {
        throw Exception('External storage not available');
      }
      final String pdfPath =
          '${externalDir.path}/Download/${widget.bookName}_${widget.authorName}.pdf';
      final File pdfFile = File(pdfPath);
      if (!pdfFile.existsSync()) {
        throw Exception('PDF not found: $pdfPath');
      }
      setState(() {
        pdfFilePath = pdfPath;
      });
    } catch (e) {
      print('Error getting PDF path: $e');
    }
  }

  // var pdfFilePath = "";
  String pdfFilePath = '';
  Future<void> fetchData() async {
    try {
      var result = await getPdfPath('${widget.bookName}_${widget.authorName}');

      if (result != null) {
        setState(() {
          pdfFilePath = result;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //spanish
    log('File Name $pdfFilePath');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              context.read<DictionaryProvider>().loadDictionary(context);
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(widget.bookName),
       // actions: [IconButton(onPressed: () {}, icon: Icon(Icons.save))],
      ),
      body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: pdfFilePath.isEmpty
              ? CircularProgressIndicator()
              : SfPdfViewer.file(
                  File('${pdfFilePath}'),
                  onTextSelectionChanged:
                      (PdfTextSelectionChangedDetails details) {
                    if (details.selectedText == null && _overlayEntry != null) {
                      _overlayEntry!.remove();
                      _overlayEntry = null;
                    } else if (details.selectedText != null &&
                        _overlayEntry == null) {
                      //_showContextMenu(context, details);
                    }
                  },
                  key: _pdfViewerKey,
                  controller: _pdfViewerController,
                )),
    );
  }
}

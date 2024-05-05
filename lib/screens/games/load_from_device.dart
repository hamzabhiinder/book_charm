import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:file_picker/file_picker.dart';
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

class PDFViewer extends StatefulWidget {
  final String path;
  const PDFViewer({super.key, required this.path});

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  String selectTextValue = '';
  String translateTextValue = '';

  bool isLoading = false;

  // Future<void> pickPDF() async {
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['pdf'],
  //     );
  //     if (result != null) {
  //       File file = File(result.files.single.path!);
  //       setState(() {
  //         isLoading = true;
  //         path = file.path;
  //       });
  //     }
  //   } on PlatformException catch (e) {
  //     if (kDebugMode) {
  //       print("Unsupported operation" + e.toString());
  //     }
  //   }
  // }

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

    loadDictionary();
  }

  // var pdfFilePath = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ElevatedButton(
            //   onPressed: pickPDF,
            //   child: Text('Pick PDF'),
            // ),
            // SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: SfPdfViewer.file(
                    File('${widget.path!}'),
                    onTextSelectionChanged:
                        (PdfTextSelectionChangedDetails details) {
                      if (details.selectedText == null &&
                          _overlayEntry != null) {
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
            ),
            // Expanded(
            //   child: isLoading
            //       ? SfPdfViewer.file(File(path!))
            //       : Container(),
            // ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:flutter/services.dart'; // For Clipboard
import 'package:share_plus/share_plus.dart';
import 'package:translator/translator.dart';

class BookReadingScreen extends StatefulWidget {
  const BookReadingScreen({super.key});

  @override
  State<BookReadingScreen> createState() => _BookReadingScreenState();
}

class _BookReadingScreenState extends State<BookReadingScreen> {
  final translator = GoogleTranslator();

  void translateAction(String selectedText) async {
    try {
      // Replace 'es' with the language code you want to translate to
      var translatedText =
          await translator.translate(selectedText, from: 'es', to: 'en');
      print("Translated text: $translatedText");
    } catch (e) {
      print("Error translating text: $e");
    }
    print("Translate action with text: $selectedText");
  }

  void copyAction(String selectedText) {
    Clipboard.setData(ClipboardData(text: selectedText));
    print("Copied to clipboard: $selectedText");
  }

  void shareAction(String selectedText) {
    Share.share(selectedText, subject: 'Shared Text');
  }

  @override
  Widget build(BuildContext context) {
    //spanish
    const myText = """Señoras y señores,
Os pido que votéis a favor del sufragio femenino.
Os pido que hagáis justicia a las mujeres.
Os pido que nos deis la oportunidad de 
participar en la vida política de nuestro país.
Muchas gracias.""";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Games'),
      ),
      body: SingleChildScrollView(
        child: SelectableText(
          myText,
          showCursor: true,
          scrollPhysics: ClampingScrollPhysics(),
          contextMenuBuilder: (context, editableTextState) =>
              AdaptiveTextSelectionToolbar(
            anchors: editableTextState.contextMenuAnchors,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    String selectedText = myText.substring(
                      editableTextState.textEditingValue.selection.baseOffset,
                      editableTextState.textEditingValue.selection.extentOffset,
                    );
                    print("Your custom action goes here! $selectedText");
                    translateAction(selectedText);
                  },
                  child: Text('Translate'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    String selectedText = myText.substring(
                      editableTextState.textEditingValue.selection.baseOffset,
                      editableTextState.textEditingValue.selection.extentOffset,
                    );
                    // print("Your custom action goes here! $selectedText");
                    copyAction(selectedText);
                  },
                  child: Text('Copy'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    String selectedText = myText.substring(
                      editableTextState.textEditingValue.selection.baseOffset,
                      editableTextState.textEditingValue.selection.extentOffset,
                    );
                    shareAction(selectedText);
                  },
                  child: Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

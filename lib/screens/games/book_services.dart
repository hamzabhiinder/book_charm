import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class BookFunctionServices {
  final translator = GoogleTranslator();

  void translateAction(String selectedText, BuildContext context) async {
    try {
      // Replace 'es' with the language code you want to translate to
      var translatedText =
          await translator.translate(selectedText, from: 'fr', to: 'en');
      log("Translated text: $translatedText");

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            // height: 200,
            width: MediaQuery.of(context).size.width,
            child: Column(
              //  mainAxisSize: MainAxisSize.min,
              children: [
                Text("$selectedText:\n ${translatedText.text}"),
                // Text("Translated text: $translateTextValue"),
                TextButton(
                  onPressed: () {
                    // addWordPair(selectTextValue, translateTextValue);
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
}

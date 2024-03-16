import 'dart:developer';

import 'package:book_charm/screens/games/book_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:translator/translator.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  String selectTextValue = '';
  String translateTextValue = '';
  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  void _showContextMenu(
      BuildContext context, PdfTextSelectionChangedDetails details) {
    final OverlayState overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalSelectedRegion!.center.dy - 55,
        left: details.globalSelectedRegion!.bottomLeft.dx,
        child: ElevatedButton(
          onPressed: () {
            if (details.selectedText != null) {
              translateAction(details.selectedText!);
              Clipboard.setData(ClipboardData(text: details.selectedText!));
              print('Text copied to clipboard: ${details.selectedText}');
              _pdfViewerController.clearSelection();
            }
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            )),
          ),
          child: const Row(
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
    );
    overlayState.insert(_overlayEntry!);
  }

  void translateAction(String selectedText) async {
    try {
      final translator = GoogleTranslator();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Syncfusion Flutter PDF Viewer'),
          actions: [
            IconButton(
                onPressed: () {
                  _pdfViewerKey.currentState?.openBookmarkView();
                },
                icon: Icon(Icons.bookmark))
          ],
        ),
        body: SfPdfViewer.network(
          'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
          onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
            if (details.selectedText == null && _overlayEntry != null) {
              _overlayEntry!.remove();
              _overlayEntry = null;
            } else if (details.selectedText != null && _overlayEntry == null) {
              _showContextMenu(context, details);
            }
          },
          key: _pdfViewerKey,
          controller: _pdfViewerController,
        ));
  }
}

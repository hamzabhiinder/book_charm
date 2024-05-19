import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:book_charm/screens/games/load_from_device.dart';
import 'package:book_charm/utils/show_snackBar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class PickedFilesPage extends StatefulWidget {
  const PickedFilesPage({super.key});

  @override
  State<PickedFilesPage> createState() => _PickedFilesPageState();
}

class _PickedFilesPageState extends State<PickedFilesPage> {
  List<Map<String, String>> pickedFiles = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadFiles();
  }

  Future<void> loadFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/readingFiles.json');
    if (file.existsSync()) {
      List<dynamic> jsonData = jsonDecode(await file.readAsString());
      setState(() {
        pickedFiles =
            jsonData.map((item) => Map<String, String>.from(item)).toList();
      });

      log('pickedFiles ${pickedFiles.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    //  loadFiles();
    return Scaffold(
      appBar: AppBar(
        title: Text('Load Books'),
      ),
      body: pickedFiles.isEmpty
          ? Center(
              child: Text(
                'No files picked yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: pickedFiles.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  elevation: 5,
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf,
                        color: Colors.redAccent, size: 40),
                    title: Text(
                      pickedFiles[index]['name']!,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // Function to open the PDF viewer
                       nextScreen(context, PDFViewer(path: pickedFiles[index]['path']!));
                    },
                  ),
                );
              },
            ),
    );
  }
}



import 'dart:developer';
import 'dart:io'; // Import this for file operations
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:path_provider/path_provider.dart';
// Import this for file path

Future<String?> scrapePreTagContent(
    {required String url,
    required String bookName,
    required String authorName}) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final document = html.parse(response.body);
      final preTag = document.querySelector('pre');

      if (preTag != null) {
        // Save the text to a file
        await saveTextToFile(preTag.text, '${bookName}_$authorName');
        log('object ${preTag.text}');
        // Store the text in local storage (SharedPreferences)
        //  saveTextToLocalStorage(preTag.text);

        return preTag.text;
      } else {
        log('No <pre> tag found on $url');
        return null;
      }
    } else {
      log('Failed to load page: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    log('Error scraping $url: $e');
    return null;
  }
}


Future<void> saveTextToFile(String text, String bookName) async {
  try {
    final externalDir = await getExternalStorageDirectory();

    if (externalDir == null) {
      // External storage is not available
      throw Exception('External storage not available');
    }

    final file = File('${externalDir.path}/$bookName.txt');

    await file.writeAsString(text);

    log('Text saved to file: ${file.path}');
  } catch (e) {
    log('Error saving text to file: $e');
  }
}

Future<String?> readTextFromFile(String bookName) async {
  try {
    final externalDir = await getExternalStorageDirectory();

    if (externalDir == null) {
      // External storage is not available
      throw Exception('External storage not available');
    }

    final file = File('${externalDir.path}/$bookName.txt');

    if (!file.existsSync()) {
      // File does not exist
      throw Exception('File not found: ${file.path}');
    }

    String fileContent = await file.readAsString();
    log('File content:\n$fileContent');

    return fileContent;
  } catch (e) {
    log('Error reading file: $e');
    return null;
  }
}

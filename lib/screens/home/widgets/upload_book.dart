// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:provider/provider.dart';

// class UploadProvider extends ChangeNotifier {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController authorController = TextEditingController();
//   TextEditingController categoryController = TextEditingController();
//   File? pdfFile;
//   File? coverImageFile;
//   bool isUploading = false;

//   Future<void> uploadPDF() async {
//     isUploading = true;
//     notifyListeners();

//     Reference storageReference = FirebaseStorage.instance
//         .ref()
//         .child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');
//     UploadTask pdfUploadTask = storageReference.putFile(pdfFile!);
//     TaskSnapshot pdfTaskSnapshot = await pdfUploadTask.whenComplete(() => null);

//     String pdfUrl = await storageReference.getDownloadURL();

//     // Uploading cover image
//     if (coverImageFile != null) {
//       Reference coverStorageReference = FirebaseStorage.instance
//           .ref()
//           .child('covers/${DateTime.now().millisecondsSinceEpoch}.jpg');
//       UploadTask coverUploadTask =
//           coverStorageReference.putFile(coverImageFile!);
//       TaskSnapshot coverTaskSnapshot =
//           await coverUploadTask.whenComplete(() => null);

//       String coverUrl = await coverStorageReference.getDownloadURL();
// //  await FirebaseFirestore.instance
// //           .collection('UploadBooks')
// //           .doc(FirebaseAuth.instance.currentUser?.uid)
// //           .set({
// //         'Name': nameController.text,
// //         'Author': authorController.text,
// //         'Category': categoryController.text,
// //         'PdfUrl': pdfUrl,
// //         'CoverUrl': coverUrl,
// //       });
//       await FirebaseFirestore.instance.collection('uploadBook').add({
//         'Name': nameController.text,
//         'Author': authorController.text,
//         'Category': categoryController.text,
//         'PdfUrl': pdfUrl,
//         'CoverUrl': coverUrl,
//       });
//     } else {
//       await FirebaseFirestore.instance.collection('books').add({
//         'Name': nameController.text,
//         'Author': authorController.text,
//         'Category': categoryController.text,
//         'PdfUrl': pdfUrl,
//       });
//     }

//     nameController.clear();
//     authorController.clear();
//     categoryController.clear();

//     pdfFile = null;
//     coverImageFile = null;
//     isUploading = false;
//     notifyListeners();
//   }

//   Future<void> pickPDF() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//     );

//     if (result != null) {
//       pdfFile = File(result.files.single.path!);
//       notifyListeners();
//     }
//   }

//   Future<void> pickCoverImage() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.image,
//     );

//     if (result != null) {
//       coverImageFile = File(result.files.single.path!);
//       notifyListeners();
//     }
//   }
// }

// class UploadPage extends StatelessWidget {
//   const UploadPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Upload PDF'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Consumer<UploadProvider>(
//           builder: (context, provider, _) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 TextFormField(
//                   controller: provider.nameController,
//                   decoration: const InputDecoration(labelText: 'Name'),
//                 ),
//                 const SizedBox(height: 10.0),
//                 TextFormField(
//                   controller: provider.authorController,
//                   decoration: const InputDecoration(labelText: 'Author'),
//                 ),
//                 const SizedBox(height: 10.0),
//                 TextFormField(
//                   controller: provider.categoryController,
//                   decoration: const InputDecoration(labelText: 'Category'),
//                 ),
//                 const SizedBox(height: 20.0),
//                 ElevatedButton(
//                   onPressed: provider.pickPDF,
//                   child: const Text('Select PDF'),
//                 ),
//                 const SizedBox(height: 10.0),
//                 if (provider.pdfFile != null)
//                   Text('PDF selected: ${provider.pdfFile!.path}'),
//                 const SizedBox(height: 20.0),
//                 ElevatedButton(
//                   onPressed: provider.pickCoverImage,
//                   child: const Text('Select Cover Image (Optional)'),
//                 ),
//                 const SizedBox(height: 10.0),
//                 if (provider.coverImageFile != null)
//                   Text(
//                       'Cover Image selected: ${provider.coverImageFile!.path}'),
//                 const SizedBox(height: 20.0),
//                 ElevatedButton(
//                   onPressed: provider.isUploading ? null : provider.uploadPDF,
//                   child: provider.isUploading
//                       ? const CircularProgressIndicator()
//                       : const Text('Upload PDF'),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class UploadProvider extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  File? pdfFile;
  File? coverImageFile;
  bool isUploading = false;
  bool pdfSelected = false;

  Future<void> uploadPDF() async {
    if (pdfFile == null) {
      throw 'PDF file not selected';
    }

    isUploading = true;
    notifyListeners();

    try {
      Reference pdfStorageReference = FirebaseStorage.instance
          .ref()
          .child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');
      UploadTask pdfUploadTask = pdfStorageReference.putFile(pdfFile!);
      TaskSnapshot pdfTaskSnapshot =
          await pdfUploadTask.whenComplete(() => null);

      String pdfUrl = await pdfStorageReference.getDownloadURL();

      // Uploading cover image
      String? coverUrl;
      if (coverImageFile != null) {
        Reference coverStorageReference = FirebaseStorage.instance
            .ref()
            .child('covers/${DateTime.now().millisecondsSinceEpoch}.jpg');
        UploadTask coverUploadTask =
            coverStorageReference.putFile(coverImageFile!);
        TaskSnapshot coverTaskSnapshot =
            await coverUploadTask.whenComplete(() => null);

        coverUrl = await coverStorageReference.getDownloadURL();
      }

      // Determine language key based on some condition
      String languageKey = 'fr'; // Example: If English, set it to 'en'

      // Store data in Firestore
      await FirebaseFirestore.instance
          .collection('books')
          .doc('upload_book')
          .update({
        '$languageKey': FieldValue.arrayUnion([
          {
            'Name': nameController.text,
            'Author': authorController.text,
            'Category': categoryController.text,
            'PdfUrl': pdfUrl,
            'CoverUrl': coverUrl ?? '',
            'isPublished': false,
          }
        ]),
      });

      nameController.clear();
      authorController.clear();
      categoryController.clear();

      pdfFile = null;
      coverImageFile = null;
      isUploading = false;
      pdfSelected = false;
      notifyListeners();
    } catch (e) {
      isUploading = false;
      pdfSelected = true;
      notifyListeners();
      throw 'Failed to upload PDF: $e';
    }
  }

  Future<void> pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      pdfFile = File(result.files.single.path!);
      pdfSelected = true;
      notifyListeners();
    }
  }

  Future<void> pickCoverImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        coverImageFile = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("$e");
    }
  }
}

class UploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload PDF'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Consumer<UploadProvider>(
            builder: (context, provider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: provider.nameController,
                    decoration: InputDecoration(
                      labelText: 'Book Name',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Enter book name',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: provider.authorController,
                    decoration: InputDecoration(
                      labelText: 'Author Name',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Enter author name',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: provider.categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                      hintText: 'Enter category',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  // ElevatedButton(
                  //   onPressed: provider.pickPDF,
                  //   child: Text('Select PDF'),
                  // ),
                  // SizedBox(height: 10.0),
                  // if (provider.pdfSelected)
                  //   Text('PDF selected: ${provider.pdfFile!.path}'),
                  // SizedBox(height: 20.0),
                  TextFormField(
                    controller: TextEditingController(
                        text: provider.pdfSelected
                            ? provider.pdfFile!.path.split('/').last
                            : ""),
                    readOnly: true, // Make the text field read-only
                    decoration: InputDecoration(
                      labelText: 'Select PDF',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                      suffixIcon: IconButton(
                        icon: Icon(Icons.file_upload), // Icon for file upload
                        onPressed:
                            provider.pickPDF, // Method to open file picker
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),

                  TextFormField(
                    controller: TextEditingController(
                        text: provider.coverImageFile != null
                            ? provider.coverImageFile!.path.split('/').last
                            : ""),
                    readOnly: true, // Make the text field read-only
                    decoration: InputDecoration(
                      labelText: 'Select Cover Image (Optional)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[200],
                      suffixIcon: IconButton(
                        icon: Icon(Icons.image), // Icon for image picker
                        onPressed: provider
                            .pickCoverImage, // Method to open image picker
                      ),
                    ),
                  ),

                  // ElevatedButton(
                  //   onPressed: provider.pickCoverImage,
                  //   child: Text('Select Cover Image (Optional)'),
                  // ),
                  // SizedBox(height: 10.0),
                  // if (provider.coverImageFile != null)
                  //   Text(
                  //       'Cover Image selected: ${provider.coverImageFile!.path}'),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: provider.isUploading ? null : provider.uploadPDF,
                    child: provider.isUploading
                        ? CircularProgressIndicator()
                        : Text('Upload PDF'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

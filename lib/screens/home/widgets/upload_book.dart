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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../profile/view/widget/language_selector.dart';
import '../view/library_screen.dart';

class UploadProvider extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  File? pdfFile;
  File? coverImageFile;
  bool isUploading = false;
  bool pdfSelected = false;
// Function to upload PDF and cover image to Firebase Storage and update Firestore
  Future<void> uploadPDF(BuildContext context) async {
    // Check for necessary inputs
    if (pdfFile == null ||
        nameController.text.isEmpty ||
        authorController.text.isEmpty ||
        categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields and a PDF file are required.')),
      );
      return;
    }

    // Start the upload process
    isUploading = true;
    notifyListeners();

    try {
      // Upload PDF to Firebase Storage
      Reference pdfStorageReference = FirebaseStorage.instance
          .ref()
          .child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');
      UploadTask pdfUploadTask = pdfStorageReference.putFile(pdfFile!);
      TaskSnapshot pdfTaskSnapshot =
          await pdfUploadTask.whenComplete(() => null);

      // Get the PDF file URL
      String pdfUrl = await pdfStorageReference.getDownloadURL();

      // Optional: Upload cover image to Firebase Storage
      String? coverUrl;
      if (coverImageFile != null) {
        Reference coverStorageReference = FirebaseStorage.instance
            .ref()
            .child('covers/${DateTime.now().millisecondsSinceEpoch}.jpg');
        UploadTask coverUploadTask =
            coverStorageReference.putFile(coverImageFile!);
        TaskSnapshot coverTaskSnapshot =
            await coverUploadTask.whenComplete(() => null);

        // Get the cover image file URL
        coverUrl = await coverStorageReference.getDownloadURL();
      }

      // Determine language key based on your criteria (adjust as needed)
      // Change to your actual language key logic
      LanguageProvider languageKey =
          Provider.of<LanguageProvider>(context, listen: false);

      // Add book data to Firestore
      await FirebaseFirestore.instance
          .collection('books')
          .doc('upload_book')
          .set({
        languageKey.selectedLanguageCode: FieldValue.arrayUnion([
          {
            'Name': nameController.text,
            'Author': authorController.text,
            'Category': categoryController.text,
            'PdfUrl': pdfUrl,
            'CoverUrl': coverUrl ?? '',
            'isPublished': false,
            'userID': FirebaseAuth.instance.currentUser?.uid
          },
        ]),
      }, SetOptions(merge: true)); // Use merge option to retain existing data

      // Reset controllers and file selections after successful upload
      nameController.clear();
      authorController.clear();
      categoryController.clear();
      pdfFile = null;
      coverImageFile = null;
      pdfSelected = false;
      isUploading = false;
      notifyListeners();
      Provider.of<LibraryProvider>(context, listen: false)
          .loadJsonDataFunction(context);
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF and cover image uploaded successfully.')),
      );
    } catch (e) {
      // Handle errors during upload process
      isUploading = false;
      notifyListeners();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload PDF: $e')),
      );
    }
  }

  // Future<void> uploadPDF() async {
  //   if (pdfFile == null) {
  //     throw 'PDF file not selected';
  //   }

  //   isUploading = true;
  //   notifyListeners();

  //   try {
  //     Reference pdfStorageReference = FirebaseStorage.instance
  //         .ref()
  //         .child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');
  //     UploadTask pdfUploadTask = pdfStorageReference.putFile(pdfFile!);
  //     TaskSnapshot pdfTaskSnapshot =
  //         await pdfUploadTask.whenComplete(() => null);

  //     String pdfUrl = await pdfStorageReference.getDownloadURL();

  //     // Uploading cover image
  //     String? coverUrl;
  //     if (coverImageFile != null) {
  //       Reference coverStorageReference = FirebaseStorage.instance
  //           .ref()
  //           .child('covers/${DateTime.now().millisecondsSinceEpoch}.jpg');
  //       UploadTask coverUploadTask =
  //           coverStorageReference.putFile(coverImageFile!);
  //       TaskSnapshot coverTaskSnapshot =
  //           await coverUploadTask.whenComplete(() => null);

  //       coverUrl = await coverStorageReference.getDownloadURL();
  //     }

  //     // Determine language key based on some condition
  //     String languageKey = 'fr'; // Example: If English, set it to 'en'

  //     // Store data in Firestore
  //     await FirebaseFirestore.instance
  //         .collection('books')
  //         .doc('upload_book')
  //         .set({
  //       languageKey: FieldValue.arrayUnion([
  //         {
  //           'Name': nameController.text,
  //           'Author': authorController.text,
  //           'Category': categoryController.text,
  //           'PdfUrl': pdfUrl,
  //           'CoverUrl': coverUrl ?? '',
  //           'isPublished': false,
  //         },
  //       ]),
  //     }, SetOptions(merge: true));
  //     nameController.clear();
  //     authorController.clear();
  //     categoryController.clear();

  //     pdfFile = null;
  //     coverImageFile = null;
  //     isUploading = false;
  //     pdfSelected = false;
  //     notifyListeners();
  //   } catch (e) {
  //     isUploading = false;
  //     pdfSelected = true;
  //     notifyListeners();
  //     throw 'Failed to upload PDF: $e';
  //   }
  // }

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
  // Create a form key to manage the form
  final _formKey = GlobalKey<FormState>();

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
              return Form(
                key: _formKey, // Assign the form key
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Book Name TextField
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Book name is required.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.0),

                    // Author Name TextField
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Author name is required.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.0),

                    // Category TextField
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Category is required.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.0),

                    // PDF Selection
                    TextFormField(
                      controller: TextEditingController(
                          text: provider.pdfFile?.path.split('/').last ?? ''),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a PDF file.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.0),

                    // Cover Image Selection
                    TextFormField(
                      controller: TextEditingController(
                        text: provider.coverImageFile != null
                            ? provider.coverImageFile!.path.split('/').last
                            : "",
                      ),
                      readOnly: true, // Make the text field read-only
                      decoration: InputDecoration(
                        labelText: 'Select Cover Image',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                        suffixIcon: IconButton(
                          icon: Icon(Icons.image), // Icon for image picker
                          onPressed: provider
                              .pickCoverImage, // Method to open image picker
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select  Cover Image.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),

                    // Upload PDF button
                    ElevatedButton(
                      onPressed: provider.isUploading
                          ? null
                          : () {
                              // Validate form fields before uploading
                              if (_formKey.currentState!.validate()) {
                                provider.uploadPDF(context);
                              }
                            },
                      child: provider.isUploading
                          ? CircularProgressIndicator()
                          : Text('Upload PDF'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

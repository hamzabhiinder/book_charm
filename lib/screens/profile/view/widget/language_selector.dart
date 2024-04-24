import 'package:book_charm/screens/home/view/dictionary_screen.dart';
import 'package:book_charm/screens/home/view/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageList extends StatefulWidget {
  const LanguageList({super.key});

  @override
  State<LanguageList> createState() => _LanguageListState();
}

class _LanguageListState extends State<LanguageList> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildLanguageList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageList(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final selectedLanguage = languageProvider.selectedLanguageName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: languageProvider.languages.keys.map((language) {
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.language),
          ),
          title: Text(language),
          trailing: Radio<String>(
            value: language,
            groupValue: selectedLanguage,
            onChanged: (value) {
              languageProvider.setSelectedLanguage(value!, context);
              Navigator.pop(context); // Close the bottom sheet
              setState(() {});
            },
          ),
        );
      }).toList(),
    );
  }
}

class LanguageProvider extends ChangeNotifier {
  String _selectedLanguageName = '';
  String _selectedLanguageCode = '';

  String get selectedLanguageName => _selectedLanguageName;
  String get selectedLanguageCode => _selectedLanguageCode;

  final Map<String, String> _languages = {
    'English': 'en',
    'French': 'fr',
    'German': 'gr',
    'Spanish': 'es',
    'Italian': 'it',
    'Urdu': 'ur',
  };

  Map<String, String> get languages => _languages;

  void setSelectedLanguage(String name, BuildContext context) async {
    final code = _languages[name]!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguageName', name);
    await prefs.setString('selectedLanguageCode', code);
    _selectedLanguageName = name;
    _selectedLanguageCode = code;
    Provider.of<LibraryProvider>(context, listen: false)
        .loadJsonDataFunction(context);
    Provider.of<DictionaryProvider>(context, listen: false)
        .loadDictionary(context);

    notifyListeners();
  }

  Future<void> loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('selectedLanguageName') == null ||
        prefs.getString('selectedLanguageName') == '') {
      await prefs.setString('selectedLanguageName', 'English');
      await prefs.setString('selectedLanguageCode', 'en');
      _selectedLanguageName = 'English';
      _selectedLanguageCode = 'en';
    } else {
      _selectedLanguageName = prefs.getString('selectedLanguageName') ?? '';
      _selectedLanguageCode = prefs.getString('selectedLanguageCode') ?? '';
    }

    notifyListeners();
  }
}

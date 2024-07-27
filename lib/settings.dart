import 'package:flutter/material.dart';
import 'package:hajj_app/question_model.dart';

// make a provider for changing theme from light to dark
class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// bookmark provider
class BookmarkProvider extends ChangeNotifier {
  List<QuestionModel> bookmarks = [];

  void addBookmark(QuestionModel question) {
    bookmarks.add(question);
    notifyListeners();
  }

  void removeBookmark(QuestionModel question) {
    bookmarks.remove(question);
    notifyListeners();
  }
}

// font size provider
class FontSizeProvider extends ChangeNotifier {
  double _size = 32;

  double get fontSize => _size;

  set fontSize(double size) {
    _size = size;
    notifyListeners();
  }
}

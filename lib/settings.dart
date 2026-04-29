import 'dart:convert';
import 'package:hive_ce/hive_ce.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/question_model.dart';

// make a provider for changing theme from light to dark
class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    var box = Hive.box('appBox');
    bool? isDark = box.get('isDarkMode');
    if (isDark != null) {
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    var box = Hive.box('appBox');
    box.put('isDarkMode', isOn);
    notifyListeners();
  }
}

// bookmark provider
class BookmarkProvider extends ChangeNotifier {
  List<Question> bookmarks = [];

  BookmarkProvider() {
    _loadBookmarks();
  }

  void _loadBookmarks() {
    var box = Hive.box('appBox');
    String? savedBookmarks = box.get('bookmarks');

    if (savedBookmarks != null) {
      List<dynamic> decodedList = jsonDecode(savedBookmarks);
      bookmarks = decodedList.map((item) => Question.fromJson(item)).toList();
      notifyListeners();
    }
  }

  void _saveBookmarks() {
    var box = Hive.box('appBox');
    box.put('bookmarks', jsonEncode(bookmarks.map((q) => q.toJson()).toList()));
  }

  void addBookmark(Question question) {
    bookmarks.add(question);
    _saveBookmarks();
    notifyListeners();
  }

  void removeBookmark(Question question) {
    bookmarks.removeWhere((q) => q.no == question.no);
    _saveBookmarks();
    notifyListeners();
  }
}

// font size provider
class QuestionPrefsProvider extends ChangeNotifier {
  double _size = 32;

  double get fontSize => _size;

  set fontSize(double size) {
    _size = size;
    notifyListeners();
  }

  double _audioSpeed = 1.0;

  double get audioSpeed => _audioSpeed;

  set audioSpeed(double speed) {
    _audioSpeed = speed;
    notifyListeners();
  }
}

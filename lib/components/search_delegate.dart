// search delegate class for questions
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/pages/question_page.dart';
import 'package:provider/provider.dart';
import 'package:hajj_app/main.dart';

class QuestionSearch extends SearchDelegate<String> {
  final List<Question> questions;
  QuestionSearch(this.questions);

  // change direction
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(textTheme: theme.textTheme);
  }

  // change the hint text
  @override
  String get searchFieldLabel => 'ابحث عن سؤال';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  String _normalizeText(String text) {
    return text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('٠', '0')
        .replaceAll('١', '1')
        .replaceAll('٢', '2')
        .replaceAll('٣', '3')
        .replaceAll('٤', '4')
        .replaceAll('٥', '5')
        .replaceAll('٦', '6')
        .replaceAll('٧', '7')
        .replaceAll('٨', '8')
        .replaceAll('٩', '9')
        .toLowerCase();
  }

  List<Question> _getFilteredQuestions(String query) {
    if (query.trim().isEmpty) {
      return questions;
    }

    final normalizedQuery = _normalizeText(query);
    final queryWords =
        normalizedQuery.split(' ').where((w) => w.isNotEmpty).toList();

    return questions.where((q) {
      final normalizedTitle = _normalizeText(q.question ?? "");
      // Ensure any word in the query appears somewhere in the question
      return queryWords.any((word) => normalizedTitle.contains(word));
    }).toList();
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Question> suggestionList = _getFilteredQuestions(query);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
          itemCount: suggestionList.length,
          itemBuilder: (context, index) => ListTile(
                title: Text(
                  // Safely handle null questions so it doesn't crash the search page
                  suggestionList[index].question ?? 'بدون عنوان',
                  style: const TextStyle(fontFamily: "Zarids", fontSize: 24),
                ),
                onTap: () {
                  Provider.of<GlobalAudioProvider>(context, listen: false)
                      .setBookmarkMode(false);
                  Get.to(() => QuestionPage(suggestionList[index]),
                      transition: Transition.rightToLeft,
                      routeName: '/question/${suggestionList[index].no}');
                },
              )),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Question> suggestionList = _getFilteredQuestions(query);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            // Safely handle null questions so it doesn't crash the search page
            suggestionList[index].question ?? 'بدون عنوان',
            style: const TextStyle(fontFamily: "Zarids", fontSize: 24),
          ),
          onTap: () {
            Provider.of<GlobalAudioProvider>(context, listen: false)
                .setBookmarkMode(false);
            Get.to(() => QuestionPage(suggestionList[index]),
                transition: Transition.rightToLeft,
                routeName: '/question/${suggestionList[index].no}');
          },
        ),
      ),
    );
  }
}

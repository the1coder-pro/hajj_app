// search delegate class for questions
import 'package:flutter/material.dart';
import 'package:hajj_app/main.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/question_page.dart';

class QuestionSearch extends SearchDelegate<String> {
  final List<QuestionModel> questions;
  QuestionSearch(this.questions);

  // change the hint text
  @override
  String get searchFieldLabel => 'ابحث عن سؤال';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
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

  @override
  Widget buildResults(BuildContext context) {
    final List<QuestionModel> suggestionList = query.isEmpty
        ? questions
        : questions
            .where((element) =>
                element.question!.toLowerCase().contains(query) ||
                element.subTitle!.toLowerCase().contains(query))
            .toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
          itemCount: suggestionList.length,
          itemBuilder: (context, index) =>
              QuestionTile(question: suggestionList[index])),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<QuestionModel> suggestionList = query.isEmpty
        ? questions
        : questions
            .where((element) =>
                element.question!.toLowerCase().contains(query) ||
                element.subTitle!.toLowerCase().contains(query))
            .toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(suggestionList[index].question!),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return QuestionPage(suggestionList[index]);
            }));
          },
        ),
      ),
    );
  }
}

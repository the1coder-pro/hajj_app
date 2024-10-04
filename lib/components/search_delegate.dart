// search delegate class for questions
import 'package:flutter/material.dart';
import 'package:hajj_app/components/question_tile.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/pages/question_page.dart';

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

  @override
  Widget buildResults(BuildContext context) {
    // get the suggestionList from the query but even if the word is not complete
    final List<Question> suggestionList = questions;

    // get the questions that have the same words (order not important)

    // split the query into words
    final List<String> queryList = query.split(' ');

    // get all the questions that have any of the query words (order not important)
    if (query.isNotEmpty) {
      suggestionList.clear();
      for (var question in questions) {
        for (String word in queryList) {
          if (question.question!.split(' ').contains(word)) {
            suggestionList.add(question);
          }
        }
      }
    }

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
    List<Question> suggestionList = questions;

    if (query.isEmpty) {
      suggestionList = questions;
    } else {
      // // make search more flexible that it could give you the question even if the query is reversed or not complete
      // suggestionList = questions.where((element) {
      //   return element.question!.contains(query);
      // }).toList();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            suggestionList[index].question!,
            style: const TextStyle(fontFamily: "Zarids", fontSize: 24),
          ),
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

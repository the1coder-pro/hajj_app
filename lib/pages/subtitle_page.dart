import 'package:flutter/material.dart';
import 'package:hajj_app/components/question_tile.dart';
import 'package:hajj_app/question_model.dart';

class SubTitlePage extends StatelessWidget {
  const SubTitlePage({
    super.key,
    required this.index,
    required this.i,
    required this.mainTitles,
    required this.questions,
  });

  final int index;
  final int i;

  final List<Map> mainTitles;
  final List<QuestionModel> questions;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(mainTitles[index]['subTitles'][i],
                style: TextStyle(
                  fontFamily: "Zarids",
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                )),
          ),
          body: ListView.builder(
            itemCount: questions
                .where((question) =>
                    question.subTitle == mainTitles[index]['subTitles'][i])
                .toList()
                .length,
            itemBuilder: (context, k) {
              var selectedQuestions = questions
                  .where((question) =>
                      question.subTitle == mainTitles[index]['subTitles'][i])
                  .toList();

              if (selectedQuestions.isNotEmpty) {
                return QuestionTile(question: selectedQuestions[k]);
              } else {
                return const Center(
                    child: Text(
                  'لا يوجد أسئلة',
                  style: TextStyle(
                      fontFamily: "Zarids",
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ));
              }
            },
          )),
    );
  }
}

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
  final List<Question> questions;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("- ${mainTitles[index]['subTitles'][i]} -",
                      style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.onSurface)),
                  Text("اختر المسألة",
                      style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold))
                ],
              ),
            ),
            centerTitle: true,
            toolbarHeight: 80,
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

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
            title: Text(
              mainTitles[index]['subTitles'][i],
              style: const TextStyle(
                  fontFamily: "Zarids",
                  fontSize: 30,
                  fontWeight: FontWeight.normal),
            ),
          ),
          body: ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, k) {
              if (questions.isNotEmpty) {
                if (mainTitles[index]['subTitles'][i] ==
                    questions[k].subTitle) {
                  return QuestionTile(question: questions[k]);
                } else {
                  return const SizedBox();
                }
              } else {
                return const Center(
                  child: Text("لا توجد أسئلة"),
                );
              }
            },
          )),
    );
  }
}

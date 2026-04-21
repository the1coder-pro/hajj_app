import 'package:flutter/material.dart';
import 'package:hajj_app/components/question_tile.dart';
import 'package:hajj_app/question_model.dart';

class SubTitlePage extends StatefulWidget {
  const SubTitlePage({
    super.key,
    required this.index,
    required this.i,
    required this.mainTitles,
    required this.questions,
    this.showAppBar = true,
    this.onQuestionTap,
  });

  final int index;
  final int i;

  final List<Map> mainTitles;
  final List<Question> questions;
  final bool showAppBar;
  final void Function(Question)? onQuestionTap;

  @override
  State<SubTitlePage> createState() => _SubTitlePageState();
}

class _SubTitlePageState extends State<SubTitlePage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: widget.showAppBar
              ? AppBar(
                  title: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            "- ${widget.mainTitles[widget.index]['subTitles'][widget.i]} -",
                            style: TextStyle(
                                fontSize: 22,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
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
                )
              : null,
          body: ListView.builder(
            itemCount: widget.questions
                .where((question) =>
                    question.subTitle ==
                    widget.mainTitles[widget.index]['subTitles'][widget.i])
                .toList()
                .length,
            itemBuilder: (context, k) {
              var selectedQuestions = widget.questions
                  .where((question) =>
                      question.subTitle ==
                      widget.mainTitles[widget.index]['subTitles'][widget.i])
                  .toList();

              if (selectedQuestions.isNotEmpty) {
                return QuestionTile(
                  question: selectedQuestions[k],
                  onTap: widget.onQuestionTap,
                );
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

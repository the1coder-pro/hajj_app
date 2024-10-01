import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/pages/other_question_page.dart';
import 'package:hajj_app/pages/question_page.dart';
import 'package:hajj_app/question_model.dart';

class QuestionTile extends StatelessWidget {
  final QuestionModel? question;
  final QuestionModelOther? questionModelAr;
  const QuestionTile({
    this.question,
    this.questionModelAr,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (question != null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Card.filled(
            color: Theme.of(context).colorScheme.surfaceBright,
            // rounded
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Get.to(() => QuestionPage(question!),
                    transition: Transition.downToUp);
              },
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          width: 2)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              question!.subTitle!,
                              style: TextStyle(
                                  fontFamily: "Zarids",
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () {
                                // add to favorites
                              },
                              icon: Icon(
                                Icons.bookmark_border,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          question!.question!,
                          style: TextStyle(
                              fontFamily: "Zarids",
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 28,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Chip(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              padding: const EdgeInsets.all(4),
                              label: Text(
                                question!.mainTitle!,
                                style: TextStyle(
                                    fontFamily: "Zarids",
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )

                  // ListTile(
                  //   subtitle: Padding(
                  //     padding: const EdgeInsets.all(5),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.end,
                  //       children: [
                  //         Chip(
                  //           label: Text(question!.mainTitle!,
                  //               style: const TextStyle(fontSize: 18)),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  //   isThreeLine: true,
                  //   // remove the number before ":" and show the question
                  //   title: Padding(
                  //     padding: const EdgeInsets.only(right: 5, left: 5, top: 5),
                  //     child: RichText(
                  //       text: TextSpan(
                  //         children: [
                  //           TextSpan(
                  //             text: "${question!.subTitle}\n",
                  //             style: TextStyle(
                  //                 color: Theme.of(context).colorScheme.primary,
                  //                 fontSize: 20,
                  //                 fontFamily: "Zarids",
                  //                 fontWeight: FontWeight.w600),
                  //           ),
                  //           TextSpan(
                  //             text: question!.question!,
                  //             style: TextStyle(
                  //                 fontFamily: "Zarids",
                  //                 height: 1.2,
                  //                 color: Theme.of(context).colorScheme.onSurface,
                  //                 fontWeight: FontWeight.w400,
                  //                 fontSize: 26),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  ),
            ),
          ),
        ),
      );
    } else {
      // return questionmodelar
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Card.outlined(
            // rounded
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 1,

            child: InkWell(
              onTap: () {
                Get.to(() => OtherQuestionPage(questionModelAr!),
                    transition: Transition.downToUp);
              },
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(right: 5, left: 5, top: 5),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${questionModelAr!.section}\n",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: questionModelAr!.question!,
                          style: TextStyle(
                              height: 1.2,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 26),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

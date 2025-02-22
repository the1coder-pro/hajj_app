import 'dart:convert';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/pages/extra_questions_page.dart';
import 'package:hajj_app/pages/subtitle_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/components/search_delegate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class InstructorPage extends StatefulWidget {
  final String instructor;
  const InstructorPage(this.instructor, {super.key});

  @override
  State<InstructorPage> createState() => _InstructorPageState();
}

class _InstructorPageState extends State<InstructorPage> {
  int currentPageIndex = 0;

  dynamic jsonData = "";
  Future<void> loadJsonAsset() async {
    // https://opensheet.elk.sh/1KxJKKxKBcEd0lguKAbK-UkGIqzAcOXs5is3zNiTnFgY/1
    // get the data from the link
    final response = await http.get(Uri.parse(
        "https://opensheet.elk.sh/1KxJKKxKBcEd0lguKAbK-UkGIqzAcOXs5is3zNiTnFgY/1"));
    // json
    var data1 = utf8.decode(response.bodyBytes);
    var data = jsonDecode(data1);
    setState(() {
      jsonData = data;
    });
    for (var i = 0; i < jsonData.length; i++) {
      questions.add(Question.fromJson(jsonData[i]));

      // get the mainTitles and add them to the generatedMainTitles (without duplicates)
      if (generatedMainTitles.isEmpty) {
        generatedMainTitles.add({
          "title": jsonData[i]['MainTitle'],
          "subTitles": [jsonData[i]['SubTitle']]
        });
      } else {
        bool isExist = false;
        for (var j = 0; j < generatedMainTitles.length; j++) {
          if (jsonData[i]['MainTitle'] == generatedMainTitles[j]['title']) {
            isExist = true;
          }
        }
        if (!isExist) {
          generatedMainTitles.add({
            "title": jsonData[i]['MainTitle'],
            "subTitles": [jsonData[i]['SubTitle']]
          });
        }
      }

      // get the subtitles and add them to the mainTitles (without duplicates)
      for (var j = 0; j < generatedMainTitles.length; j++) {
        if (jsonData[i]['MainTitle'] == generatedMainTitles[j]['title']) {
          if (!generatedMainTitles[j]['subTitles']
              .contains(jsonData[i]['SubTitle'])) {
            generatedMainTitles[j]['subTitles'].add(jsonData[i]['SubTitle']);
          }
        }
      }
    }
    // debugPrint(generatedMainTitles as String?);
    questions = getQuestionsByInstructor(widget.instructor);
    if (widget.instructor == "شيخ جعفر العبدالكريم") {
      generatedMainTitles.add({"title": "مسائل إضافية"});
    }
  }

  List<Question> getQuestionsByInstructor(String instructor) {
    return questions.where((element) {
      return element.instructor == instructor;
    }).toList();
  }

  List<Question> questions = [];

  List<Map> generatedMainTitles = [];

  @override
  void initState() {
    super.initState();
    loadJsonAsset();
  }

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
                Text("- ${widget.instructor} -",
                    style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onSurface)),
                Text("اختر القسم",
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
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Card.outlined(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("تواصل مع الشيخ",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Zarids")),
                      const SizedBox(width: 10),
                      // two buttons to contact the instructor
                      IconButton.outlined(
                        icon: Icon(CommunityMaterialIcons.whatsapp,
                            color: Theme.of(context).colorScheme.primary),
                        onPressed: () async {
                          Uri url = Uri.parse("https://wa.me/+966506906007");
                          // open link
                          if (!await launchUrl(url)) {
                            throw Exception('Could not launch $url');
                          }
                        },
                      ),
                      const SizedBox(width: 5),

                      IconButton.outlined(
                        icon: Icon(Icons.phone_outlined,
                            color: Theme.of(context).colorScheme.primary),
                        onPressed: () async {
                          Uri url = Uri.parse("tel:+966506906007");
                          // open link
                          if (!await launchUrl(url)) {
                            throw Exception('Could not launch $url');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: generatedMainTitles.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: Card.outlined(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          // color: const Color(0xFFe4e4e6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: InkWell(
                            // radius is like the card
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              if (!(generatedMainTitles[index]['title'] ==
                                  "مسائل إضافية")) {
                                Get.to(
                                    () => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Scaffold(
                                          appBar: AppBar(
                                            title: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      "- ${generatedMainTitles[index]['title']} -",
                                                      style: TextStyle(
                                                          fontSize: 22,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface)),
                                                  Text("اختر القسم",
                                                      style: TextStyle(
                                                          fontSize: 22,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface,
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ],
                                              ),
                                            ),
                                            centerTitle: true,
                                            toolbarHeight: 80,
                                          ),
                                          body: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 10),
                                            child: GridView.builder(
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                              ),
                                              itemCount:
                                                  generatedMainTitles[index]
                                                          ['subTitles']
                                                      .length,
                                              itemBuilder: (context, i) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Card.outlined(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surfaceContainerHighest
                                                        .withValues(alpha: 0.5),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30)),
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      onTap: () {
                                                        Get.to(
                                                            () => SubTitlePage(
                                                                index: index,
                                                                i: i,
                                                                mainTitles:
                                                                    generatedMainTitles,
                                                                questions:
                                                                    questions),
                                                            transition: Transition
                                                                .leftToRight);
                                                      },
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 10),
                                                          child: ListTile(
                                                            title: Center(
                                                                child: Text(
                                                              generatedMainTitles[
                                                                      index][
                                                                  'subTitles'][i],
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary,
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      "Zarids"),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            )),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        )),
                                    transition: Transition.leftToRight);
                              } else {
                                Get.to(() => ExtraQuestionsPage());
                              }
                            },
                            child: Center(
                              child: Text(generatedMainTitles[index]['title'],
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Zarids"),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Directionality(
          textDirection: TextDirection.rtl,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.secondaryContainer,
            onPressed: () {
              showSearch(
                context: context,
                delegate: QuestionSearch(questions),
              );
            },
            child: const Icon(Icons.search),
          ),
        ),
      ),
    );
  }
}

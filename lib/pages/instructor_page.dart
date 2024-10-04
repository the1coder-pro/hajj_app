import 'dart:convert';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hajj_app/pages/subtitle_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/components/search_delegate.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final String jsonString = await rootBundle.loadString('assets/data.json');
    var data = jsonDecode(jsonString);
    setState(() {
      jsonData = data;
    });
    for (var i = 0; i < jsonData.length; i++) {
      questions.add(QuestionModel.fromJson(jsonData[i]));

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

  List<QuestionModel> getQuestionsByInstructor(String instructor) {
    return questions.where((element) {
      return element.instructor == instructor;
    }).toList();
  }

  List<QuestionModel> questions = [];

  List<Map> generatedMainTitles = [];

  List<Map> mainTitles = [
    {"title": "المقدمة", "image": "1.png"},
    {
      "title": "مسائل",
      "subTtiles": [
        "وجوب الحج",
        "شرائط وجوب حجة الإسلام",
        "الاستطاعة",
        "أقسام الحج والعمرة",
        "مجمل عمرة وحج التمتع",
        "مواقيت الإحرام",
        "أحكام المواقيت",
        "كيفية الإحرام"
      ],
      "image": "2.png"
    },
    {
      "title": "محرمات الأحرام",
      "subTtiles": ["الصيد البري", "الجماع", "كيفية الإحرام"],
      "image": "3.png"
    },
    {"title": "محرمات الحرم", "image": "4.png"},
    {"title": "أحكام الكفارة", "image": "5.png"},
    {"title": "عمرة التمتع", "image": "6.png"},
    {"title": "حج التمتع", "image": "7.png"},
    {"title": "مسائل إضافية"}
  ];

  @override
  void initState() {
    super.initState();
    loadJsonAsset();
  }

  @override
  Widget build(BuildContext context) {
    // BookmarkProvider bookmarkProvider = Provider.of<BookmarkProvider>(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.instructor,
              style: TextStyle(
                fontFamily: "Zarids",
                fontSize: 30,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              )),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Row(
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
                OutlinedButton.icon(
                  label: Text("واتساب",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Zarids")),
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

                OutlinedButton.icon(
                  label: Text("اتصال",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Zarids")),
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
                              .withOpacity(0.5),
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
                                            title: Text(
                                                generatedMainTitles[index]
                                                    ['title'],
                                                style: TextStyle(
                                                  fontFamily: "Zarids",
                                                  fontSize: 30,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  fontWeight: FontWeight.w400,
                                                )),
                                            centerTitle: true,
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
                                                        .withOpacity(0.5),
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
                                Get.to(() => Scaffold(
                                      appBar: AppBar(
                                        title: const Text("مسائل إضافية",
                                            style: TextStyle(
                                              fontFamily: "Zarids",
                                              fontSize: 30,
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ),
                                      body: const Column(
                                        children: [],
                                      ),
                                    ));
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

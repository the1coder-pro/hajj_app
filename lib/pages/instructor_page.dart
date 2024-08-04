import 'dart:convert';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/customized_icon_button.dart';
import 'package:hajj_app/pages/subtitle_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/components/search_delegate.dart';
import 'package:hajj_app/settings.dart';
import 'package:provider/provider.dart';

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
  TextEditingController searchController = TextEditingController();

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
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    // BookmarkProvider bookmarkProvider = Provider.of<BookmarkProvider>(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.instructor),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            if (widget.instructor == "شيخ جعفر العبدالكريم")
              Stack(alignment: AlignmentDirectional.center, children: [
                Image(
                    image: AssetImage(
                        'assets/contact_banner_${themeProvider.themeMode == ThemeMode.dark ? 'dark' : 'light'}.jpg')),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomizedIconButton(
                          icon: CommunityMaterialIcons.whatsapp,
                          link: 'https://wa.me/+966506906007',
                          themeProvider: themeProvider),
                      CustomizedIconButton(
                          icon: Icons.phone_outlined,
                          link: 'tel:+966506906007',
                          themeProvider: themeProvider),
                    ],
                  ),
                )
              ]),
            Divider(
                color: Theme.of(context).colorScheme.secondary, thickness: 10),
            Expanded(
              flex: 6,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: generatedMainTitles.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: Card(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        // color: const Color(0xFFe4e4e6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        child: InkWell(
                          onTap: () {
                            if (!(generatedMainTitles[index]['title'] ==
                                "مسائل إضافية")) {
                              Get.to(
                                  () => Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Scaffold(
                                        appBar: AppBar(
                                          title: Text(generatedMainTitles[index]
                                              ['title']),
                                          centerTitle: true,
                                        ),
                                        body: Padding(
                                          padding: const EdgeInsets.all(10),
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
                                                child: Card(
                                                  color:
                                                      const Color(0xFFe0eeed),
                                                  elevation: 0.5,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      child: ListTile(
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
                                                        title: Center(
                                                            child: Text(
                                                          generatedMainTitles[
                                                                  index]
                                                              ['subTitles'][i],
                                                          style: const TextStyle(
                                                              color: Color(
                                                                  0xFF267678),
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  "Zarids"),
                                                          textAlign:
                                                              TextAlign.center,
                                                        )),
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
                                      title: Text("مسائل إضافية"),
                                    ),
                                    body: Column(
                                      children: [],
                                    ),
                                  ));
                            }
                          },
                          child: Center(
                            child: Text(generatedMainTitles[index]['title'],
                                style: const TextStyle(
                                    color: Color(0xFF267678),
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
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
    );
  }
}

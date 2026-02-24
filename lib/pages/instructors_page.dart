import 'dart:convert';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/components/search_delegate.dart';
import 'package:hajj_app/pages/extra_questions_page.dart';
import 'package:hajj_app/pages/subtitle_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class InstructorsPage extends StatefulWidget {
  const InstructorsPage({super.key});

  @override
  State<InstructorsPage> createState() => _InstructorsPageState();
}

class _InstructorsPageState extends State<InstructorsPage> {
  dynamic jsonData = "";
  List<Question> questions = [];
  List<Map> generatedMainTitles = [];
  final String instructor = "شيخ جعفر العبدالكريم";

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
    questions = getQuestionsByInstructor(instructor);
    if (instructor == "شيخ جعفر العبدالكريم") {
      generatedMainTitles.add({"title": "مسائل إضافية"});
    }
  }

  List<Question> getQuestionsByInstructor(String instructor) {
    return questions.where((element) {
      return element.instructor == instructor;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    loadJsonAsset();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: false,
              snap: false,
              floating: true,
              stretchTriggerOffset: 300.0,
              expandedHeight: 200.0,
              flexibleSpace: FlexibleSpaceBar(
                // centerTitle: true,
                // title: Text('المعلمين'),

                background: Image.asset(
                  themeProvider.themeMode == ThemeMode.dark
                      ? "assets/main_banner_dark.jpg"
                      : "assets/main_banner_light.jpg",
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Stack(
                  // alignment: Alignment.center,
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        themeProvider.themeMode == ThemeMode.dark
                            ? "assets/contact_banner_dark.jpg"
                            : "assets/contact_banner_light.jpg",
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            icon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(CommunityMaterialIcons.whatsapp,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                            onPressed: () async {
                              Uri url =
                                  Uri.parse("https://wa.me/+966506906007");
                              // open link
                              if (!await launchUrl(url)) {
                                throw Exception('Could not launch $url');
                              }
                            },
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            icon: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.phone_outlined,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                            onPressed: () async {
                              Uri url = Uri.parse("tel:+966506906007");
                              // open link
                              if (!await launchUrl(url)) {
                                throw Exception('Could not launch $url');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
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
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface)),
                                                Text("اختر القسم",
                                                    style: TextStyle(
                                                        fontSize: 22,
                                                        color: Theme.of(context)
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
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                                            textAlign: TextAlign
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
                  childCount: generatedMainTitles.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ContactFooter(),
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

import 'dart:convert';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/components/search_delegate.dart';
import 'package:hajj_app/pages/extra_questions_page.dart';
import 'package:hajj_app/pages/subtitle_page.dart';
import 'package:hajj_app/pages/question_page.dart';
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
    bool isLargeScreen = MediaQuery.of(context).size.width >= 800;
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
              expandedHeight: isLargeScreen ? 150.0 : 200.0,
              flexibleSpace: FlexibleSpaceBar(
                // centerTitle: true,
                // title: Text('المعلمين'),

                background: Center(
                  child: Container(
                    // rounded
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all()),
                    constraints: BoxConstraints(
                        maxWidth: isLargeScreen ? 600 : double.infinity),
                    child: Image.asset(
                      themeProvider.themeMode == ThemeMode.dark
                          ? "assets/main_banner_dark.jpg"
                          : "assets/main_banner_light.jpg",
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: isLargeScreen ? 600 : double.infinity),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 10),
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
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
                              if (MediaQuery.of(context).size.width >= 800) {
                                Get.to(
                                  () => LargeScreenSubtitlesPage(
                                    mainTitleIndex: index,
                                    mainTitles: generatedMainTitles,
                                    questions: questions,
                                  ),
                                );
                              } else {
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
                                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: 250,
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
                                                                questions,
                                                            showAppBar: true),
                                                        transition: Transition
                                                            .leftToRight,

                                                        // routeName:
                                                        //     '/section/${generatedMainTitles[index]['title']}/${generatedMainTitles[index]['subTitles'][i]}'
                                                      );
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
                                  transition: Transition.leftToRight,
                                  // routeName: '/'
                                  // routeName:
                                  //     '/section/${generatedMainTitles[index]['title']}'
                                );
                              }
                            } else {
                              Get.to(() => ExtraQuestionsPage(),
                                  routeName: '/extra-questions');
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
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                ),
              ),
            ),
            if (!isLargeScreen)
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

class LargeScreenSubtitlesPage extends StatefulWidget {
  final int mainTitleIndex;
  final List<Map> mainTitles;
  final List<Question> questions;

  const LargeScreenSubtitlesPage({
    super.key,
    required this.mainTitleIndex,
    required this.mainTitles,
    required this.questions,
  });

  @override
  State<LargeScreenSubtitlesPage> createState() =>
      _LargeScreenSubtitlesPageState();
}

class _LargeScreenSubtitlesPageState extends State<LargeScreenSubtitlesPage> {
  int _selectedSubtitleIndex = 0;
  Question? _selectedQuestion;

  @override
  Widget build(BuildContext context) {
    var subtitles =
        widget.mainTitles[widget.mainTitleIndex]['subTitles'] as List;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 300,
              child: Drawer(
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 16.0, right: 8.0, left: 16.0, bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    widget.mainTitles[widget.mainTitleIndex]
                                        ['title'],
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontFamily: "Zarids",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Text(
                                "الأقسام",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontFamily: "Zarids",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: subtitles.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            selected: _selectedSubtitleIndex == index,
                            selectedTileColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            title: Text(
                              subtitles[index],
                              style: TextStyle(
                                fontFamily: "Zarids",
                                fontSize: 20,
                                fontWeight: _selectedSubtitleIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedSubtitleIndex == index
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedSubtitleIndex = index;
                                _selectedQuestion =
                                    null; // Clear details on section switch
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              flex: 1,
              child: SubTitlePage(
                index: widget.mainTitleIndex,
                i: _selectedSubtitleIndex,
                mainTitles: widget.mainTitles,
                questions: widget.questions,
                showAppBar: false,
                onQuestionTap: (question) {
                  setState(() {
                    _selectedQuestion = question;
                  });
                },
              ),
            ),
            if (_selectedQuestion != null)
              const VerticalDivider(width: 1, thickness: 1),
            if (_selectedQuestion != null)
              Expanded(
                flex: 2,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: QuestionPage(
                    _selectedQuestion!,
                    key: ValueKey(_selectedQuestion!.no),
                    showAppBar: false,
                    onBack: () {
                      setState(() {
                        _selectedQuestion = null; // Close the details pane
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

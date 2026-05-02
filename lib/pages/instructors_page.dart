import 'dart:convert';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/pages/intro_audio_page.dart';
import 'package:hajj_app/pages/other_questions_page.dart';
import 'package:hajj_app/components/search_delegate.dart';
import 'package:hajj_app/pages/subtitle_page.dart';
import 'package:hajj_app/pages/question_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:hajj_app/main.dart';

class InstructorsPage extends StatefulWidget {
  const InstructorsPage({super.key});

  @override
  State<InstructorsPage> createState() => _InstructorsPageState();
}

class _InstructorsPageState extends State<InstructorsPage> {
  dynamic jsonData = "";
  List<Question> questions = [];
  List<Map> generatedMainTitles = [
    {"title": "المقدمة", "subTitles": <String>[]},
    {"title": "مسائل", "subTitles": <String>[]},
    {"title": "محرمات الأحرام", "subTitles": <String>[]},
    {"title": "محرمات الحرم", "subTitles": <String>[]},
    {"title": "أحكام الكفارة", "subTitles": <String>[]},
    {"title": "عمرة التمتع", "subTitles": <String>[]},
    {"title": "حج التمتع", "subTitles": <String>[]},
    {"title": "مسائل إضافية", "subTitles": <String>[]},
  ];
  bool _isLoading = true;
  final String instructor = "شيخ جعفر العبدالكريم";

  static dynamic _cachedJsonData;
  static List<Question> _cachedQuestions = [];
  static List<Map> _cachedGeneratedMainTitles = [];

  Future<void> loadJsonAsset() async {
    if (_cachedQuestions.isNotEmpty && _cachedGeneratedMainTitles.isNotEmpty) {
      if (mounted) {
        setState(() {
          jsonData = _cachedJsonData;
          questions = _cachedQuestions;
          generatedMainTitles = List.from(_cachedGeneratedMainTitles);
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          "https://opensheet.elk.sh/1KxJKKxKBcEd0lguKAbK-UkGIqzAcOXs5is3zNiTnFgY/1"));
      var data1 = utf8.decode(response.bodyBytes);
      var data = jsonDecode(data1);
      if (mounted) {
        setState(() {
          jsonData = data;
        });
      } else {
        jsonData = data;
      }

      String normalize(String s) =>
          s.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');

      for (var i = 0; i < jsonData.length; i++) {
        questions.add(Question.fromJson(jsonData[i]));

        String mainTitle = jsonData[i]['MainTitle']?.toString().trim() ?? '';
        String subTitle = jsonData[i]['SubTitle']?.toString().trim() ?? '';

        if (mainTitle.isEmpty) continue;

        int index = generatedMainTitles.indexWhere(
            (element) => normalize(element['title']) == normalize(mainTitle));

        if (index == -1) {
          generatedMainTitles.insert(generatedMainTitles.length - 1, {
            "title": mainTitle,
            "subTitles": [subTitle]
          });
        } else {
          if (!generatedMainTitles[index]['subTitles'].contains(subTitle)) {
            generatedMainTitles[index]['subTitles'].add(subTitle);
          }
        }
      }

      questions = getQuestionsByInstructor(instructor);

      _cachedJsonData = jsonData;
      _cachedQuestions = questions;
      _cachedGeneratedMainTitles = List.from(generatedMainTitles);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      } else {
        _isLoading = false;
      }
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
              expandedHeight: isLargeScreen ? 180.0 : 200.0,
              flexibleSpace: FlexibleSpaceBar(
                // centerTitle: true,
                // title: Text('المعلمين'),

                background: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      // rounded
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? Colors.black
                                : Colors.white,
                          )),
                      constraints: BoxConstraints(
                          maxWidth: isLargeScreen ? 600 : double.infinity),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          themeProvider.themeMode == ThemeMode.dark
                              ? "assets/main_banner_dark.jpg"
                              : "assets/main_banner_light.jpg",
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          gaplessPlayback: true,
                        ),
                      ),
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
                            // move image to the right
                            alignment: Alignment.center,
                            width: double.infinity,
                            gaplessPlayback: true,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: Padding(
                                  padding: const EdgeInsets.all(5),
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: Padding(
                                  padding: const EdgeInsets.all(5),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  color: Theme.of(context).colorScheme.secondary,
                  thickness: 2,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(5),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    String currentTitle = generatedMainTitles[index]['title'];

                    void onItemTap() async {
                      if (currentTitle == "المقدمة") {
                        Get.to(() => const IntroAudioPage(),
                            routeName: '/intro');
                      } else if (currentTitle == "مسائل إضافية") {
                        Get.to(() => const OtherQuestionsPage(),
                            routeName: '/other-questions');
                      } else {
                        if (_isLoading) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                                child: CircularProgressIndicator()),
                          );
                          while (_isLoading && mounted) {
                            await Future.delayed(
                                const Duration(milliseconds: 100));
                          }
                          if (mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        }

                        if (MediaQuery.of(context).size.width >= 800) {
                          Get.to(
                            () => LargeScreenSubtitlesPage(
                              mainTitleIndex: index,
                              mainTitles: generatedMainTitles,
                              questions: questions,
                            ),
                            routeName:
                                '/section/${Uri.encodeComponent(currentTitle)}',
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
                                              "- ${currentTitle == "مسائل" ? "شرائط الحج وأحكامه" : currentTitle} -",
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
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                    ),
                                    centerTitle: true,
                                    toolbarHeight: 80,
                                  ),
                                  body: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Builder(builder: (context) {
                                      bool isInnerLargeScreen =
                                          MediaQuery.of(context).size.width >=
                                              800;
                                      return GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent:
                                              isInnerLargeScreen ? 350 : 250,
                                          childAspectRatio:
                                              isInnerLargeScreen ? 1.0 : 0.85,
                                        ),
                                        itemCount: generatedMainTitles[index]
                                                ['subTitles']
                                            .length,
                                        itemBuilder: (context, i) {
                                          return Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Card.outlined(
                                                clipBehavior: Clip.antiAlias,
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
                                                        routeName:
                                                            '/section/${Uri.encodeComponent(currentTitle)}/${Uri.encodeComponent(generatedMainTitles[index]['subTitles'][i])}',
                                                      );
                                                    },
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 12.0,
                                                                    left: 12.0,
                                                                    right:
                                                                        12.0),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              child:
                                                                  Image.asset(
                                                                'assets/kabba.jpg',
                                                                fit: BoxFit
                                                                    .cover,
                                                                width: double
                                                                    .infinity,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12.0,
                                                                    vertical:
                                                                        4.0),
                                                            child: Center(
                                                              child: Text(
                                                                generatedMainTitles[
                                                                        index][
                                                                    'subTitles'][i],
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .primary,
                                                                    fontSize:
                                                                        22,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    height: 1.1,
                                                                    fontFamily:
                                                                        "Zarids"),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ))),
                                          );
                                        },
                                      );
                                    }),
                                  ),
                                )),
                            transition: Transition.leftToRight,
                            routeName:
                                '/section/${Uri.encodeComponent(currentTitle)}',
                          );
                        }
                      }
                    }

                    if (isLargeScreen) {
                      return Padding(
                        padding: const EdgeInsets.all(5),
                        child: Card.outlined(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: onItemTap,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      generatedMainTitles[index]['title'] ==
                                              "مسائل"
                                          ? "شرائط الحج وأحكامه"
                                          : generatedMainTitles[index]['title'],
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Zarids"),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Image.asset(
                                    'assets/titlesImages/${index + 1}_icon.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.contain,
                                    gaplessPlayback: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(5),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image: DecorationImage(
                            image: AssetImage(
                              themeProvider.themeMode == ThemeMode.dark
                                  ? 'assets/titlesImages/${index + 1}_dark.png'
                                  : 'assets/titlesImages/${index + 1}.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: InkWell(
                          // radius is like the card
                          borderRadius: BorderRadius.circular(30),
                          onTap: onItemTap,
                        ),
                      ),
                    );
                  },
                  childCount: generatedMainTitles.length,
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isLargeScreen ? 400 : 250,
                  childAspectRatio: isLargeScreen ? 3.0 : 1.0,
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
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
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

class PulseSkeleton extends StatefulWidget {
  final Widget child;
  const PulseSkeleton({super.key, required this.child});

  @override
  State<PulseSkeleton> createState() => _PulseSkeletonState();
}

class _PulseSkeletonState extends State<PulseSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
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
  double _drawerWidth = 300.0;
  double _detailsWidth = 400.0;

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
              width: _drawerWidth,
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
                                                ['title'] ==
                                            "مسائل"
                                        ? "شرائط الحج وأحكامه"
                                        : widget.mainTitles[
                                            widget.mainTitleIndex]['title'],
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
                            selectedTileColor:
                                Theme.of(context).colorScheme.primaryContainer,
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
                                        .onPrimaryContainer
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
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanUpdate: (details) {
                  setState(() {
                    _drawerWidth -= details.delta.dx;
                    _drawerWidth = _drawerWidth.clamp(
                        200.0, MediaQuery.of(context).size.width * 0.5);
                  });
                },
                child: const SizedBox(
                  width: 10,
                  child: VerticalDivider(width: 1, thickness: 1),
                ),
              ),
            ),
            Expanded(
              child: SubTitlePage(
                index: widget.mainTitleIndex,
                i: _selectedSubtitleIndex,
                mainTitles: widget.mainTitles,
                questions: widget.questions,
                showAppBar: false,
                onQuestionTap: (question) {
                  Provider.of<GlobalAudioProvider>(context, listen: false)
                      .setBookmarkMode(false);
                  setState(() {
                    _selectedQuestion = question;
                  });
                },
              ),
            ),
            if (_selectedQuestion != null)
              MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onPanUpdate: (details) {
                    setState(() {
                      _detailsWidth += details.delta.dx;
                      _detailsWidth = _detailsWidth.clamp(
                          300.0, MediaQuery.of(context).size.width * 0.5);
                    });
                  },
                  child: const SizedBox(
                    width: 10,
                    child: VerticalDivider(width: 1, thickness: 1),
                  ),
                ),
              ),
            if (_selectedQuestion != null)
              SizedBox(
                width: _detailsWidth,
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

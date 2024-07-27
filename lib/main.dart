import 'package:animations/animations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/other_question_page.dart';
import 'package:hajj_app/question_page.dart';
import 'package:hajj_app/settings_page.dart';
import 'package:http/http.dart' as http;
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/search_delegate.dart';
import 'package:hajj_app/settings.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:hajj_app/color_schemes.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // load mp3 files

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => BookmarkProvider()),
        ChangeNotifierProvider(create: (context) => FontSizeProvider()),
      ],
      child: Consumer3<ThemeProvider, BookmarkProvider, FontSizeProvider>(
        builder:
            (context, themeProvider, bookmarkProvider, fontSizeProvider, _) =>
                GetMaterialApp(
          title: 'حج التمتع',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          home: const MainPage(),
        ),
      ),
    );
  }
}

class AdsSection extends StatefulWidget {
  const AdsSection({super.key});

  @override
  State<AdsSection> createState() => _AdsSectionState();
}

class _AdsSectionState extends State<AdsSection> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  List<Map> _adsList = [];
  late Future<void> _initAdsData;

  @override
  void initState() {
    super.initState();
    _initAdsData = _initAds();
  }

  List<Map> latest3Ads = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initAdsData,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              {
                return const Center(child: Text("جاري التحميل...."));
              }
            case ConnectionState.done:
              {
                return RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _refreshAds,
                    child: Column(children: [
                      const Text("اخر الأخبار", style: TextStyle(fontSize: 25)),
                      CarouselSlider(
                        options: CarouselOptions(
                            height: 250.0,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 5)),
                        // items are the three latest ads
                        items: latest3Ads.map<Widget>((item) {
                          // get id from Google drive link "https://drive.google.com/open?id=1LuvZ2inwSYe1L7qLba2btdnCeASfqSvs"
                          String id = item['Image'].toString().split('id=')[1];
                          String imageURL =
                              "https://lh3.googleusercontent.com/d/$id=s1000?authuser=0";

                          return Card(
                            child: InkWell(
                              onTap: () {
                                Get.to(
                                    () => AdDetailsPage(
                                        imageURL: imageURL,
                                        title: item['Title'],
                                        description: item['Description'],
                                        link: item['Link']),
                                    transition: Transition.downToUp);
                              },
                              child: Image.network(imageURL, fit: BoxFit.cover),
                            ),
                          );
                        }).toList(),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("جميع الإعلانات الحالية:",
                                style: TextStyle(fontSize: 25))),
                      ),
                      Expanded(
                          flex: 4,
                          child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                              ),
                              reverse: true,
                              shrinkWrap: true,
                              itemCount: _adsList.length,
                              itemBuilder: (context, index) {
                                // get id from Google drive link "https://drive.google.com/open?id=1LuvZ2inwSYe1L7qLba2btdnCeASfqSvs"
                                String id = _adsList[index]['Image']
                                    .toString()
                                    .split('id=')[1];
                                String imageURL =
                                    "https://lh3.googleusercontent.com/d/$id=s1000?authuser=0";

                                return Card(
                                  child: InkWell(
                                      onTap: () {
                                        Get.to(
                                            () => AdDetailsPage(
                                                imageURL: imageURL,
                                                title: _adsList[index]['Title'],
                                                description: _adsList[index]
                                                    ['Description'],
                                                link: _adsList[index]['Link']),
                                            transition: Transition.downToUp);
                                      },
                                      child: Center(
                                          child:
                                              Text(_adsList[index]['Title']))),
                                );
                              }))
                    ]));
              }
          }
        });
  }

  Future<void> _initAds() async {
    final response = await http.get(Uri.parse(
        'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/1'));
    if (response.statusCode == 200) {
      // get data utf8

      var decodedData = utf8.decode(response.bodyBytes);
      var data = jsonDecode(decodedData);

      List<Map> validAds = [];

      for (var i = 0; i < data.length; i++) {
        var item = data[i];
        if (DateTime.now().isAfter(DateTime.parse(item['StartDate'])) &&
            DateTime.now().isBefore(DateTime.parse(item['EndDate']))) {
          validAds.add(item);
        }
      }

      setState(() {
        _adsList = validAds;
        if (validAds.length > 3) {
          // latest3Ads = validAds.sublist(0, 3);
          latest3Ads = validAds.sublist(validAds.length - 3);
        } else {
          latest3Ads = validAds;
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _refreshAds() async {
    final response = await http.get(Uri.parse(
        'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/1'));
    if (response.statusCode == 200) {
      // get data utf8

      var decodedData = utf8.decode(response.bodyBytes);
      var data = jsonDecode(decodedData);

      List<Map> validAds = [];

      for (var i = 0; i < data.length; i++) {
        var item = data[i];
        if (DateTime.now().isAfter(DateTime.parse(item['StartDate'])) &&
            DateTime.now().isBefore(DateTime.parse(item['EndDate']))) {
          validAds.add(item);
        }
      }

      setState(() {
        _adsList = validAds;
        if (validAds.length > 3) {
          // get the last 3 items in validAds
          latest3Ads = validAds.sublist(validAds.length - 3);
        } else {
          latest3Ads = validAds;
        }
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return DefaultTabController(
      length: 2,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("حج التمتع"),
            centerTitle: true,
            // toolbarHeight: 200,
            // title: Stack(children: [
            //   Image(
            //     fit: BoxFit.fill,
            //     image: AssetImage(
            //         'assets/main_banner_${themeProvider.themeMode == ThemeMode.dark ? 'dark' : 'light'}.jpg'),
            //   ),
            //   Row(
            //     children: [
            //       IconButton(
            //         onPressed: () {
            //           Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (context) => const SettingsPage()));
            //         },
            //         icon: const Icon(Icons.settings_outlined),
            //       ),
            //     ],
            //   )
            // ]),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.groups_outlined), text: "المعلمين"),
                Tab(icon: Icon(Icons.new_releases_outlined), text: "الإعلانات"),
              ],
            ),
          ),
          body: TabBarView(
            children: [instructors(themeProvider), const AdsSection()],
          ),
        ),
      ),
    );
  }
}

var _intructorsNames = <String>[
  "شيخ جعفر العبدالكريم",
  "شيخ عبدالله العبدالله",
  "شيخ علي الدهنين"
];

Column instructors(themeProvider) {
  return Column(
    children: [
      // Image(
      //   fit: BoxFit.fill,
      //   image: AssetImage(
      //       'assets/main_banner_${themeProvider.themeMode == ThemeMode.dark ? 'dark' : 'light'}.jpg'),
      // ),

      Expanded(
        flex: 3,
        child: ListView.builder(
          itemCount: _intructorsNames.length,
          itemBuilder: (context, i) {
            return GestureDetector(
              child: ListTile(
                trailing: const Icon(Icons.arrow_forward_ios),
                title: Text(_intructorsNames[i],
                    style: TextStyle(
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.white
                            : Colors.black)),
                onTap: () {
                  Get.to(() => InstructorPage(_intructorsNames[i]),
                      transition: Transition.leftToRight);
                },
              ),
            );
          },
        ),
      ),
      const ContactFooter(),
    ],
  );
}

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
    print(generatedMainTitles);
    questions = getQuestionsByInstructor(widget.instructor);
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
    // {"title": "مسائل إضافية"}
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
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.all(10),
                    child: Card(
                      color: const Color(0xFFe4e4e6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: InkWell(
                        onTap: () {
                          Get.to(
                              () => Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Scaffold(
                                    appBar: AppBar(
                                      title: Text(
                                          generatedMainTitles[index]['title']),
                                      centerTitle: true,
                                    ),
                                    body: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                        ),
                                        itemCount: generatedMainTitles[index]
                                                ['subTitles']
                                            .length,
                                        itemBuilder: (context, i) {
                                          return Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Card(
                                              color: const Color(0xFFe0eeed),
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
                                                      generatedMainTitles[index]
                                                          ['subTitles'][i],
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xFF267678),
                                                          fontSize: 24,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: "Zarids"),
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
                  ),
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

class OtherQuestionsPage extends StatefulWidget {
  const OtherQuestionsPage({
    super.key,
  });

  @override
  State<OtherQuestionsPage> createState() => _OtherQuestionsPageState();
}

class _OtherQuestionsPageState extends State<OtherQuestionsPage> {
  // load question from https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/2
  Future<void> loadJSONQuestionData() async {
    final response = await http.get(Uri.parse(
        'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/2'));
    if (response.statusCode == 200) {
      // get data utf8

      var decodedData = utf8.decode(response.bodyBytes);
      var data = jsonDecode(decodedData);

      // get mainTitle from subTitle

      for (var i = 0; i < data.length; i++) {
        var question = QuestionModel.fromJson(data[i]);
        otherQuestions.add(question);
        debugPrint(question.question);
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<QuestionModel> otherQuestions = [];

  @override
  void initState() {
    super.initState();
    loadJSONQuestionData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('مسائل إضافية'),
            centerTitle: true,
          ),
          body: FutureBuilder(
            future: http.get(Uri.parse(
                'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/2')),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                ///first decode the response to utf-8 string
                var myDataString = utf8.decode(snapshot.data!.bodyBytes);

                ///obtain json from string
                var data = jsonDecode(myDataString);
                // var data = jsonDecode(snapshot.data!.body);

                if (data.length == 0) {
                  return const Center(child: Text("لا توجد أسئلة أخرى"));
                }

                // show a grid view with images like pinterest
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var question = QuestionModelOther.fromJson(data[index]);
// 4949
                    return QuestionTile(
                      questionModelAr: question,
                    );
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )),
    );
  }
}

class AdCardWidget extends StatelessWidget {
  const AdCardWidget(
      {super.key,
      required this.title,
      required this.description,
      required this.imageURL,
      required this.link});

  final String imageURL;
  final String title;
  final String description;
  final String link;

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedElevation: 0,
      openBuilder: (BuildContext context, void Function() action) {
        return AdDetailsPage(
            imageURL: imageURL,
            title: title,
            description: description,
            link: link);
      },
      closedBuilder: (BuildContext context, void Function() action) => Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 2,
        margin: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 335,
              height: 150,
              child: Image.network(imageURL, fit: BoxFit.cover, frameBuilder:
                  (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) {
                  return child;
                } else {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: frame == null ? 0 : 1,
                    child: child,
                  );
                }
              }, errorBuilder: (context, error, stackTrace) {
                return const Center(child: Text("لا يمكن تحميل الصورة"));
              }, loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class AdDetailsPage extends StatelessWidget {
  const AdDetailsPage({
    super.key,
    required this.imageURL,
    required this.title,
    required this.description,
    required this.link,
  });

  final String imageURL;
  final String title;
  final String description;
  final String link;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: [
            InteractiveViewer(
                child: Image.network(
              imageURL,
              // fit: BoxFit.cover,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(description),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilledButton.icon(
                  onPressed: () async {
                    Uri url = Uri.parse(link);
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.launch_outlined),
                  label: const Text("رابط")),
            )
          ],
        ),
      ),
    );
  }
}

class CustomizedIconButton extends StatelessWidget {
  const CustomizedIconButton({
    super.key,
    required this.icon,
    required this.link,
    required this.themeProvider,
  });

  final ThemeProvider themeProvider;
  final IconData icon;
  final String link;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, top: 2),
      child: IconButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          backgroundColor: themeProvider.themeMode == ThemeMode.dark
              ? WidgetStateProperty.all(Colors.green[400])
              : WidgetStateProperty.all(Colors.green),
        ),
        color: themeProvider.themeMode == ThemeMode.dark
            ? Colors.black
            : Colors.white,
        onPressed: () async {
          Uri url = Uri.parse(link);
          // open link
          if (!await launchUrl(url)) {
            throw Exception('Could not launch $url');
          }
        },
        icon: Icon(icon),
      ),
    );
  }
}

// See Example - _onShareXFileFromAsset() or my version
//
Future<void> shareQuestion(QuestionModel question) async {
  // check if the file is in the assets folder

  final buffer = await rootBundle.load("assets/audiofiles/${question.no}.mp3");

  final data = Uint8List.view(buffer.buffer);
  try {
    final file = XFile.fromData(
      data,
      mimeType: 'audio/mpeg',
      name: '${question.no}.mp3',
      lastModified: DateTime.now(),
      length: data.length,
    );

    final result = await Share.shareXFiles([file], text: """
${question.mainTitle} - ${question.subTitle}

${question.question} 

${question.answerText}

من تطبيق حج التمتع في سؤال وجواب
""");

    debugPrint('${result.status}');
  } on Object catch (e) {
    debugPrint('$e');
  }
}

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
          child: Card.outlined(
            // rounded
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 1,

            child: InkWell(
              onTap: () {
                Get.to(() => QuestionPage(question!),
                    transition: Transition.downToUp);
              },
              child: ListTile(
                subtitle: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // IconButton.filledTonal(
                      //     onPressed: () async {
                      //       await shareQuestion(question!);
                      //       // Share.shareXFiles(
                      //       //     [XFile("assets/audiofiles/${question.no}.mp3")],
                      //       //     text: 'Great picture');
                      //       // [XFile('assets/audiofiles/${question.no}.mp3')],
                      //       // text: 'Great picture');
                      //     },
                      //     icon: const Icon(Icons.share_outlined)),
                      Text(question!.mainTitle!),
                    ],
                  ),
                ),
                isThreeLine: true,
                // remove the number before ":" and show the question
                title: Padding(
                  padding: const EdgeInsets.only(right: 5, left: 5, top: 5),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${question!.subTitle}\n",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 20,
                              fontFamily: "Zarids",
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: question!.question!,
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

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({
    super.key,
    required this.bookmarkProvider,
    required this.questions,
  });

  final BookmarkProvider bookmarkProvider;
  final List<QuestionModel> questions;

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  bool isPlaying = false;

  final AudioPlayer audioPlayer = AudioPlayer();

  // make a playlist for the bookmarked questions and when a question ends play the next one
  Future<void> initAudio() async {
    try {
      // play the first audio and when it ends play the next one
      audioPlayer.setAsset(
          "assets/audiofiles/${widget.bookmarkProvider.bookmarks[0].no}.mp3");
      audioPlayer.playerStateStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          for (var i = 0; i < widget.bookmarkProvider.bookmarks.length; i++) {
            if (widget.bookmarkProvider.bookmarks[i].no ==
                widget.bookmarkProvider.bookmarks[i].no) {
              if (i + 1 < widget.bookmarkProvider.bookmarks.length) {
                audioPlayer.setAsset(
                    "assets/audiofiles/${widget.bookmarkProvider.bookmarks[i + 1].no}.mp3");
                audioPlayer.play();
              } else {
                audioPlayer.play();
              }
            }
          }
        }
      });
    } catch (e) {
      debugPrint("$e");
    }
  }

  @override
  void initState() {
    initAudio();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('المفضلة'),
              centerTitle: true,
            ),
            body: Column(children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.bookmarkProvider.bookmarks.length,
                  itemBuilder: (context, index) {
                    if (widget.bookmarkProvider.bookmarks.isEmpty) {
                      return const Text("لا توجد أسئلة في المفضلة");
                    }
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(widget
                            .bookmarkProvider.bookmarks[index].question!
                            .split(":")[0]),
                      ),
                      title: Text(
                          widget.bookmarkProvider.bookmarks[index].question!
                              .split(":")[1],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        for (var i = 0; i < widget.questions.length; i++) {
                          if (widget
                                  .bookmarkProvider.bookmarks[index].question ==
                              widget.questions[i].question) {
                            Get.to(() => QuestionPage(widget.questions[i]),
                                transition: Transition.rightToLeft);
                          }
                        }
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          // play or pause the audio
                          setState(() {
                            isPlaying = !isPlaying;
                          });
                          if (isPlaying) {
                            audioPlayer.play();
                          } else {
                            audioPlayer.pause();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              // audio player
              if (widget.bookmarkProvider.bookmarks.isNotEmpty)
                Card(
                  elevation: 0.5,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () async {
                                  // don't remove more than the duration
                                  if (audioPlayer.position.inSeconds - 10 < 0) {
                                    await audioPlayer
                                        .seek(const Duration(seconds: 0));
                                  } else {
                                    await audioPlayer.seek(
                                        audioPlayer.position -
                                            const Duration(seconds: 10));
                                  }
                                },
                                icon: const Icon(Icons.fast_forward)),
                            // play button for playlist
                            IconButton(
                                onPressed: () async {
                                  setState(() {
                                    isPlaying = !isPlaying;
                                  });
                                  if (isPlaying) {
                                    audioPlayer.play();
                                  } else {
                                    audioPlayer.pause();
                                  }
                                },
                                icon: isPlaying
                                    ? const Icon(Icons.pause)
                                    : const Icon(Icons.play_arrow)),
                            IconButton(
                                onPressed: () async {
                                  // don't add more than the duration
                                  if (audioPlayer.position.inSeconds + 10 >
                                      audioPlayer.duration!.inSeconds) {
                                    await audioPlayer
                                        .seek(audioPlayer.duration!);
                                  } else {
                                    await audioPlayer.seek(
                                        audioPlayer.position +
                                            const Duration(seconds: 10));
                                  }
                                },
                                icon: const Icon(Icons.fast_rewind)),
                          ],
                        ),
                        // duration of the audio
                        if (audioPlayer.duration != null)
                          SizedBox(
                              width: double.infinity,
                              height: 30,
                              child: StreamBuilder<Duration?>(
                                  stream: audioPlayer.durationStream,
                                  builder: (context, snapshot) {
                                    final duration = snapshot.data;
                                    return StreamBuilder<Duration>(
                                        stream: audioPlayer.positionStream,
                                        builder: (context, snapshot) {
                                          if (snapshot.data == null) {
                                            return const SizedBox();
                                          }
                                          var position = snapshot.data;
                                          position ??= const Duration();
                                          return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "${position.inMinutes}:${position.inSeconds.remainder(60)}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                                Slider(
                                                  inactiveColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .surface,
                                                  value: position.inSeconds
                                                      .toDouble(),
                                                  onChanged: (value) {
                                                    audioPlayer.seek(Duration(
                                                        seconds:
                                                            value.toInt()));
                                                  },
                                                  min: 0.0,
                                                  max: duration!.inSeconds
                                                      .toDouble(),
                                                ),
                                                Text(
                                                  "${duration.inMinutes}:${duration.inSeconds.remainder(60)}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ]);
                                        });
                                  }))
                      ],
                    ),
                  ),
                )
            ])));
  }
}

class ContactFooter extends StatelessWidget {
  const ContactFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(
            'للتواصل معنا',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // icons for social media
              IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                ),
                color: Colors.white,
                onPressed: () async {
                  Uri url = Uri.parse(
                      'https://www.facebook.com/hamlah.alkhalaf/?locale=ar_AR');
                  // open link
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                icon: const Icon(CommunityMaterialIcons.facebook),
              ),
              const SizedBox(width: 10),
              IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.yellow),
                ),
                color: Colors.black,
                onPressed: () async {
                  Uri url = Uri.parse(
                      'https://www.snapchat.com/add/h_alkalaf?sender_web_id=6152c6b7-009d-4f62-b453-490df90fe35e&device_type=desktop&is_copy_url=true');
                  // open link
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                icon: const Icon(CommunityMaterialIcons.snapchat),
              ),
              const SizedBox(width: 10),

              IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.pink),
                ),
                color: Colors.white,
                onPressed: () async {
                  Uri url =
                      Uri.parse('https://www.instagram.com/h_alkalaf/?hl=en');
                  // open link
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                icon: const Icon(CommunityMaterialIcons.instagram),
              ),
              const SizedBox(width: 10),

              IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                ),
                color: Colors.red,
                onPressed: () async {
                  Uri url = Uri.parse('https://www.youtube.com/@halkalaf');
                  // open link
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                icon: const Icon(CommunityMaterialIcons.youtube),
              ),
              const SizedBox(width: 10),

              IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor:
                      WidgetStateProperty.all(const Color(0xFF2b7b7a)),
                ),
                color: Colors.white,
                onPressed: () async {
                  Uri url = Uri.parse('https://wa.me/+966500155187');
                  // open link
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                icon: const Icon(CommunityMaterialIcons.face_agent),
              ),
              const SizedBox(width: 5),
              Text(
                "@h_alkhalaf",
                textDirection: TextDirection.ltr,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 20),
              )
            ],
          ),
          const SizedBox(width: 90),
        ],
      ),
    );
  }
}

class ContactFooterImageTemplate extends StatelessWidget {
  const ContactFooterImageTemplate({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // icons for social media
                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  color: Colors.black,
                  onPressed: () async {
                    Uri url = Uri.parse(
                        'https://www.facebook.com/hamlah.alkhalaf/?locale=ar_AR');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.facebook),
                ),
                const SizedBox(width: 5),
                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  color: Colors.black,
                  onPressed: () async {
                    Uri url = Uri.parse(
                        'https://www.snapchat.com/add/h_alkalaf?sender_web_id=6152c6b7-009d-4f62-b453-490df90fe35e&device_type=desktop&is_copy_url=true');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.snapchat),
                ),
                const SizedBox(width: 5),

                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  color: Colors.black,
                  onPressed: () async {
                    Uri url =
                        Uri.parse('https://www.instagram.com/h_alkalaf/?hl=en');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.instagram),
                ),
                const SizedBox(width: 5),

                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  color: Colors.black,
                  onPressed: () async {
                    Uri url = Uri.parse('https://www.youtube.com/@halkalaf');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.youtube),
                ),
                const SizedBox(width: 10),
                Text("@h_alkhalaf",
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 15))
              ],
            ),
            // for maintance
          ],
        ),
      ),
    );
  }
}

class ContactFooterImage extends StatelessWidget {
  const ContactFooterImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // icons for social media
                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(Colors.blue),
                  ),
                  color: Colors.white,
                  onPressed: () async {
                    Uri url = Uri.parse(
                        'https://www.facebook.com/hamlah.alkhalaf/?locale=ar_AR');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.facebook),
                ),
                const SizedBox(width: 5),
                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(Colors.yellow),
                  ),
                  color: Colors.black,
                  onPressed: () async {
                    Uri url = Uri.parse(
                        'https://www.snapchat.com/add/h_alkalaf?sender_web_id=6152c6b7-009d-4f62-b453-490df90fe35e&device_type=desktop&is_copy_url=true');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.snapchat),
                ),
                const SizedBox(width: 5),

                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(Colors.pink),
                  ),
                  color: Colors.white,
                  onPressed: () async {
                    Uri url =
                        Uri.parse('https://www.instagram.com/h_alkalaf/?hl=en');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.instagram),
                ),
                const SizedBox(width: 5),

                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  color: Colors.red,
                  onPressed: () async {
                    Uri url = Uri.parse('https://www.youtube.com/@halkalaf');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.youtube),
                ),
                const SizedBox(width: 10),
                Text("@h_alkhalaf",
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 20))
              ],
            ),
            // for maintance
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/pages/ads_section.dart';
import 'package:hajj_app/pages/instructor_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import 'package:hajj_app/color_schemes.g.dart';

import 'pages/settings_page.dart';

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
        ChangeNotifierProvider(create: (context) => QuestionPrefsProvider()),
      ],
      child: Consumer3<ThemeProvider, BookmarkProvider, QuestionPrefsProvider>(
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
            appBarTheme: const AppBarTheme(
                titleTextStyle: TextStyle(
              fontFamily: "Zarids",
              fontSize: 35,
              fontWeight: FontWeight.bold,
            )),
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const MainPage(),
          },
        ),
      ),
    );
  }
}

enum PageType { instructors, ads, settings, bookmarks }

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

  var pageType = PageType.instructors;

  List<Map<PageType, String>> pageTitles = [
    {PageType.instructors: "المعلمين"},
    {PageType.ads: "الإعلانات"},
    {PageType.bookmarks: "المفضلة"},
    {PageType.settings: "الإعدادات"},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            pageTitles
                .where((element) => element.keys.first == pageType)
                .first
                .values
                .first,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: "Zarids",
              fontSize: 35,
              fontWeight: FontWeight.w400,
            ),
          ),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: "حج التمتع\n",
                    style: TextStyle(
                      fontFamily: "Zarids",
                      fontSize: 35,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "في سؤال وجواب",
                    style: TextStyle(
                      fontFamily: "Zarids",
                      fontSize: 25,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ])),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text(
                  'المعلمين',
                  style: TextStyle(fontFamily: "Zarids", fontSize: 25),
                ),
                onTap: () {
                  setState(() {
                    pageType = PageType.instructors;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.new_releases),
                title: const Text(
                  'الإعلانات',
                  style: TextStyle(fontFamily: "Zarids", fontSize: 25),
                ),
                onTap: () {
                  setState(() {
                    pageType = PageType.ads;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text(
                  'المفضلة',
                  style: TextStyle(fontFamily: "Zarids", fontSize: 25),
                ),
                onTap: () {
                  setState(() {
                    pageType = PageType.bookmarks;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text(
                  'الإعدادات',
                  style: TextStyle(fontFamily: "Zarids", fontSize: 25),
                ),
                onTap: () {
                  setState(() {
                    pageType = PageType.settings;
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: pageType == PageType.instructors
            ? const InstructorsSection()
            : pageType == PageType.ads
                ? const AdsSection()
                : pageType == PageType.settings
                    ? const SettingsPage()
                    : const SizedBox.shrink(),
        // body: const TabBarView(
        //   children: [
        //     InstructorsSection(),
        //     AdsSection(),
        //   ],
        // ),
      ),
    );
  }
}

var _intructorsNames = <String>[
  "شيخ جعفر العبدالكريم",
  "شيخ عبدالله العبدالله",
  "شيخ علي الدهنين"
];

class InstructorsSection extends StatefulWidget {
  const InstructorsSection({
    super.key,
  });

  @override
  State<InstructorsSection> createState() => _InstructorsSectionState();
}

class _InstructorsSectionState extends State<InstructorsSection> {
  String searchQuery = "";
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        // search bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            style: TextStyle(
                fontFamily: "Zarids",
                fontSize: 24,
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.white
                    : Colors.black),
            decoration: InputDecoration(
              hintText: "بحث",
              hintStyle: TextStyle(
                  fontFamily: "Zarids",
                  fontSize: 24,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        if (searchQuery.isNotEmpty &&
            !_intructorsNames.any((element) =>
                element.toLowerCase().contains(searchQuery.toLowerCase())))
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "لا يوجد نتائج",
              style: TextStyle(
                  fontFamily: "Zarids",
                  fontSize: 24,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black),
            ),
          ),

        Expanded(
          flex: 3,
          child: ListView.builder(
            itemCount: _intructorsNames.length,
            itemBuilder: (context, i) {
              // only show the instructors that match the search query and if there is no match show a message
              if (searchQuery.isNotEmpty &&
                  !_intructorsNames[i].contains(searchQuery)) {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                child: ListTile(
                  trailing: const Icon(Icons.arrow_forward_ios),
                  title: Text(_intructorsNames[i],
                      style: TextStyle(
                          fontFamily: "Zarids",
                          fontSize: 24,
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
}

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

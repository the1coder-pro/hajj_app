import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/pages/ads_section.dart';
import 'package:hajj_app/pages/instructor_page.dart';
import 'package:hajj_app/pages/settings_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
          initialRoute: '/',
          routes: {
            '/': (context) => const MainPage(),
          },
        ),
      ),
    );
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
      length: 3,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(75.0),
              child: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.groups_outlined), text: "المعلمين"),
                  Tab(
                      icon: Icon(Icons.new_releases_outlined),
                      text: "الإعلانات"),
                  Tab(icon: Icon(Icons.settings_outlined), text: "الإعدادات"),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              instructors(themeProvider),
              const AdsSection(),
              const SettingsPage()
            ],
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

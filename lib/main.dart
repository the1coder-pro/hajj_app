import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hajj_app/pages/ads_page.dart';
import 'package:hajj_app/pages/bookmark_page.dart';
import 'package:hajj_app/pages/home_page.dart';
import 'package:hajj_app/pages/settings_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:hajj_app/color_schemes.g.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  // load mp3 files

  runApp(const MyApp());
}

const textTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: "Zarids",
    fontSize: 35,
  ),
  displayMedium: TextStyle(
    fontFamily: "Zarids",
    fontSize: 30,
  ),
  displaySmall: TextStyle(
    fontFamily: "Zarids",
    fontSize: 25,
  ),
  headlineMedium: TextStyle(
    fontFamily: "Zarids",
    fontSize: 20,
  ),
  headlineSmall: TextStyle(
    fontFamily: "Zarids",
    fontSize: 15,
  ),
  titleLarge: TextStyle(
    fontFamily: "Zarids",
    fontSize: 20,
  ),
);

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
                        textTheme: textTheme),
                    darkTheme: ThemeData(
                      appBarTheme: const AppBarTheme(
                          titleTextStyle: TextStyle(
                        fontFamily: "Zarids",
                        fontSize: 35,
                      )),
                      textTheme: textTheme,
                      colorScheme: darkColorScheme,
                      useMaterial3: true,
                    ),
                    routes: {
                      HomePage.route: (context) => const HomePage(),
                      SettingsPage.route: (context) => const SettingsPage(),
                      AdvertismentsPage.route: (context) =>
                          const AdvertismentsPage(),
                      BookmarksPage.route: (context) => const BookmarksPage(),
                    },
                    initialRoute: "/"),
      ),
    );
  }
}

Future<void> shareQuestion(Question question) async {
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

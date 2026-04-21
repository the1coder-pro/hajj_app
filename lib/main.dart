import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hajj_app/pages/ads_page.dart';
import 'package:hajj_app/pages/bookmark_page.dart';
import 'package:hajj_app/pages/home_page.dart';
import 'package:hajj_app/pages/settings_page.dart';
import 'package:hajj_app/pages/question_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:hajj_app/color_schemes.g.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:cross_file/cross_file.dart';

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
        builder: (context, themeProvider, bookmarkProvider, fontSizeProvider,
                _) =>
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
                getPages: [
                  GetPage(name: HomePage.route, page: () => const HomePage()),
                  GetPage(
                      name: SettingsPage.route,
                      page: () => const SettingsPage()),
                  GetPage(
                      name: AdvertismentsPage.route,
                      page: () => const AdvertismentsPage()),
                  GetPage(
                      name: BookmarksPage.route,
                      page: () => const BookmarksPage()),
                  GetPage(
                      name: '/question/:id',
                      page: () => QuestionPage(
                          int.tryParse(Get.parameters['id'] ?? '')),
                      transition: Transition.rightToLeft),
                ],
                initialRoute: "/"),
      ),
    );
  }
}

Future<void> shareQuestion(Question question) async {
  // check if the file is in the assets folder

  try {
    final url =
        "https://hajjaudiofiles.kumthra.com/questions_audiofiles/${question.no}.mp3";

    final cachedFile = await DefaultCacheManager().getSingleFile(url);
    XFile file;

    if (kIsWeb) {
      final bytes = await cachedFile.readAsBytes();
      file = XFile.fromData(
        bytes,
        mimeType: 'audio/mpeg',
        name: '${question.no}.mp3',
      );
    } else {
      file = XFile(
        cachedFile.path,
        mimeType: 'audio/mpeg',
        name: '${question.no}.mp3',
      );
    }

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

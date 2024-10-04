import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hajj_app/pages/home_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:hajj_app/color_schemes.g.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';

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
                        textTheme: const TextTheme(
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
                        )),
                    darkTheme: ThemeData(
                      appBarTheme: const AppBarTheme(
                          titleTextStyle: TextStyle(
                        fontFamily: "Zarids",
                        fontSize: 35,
                      )),
                      textTheme: const TextTheme(
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
                      ),
                      colorScheme: darkColorScheme,
                      useMaterial3: true,
                    ),
                    home: const HomePage()),
      ),
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

import 'package:animations/animations.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
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
      ],
      child: Consumer2<ThemeProvider, BookmarkProvider>(
        builder: (context, themeProvider, bookmarkProvider, _) => MaterialApp(
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
          home: const MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
    }
  }

  List<QuestionModel> questions = [];
  TextEditingController searchController = TextEditingController();

  // load question from https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/2
  Future<void> loadJSONQuestionData() async {
    final response = await http.get(Uri.parse(
        'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/2'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // get mainTitle from subTitle

      for (var i = 0; i < data.length; i++) {
        otherQuestions.add(QuestionModel.fromJson(data[i]));
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<QuestionModel> otherQuestions = [];

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
    {"title": "محرمات الأحرام", "image": "3.png"},
    {"title": "محرمات الحرم", "image": "4.png"},
    {"title": "أحكام الكفارة", "image": "5.png"},
    {"title": "عمرة التمتع", "image": "6.png"},
    {"title": "حج التمتع", "image": "7.png"},
    {"title": "الاعلانات"},
    {"title": "مسائل من الشيخ"}
  ];

  @override
  void initState() {
    super.initState();
    loadJsonAsset();
    loadJSONQuestionData();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    BookmarkProvider bookmarkProvider = Provider.of<BookmarkProvider>(context);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Stack(children: [
            Image(
                image: AssetImage(
                    'assets/main_banner_${themeProvider.themeMode == ThemeMode.dark ? 'dark' : 'light'}.jpg')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IconButton(
                      onPressed: () {
                        // open the bookmarks page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return BookmarksPage(
                                  bookmarkProvider: bookmarkProvider,
                                  questions: questions);
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.bookmarks_outlined)),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: IconButton(
                    color: Theme.of(context).colorScheme.onBackground,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsPage()));
                    },
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ),
              ],
            ),
          ]),
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
          // const SizedBox(height: 5),
          Divider(
              color: Theme.of(context).colorScheme.secondary, thickness: 10),

          Directionality(
            textDirection: TextDirection.rtl,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mainTitles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, index) => GestureDetector(
                child: mainTitles[index]['image'] == null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          child: Center(
                            child: Text(mainTitles[index]['title']),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                            'assets/titlesImages/${mainTitles[index]['image']}'),
                      ),
                onTap: () {
                  // show the subTitles for every maintitle only and after clicking on them it will show the questions
                  if (mainTitles[index]['title'] == "الاعلانات") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdsSectionPage()));
                  } else if (mainTitles[index]['title'] == "مسائل من الشيخ") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Scaffold(
                                    appBar: AppBar(
                                        centerTitle: true,
                                        title: const Text("مسائل من الشيخ")),
                                    body: ListView.builder(
                                      itemCount: otherQuestions.length,
                                      itemBuilder: (context, index) {
                                        return QuestionTile(
                                            otherQuestions[index]);
                                      },
                                    ),
                                  ),
                                )));
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          final List<QuestionModel> subTitlesbyMainTitle =
                              questions.where((element) {
                            return element.mainTitle ==
                                mainTitles[index]['title'];
                          }).toList();

                          // remove duplicates subTitles
                          final List<String> subTitles = [];
                          for (var i = 0;
                              i < subTitlesbyMainTitle.length;
                              i++) {
                            if (!subTitles
                                .contains(subTitlesbyMainTitle[i].subTitle)) {
                              subTitles.add(subTitlesbyMainTitle[i].subTitle!);
                            }
                          }

                          return Directionality(
                            textDirection: TextDirection.rtl,
                            child: Scaffold(
                              appBar: AppBar(
                                title: Text(mainTitles[index]['title']),
                                centerTitle: true,
                              ),
                              body: Padding(
                                padding: const EdgeInsets.all(10),
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                                  itemCount: subTitles.length,
                                  itemBuilder: (context, i) {
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      child: ListTile(
                                        onTap: () {
                                          // show the questions for every subTitle
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Directionality(
                                                textDirection:
                                                    TextDirection.rtl,
                                                child: Scaffold(
                                                    appBar: AppBar(
                                                      centerTitle: true,
                                                      title: Text(subTitles[i]),
                                                    ),
                                                    body: ListView.builder(
                                                      itemCount:
                                                          questions.length,
                                                      itemBuilder:
                                                          (context, k) {
                                                        if (subTitles[i] ==
                                                            questions[k]
                                                                .subTitle) {
                                                          return QuestionTile(
                                                              questions[k]);
                                                        } else {
                                                          return const SizedBox();
                                                        }
                                                      },
                                                    )),
                                              ),
                                            ),
                                          );
                                        },
                                        title:
                                            Center(child: Text(subTitles[i])),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          // footer with contact information
          const ContactFooter(),
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
    );
  }
}

class AdsSectionPage extends StatefulWidget {
  const AdsSectionPage({
    super.key,
  });

  @override
  State<AdsSectionPage> createState() => _AdsSectionPageState();
}

class _AdsSectionPageState extends State<AdsSectionPage> {
  // json link
  // https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/1

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('الإعلانات'),
            centerTitle: true,
          ),
          body: FutureBuilder(
            future: http.get(Uri.parse(
                'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/1')),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                ///first decode the response to utf-8 string
                var myDataString = utf8.decode(snapshot.data!.bodyBytes);

                ///obtain json from string
                var data = jsonDecode(myDataString);
                // var data = jsonDecode(snapshot.data!.body);

                // show a grid view with images like pinterest
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    // get id from Google drive link "https://drive.google.com/open?id=1LuvZ2inwSYe1L7qLba2btdnCeASfqSvs"
                    String id = data[index]['image'].toString().split('id=')[1];
                    String imageURL = "https://lh3.googleusercontent.com/d/$id";
                    // "https://drive.google.com/thumbnail?id=$id";

                    return AdCardWidget(
                        imageURL: imageURL,
                        description: data[index]['description'],
                        link: data[index]['link'],
                        title: data[index]["title"]);
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
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(),
            body: ListView(
              children: [
                Image.network(imageURL, fit: BoxFit.fill),
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
                  child: FilledButton(
                      onPressed: () async {
                        Uri url = Uri.parse(link);
                        // open link
                        if (!await launchUrl(url)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                      child: const Text("رابط")),
                )
              ],
            ),
          ),
        );
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
              height: 110,
              child: Image.network(imageURL, fit: BoxFit.fill),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold)),
            ),
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
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          backgroundColor: themeProvider.themeMode == ThemeMode.dark
              ? MaterialStateProperty.all(Colors.green[400])
              : MaterialStateProperty.all(Colors.green),
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
  final QuestionModel question;
  const QuestionTile(
    this.question, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Card(
        // rounded
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0.5,
        child: ListTile(
          onTap: () {
            // show the answer for every question
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionPage(question),
              ),
            );
          },
          subtitle: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                    onPressed: () async {
                      await shareQuestion(question);
                      // Share.shareXFiles(
                      //     [XFile("assets/audiofiles/${question.no}.mp3")],
                      //     text: 'Great picture');
                      // [XFile('assets/audiofiles/${question.no}.mp3')],
                      // text: 'Great picture');
                    },
                    icon: const Icon(Icons.share_outlined)),
                Text(question.mainTitle!),
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
                    text: "${question.subTitle}\n",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: question.question!,
                    style: TextStyle(
                        height: 1.2,
                        color: Theme.of(context).colorScheme.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: 26),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
    } catch (e) {}
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    QuestionPage(widget.questions[i]),
                              ),
                            );
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
                                                          .background,
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
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
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
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.yellow),
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
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.pink),
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
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.white),
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

              Text(
                "@h_alkhalaf",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 20),
              )
            ],
          ),
          // for maintance
          const SizedBox(height: 10),
          TextButton.icon(
              onPressed: () async {
                Uri url = Uri.parse('https://wa.me/+966500155187');
                // open link
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
              icon: Icon(Icons.chat_outlined,
                  color: Theme.of(context).colorScheme.onSecondaryContainer),
              label: Text("الدعم الفني",
                  style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer)))
        ],
      ),
    );
  }
}

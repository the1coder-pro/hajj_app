import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cross_file/cross_file.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:http/http.dart' as http;
import 'package:hajj_app/main.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage(this.questionData, {super.key});

  final dynamic questionData;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  Question? question;
  bool isLoading = true;

  // WidgetsToImageController to access widget
  WidgetsToImageController controller = WidgetsToImageController();
// to save image bytes of widget
  Uint8List? bytes;

  bool isAudioFileThere = false;
  bool isCachedLocal = false;

  Future<void> checkAudioState() async {
    if (question == null) return;
    try {
      final url =
          "https://hajjaudiofiles.kumthra.com/questions_audiofiles/${question!.no}.mp3";
      final fileInfo = await DefaultCacheManager().getFileFromCache(url);
      if (mounted) {
        setState(() {
          isCachedLocal = fileInfo != null;
          isAudioFileThere = true;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        setState(() {
          isAudioFileThere = false;
        });
      }
    }
  }

  Future<void> fetchQuestion(int id) async {
    try {
      final response = await http.get(Uri.parse(
          "https://opensheet.elk.sh/1KxJKKxKBcEd0lguKAbK-UkGIqzAcOXs5is3zNiTnFgY/1"));
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      for (var i = 0; i < data.length; i++) {
        if (data[i]['no'].toString() == id.toString()) {
          setState(() {
            question = Question.fromJson(data[i]);
            isLoading = false;
          });
          checkAudioState();
          break;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    dynamic data = widget.questionData;
    if ((data == null || data.toString() == 'null') &&
        Get.parameters.containsKey('id')) {
      data = int.tryParse(Get.parameters['id'] ?? '');
    }

    if (data is Question) {
      question = data;
      isLoading = false;
      checkAudioState();
    } else if (data is int) {
      fetchQuestion(data);
    } else if (data is String) {
      int? id = int.tryParse(data);
      if (id != null) fetchQuestion(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsProvider =
        Provider.of<QuestionPrefsProvider>(context, listen: false);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () async {
                    try {
                      // final bytes = await controller.capture();
                      // if (bytes != null) {
                      //   final directory = await getTemporaryDirectory();
                      //   // final file = File('${directory.path}/question.png');
                      //   // await file.writeAsBytes(bytes);
                      // }

                      await Share.share("""
${question!.mainTitle} - ${question!.subTitle}

${question!.question} 

${question!.answerText}

رابط السؤال:
${(kIsWeb ? "${Uri.base.origin}/question/${question!.no}" : "https://hajj-app-1.web.app/question/${question!.no}")}

من تطبيق حج التمتع في سؤال وجواب
""");
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  }),
              IconButton(
                icon: const Icon(Icons.video_settings),
                onPressed: () {
                  openQuestionSettings(context, prefsProvider);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  // if the question is bookmarked, show the bookmarked icon if not show the normal icon
                  icon: bookmarkProvider.bookmarks.contains(question)
                      ? const Icon(Icons.bookmark)
                      : const Icon(Icons.bookmark_border),
                  onPressed: () {
                    if (bookmarkProvider.bookmarks.contains(question)) {
                      bookmarkProvider.removeBookmark(question!);
                    } else {
                      bookmarkProvider.addBookmark(question!);
                    }
                  },
                ),
              ),
            ],
            leading:
                // close the page
                IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Get.offAllNamed('/');
                }
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: Stack(
            children: [
              WidgetsToImage(
                controller: controller,
                child: QuestionImageTemplate(question: question!),
              ),
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                              alignment: Alignment.centerRight,
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: "${question!.mainTitle!} / ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary)),
                                  TextSpan(
                                      text: question!.subTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary)),
                                ]),
                              )),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(question!.question!.trim(),
                              textAlign: TextAlign.right,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontFamily: "Zarids",
                                      fontSize: 35,
                                      fontWeight: FontWeight.w300,
                                      height: 1.2)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isAudioFileThere) questionAudioPlayer(context),
                      SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: Card.outlined(
                            elevation: 0,
                            // squared
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            child: Center(
                              child: Text("نص الجواب",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: "Zarids",
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary)),
                            ),
                          )),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Card.outlined(
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Consumer<QuestionPrefsProvider>(
                                  builder: (context, provider, _) => Text(
                                      question!.answerText ?? "لا يوجد نص جواب",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontFamily: "Zarids",
                                          fontWeight: FontWeight.w400,
                                          fontSize: provider.fontSize)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Future<dynamic> openQuestionSettings(
      BuildContext context, QuestionPrefsProvider prefsProvider) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Text("إعدادات",
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(fontWeight: FontWeight.normal)),
            ),
            body: ListView(
              children: [
                ListTile(
                  title: const Text(
                    "سرعة الصوت",
                    style: TextStyle(
                      fontFamily: "Zarids",
                      fontSize: 25,
                    ),
                  ),
                  subtitle: Slider(
                    label: prefsProvider.audioSpeed.toString(),
                    value: prefsProvider.audioSpeed,
                    min: 0.5,
                    max: 5,
                    // divisions are 5 4.5 4 3.5 3 2.5 2 1.5 1 0.5
                    divisions: 9,
                    onChanged: (value) {
                      prefsProvider.audioSpeed = value;
                    },
                  ),
                  leading: IconButton(
                      onPressed: () {
                        // reset
                        prefsProvider.audioSpeed = 1.0;
                      },
                      icon: const Icon(Icons.restore)),
                  trailing: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    child: Center(
                      child: Text(
                        prefsProvider.audioSpeed.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text(
                    "حجم الخط",
                    style: TextStyle(
                      fontFamily: "Zarids",
                      fontSize: 25,
                    ),
                  ),
                  subtitle: Slider(
                    label: prefsProvider.fontSize.toString(),
                    value: prefsProvider.fontSize,
                    min: 20,
                    max: 40,
                    divisions: 5,
                    onChanged: (value) {
                      prefsProvider.fontSize = value;
                    },
                  ),
                  leading: IconButton(
                    onPressed: () {
                      // reset
                      prefsProvider.fontSize = 25;
                    },
                    icon: const Icon(Icons.restore),
                  ),
                  trailing: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    child: Center(
                      child: Text(
                        prefsProvider.fontSize.toString(),
                        style: TextStyle(
                            fontSize: 22,
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Card questionAudioPlayer(BuildContext context) {
    final prefsProvider =
        Provider.of<QuestionPrefsProvider>(context, listen: false);
    final audioProvider = Provider.of<GlobalAudioProvider>(context);
    final audioPlayer = audioProvider.audioPlayer;
    final isCurrentQuestion = audioProvider.currentQuestion?.no == question!.no;
    final isPlaying = isCurrentQuestion && audioProvider.isPlaying;

    return Card.outlined(
        elevation: 0.5,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () async {
                        if (!isCachedLocal) {
                          final url =
                              "https://hajjaudiofiles.kumthra.com/questions_audiofiles/${question!.no}.mp3";
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("جاري تحميل المقطع الصوتي...")),
                          );

                          await DefaultCacheManager().downloadFile(url);

                          if (mounted) {
                            setState(() {
                              isCachedLocal = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("تم حفظ المقطع الصوتي بنجاح")),
                            );
                          }
                          if (isCurrentQuestion) {
                            audioProvider.setCached(true);
                          }
                        }
                      },
                      icon: Icon(
                          isCachedLocal ? Icons.download_done : Icons.download),
                      color: Theme.of(context).colorScheme.primary),
                  IconButton(
                      onPressed: isCurrentQuestion
                          ? () async {
                              // don't remove more than the duration
                              if (audioPlayer.position.inSeconds - 10 < 0) {
                                await audioPlayer
                                    .seek(const Duration(seconds: 0));
                              } else {
                                await audioPlayer.seek(audioPlayer.position -
                                    const Duration(seconds: 10));
                              }
                            }
                          : null,
                      icon: const Icon(Icons.fast_forward),
                      color: Theme.of(context).colorScheme.primary),
                  Center(
                    child: IconButton.outlined(
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () async {
                          audioPlayer.setSpeed(prefsProvider.audioSpeed);
                          if (!isCurrentQuestion) {
                            await audioProvider.initAudio(question!);
                            audioPlayer.play();
                          } else {
                            if (isPlaying) {
                              audioPlayer.pause();
                            } else {
                              audioPlayer.play();
                            }
                          }
                        },
                        icon: isPlaying
                            ? const Icon(Icons.pause)
                            : const Icon(Icons.play_arrow)),
                  ),
                  IconButton(
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: isCurrentQuestion
                          ? () async {
                              // don't add more than the duration
                              if (audioPlayer.position.inSeconds + 10 >
                                  audioPlayer.duration!.inSeconds) {
                                await audioPlayer.seek(audioPlayer.duration!);
                              } else {
                                await audioPlayer.seek(audioPlayer.position +
                                    const Duration(seconds: 10));
                              }
                            }
                          : null,
                      icon: const Icon(Icons.fast_rewind)),
                ],
              ),
              // duration of the audio
              if (isCurrentQuestion && audioPlayer.duration != null)
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${position.inMinutes}:${position.inSeconds.remainder(60) < 10 ? "0" : ""}${position.inSeconds.remainder(60)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        fontSize: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                              Slider(
                                inactiveColor: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.2),
                                value: position.inSeconds.toDouble(),
                                thumbColor:
                                    Theme.of(context).colorScheme.primary,
                                activeColor: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                                onChanged: (value) {
                                  audioPlayer
                                      .seek(Duration(seconds: value.toInt()));
                                },
                                min: 0.0,
                                max: duration!.inSeconds.toDouble(),
                              ),
                              Text(
                                  // add zero to the seconds if it's less than 10
                                  "${duration.inMinutes}:${duration.inSeconds.remainder(60) < 10 ? "0" : ""}${duration.inSeconds.remainder(60)}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                          fontSize: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              if (!isCurrentQuestion || audioPlayer.duration == null)
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "0:00",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      Slider(
                        inactiveColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.2),
                        value: 0.0,
                        thumbColor: Theme.of(context).colorScheme.primary,
                        activeColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        onChanged: null,
                        min: 0.0,
                        max: 1.0,
                      ),
                      Text(
                        "0:00",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }
}

class QuestionImageTemplate extends StatelessWidget {
  const QuestionImageTemplate({
    super.key,
    required this.question,
  });

  final Question question;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            const SizedBox(height: 40),
            Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "${question.mainTitle!} - ",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Zarids",
                            fontSize: 25)),
                    TextSpan(
                        text: question.subTitle,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Zarids",
                            fontSize: 25))
                  ]),
                )),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(10),
              child: AutoSizeText(
                question.question!.trim(),
                minFontSize: 28,
                maxLines: 3,
                style: TextStyle(
                    fontSize: 28,
                    fontFamily: "Zarids",
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w200),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: AutoSizeText(
                  question.answerText!,
                  maxLines: 8,
                  minFontSize: 25,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      fontSize: 30,
                      fontFamily: "Zarids",
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const ContactFooterImageTemplate()
          ],
        ),
      ) /* add child content here */,
    );
  }
}

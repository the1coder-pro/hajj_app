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
  const QuestionPage(this.questionData,
      {super.key, this.onBack, this.showAppBar = true});

  final dynamic questionData;
  final VoidCallback? onBack;
  final bool showAppBar;

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
  bool isDownloading = false;

  Future<void> checkAudioState() async {
    if (question == null) return;
    try {
      final url =
          "https://hajjaudiofiles.kumthra.com/questions_audiofiles/${question!.no}.mp3";
      bool isCached = false;
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${question!.no}.mp3');
        if (await file.exists()) {
          isCached = true;
        } else {
          final fileInfo = await DefaultCacheManager().getFileFromCache(url);
          isCached = fileInfo != null;
        }
      } else {
        final fileInfo = await DefaultCacheManager().getFileFromCache(url);
        isCached = fileInfo != null;
      }
      if (mounted) {
        setState(() {
          isCachedLocal = isCached;
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

  void _initQuestionData() {
    dynamic data = widget.questionData;
    if (data == null || data.toString() == 'null') {
      if (Get.parameters.containsKey('questionNo')) {
        data = int.tryParse(Get.parameters['questionNo'] ?? '');
      } else if (Get.parameters.containsKey('id')) {
        data = int.tryParse(Get.parameters['id'] ?? '');
      }
    }

    if (data is Question) {
      setState(() {
        question = data;
        isLoading = false;
        isAudioFileThere = false;
        isCachedLocal = false;
        isDownloading = false;
      });
      checkAudioState();
    } else if (data is int) {
      setState(() {
        isAudioFileThere = false;
        isCachedLocal = false;
        isDownloading = false;
      });
      fetchQuestion(data);
    } else if (data is String) {
      setState(() {
        isAudioFileThere = false;
        isCachedLocal = false;
        isDownloading = false;
      });
      int? id = int.tryParse(data);
      if (id != null) fetchQuestion(id);
    }
  }

  @override
  void initState() {
    super.initState();
    _initQuestionData();
  }

  @override
  void didUpdateWidget(covariant QuestionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.questionData != oldWidget.questionData) {
      if (widget.questionData is! Question) {
        setState(() {
          isLoading = true;
        });
      }
      _initQuestionData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsProvider =
        Provider.of<QuestionPrefsProvider>(context, listen: false);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

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
          appBar: widget.showAppBar
              ? AppBar(
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
${question!.question} 

${question!.answerText}

رابط استماع للإجابة:
https://hajjaudiofiles.kumthra.com/questions_audiofiles/${question!.no}.mp3

رابط السؤال:
${(kIsWeb ? "${Uri.base.origin}/q/${question!.no}" : "https://app.h-alkalaf.com/q/${question!.no}")}

${question!.mainTitle} - ${question!.subTitle}

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
                      if (widget.onBack != null) {
                        widget.onBack!();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Get.offAllNamed('/');
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                )
              : null,
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLargeScreen ? 800 : double.infinity,
              ),
              child: Stack(
                children: [
                  WidgetsToImage(
                    controller: controller,
                    child: QuestionImageTemplate(question: question!),
                  ),
                  Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView(
                        children: [
                          if (!widget.showAppBar)
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (widget.onBack != null) {
                                      widget.onBack!();
                                    } else if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    } else {
                                      Get.offAllNamed('/');
                                    }
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                                const Spacer(),
                                IconButton(
                                    icon: const Icon(Icons.share_outlined),
                                    onPressed: () async {
                                      try {
                                        await Share.share("""
${question!.question} 

${question!.answerText}

رابط استماع للإجابة:
https://hajjaudiofiles.kumthra.com/questions_audiofiles/${question!.no}.mp3

رابط السؤال:
${(kIsWeb ? "${Uri.base.origin}/q/${question!.no}" : "https://app.h-alkalaf.com/q/${question!.no}")}

${question!.mainTitle} - ${question!.subTitle}

من تطبيق حج التمتع في سؤال وجواب
""");
                                      } catch (e) {
                                        debugPrint(e.toString());
                                      }
                                    }),
                                IconButton(
                                  icon: const Icon(Icons.video_settings),
                                  onPressed: () {
                                    openQuestionSettings(
                                        context, prefsProvider);
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: IconButton(
                                    icon: bookmarkProvider.bookmarks
                                            .contains(question)
                                        ? const Icon(Icons.bookmark)
                                        : const Icon(Icons.bookmark_border),
                                    onPressed: () {
                                      if (bookmarkProvider.bookmarks
                                          .contains(question)) {
                                        bookmarkProvider
                                            .removeBookmark(question!);
                                      } else {
                                        bookmarkProvider.addBookmark(question!);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: SelectableText.rich(
                                    TextSpan(children: [
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
                              child: SelectableText(question!.question!.trim(),
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
                                  child: SelectableText("نص الجواب",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: "Zarids",
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer)),
                                ),
                              )),
                          SizedBox(
                            width: double.infinity,
                            child: Card.outlined(
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Consumer<QuestionPrefsProvider>(
                                  builder: (context, provider, _) =>
                                      SelectableText.rich(
                                    TextSpan(
                                      children: _buildMarkdownSpans(
                                        question!.answerText ??
                                            "لا يوجد نص جواب",
                                        TextStyle(
                                            fontFamily: "Zarids",
                                            fontWeight: FontWeight.w400,
                                            fontSize: provider.fontSize),
                                      ),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 400),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Future<dynamic> openQuestionSettings(
      BuildContext context, QuestionPrefsProvider prefsProvider) {
    return showDialog(
      context: context,
      builder: (context) {
        final isLargeScreen = MediaQuery.of(context).size.width >= 800;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text("إعدادات",
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(fontWeight: FontWeight.normal)),
            contentPadding: const EdgeInsets.all(10),
            content: SizedBox(
              width: isLargeScreen ? 400 : double.maxFinite,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "سرعة الصوت",
                                style: TextStyle(
                                  fontFamily: "Zarids",
                                  fontSize: 25,
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
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
                            ],
                          ),
                          Slider(
                            label: prefsProvider.audioSpeed.toString(),
                            value: prefsProvider.audioSpeed,
                            inactiveColor:
                                Theme.of(context).colorScheme.surfaceDim,
                            min: 0.5,
                            max: 5,
                            // divisions are 5 4.5 4 3.5 3 2.5 2 1.5 1 0.5
                            divisions: 9,
                            onChanged: (value) {
                              prefsProvider.audioSpeed = value;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "حجم الخط",
                                style: TextStyle(
                                  fontFamily: "Zarids",
                                  fontSize: 25,
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
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
                            ],
                          ),
                          Slider(
                            label: prefsProvider.fontSize.toString(),
                            value: prefsProvider.fontSize,
                            inactiveColor:
                                Theme.of(context).colorScheme.surfaceDim,
                            min: 20,
                            max: 40,
                            divisions: 5,
                            onChanged: (value) {
                              prefsProvider.fontSize = value;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("إغلاق",
                    style: TextStyle(fontFamily: "Zarids", fontSize: 18)),
              ),
            ],
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
    final isPlaying = isCurrentQuestion && audioPlayer.playing;
    final showPauseIcon =
        isPlaying && audioPlayer.processingState != ProcessingState.completed;

    return Card.outlined(
        elevation: 0.5,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                          onPressed: () async {
                            if (!isCachedLocal && !isDownloading) {
                              final url =
                                  "https://hajjaudiofiles.kumthra.com/questions_audiofiles/${question!.no}.mp3";
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "جاري حفظ السؤال للاستماع لاحقا ...")),
                              );

                              if (mounted) {
                                setState(() {
                                  isDownloading = true;
                                });
                              }

                              bool downloadSuccess = false;
                              if (!kIsWeb) {
                                try {
                                  final directory =
                                      await getApplicationDocumentsDirectory();
                                  final file = File(
                                      '${directory.path}/${question!.no}.mp3');
                                  final response =
                                      await http.get(Uri.parse(url));
                                  if (response.statusCode == 200) {
                                    await file.writeAsBytes(response.bodyBytes);
                                    downloadSuccess = true;
                                  }
                                } catch (e) {
                                  debugPrint("Download error: $e");
                                }
                              } else {
                                try {
                                  await DefaultCacheManager().downloadFile(url);
                                  downloadSuccess = true;
                                } catch (e) {
                                  debugPrint("Download error: $e");
                                }
                              }

                              if (mounted) {
                                // Instantly hide the "Downloading..." snackbar so they don't queue up
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();

                                if (downloadSuccess) {
                                  setState(() {
                                    isCachedLocal = true;
                                    isDownloading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("تم حفظ السؤال بنجاح")),
                                  );
                                  if (isCurrentQuestion) {
                                    audioProvider.setCached(true);
                                  }
                                } else {
                                  setState(() {
                                    isDownloading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("حدث خطأ أثناء تحميل السؤال")),
                                  );
                                }
                              }
                            }
                          },
                          icon: isDownloading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : Icon(isCachedLocal
                                  ? Icons.offline_pin
                                  : Icons.download_for_offline_outlined),
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  StreamBuilder<PlayerState>(
                    stream: audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState ??
                          audioPlayer.processingState;
                      final playing =
                          playerState?.playing ?? audioPlayer.playing;
                      final showPause = isCurrentQuestion &&
                          playing &&
                          processingState != ProcessingState.completed;

                      return IconButton.outlined(
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () async {
                          audioPlayer.setSpeed(prefsProvider.audioSpeed);
                          if (!isCurrentQuestion) {
                            bool success =
                                await audioProvider.initAudio(question!);
                            if (success) audioPlayer.play();
                          } else {
                            if (playing &&
                                processingState != ProcessingState.completed) {
                              await audioPlayer.pause();
                            } else {
                              if (processingState ==
                                  ProcessingState.completed) {
                                final position = audioPlayer.position;
                                final duration =
                                    audioPlayer.duration ?? Duration.zero;

                                await audioPlayer.stop();
                                await audioProvider.initAudio(question!,
                                    force: true);

                                if (position.inSeconds <
                                    duration.inSeconds - 1) {
                                  await audioPlayer.seek(position);
                                }
                              }
                              audioPlayer.play();
                            }
                          }
                        },
                        icon: Icon(showPause ? Icons.pause : Icons.play_arrow),
                      );
                    },
                  ),
                  const Spacer(),
                ],
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
                child: AutoSizeText.rich(
                  TextSpan(
                    children: _buildMarkdownSpans(
                      question.answerText ?? "",
                      const TextStyle(
                          fontSize: 30,
                          fontFamily: "Zarids",
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  maxLines: 8,
                  minFontSize: 25,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
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

List<TextSpan> _buildMarkdownSpans(String text, TextStyle baseStyle) {
  final spans = <TextSpan>[];
  final RegExp exp = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*');
  int lastMatchEnd = 0;

  for (final match in exp.allMatches(text)) {
    if (match.start > lastMatchEnd) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd, match.start),
        style: baseStyle,
      ));
    }

    final boldText = match.group(1) ?? match.group(2) ?? '';
    spans.add(TextSpan(
      text: boldText,
      style: baseStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 26),
    ));
    lastMatchEnd = match.end;
  }

  if (lastMatchEnd < text.length) {
    spans.add(TextSpan(
      text: text.substring(lastMatchEnd),
      style: baseStyle,
    ));
  }

  return spans;
}

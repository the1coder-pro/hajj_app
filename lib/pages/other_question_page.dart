import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:hajj_app/main.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:http/http.dart' as http;

class OtherQuestionPage extends StatefulWidget {
  const OtherQuestionPage(
    this.questionData, {
    super.key,
    this.onBack,
    this.showAppBar = true,
  });

  final dynamic questionData;
  final VoidCallback? onBack;
  final bool showAppBar;

  @override
  State<OtherQuestionPage> createState() => _OtherQuestionPageState();
}

class _OtherQuestionPageState extends State<OtherQuestionPage> {
  WidgetsToImageController controller = WidgetsToImageController();
// to save image bytes of widget
  Uint8List? bytes;

  OtherQuestion? question;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initQuestionData();
  }

  @override
  void didUpdateWidget(covariant OtherQuestionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.questionData != oldWidget.questionData) {
      if (widget.questionData is! OtherQuestion) {
        setState(() {
          isLoading = true;
        });
      }
      _initQuestionData();
    }
  }

  void _initQuestionData() {
    dynamic data = widget.questionData;
    if (data == null || data.toString() == 'null') {
      if (Get.parameters.containsKey('id')) {
        data = Get.parameters['id'];
      }
    }

    if (data is OtherQuestion) {
      setState(() {
        question = data;
        isLoading = false;
      });
    } else if (data is String && data.isNotEmpty) {
      fetchQuestion(data);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchQuestion(String id) async {
    try {
      final response = await http.get(Uri.parse(
          'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/4'));
      var dataList = jsonDecode(utf8.decode(response.bodyBytes));
      for (var item in dataList) {
        final q = OtherQuestion.fromJson(item);

        String derivedId = base64Url
            .encode(utf8.encode(q.timestamp ?? q.question ?? ''))
            .replaceAll('=', '');
        if (derivedId == id ||
            base64Url.encode(utf8.encode(q.timestamp ?? q.question ?? '')) ==
                id) {
          if (mounted) {
            setState(() {
              question = q;
              isLoading = false;
            });
          }
          return;
        }
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsProvider =
        Provider.of<QuestionPrefsProvider>(context, listen: false);
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

    if (isLoading) {
      return Scaffold(
        appBar: widget.showAppBar ? AppBar() : null,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (question == null) {
      return Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                leading: IconButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Get.offAllNamed('/');
                    }
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              )
            : null,
        body: const Center(
          child: Text("السؤال غير موجود",
              style: TextStyle(fontSize: 20, fontFamily: "Zarids")),
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
                        onPressed: () async {
                          try {
                            String derivedId = base64Url
                                .encode(utf8.encode(question!.timestamp ??
                                    question!.question ??
                                    ''))
                                .replaceAll('=', '');

                            String shareLink = kIsWeb
                                ? "${Uri.base.origin}/oq/$derivedId"
                                : "https://app.h-alkalaf.com/oq/$derivedId";
                            await Share.share("""
${question!.question} 

${question!.answerText}
${question!.audioLink != null && question!.audioLink!.isNotEmpty ? '\nرابط استماع للإجابة:\n ${question!.audioLink}\n' : ''}
رابط السؤال:
$shareLink

${question!.section}

من تطبيق حج التمتع في سؤال وجواب
""");
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                        },
                        icon: const Icon(Icons.share_outlined)),
                    IconButton(
                      icon: const Icon(Icons.video_settings),
                      onPressed: () {
                        openQuestionSettings(context, prefsProvider);
                      },
                    ),
                  ],
                  leading: IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
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
                                    onPressed: () async {
                                      try {
                                        String derivedId = base64Url
                                            .encode(utf8.encode(
                                                question!.timestamp ??
                                                    question!.question ??
                                                    ''))
                                            .replaceAll('=', '');
                                        String shareLink = kIsWeb
                                            ? "${Uri.base.origin}/oq/$derivedId"
                                            : "https://app.h-alkalaf.com/oq/$derivedId";
                                        await Share.share("""
${question!.question} 

${question!.answerText}
${question!.audioLink != null && question!.audioLink!.isNotEmpty ? '\nرابط استماع للإجابة:\n ${question!.audioLink}\n' : ''}
رابط السؤال:
$shareLink

${question!.section}

من تطبيق حج التمتع في سؤال وجواب
""");
                                      } catch (e) {
                                        debugPrint(e.toString());
                                      }
                                    },
                                    icon: const Icon(Icons.share_outlined)),
                                IconButton(
                                  icon: const Icon(Icons.video_settings),
                                  onPressed: () {
                                    openQuestionSettings(
                                        context, prefsProvider);
                                  },
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
                                          text: question!.section ?? "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary)),
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
                          if (question!.audioLink != null &&
                              question!.audioLink!.isNotEmpty)
                            _buildAudioPlayer(context, question!),
                          SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: Card.outlined(
                                elevation: 0,
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

  Widget _buildAudioPlayer(BuildContext context, OtherQuestion question) {
    final prefsProvider =
        Provider.of<QuestionPrefsProvider>(context, listen: false);
    final audioProvider = Provider.of<GlobalAudioProvider>(context);
    final audioPlayer = audioProvider.audioPlayer;
    final isCurrentOther =
        audioProvider.currentOtherQuestion?.question == question.question;

    return Card.outlined(
      elevation: 0.5,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Spacer(),
            StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState =
                    playerState?.processingState ?? audioPlayer.processingState;
                final playing = playerState?.playing ?? audioPlayer.playing;
                final showPause = isCurrentOther &&
                    playing &&
                    processingState != ProcessingState.completed;

                return IconButton.outlined(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    audioPlayer.setSpeed(prefsProvider.audioSpeed);
                    if (!isCurrentOther) {
                      bool success =
                          await audioProvider.initOtherAudio(question);
                      if (success) audioPlayer.play();
                    } else {
                      if (playing &&
                          processingState != ProcessingState.completed) {
                        await audioPlayer.pause();
                      } else {
                        if (processingState == ProcessingState.completed) {
                          final position = audioPlayer.position;
                          final duration =
                              audioPlayer.duration ?? Duration.zero;
                          await audioPlayer.stop();
                          await audioProvider.initOtherAudio(question,
                              force: true);
                          if (position.inSeconds < duration.inSeconds - 1) {
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
      ),
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
                                "حجم الخط",
                                style: TextStyle(
                                  fontFamily: "Zarids",
                                  fontSize: 25,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      prefsProvider.fontSize = 25;
                                    },
                                    icon: const Icon(Icons.restore),
                                  ),
                                  const SizedBox(width: 8),
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
                child: const Text("إغلاق",
                    style: TextStyle(fontFamily: "Zarids", fontSize: 18)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QuestionImageTemplate extends StatelessWidget {
  const QuestionImageTemplate({
    super.key,
    required this.question,
  });

  final OtherQuestion question;

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
                        text: "${question.section!} - ",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Zarids",
                            fontSize: 25)),
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

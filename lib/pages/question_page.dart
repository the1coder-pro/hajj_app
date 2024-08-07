import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'dart:html' as html;

void share(Map data) async {
  try {
    await html.window.navigator.share(data);
    debugPrint('done');
  } catch (e) {
    debugPrint(e as String);
  }
}

class QuestionPage extends StatefulWidget {
  const QuestionPage(
    this.question, {
    super.key,
  });

  final QuestionModel question;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  bool isPlaying = false;

  final AudioPlayer audioPlayer = AudioPlayer();

  // WidgetsToImageController to access widget
  WidgetsToImageController controller = WidgetsToImageController();
// to save image bytes of widget
  Uint8List? bytes;

  bool isAudioFileThere = false;

  Future<void> initAudio() async {
    bool result = true;
    try {
      await audioPlayer.setAsset("assets/audiofiles/${widget.question.no}.mp3");
    } catch (e) {
      debugPrint(e.toString());

      result = false;
    }
    setState(() {
      isAudioFileThere = result;
    });
  }

  @override
  void initState() {
    initAudio();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // BookmarkProvider bookmarkProvider =
    //     Provider.of<BookmarkProvider>(context, listen: false);
    final fontSizeProvider =
        Provider.of<FontSizeProvider>(context, listen: false);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Directionality(
                            textDirection: TextDirection.rtl,
                            child: Scaffold(
                              appBar:
                                  AppBar(title: const Text("تغيير حجم الخط")),
                              body: ListView(
                                padding: const EdgeInsets.all(16),
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      // add two segmented buttons to increase and decrease the font size
                                      IconButton.outlined(
                                          onPressed: () {
                                            if (fontSizeProvider.fontSize >
                                                20) {
                                              fontSizeProvider.fontSize -= 1;
                                            }
                                          },
                                          icon: const Icon(Icons.remove)),
                                      Center(
                                          child: Text(
                                              fontSizeProvider.fontSize
                                                  .toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!)),
                                      IconButton.outlined(
                                          onPressed: () {
                                            if (fontSizeProvider.fontSize <
                                                40) {
                                              fontSizeProvider.fontSize += 1;
                                            }
                                          },
                                          icon: const Icon(Icons.add)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  icon: const Icon(Icons.text_fields)),

              IconButton(
                  onPressed: () async {
                    final bytes = await controller.capture();
                    final buffer = await rootBundle
                        .load("assets/audiofiles/${widget.question.no}.mp3");

                    final mp3Audio = Uint8List.view(buffer.buffer);

                    var files = [
                      html.File([bytes!], "question_${widget.question.no}.jpg",
                          {"type": "image/jpeg"}),
                      html.File(
                          // mp3
                          [mp3Audio],
                          "question_${widget.question.no}.mp3",
                          {"type": "audio/mpeg"})
                    ];
                    var data = {
                      // "title": "سؤال رقم ${widget.question.no}",
                      // "text": "${widget.question.question}",
                      // "url": "https://hajj-app-1.web.app",
                      "files": files
                    };
                    share(data);
                  },
                  icon: const Icon(Icons.share_outlined)),
              // bookmark the question
              // IconButton(
              //   onPressed: () {
              //     if (bookmarkProvider.bookmarks.contains(widget.question)) {
              //       bookmarkProvider.removeBookmark(widget.question);
              //       return;
              //     }
              //     bookmarkProvider.addBookmark(widget.question);
              //   },
              //   // check if the question is already bookmarked
              //   icon: bookmarkProvider.bookmarks.contains(widget.question)
              //       ? const Icon(Icons.bookmark)
              //       : const Icon(Icons.bookmark_border),
              // ),
            ],
            leading:
                // close the page
                IconButton(
              onPressed: () {
                audioPlayer.pause();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: Stack(
            children: [
              WidgetsToImage(
                controller: controller,
                child: QuestionImageTemplate(widget: widget),
              ),
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.centerRight,
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: "${widget.question.mainTitle!} - ",
                                  style: const TextStyle(
                                      color: Color(0xFFbe8f2f),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Zarids",
                                      fontSize: 25)),
                              TextSpan(
                                  text: widget.question.subTitle,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Zarids",
                                      fontSize: 25))
                            ]),
                          )),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(widget.question.question!.trim(),
                              textAlign: TextAlign.right,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontFamily: "Zarids",
                                      fontSize: 35,
                                      fontWeight: FontWeight.w600,
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
                                child: Text(
                                    widget.question.answerText ??
                                        "لا يوجد نص جواب",
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            fontFamily: "Zarids",
                                            fontWeight: FontWeight.w400,
                                            fontSize:
                                                fontSizeProvider.fontSize)),
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

  Card questionAudioPlayer(BuildContext context) {
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
                        // don't remove more than the duration
                        if (audioPlayer.position.inSeconds - 10 < 0) {
                          await audioPlayer.seek(const Duration(seconds: 0));
                        } else {
                          await audioPlayer.seek(audioPlayer.position -
                              const Duration(seconds: 10));
                        }
                      },
                      icon: const Icon(Icons.fast_forward),
                      color: Theme.of(context).colorScheme.primary),
                  Center(
                    child: IconButton(
                        color: Theme.of(context).colorScheme.primary,
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
                  ),
                  IconButton(
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () async {
                        // don't add more than the duration
                        if (audioPlayer.position.inSeconds + 10 >
                            audioPlayer.duration!.inSeconds) {
                          await audioPlayer.seek(audioPlayer.duration!);
                        } else {
                          await audioPlayer.seek(audioPlayer.position +
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
                                    .withOpacity(0.2),
                                value: position.inSeconds.toDouble(),
                                thumbColor:
                                    Theme.of(context).colorScheme.primary,
                                activeColor: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
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
            ],
          ),
        ));
  }
}

class QuestionImageTemplate extends StatelessWidget {
  const QuestionImageTemplate({
    super.key,
    required this.widget,
  });

  final QuestionPage widget;

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
                        text: "${widget.question.mainTitle!} - ",
                        style: const TextStyle(
                            color: Color(0xFFbe8f2f),
                            fontWeight: FontWeight.bold,
                            fontFamily: "Zarids",
                            fontSize: 25)),
                    TextSpan(
                        text: widget.question.subTitle,
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
                widget.question.question!.trim(),
                minFontSize: 28,
                maxLines: 3,
                style: const TextStyle(
                    fontSize: 28,
                    fontFamily: "Zarids",
                    color: Colors.black,
                    fontWeight: FontWeight.w200),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: const Color(0xFFe0eeed),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: AutoSizeText(
                  widget.question.answerText!,
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

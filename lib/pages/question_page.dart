import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
// import 'dart:html' as html;

// void share(Map data) async {
//   try {
//     await html.window.navigator.share(data);
//     debugPrint('done');
//   } catch (e) {
//     debugPrint(e as String);
//   }
// }

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
    final prefsProvider =
        Provider.of<QuestionPrefsProvider>(context, listen: false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              // show modal bottom sheet to change the speed of the audio
              IconButton(
                icon: const Icon(Icons.video_settings),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Scaffold(
                          appBar: AppBar(
                            title: const Text(
                              "إعدادات",
                              style: TextStyle(
                                fontFamily: "Zarids",
                                fontSize: 30,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          body: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Card(
                                child: Column(
                                  children: [
                                    const Text(
                                      "سرعة الصوت",
                                      style: TextStyle(
                                        fontFamily: "Zarids",
                                        fontSize: 25,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // add two segmented buttons to increase and decrease the speed
                                        if (prefsProvider.audioSpeed != 1.0)
                                          IconButton(
                                              onPressed: () {
                                                // reset
                                                prefsProvider.audioSpeed = 1.0;
                                              },
                                              icon: const Icon(Icons.restore)),
                                        Slider(
                                          label: prefsProvider.audioSpeed
                                              .toString(),
                                          value: prefsProvider.audioSpeed,
                                          min: 0.5,
                                          max: 5,
                                          // divisions are 5 4.5 4 3.5 3 2.5 2 1.5 1 0.5
                                          divisions: 9,
                                          onChanged: (value) {
                                            prefsProvider.audioSpeed = value;
                                          },
                                        ),
                                        Center(
                                          child: Text(
                                              prefsProvider.audioSpeed
                                                  .toStringAsFixed(2),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayLarge!
                                                  .copyWith(fontSize: 25)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                              Card(
                                  child: Column(children: [
                                const Text(
                                  "حجم الخط",
                                  style: TextStyle(
                                    fontFamily: "Zarids",
                                    fontSize: 25,
                                  ),
                                ),
                                // add two segmented buttons to increase and decrease the font size

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Slider(
                                      label: prefsProvider.fontSize.toString(),
                                      value: prefsProvider.fontSize,
                                      min: 20,
                                      max: 40,
                                      divisions: 5,
                                      onChanged: (value) {
                                        prefsProvider.fontSize = value;
                                      },
                                    ),
                                    Center(
                                        child: Text(
                                            prefsProvider.fontSize.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .copyWith(fontSize: 25))),
                                  ],
                                ),
                              ])),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              IconButton(
                  onPressed: () async {
                    // TODO: don't remove just comment
                    // final bytes = await controller.capture();
                    // final buffer = await rootBundle
                    //     .load("assets/audiofiles/${widget.question.no}.mp3");

                    // final mp3Audio = Uint8List.view(buffer.buffer);

                    // var files = [
                    //   html.File([bytes!], "question_${widget.question.no}.jpg",
                    //       {"type": "image/jpeg"}),
                    //   html.File(
                    //       // mp3
                    //       [mp3Audio],
                    //       "question_${widget.question.no}.mp3",
                    //       {"type": "audio/mpeg"})
                    // ];
                    // var data = {
                    //   // "title": "سؤال رقم ${widget.question.no}",
                    //   // "text": "${widget.question.question}",
                    //   // "url": "https://hajj-app-1.web.app",
                    //   "files": files
                    // };
                    // share(data);
                  },
                  icon: const Icon(Icons.share_outlined)),
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
                                      text: "${widget.question.mainTitle!} - ",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Zarids",
                                          fontSize: 25)),
                                  TextSpan(
                                      text: widget.question.subTitle,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Zarids",
                                          fontSize: 25))
                                ]),
                              )),
                          IconButton(
                            icon: Icon(Icons.bookmark_border),
                            onPressed: () {
                              // add to favorites
                            },
                          )
                        ],
                      ),
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
                                      widget.question.answerText ??
                                          "لا يوجد نص جواب",
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

  Card questionAudioPlayer(BuildContext context) {
    final prefsProvider =
        Provider.of<QuestionPrefsProvider>(context, listen: false);
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
                          audioPlayer.setSpeed(prefsProvider.audioSpeed);
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
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
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

import 'package:flutter/material.dart';
import 'package:hajj_app/main.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

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

  bool isAudioFileThere = true;

  Future<void> initAudio() async {
    try {
      await audioPlayer.setAsset("assets/audiofiles/${widget.question.no}.mp3");
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isAudioFileThere = false;
      });
    }
  }

  @override
  void initState() {
    initAudio();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BookmarkProvider bookmarkProvider =
        Provider.of<BookmarkProvider>(context, listen: false);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () async {
                    await shareQuestion(widget.question);
                  },
                  icon: const Icon(Icons.share_outlined)),
              // bookmark the question
              IconButton(
                onPressed: () {
                  if (bookmarkProvider.bookmarks.contains(widget.question)) {
                    bookmarkProvider.removeBookmark(widget.question);
                    return;
                  }
                  bookmarkProvider.addBookmark(widget.question);
                },
                // check if the question is already bookmarked
                icon: bookmarkProvider.bookmarks.contains(widget.question)
                    ? const Icon(Icons.bookmark)
                    : const Icon(Icons.bookmark_border),
              ),
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
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: "${widget.question.mainTitle!}\n",
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                        TextSpan(
                            text: widget.question.subTitle,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18))
                      ]),
                    )),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.center,
                  child: Text(widget.question.question!.trim(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontWeight: FontWeight.bold, height: 1.2)),
                ),
                const SizedBox(height: 10),
                if (isAudioFileThere) questionAudioPlayer(context),
                SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: Card(
                      elevation: 0,
                      // squared
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      child: Center(
                        child: Text("نص الجواب",
                            style: TextStyle(
                                fontSize: 20,
                                color:
                                    Theme.of(context).colorScheme.secondary)),
                      ),
                    )),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(
                              widget.question.answerText ?? "لا يوجد نص جواب",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 20)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Card questionAudioPlayer(BuildContext context) {
    return Card(
        elevation: 0.5,
        color: Theme.of(context).colorScheme.surface,
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
                          await audioPlayer.seek(const Duration(seconds: 0));
                        } else {
                          await audioPlayer.seek(audioPlayer.position -
                              const Duration(seconds: 10));
                        }
                      },
                      icon: const Icon(Icons.fast_forward),
                      color: Theme.of(context).colorScheme.primary),
                  IconButton(
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
                            children: [
                              Text(
                                "${position.inSeconds.remainder(60)}:${position.inMinutes}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                              Slider(
                                inactiveColor:
                                    Theme.of(context).colorScheme.background,
                                value: position.inSeconds.toDouble(),
                                thumbColor:
                                    Theme.of(context).colorScheme.primary,
                                activeColor: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.5),
                                onChanged: (value) {
                                  audioPlayer
                                      .seek(Duration(seconds: value.toInt()));
                                },
                                min: 0.0,
                                max: duration!.inSeconds.toDouble(),
                              ),
                              Text(
                                  "${duration.inSeconds.remainder(60)}:${duration.inMinutes}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
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
              // replay the audio
              if (audioPlayer.duration != null)
                IconButton(
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () async {
                      await audioPlayer.seek(const Duration(seconds: 0));
                    },
                    icon: const Icon(Icons.replay)),
            ],
          ),
        ));
  }
}

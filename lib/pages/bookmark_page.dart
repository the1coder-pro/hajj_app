import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/question_tile.dart';
import 'package:hajj_app/pages/question_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    return Scaffold(
        body: bookmarkProvider.bookmarks.isEmpty
            ? const Center(child: Text("لا توجد أسئلة في المفضلة"))
            : ListView.builder(
                itemCount: bookmarkProvider.bookmarks.length,
                itemBuilder: (context, index) {
                  if (bookmarkProvider.bookmarks.isEmpty) {
                    return const Text("لا توجد أسئلة في المفضلة");
                  }
                  return QuestionTile(
                    question: bookmarkProvider.bookmarks[index],
                  );
                },
              ));
  }
}

class Bookmarks2Page extends StatefulWidget {
  const Bookmarks2Page({
    super.key,
    required this.bookmarkProvider,
    required this.questions,
  });

  final BookmarkProvider bookmarkProvider;
  final List<QuestionModel> questions;

  @override
  State<Bookmarks2Page> createState() => _Bookmarks2PageState();
}

class _Bookmarks2PageState extends State<Bookmarks2Page> {
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
    } catch (e) {
      debugPrint("$e");
    }
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
                            Get.to(() => QuestionPage(widget.questions[i]),
                                transition: Transition.rightToLeft);
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
                                                          .surface,
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

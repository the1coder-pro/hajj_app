import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hajj_app/pages/question_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cross_file/cross_file.dart';
import 'package:provider/provider.dart';
import 'package:hajj_app/main.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});
  static const route = "/bookmarks";

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  bool _isAscending = true;

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final audioProvider = Provider.of<GlobalAudioProvider>(context);

    final displayList = _isAscending
        ? bookmarkProvider.bookmarks
        : bookmarkProvider.bookmarks.reversed.toList();

    return Scaffold(
        body: Column(
      children: [
        if (displayList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card.outlined(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Text(
                      (audioProvider.isBookmarkMode &&
                              audioProvider.currentQuestion != null)
                          ? audioProvider.currentQuestion!.question ??
                              'بدون عنوان'
                          : 'تشغيل قائمة المفضلة',
                      style: const TextStyle(
                          fontFamily: "Zarids",
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (audioProvider.isBookmarkMode &&
                                audioProvider.bookmarkPlaylist.isNotEmpty) {
                              int currentIndex = audioProvider.bookmarkPlaylist
                                  .indexWhere((q) =>
                                      q.no.toString() ==
                                      audioProvider.currentQuestion?.no
                                          .toString());
                              if (currentIndex > 0) {
                                int prevId = int.tryParse(audioProvider
                                        .bookmarkPlaylist[currentIndex - 1].no
                                        .toString()) ??
                                    1;
                                audioProvider.playQuestionById(prevId);
                              } else if (currentIndex == 0) {
                                int prevId = int.tryParse(audioProvider
                                        .bookmarkPlaylist.last.no
                                        .toString()) ??
                                    1;
                                audioProvider.playQuestionById(prevId);
                              }
                            }
                          },
                          icon: const Icon(Icons.skip_next),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        IconButton(
                          onPressed: () {
                            if (audioProvider.isBookmarkMode &&
                                audioProvider.currentQuestion != null) {
                              if (audioProvider.isPlaying) {
                                audioProvider.audioPlayer.pause();
                              } else {
                                audioProvider.audioPlayer.play();
                              }
                            } else {
                              audioProvider.setBookmarkMode(true, displayList);
                              int firstId =
                                  int.tryParse(displayList[0].no.toString()) ??
                                      1;
                              audioProvider.playQuestionById(firstId);
                            }
                          },
                          icon: Icon((audioProvider.isBookmarkMode &&
                                  audioProvider.isPlaying)
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill),
                          iconSize: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        IconButton(
                          onPressed: () {
                            if (audioProvider.isBookmarkMode &&
                                audioProvider.bookmarkPlaylist.isNotEmpty) {
                              int currentIndex = audioProvider.bookmarkPlaylist
                                  .indexWhere((q) =>
                                      q.no.toString() ==
                                      audioProvider.currentQuestion?.no
                                          .toString());
                              if (currentIndex != -1) {
                                int nextIndex = (currentIndex + 1) %
                                    audioProvider.bookmarkPlaylist.length;
                                int nextId = int.tryParse(audioProvider
                                        .bookmarkPlaylist[nextIndex].no
                                        .toString()) ??
                                    1;
                                audioProvider.playQuestionById(nextId);
                              }
                            }
                          },
                          icon: const Icon(Icons.skip_previous),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    if (audioProvider.isBookmarkMode &&
                        audioProvider.currentQuestion != null)
                      StreamBuilder<Duration?>(
                          stream: audioProvider.audioPlayer.durationStream,
                          builder: (context, snapshot) {
                            final duration = snapshot.data ??
                                audioProvider.lastKnownDuration;
                            return StreamBuilder<Duration>(
                                stream:
                                    audioProvider.audioPlayer.positionStream,
                                builder: (context, snapshot) {
                                  var position = snapshot.data ?? Duration.zero;
                                  if (duration == null ||
                                      duration.inSeconds == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Row(
                                    children: [
                                      Text(
                                          "${position.inMinutes}:${position.inSeconds.remainder(60).toString().padLeft(2, '0')}"),
                                      Expanded(
                                        child: Slider(
                                          activeColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          value: position.inSeconds
                                              .toDouble()
                                              .clamp(
                                                  0.0,
                                                  duration.inSeconds
                                                      .toDouble()),
                                          max: duration.inSeconds.toDouble(),
                                          onChanged: (val) {
                                            audioProvider.audioPlayer.seek(
                                                Duration(seconds: val.toInt()));
                                          },
                                        ),
                                      ),
                                      Text(
                                          "${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}"),
                                    ],
                                  );
                                });
                          })
                  ],
                ),
              ),
            ),
          ),
        if (displayList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "المسائل المحفوظة (${displayList.length})",
                  style: const TextStyle(
                      fontFamily: "Zarids",
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isAscending = !_isAscending;
                    });
                    final audioProv = Provider.of<GlobalAudioProvider>(context,
                        listen: false);
                    if (audioProv.isBookmarkMode) {
                      audioProv.setBookmarkMode(
                          true,
                          _isAscending
                              ? bookmarkProvider.bookmarks
                              : bookmarkProvider.bookmarks.reversed.toList());
                    }
                  },
                  icon: Icon(
                      _isAscending ? Icons.arrow_downward : Icons.arrow_upward),
                  label: Text(
                    _isAscending ? "ترتيب تنازلي" : "ترتيب تصاعدي",
                    style: const TextStyle(fontFamily: "Zarids"),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: displayList.isEmpty
              ? const Center(
                  child: Text("لا توجد مسائل محفوظة",
                      style: TextStyle(fontSize: 24, fontFamily: "Zarids")))
              : ListView.builder(
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final q = displayList[index];
                    final isPlayingThis =
                        audioProvider.currentQuestion?.no.toString() ==
                            q.no.toString();
                    final isPlayingState =
                        isPlayingThis && audioProvider.isPlaying;

                    return ListTile(
                      selected: isPlayingThis,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withValues(alpha: 0.3),
                      leading: CircleAvatar(
                        backgroundColor: isPlayingThis
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: isPlayingThis
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : Theme.of(context).colorScheme.onPrimaryContainer,
                        child: Text(q.no?.toString() ?? '?'),
                      ),
                      title: Text(
                        q.question ?? 'بدون عنوان',
                        style:
                            const TextStyle(fontFamily: "Zarids", fontSize: 24),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                            isPlayingState ? Icons.pause : Icons.play_arrow),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          audioProvider.setBookmarkMode(true, displayList);
                          if (audioProvider.currentQuestion?.no.toString() ==
                              q.no.toString()) {
                            if (audioProvider.isPlaying) {
                              audioProvider.audioPlayer.pause();
                            } else {
                              audioProvider.audioPlayer.play();
                            }
                          } else {
                            int id = int.tryParse(q.no.toString()) ?? 1;
                            audioProvider.playQuestionById(id);
                          }
                        },
                      ),
                      onTap: () {
                        audioProvider.setBookmarkMode(true, displayList);
                        Get.to(() => QuestionPage(q),
                            transition: Transition.rightToLeft,
                            routeName: '/question/${q.no}');
                      },
                    );
                  },
                ),
        ),
      ],
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
  final List<Question> questions;

  @override
  State<Bookmarks2Page> createState() => _Bookmarks2PageState();
}

class _Bookmarks2PageState extends State<Bookmarks2Page> {
  bool isPlaying = false;

  final AudioPlayer audioPlayer = AudioPlayer();

  // make a playlist for the bookmarked questions and when a question ends play the next one
  Future<void> initAudio() async {
    try {
      // Pause the global question player before playing localized playlist
      Provider.of<GlobalAudioProvider>(context, listen: false).stopAudio();

      // play the first audio and when it ends play the next one
      final firstUrl =
          "https://hajjaudiofiles.kumthra.com/questions_audiofiles/${widget.bookmarkProvider.bookmarks[0].no}.mp3";
      final firstFileInfo =
          await DefaultCacheManager().getFileFromCache(firstUrl);
      if (firstFileInfo != null) {
        if (kIsWeb) {
          final bytes = await firstFileInfo.file.readAsBytes();
          final xFile = XFile.fromData(bytes, mimeType: 'audio/mpeg');
          await audioPlayer.setUrl(xFile.path);
        } else {
          await audioPlayer.setFilePath(firstFileInfo.file.path);
        }
      } else {
        await audioPlayer.setUrl(firstUrl);
      }

      audioPlayer.playerStateStream.listen((event) async {
        if (event.processingState == ProcessingState.completed) {
          for (var i = 0; i < widget.bookmarkProvider.bookmarks.length; i++) {
            if (widget.bookmarkProvider.bookmarks[i].no ==
                widget.bookmarkProvider.bookmarks[i].no) {
              if (i + 1 < widget.bookmarkProvider.bookmarks.length) {
                final nextUrl =
                    "https://hajjaudiofiles.kumthra.com/questions_audiofiles/${widget.bookmarkProvider.bookmarks[i + 1].no}.mp3";
                final nextFileInfo =
                    await DefaultCacheManager().getFileFromCache(nextUrl);

                if (nextFileInfo != null) {
                  if (kIsWeb) {
                    final bytes = await nextFileInfo.file.readAsBytes();
                    final xFile = XFile.fromData(bytes, mimeType: 'audio/mpeg');
                    await audioPlayer.setUrl(xFile.path);
                  } else {
                    await audioPlayer.setFilePath(nextFileInfo.file.path);
                  }
                } else {
                  await audioPlayer.setUrl(nextUrl);
                }
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
                                transition: Transition.rightToLeft,
                                routeName:
                                    '/question/${widget.questions[i].no}');
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
                                                      .toDouble()
                                                      .clamp(
                                                          0.0,
                                                          duration!.inSeconds
                                                              .toDouble()),
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

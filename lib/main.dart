import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hajj_app/pages/ads_page.dart';
import 'package:hajj_app/pages/bookmark_page.dart';
import 'package:hajj_app/pages/home_page.dart';
import 'package:hajj_app/pages/settings_page.dart';
import 'package:hajj_app/pages/question_page.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:hajj_app/color_schemes.g.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:cross_file/cross_file.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  // load mp3 files

  runApp(const MyApp());
}

const textTheme = TextTheme(
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
);

class GlobalAudioProvider extends ChangeNotifier {
  final AudioPlayer audioPlayer = AudioPlayer();
  Question? currentQuestion;
  bool isCached = false;
  bool isPlaying = false;
  bool isFetching = false;
  bool autoPlayNext = true;
  List<dynamic>? _cachedData;
  Duration? lastKnownDuration;
  bool _isStopped = false;

  GlobalAudioProvider() {
    audioPlayer.durationStream.listen((d) {
      if (d != null) {
        lastKnownDuration = d;
      }
    });
    audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        // Only auto-skip if it naturally finished while playing and isn't just starting
        if (state.playing && audioPlayer.position.inMilliseconds > 500) {
          if (currentQuestion != null) {
            int currentId = int.tryParse(currentQuestion!.no.toString()) ?? 1;
            if (autoPlayNext && currentId < 322) {
              // Prevent multiple triggers while the next audio is still loading
              if (!isFetching) {
                playQuestionById(currentId + 1);
              }
            }
          }
        }
      }
      notifyListeners();
    });
  }

  void toggleAutoPlayNext() {
    autoPlayNext = !autoPlayNext;
    notifyListeners();
  }

  Future<void> playQuestionById(int id) async {
    _isStopped = false;
    isFetching = true;
    notifyListeners();
    try {
      if (_cachedData == null) {
        final response = await http.get(Uri.parse(
            "https://opensheet.elk.sh/1KxJKKxKBcEd0lguKAbK-UkGIqzAcOXs5is3zNiTnFgY/1"));
        _cachedData = jsonDecode(utf8.decode(response.bodyBytes));
      }
      for (var i = 0; i < _cachedData!.length; i++) {
        if (_cachedData![i]['no'].toString() == id.toString()) {
          Question q = Question.fromJson(_cachedData![i]);
          if (_isStopped) return;
          bool success = await initAudio(q);
          if (_isStopped || !success) return;
          audioPlayer.play();
          break;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    if (!_isStopped) {
      isFetching = false;
      notifyListeners();
    }
  }

  Future<bool> initAudio(Question question, {bool force = false}) async {
    _isStopped = false;
    if (!force && currentQuestion?.no == question.no) return true;
    currentQuestion = question;
    if (!force) {
      isCached = false;
      lastKnownDuration = null; // Clear when loading a completely new question
      notifyListeners();
    }

    bool success = true;
    try {
      final url =
          "https://hajjaudiofiles.kumthra.com/questions_audiofiles/${question.no}.mp3";

      final fileInfo = await DefaultCacheManager().getFileFromCache(url);

      if (fileInfo != null) {
        if (kIsWeb) {
          final bytes = await fileInfo.file.readAsBytes();
          final xFile = XFile.fromData(bytes, mimeType: 'audio/mpeg');
          if (_isStopped) return false;
          await audioPlayer.setUrl(xFile.path);
        } else {
          if (_isStopped) return false;
          await audioPlayer.setFilePath(fileInfo.file.path);
        }
        isCached = true;
      } else {
        if (_isStopped) return false;
        await audioPlayer.setUrl(url);
        isCached = false;
      }
    } catch (e) {
      debugPrint(e.toString());
      success = false;
    }
    if (_isStopped) return false;
    notifyListeners();
    return success;
  }

  void setCached(bool cached) {
    isCached = cached;
    notifyListeners();
  }

  void stopAudio() async {
    _isStopped = true;
    currentQuestion = null;
    isFetching = false;
    notifyListeners();
    await audioPlayer.stop();
  }
}

class GlobalMiniPlayer extends StatelessWidget {
  const GlobalMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final prefsProvider = Provider.of<QuestionPrefsProvider>(context);
    return Consumer<GlobalAudioProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentQuestion == null) {
          return const SizedBox.shrink();
        }
        final question = audioProvider.currentQuestion!;
        final audioPlayer = audioProvider.audioPlayer;
        final isLargeScreen = MediaQuery.of(context).size.width >= 800;

        final titleWidget = Text(
          question.question ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontFamily: "Zarids",
              fontWeight: FontWeight.bold,
              fontSize: 16),
        );

        final closeButton = IconButton(
          icon: Icon(Icons.close,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          onPressed: () {
            audioProvider.stopAudio();
          },
        );

        final playbackButtons = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: audioProvider.autoPlayNext
                  ? "إيقاف التشغيل التلقائي"
                  : "تفعيل التشغيل التلقائي",
              child: IconButton(
                onPressed: () {
                  audioProvider.toggleAutoPlayNext();
                },
                icon: Icon(audioProvider.autoPlayNext
                    ? Icons.repeat
                    : Icons.repeat_one),
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: audioProvider.autoPlayNext ? 1.0 : 0.4),
              ),
            ),
            IconButton(
              onPressed: () {
                int currentId = int.tryParse(question.no.toString()) ?? 1;
                if (currentId > 1) {
                  audioProvider.playQuestionById(currentId - 1);
                }
              },
              icon: const Icon(Icons.skip_next),
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            IconButton(
              onPressed: () async {
                if (audioPlayer.position.inSeconds - 10 < 0) {
                  await audioPlayer.seek(const Duration(seconds: 0));
                } else {
                  await audioPlayer
                      .seek(audioPlayer.position - const Duration(seconds: 10));
                }
              },
              icon: const Icon(Icons.forward_10_outlined),
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState =
                    playerState?.processingState ?? audioPlayer.processingState;
                final playing = playerState?.playing ?? audioPlayer.playing;

                return IconButton(
                  onPressed: () async {
                    if (playing &&
                        processingState != ProcessingState.completed) {
                      await audioPlayer.pause();
                    } else {
                      if (processingState == ProcessingState.completed) {
                        final position = audioPlayer.position;
                        final duration = audioPlayer.duration ?? Duration.zero;

                        await audioPlayer.stop();
                        await audioProvider.initAudio(question, force: true);
                        if (position.inSeconds < duration.inSeconds - 1) {
                          await audioPlayer.seek(position);
                        }
                      }
                      audioPlayer.setSpeed(prefsProvider.audioSpeed);
                      audioPlayer.play();
                    }
                  },
                  icon: Icon(
                    (playing && processingState != ProcessingState.completed)
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 30,
                  ),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                );
              },
            ),
            IconButton(
              onPressed: () async {
                if (audioPlayer.duration != null &&
                    audioPlayer.position.inSeconds + 10 >
                        audioPlayer.duration!.inSeconds) {
                  await audioPlayer.seek(audioPlayer.duration!);
                } else {
                  await audioPlayer
                      .seek(audioPlayer.position + const Duration(seconds: 10));
                }
              },
              icon: const Icon(Icons.replay_10_outlined),
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            IconButton(
              onPressed: () {
                int currentId = int.tryParse(question.no.toString()) ?? 1;
                if (currentId < 322) {
                  audioProvider.playQuestionById(currentId + 1);
                }
              },
              icon: const Icon(Icons.skip_previous),
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            Tooltip(
              message: "سرعة التشغيل",
              child: TextButton(
                onPressed: () {
                  double nextSpeed = prefsProvider.audioSpeed + 0.5;
                  if (nextSpeed > 2.0) {
                    nextSpeed = 0.5;
                  }
                  prefsProvider.audioSpeed = nextSpeed;
                  audioPlayer.setSpeed(nextSpeed);
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                ),
                child: SizedBox(
                  width: 40,
                  child: Text(
                    "${prefsProvider.audioSpeed == 1.0 ? '1' : prefsProvider.audioSpeed}x",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

        final trackWidget = StreamBuilder<Duration?>(
          stream: audioPlayer.durationStream,
          builder: (context, snapshot) {
            final duration = snapshot.data ?? audioProvider.lastKnownDuration;
            return StreamBuilder<Duration>(
              stream: audioPlayer.positionStream,
              builder: (context, snapshot) {
                var position = snapshot.data ?? Duration.zero;
                if (duration == null || duration.inSeconds == 0) {
                  return SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "0:00",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                        ),
                        Expanded(
                          child: Slider(
                            inactiveColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withValues(alpha: 0.2),
                            value: 0.0,
                            thumbColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            activeColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withValues(alpha: 0.5),
                            onChanged: null,
                          ),
                        ),
                        Text(
                          "0:00",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${position.inMinutes}:${position.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                      ),
                      Expanded(
                        child: Slider(
                          inactiveColor: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.2),
                          value: position.inSeconds
                              .toDouble()
                              .clamp(0.0, duration.inSeconds.toDouble()),
                          thumbColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          activeColor: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.5),
                          onChanged: (value) {
                            audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                          min: 0.0,
                          max: duration.inSeconds.toDouble(),
                        ),
                      ),
                      Text(
                        "${duration.inMinutes}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );

        return Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: isLargeScreen ? 800 : 600),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 8.0,
                      bottom: MediaQuery.of(context).size.width >= 800
                          ? 24.0
                          : 8.0),
                  child: Card(
                      elevation: 4,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          Get.toNamed('/question/${question.no}');
                        },
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isLargeScreen
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      closeButton,
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0, bottom: 4.0),
                                              child: titleWidget,
                                            ),
                                            trackWidget,
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      playbackButtons,
                                    ],
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: titleWidget),
                                          closeButton,
                                        ],
                                      ),
                                      playbackButtons,
                                      trackWidget,
                                    ],
                                  ),
                          ),
                        ),
                      )),
                )));
      },
    );
  }
}

class _GlobalPlayerOverlay extends StatefulWidget {
  final Widget child;

  const _GlobalPlayerOverlay({required this.child});

  @override
  State<_GlobalPlayerOverlay> createState() => _GlobalPlayerOverlayState();
}

class _GlobalPlayerOverlayState extends State<_GlobalPlayerOverlay> {
  late final OverlayEntry _childEntry;
  late final OverlayEntry _playerEntry;

  @override
  void initState() {
    super.initState();
    _childEntry = OverlayEntry(builder: (context) => widget.child);
    _playerEntry = OverlayEntry(
      builder: (context) => const Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SafeArea(child: GlobalMiniPlayer()),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _GlobalPlayerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _childEntry.markNeedsBuild();
    }
    // Ensure the mini player rebuilds its theme values seamlessly if theme changes
    _playerEntry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [_childEntry, _playerEntry],
    );
  }
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
        ChangeNotifierProvider(create: (context) => GlobalAudioProvider()),
      ],
      child: Consumer3<ThemeProvider, BookmarkProvider, QuestionPrefsProvider>(
        builder: (context, themeProvider, bookmarkProvider, fontSizeProvider,
                _) =>
            GetMaterialApp(
                title: 'حج التمتع',
                debugShowCheckedModeBanner: false,
                themeMode: themeProvider.themeMode,
                theme: ThemeData(
                    colorScheme: lightColorScheme,
                    useMaterial3: true,
                    textTheme: textTheme),
                darkTheme: ThemeData(
                  appBarTheme: const AppBarTheme(
                      titleTextStyle: TextStyle(
                    fontFamily: "Zarids",
                    fontSize: 35,
                  )),
                  textTheme: textTheme,
                  colorScheme: darkColorScheme,
                  useMaterial3: true,
                ),
                builder: (context, child) {
                  return _GlobalPlayerOverlay(child: child!);
                },
                getPages: [
                  GetPage(name: HomePage.route, page: () => const HomePage()),
                  GetPage(
                      name: SettingsPage.route,
                      page: () => const SettingsPage()),
                  GetPage(
                      name: AdvertismentsPage.route,
                      page: () => const AdvertismentsPage()),
                  GetPage(
                      name: BookmarksPage.route,
                      page: () => const BookmarksPage()),
                  GetPage(
                      name: '/question/:id',
                      page: () => QuestionPage(
                          int.tryParse(Get.parameters['id'] ?? '')),
                      transition: Transition.rightToLeft),
                ],
                initialRoute: "/"),
      ),
    );
  }
}

Future<void> shareQuestion(Question question) async {
  // check if the file is in the assets folder

  try {
    final url =
        "https://hajjaudiofiles.kumthra.com/questions_audiofiles/${question.no}.mp3";

    final cachedFile = await DefaultCacheManager().getSingleFile(url);
    XFile file;

    if (kIsWeb) {
      final bytes = await cachedFile.readAsBytes();
      file = XFile.fromData(
        bytes,
        mimeType: 'audio/mpeg',
        name: '${question.no}.mp3',
      );
    } else {
      file = XFile(
        cachedFile.path,
        mimeType: 'audio/mpeg',
        name: '${question.no}.mp3',
      );
    }

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

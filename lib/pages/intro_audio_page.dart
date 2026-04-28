import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/settings.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class IntroAudioPage extends StatefulWidget {
  const IntroAudioPage({super.key});

  @override
  State<IntroAudioPage> createState() => _IntroAudioPageState();
}

class _IntroAudioPageState extends State<IntroAudioPage> {
  late AudioPlayer _audioPlayer;
  double _currentSpeed = 1.0;

  // TODO: Replace this with your actual Cloudflare URL
  final String introUrl =
      "https://hajjaudiofiles.kumthra.com/questions_audiofiles/intro.mp3";

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(introUrl);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isLargeScreen = MediaQuery.of(context).size.width >= 800;

    Widget imageSection = Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: AssetImage('assets/intro.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );

    Widget contentSection = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Audio Player Card
        Card.outlined(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(child: SizedBox()),
                    StreamBuilder<PlayerState>(
                      stream: _audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;

                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return const CircularProgressIndicator();
                        } else if (playing != true) {
                          return IconButton(
                            icon: const Icon(Icons.play_circle_fill),
                            iconSize: 64,
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: _audioPlayer.play,
                          );
                        } else if (processingState !=
                            ProcessingState.completed) {
                          return IconButton(
                            icon: const Icon(Icons.pause_circle_filled),
                            iconSize: 64,
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: _audioPlayer.pause,
                          );
                        } else {
                          return IconButton(
                            icon: const Icon(Icons.replay_circle_filled),
                            iconSize: 64,
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: () => _audioPlayer.seek(Duration.zero),
                          );
                        }
                      },
                    ),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Tooltip(
                            message: "سرعة التشغيل",
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _currentSpeed += 0.5;
                                  if (_currentSpeed > 2.0) {
                                    _currentSpeed = 0.5;
                                  }
                                  _audioPlayer.setSpeed(_currentSpeed);
                                });
                              },
                              child: SizedBox(
                                width: 40,
                                child: Text(
                                  "${_currentSpeed == 1.0 ? '1' : _currentSpeed}x",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                StreamBuilder<Duration>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = _audioPlayer.duration ?? Duration.zero;
                    return Column(
                      children: [
                        Slider(
                          value: position.inMilliseconds.toDouble(),
                          max: duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            _audioPlayer
                                .seek(Duration(milliseconds: value.toInt()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position),
                                  style: const TextStyle(fontFamily: "Zarids")),
                              Text(_formatDuration(duration),
                                  style: const TextStyle(fontFamily: "Zarids")),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card.outlined(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        themeProvider.themeMode == ThemeMode.dark
                            ? "assets/contact_banner_dark.jpg"
                            : "assets/contact_banner_light.jpg",
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.center,
                        width: double.infinity,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Icon(CommunityMaterialIcons.whatsapp,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                            onPressed: () async {
                              Uri url =
                                  Uri.parse("https://wa.me/+966506906007");
                              if (!await launchUrl(url)) {
                                throw Exception('Could not launch $url');
                              }
                            },
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Icon(Icons.phone_outlined,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary),
                            ),
                            onPressed: () async {
                              Uri url = Uri.parse("tel:+966506906007");
                              if (!await launchUrl(url)) {
                                throw Exception('Could not launch $url');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text("المقدمة",
              style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: "Zarids")),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isLargeScreen ? 1000 : 800),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLargeScreen
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: contentSection),
                          const SizedBox(width: 12),
                          imageSection,
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          imageSection,
                          const SizedBox(height: 8),
                          contentSection,
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

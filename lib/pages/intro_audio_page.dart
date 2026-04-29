import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:hajj_app/main.dart';
import 'package:hajj_app/question_model.dart';
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
  final String introUrl =
      "https://hajjaudiofiles.kumthra.com/questions_audiofiles/intro.mp3";

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    var audioProvider = Provider.of<GlobalAudioProvider>(context);
    bool isLargeScreen = MediaQuery.of(context).size.width >= 800;

    bool isIntroPlaying =
        audioProvider.currentQuestion?.no?.toString() == 'intro' ||
            audioProvider.currentQuestion?.question == 'المقدمة';

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
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Center(
              child: StreamBuilder<PlayerState>(
                stream: audioProvider.audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;

                  if (isIntroPlaying &&
                      (processingState == ProcessingState.loading ||
                          processingState == ProcessingState.buffering)) {
                    return const CircularProgressIndicator();
                  }

                  bool isPlaying = isIntroPlaying && audioProvider.isPlaying;

                  return IconButton(
                    icon: Icon(isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill),
                    iconSize: 64,
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () async {
                      if (isIntroPlaying) {
                        if (audioProvider.isPlaying) {
                          audioProvider.audioPlayer.pause();
                        } else {
                          audioProvider.audioPlayer.play();
                        }
                      } else {
                        audioProvider.stopAudio();
                        try {
                          audioProvider.setBookmarkMode(false);
                        } catch (e) {}
                        try {
                          // Safely assign currentQuestion if it acts as a normal setter
                          audioProvider.currentQuestion = Question.fromJson({
                            "no": "intro",
                            "No": "intro",
                            "question": "المقدمة",
                            "Question": "المقدمة",
                            "MainTitle": "المقدمة",
                            "SubTitle": "المقدمة",
                            "instructor": "شيخ جعفر العبدالكريم"
                          });
                        } catch (e) {}
                        await audioProvider.audioPlayer.setUrl(introUrl);
                        audioProvider.audioPlayer.play();
                      }
                    },
                  );
                },
              ),
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
                        gaplessPlayback: true,
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
}

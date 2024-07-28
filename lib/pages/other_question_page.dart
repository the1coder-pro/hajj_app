import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/pages/question_page.dart';
import 'package:hajj_app/settings.dart';
import 'package:provider/provider.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'dart:html' as html;

class OtherQuestionPage extends StatefulWidget {
  const OtherQuestionPage(
    this.question, {
    super.key,
  });

  final QuestionModelOther question;

  @override
  State<OtherQuestionPage> createState() => _OtherQuestionPageState();
}

class _OtherQuestionPageState extends State<OtherQuestionPage> {
  WidgetsToImageController controller = WidgetsToImageController();
// to save image bytes of widget
  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
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
                        .load("assets/audiofiles/${widget.question}.mp3");

                    final mp3Audio = Uint8List.view(buffer.buffer);

                    var files = [
                      html.File([bytes!], "question_${widget.question}.jpg",
                          {"type": "image/jpeg"}),
                      html.File(
                          // mp3
                          [mp3Audio],
                          "question_${widget.question}.mp3",
                          {"type": "audio/mpeg"})
                    ];
                    var data = {
                      "title": "سؤال رقم ${widget.question}",
                      "text": "${widget.question.question}",
                      "url": "https://hajj-app-1.web.app",
                      "files": files
                    };
                    share(data);
                  },
                  icon: const Icon(Icons.share_outlined)),
              // bookmark the question
            ],
            leading:
                // close the page
                IconButton(
              onPressed: () {
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
                                  text: widget.question.section!,
                                  style: const TextStyle(
                                      color: Color(0xFFbe8f2f),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Zarids",
                                      fontSize: 25)),
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
                                      fontWeight: FontWeight.w200,
                                      height: 1.2)),
                        ),
                      ),
                      const SizedBox(height: 10),
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
}

class QuestionImageTemplate extends StatelessWidget {
  const QuestionImageTemplate({
    super.key,
    required this.widget,
  });

  final OtherQuestionPage widget;

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
                        text: widget.question.section!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Zarids",
                            fontSize: 25)),
                  ]),
                )),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(10),
              child: AutoSizeText(
                widget.question.question!,
                minFontSize: 30,
                maxLines: 3,
                style: const TextStyle(
                    fontSize: 30,
                    fontFamily: "Zarids",
                    color: Color(0xFFbe8f2f),
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

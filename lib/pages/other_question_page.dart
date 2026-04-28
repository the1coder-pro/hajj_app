import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/question_model.dart';
import 'package:hajj_app/settings.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class OtherQuestionPage extends StatefulWidget {
  const OtherQuestionPage(
    this.question, {
    super.key,
    this.onBack,
    this.showAppBar = true,
  });

  final OtherQuestion question;
  final VoidCallback? onBack;
  final bool showAppBar;

  @override
  State<OtherQuestionPage> createState() => _OtherQuestionPageState();
}

class _OtherQuestionPageState extends State<OtherQuestionPage> {
  WidgetsToImageController controller = WidgetsToImageController();
// to save image bytes of widget
  Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    final prefsProvider =
        Provider.of<QuestionPrefsProvider>(context, listen: false);
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: widget.showAppBar
              ? AppBar(
                  actions: [
                    IconButton(
                        onPressed: () async {
                          try {
                            await Share.share("""
${widget.question.section}

${widget.question.question} 

${widget.question.answerText}

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
                    child: QuestionImageTemplate(widget: widget),
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
                                        await Share.share("""
${widget.question.section}

${widget.question.question} 

${widget.question.answerText}

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
                                  child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: widget.question.section ?? "",
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
                                  child: Text("نص الجواب",
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
            content: SizedBox(
              width: isLargeScreen ? 400 : double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text(
                        "حجم الخط",
                        style: TextStyle(
                          fontFamily: "Zarids",
                          fontSize: 25,
                        ),
                      ),
                      subtitle: Slider(
                        label: prefsProvider.fontSize.toString(),
                        value: prefsProvider.fontSize,
                        min: 20,
                        max: 40,
                        divisions: 5,
                        onChanged: (value) {
                          prefsProvider.fontSize = value;
                        },
                      ),
                      leading: IconButton(
                        onPressed: () {
                          prefsProvider.fontSize = 25;
                        },
                        icon: const Icon(Icons.restore),
                      ),
                      trailing: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
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
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
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
                        text: "${widget.question.section!} - ",
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

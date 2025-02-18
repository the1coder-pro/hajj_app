
import 'package:flutter/material.dart';

class ExtraQuestionsPage extends StatelessWidget {
  const ExtraQuestionsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("مسائل إضافية",
                  style: TextStyle(
                    fontFamily: "Zarids",
                    fontSize: 30,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface,
                    fontWeight: FontWeight.w400,
                  )),
            ),
            body: const Column(
              children: [],
            ),
          ),
    );
  }
}
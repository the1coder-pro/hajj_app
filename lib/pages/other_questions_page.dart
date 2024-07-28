import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hajj_app/components/question_tile.dart';
import 'package:hajj_app/question_model.dart';

import 'package:http/http.dart' as http;

class OtherQuestionsPage extends StatefulWidget {
  const OtherQuestionsPage({
    super.key,
  });

  @override
  State<OtherQuestionsPage> createState() => _OtherQuestionsPageState();
}

class _OtherQuestionsPageState extends State<OtherQuestionsPage> {
  // load question from https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/2
  Future<void> loadJSONQuestionData() async {
    final response = await http.get(Uri.parse(
        'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/2'));
    if (response.statusCode == 200) {
      // get data utf8

      var decodedData = utf8.decode(response.bodyBytes);
      var data = jsonDecode(decodedData);

      // get mainTitle from subTitle

      for (var i = 0; i < data.length; i++) {
        var question = QuestionModel.fromJson(data[i]);
        otherQuestions.add(question);
        debugPrint(question.question);
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  List<QuestionModel> otherQuestions = [];

  @override
  void initState() {
    super.initState();
    loadJSONQuestionData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            title: const Text('مسائل إضافية'),
            centerTitle: true,
          ),
          body: FutureBuilder(
            future: http.get(Uri.parse(
                'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/2')),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                ///first decode the response to utf-8 string
                var myDataString = utf8.decode(snapshot.data!.bodyBytes);

                ///obtain json from string
                var data = jsonDecode(myDataString);
                // var data = jsonDecode(snapshot.data!.body);

                if (data.length == 0) {
                  return const Center(child: Text("لا توجد أسئلة أخرى"));
                }

                // show a grid view with images like pinterest
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var question = QuestionModelOther.fromJson(data[index]);
// 4949
                    return QuestionTile(questionModelAr: question);
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/pages/instructor_page.dart';
import 'package:hajj_app/settings.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// get the list of instructors from the link file and display them in a list view
// the user can search for an instructor by name

Future<List<String>> getInstructorsNames() async {
  // https://opensheet.elk.sh/1KxJKKxKBcEd0lguKAbK-UkGIqzAcOXs5is3zNiTnFgY/1

  // get the data from the link
  final response = await http.get(Uri.parse(
      "https://opensheet.elk.sh/1KxJKKxKBcEd0lguKAbK-UkGIqzAcOXs5is3zNiTnFgY/1"));
  // json
  var data1 = utf8.decode(response.bodyBytes);
  var data = jsonDecode(data1);
  // get the names of the instructors without duplicates
  List<String> instructorsNames = [];
  for (var i = 0; i < data.length; i++) {
    if (!instructorsNames.contains(data[i]['Instructor'])) {
      instructorsNames.add(data[i]['Instructor']);
    }
  }
  debugPrint(instructorsNames.toString());
  return instructorsNames;
}

class InstructorsPage extends StatefulWidget {
  const InstructorsPage({super.key});

  @override
  State<InstructorsPage> createState() => _InstructorsPageState();
}

class _InstructorsPageState extends State<InstructorsPage> {
  final List<String> _intructorsNames = [];

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
        body: FutureBuilder(
          future: getInstructorsNames(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              debugPrint(snapshot.error.toString());
              return const Center(
                child: Text("حدث خطأ"),
              );
            }
            _intructorsNames.addAll(snapshot.data as List<String>);
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverAppBar(
                  pinned: false,
                  snap: false,
                  floating: true,
                  stretchTriggerOffset: 300.0,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    // centerTitle: true,
                    // title: Text('المعلمين'),
                    background: Image.asset(
                      themeProvider.themeMode == ThemeMode.dark
                          ? "assets/main_banner_dark.jpg"
                          : "assets/main_banner_light.jpg",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      childCount: _intructorsNames.length,
                      (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                        Get.to(() => InstructorPage(_intructorsNames[index]),
                            transition: Transition.leftToRight);
                      },
                      trailing: const Icon(Icons.arrow_forward_ios),
                      title: Text(_intructorsNames[index],
                          style: const TextStyle(
                            fontFamily: "Zarids",
                            fontSize: 24,
                          )),
                    );
                  }),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: BottomAppBar(
            notchMargin: 0,
            padding: EdgeInsets.zero,
            height: 100,
            child: ContactFooter()));
  }
}

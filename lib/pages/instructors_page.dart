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
  print(instructorsNames);
  return instructorsNames;
}

// var _intructorsNames = <String>[
//   "شيخ جعفر العبدالكريم",
//   "شيخ عبدالله العبدالله",
//   "شيخ علي الدهنين"
// ];

class InstructorsPage extends StatefulWidget {
  const InstructorsPage({
    super.key,
  });

  @override
  State<InstructorsPage> createState() => _InstructorsPageState();
}

class _InstructorsPageState extends State<InstructorsPage> {
  String searchQuery = "";
  final searchController = TextEditingController();

  final List<String> _intructorsNames = [];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return FutureBuilder(
        future: getInstructorsNames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(
              child: Text("حدث خطأ"),
            );
          }
          _intructorsNames.addAll(snapshot.data as List<String>);
          return _buildInstructorsList(themeProvider);
        });
  }
  //     child: Column(
  //       children: [
  //         // search bar
  //         Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: TextField(
  //             controller: searchController,
  //             onChanged: (value) {
  //               setState(() {
  //                 searchQuery = value;
  //               });
  //             },
  //             style: const TextStyle(
  //               fontFamily: "Zarids",
  //               fontSize: 20,
  //             ),
  //             decoration: InputDecoration(
  //               hintText: "بحث",
  //               hintStyle: const TextStyle(
  //                 fontFamily: "Zarids",
  //                 fontSize: 20,
  //               ),
  //               prefixIcon: const Icon(Icons.search),
  //               border: OutlineInputBorder(
  //                 borderRadius: BorderRadius.circular(15),
  //               ),
  //             ),
  //           ),
  //         ),
  //         if (searchQuery.isNotEmpty &&
  //             !_intructorsNames.any((element) =>
  //                 element.toLowerCase().contains(searchQuery.toLowerCase())))
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Text(
  //               "لا يوجد نتائج",
  //               style: TextStyle(
  //                   fontFamily: "Zarids",
  //                   fontSize: 24,
  //                   color: themeProvider.themeMode == ThemeMode.dark
  //                       ? Colors.white
  //                       : Colors.black),
  //             ),
  //           ),

  //         Expanded(
  //           flex: 3,
  //           child: ListView.builder(
  //             itemCount: _intructorsNames.length,
  //             itemBuilder: (context, i) {
  //               // only show the instructors that match the search query and if there is no match show a message
  //               if (searchQuery.isNotEmpty &&
  //                   !_intructorsNames[i].contains(searchQuery)) {
  //                 return const SizedBox.shrink();
  //               }

  //               return ListTile(
  //                 onTap: () {
  //                   Get.to(() => InstructorPage(_intructorsNames[i]),
  //                       transition: Transition.leftToRight);
  //                 },
  //                 trailing: const Icon(Icons.arrow_forward_ios),
  //                 title: Text(_intructorsNames[i],
  //                     style: const TextStyle(
  //                       fontFamily: "Zarids",
  //                       fontSize: 24,
  //                     )),
  //               );
  //             },
  //           ),
  //         ),
  //         const ContactFooter(),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildInstructorsList(ThemeProvider themeProvider) {
    return Column(
      children: [
        // search bar
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            style: const TextStyle(
              fontFamily: "Zarids",
              fontSize: 20,
            ),
            decoration: InputDecoration(
              hintText: "بحث",
              hintStyle: const TextStyle(
                fontFamily: "Zarids",
                fontSize: 20,
              ),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        if (searchQuery.isNotEmpty &&
            !_intructorsNames.any((element) =>
                element.toLowerCase().contains(searchQuery.toLowerCase())))
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "لا يوجد نتائج",
              style: TextStyle(
                  fontFamily: "Zarids",
                  fontSize: 24,
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.white
                      : Colors.black),
            ),
          ),
        Expanded(
          flex: 3,
          child: ListView.builder(
            itemCount: _intructorsNames.length,
            itemBuilder: (context, i) {
              // only show the instructors that match the search query and if there is no match show a message
              if (searchQuery.isNotEmpty &&
                  !_intructorsNames[i].contains(searchQuery)) {
                return const SizedBox.shrink();
              }

              return ListTile(
                onTap: () {
                  Get.to(() => InstructorPage(_intructorsNames[i]),
                      transition: Transition.leftToRight);
                },
                trailing: const Icon(Icons.arrow_forward_ios),
                title: Text(_intructorsNames[i],
                    style: const TextStyle(
                      fontFamily: "Zarids",
                      fontSize: 24,
                    )),
              );
            },
          ),
        ),
        const ContactFooter(),
      ],
    );
  }
}

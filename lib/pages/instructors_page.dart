import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/pages/instructor_page.dart';
import 'package:hajj_app/settings.dart';
import 'package:provider/provider.dart';

var _intructorsNames = <String>[
  "شيخ جعفر العبدالكريم",
  "شيخ عبدالله العبدالله",
  "شيخ علي الدهنين"
];

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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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

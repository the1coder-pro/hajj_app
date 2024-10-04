import 'package:flutter/material.dart';
import 'package:hajj_app/pages/ads_page.dart';
import 'package:hajj_app/pages/bookmark_page.dart';
import 'package:hajj_app/pages/instructors_page.dart';
import 'package:hajj_app/pages/settings_page.dart';

enum PageType { instructors, ads, settings, bookmarks }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  var pageType = PageType.instructors;

  List<Map<PageType, String>> pageTitles = [
    {PageType.instructors: "المعلمين"},
    {PageType.ads: "الإعلانات"},
    {PageType.bookmarks: "المفضلة"},
    {PageType.settings: "الإعدادات"},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              pageTitles
                  .where((element) => element.keys.first == pageType)
                  .first
                  .values
                  .first,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: "Zarids",
                fontSize: 35,
                fontWeight: FontWeight.w400,
              ),
            ),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer),
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                      text: "حج التمتع\n",
                      style: TextStyle(
                        fontFamily: "Zarids",
                        fontSize: 35,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "في سؤال وجواب",
                      style: TextStyle(
                        fontFamily: "Zarids",
                        fontSize: 25,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ])),
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text(
                    'المعلمين',
                    style: TextStyle(fontFamily: "Zarids", fontSize: 25),
                  ),
                  onTap: () {
                    setState(() {
                      pageType = PageType.instructors;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.new_releases),
                  title: const Text(
                    'الإعلانات',
                    style: TextStyle(fontFamily: "Zarids", fontSize: 25),
                  ),
                  onTap: () {
                    setState(() {
                      pageType = PageType.ads;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: const Text(
                    'المفضلة',
                    style: TextStyle(fontFamily: "Zarids", fontSize: 25),
                  ),
                  onTap: () {
                    setState(() {
                      pageType = PageType.bookmarks;
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text(
                    'الإعدادات',
                    style: TextStyle(fontFamily: "Zarids", fontSize: 25),
                  ),
                  onTap: () {
                    setState(() {
                      pageType = PageType.settings;
                    });

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          body: selectedPage(pageType)),
    );
  }
}

Widget selectedPage(PageType page) {
  switch (page) {
    case PageType.instructors:
      return const InstructorsPage();
    case PageType.ads:
      return const AdvertismentsPage();
    case PageType.settings:
      return const SettingsPage();
    case PageType.bookmarks:
      return const BookmarksPage();
    default:
      return const InstructorsPage();
  }
}

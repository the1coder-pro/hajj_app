import 'package:flutter/material.dart';
import 'package:hajj_app/pages/ads_page.dart';
import 'package:hajj_app/pages/bookmark_page.dart';
import 'package:hajj_app/components/contact_footer.dart';
import 'package:hajj_app/pages/instructors_page.dart';
import 'package:hajj_app/pages/settings_page.dart';

enum PageType { instructors, ads, settings, bookmarks }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const route = "/";

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var pageType = PageType.instructors;

  List<Map<PageType, String>> pageTitles = [
    {PageType.instructors: "الرئيسية"},
    {PageType.ads: "الإعلانات"},
    {PageType.bookmarks: "المفضلة"},
    {PageType.settings: "الإعدادات"},
  ];

  Widget _buildDrawerContent(BuildContext context, {required bool isModal}) {
    return Column(
      children: [
        Expanded(
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
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "في سؤال وجواب",
                    style: TextStyle(
                      fontFamily: "Zarids",
                      fontSize: 25,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ])),
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text(
                  'الرئيسية',
                  style: TextStyle(fontFamily: "Zarids", fontSize: 25),
                ),
                onTap: () {
                  setState(() {
                    pageType = PageType.instructors;
                  });
                  if (isModal) Navigator.pop(context);
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
                  if (isModal) Navigator.pop(context);
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
                  if (isModal) Navigator.pop(context);
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
                  if (isModal) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        if (!isModal)
          ContactFooter(
            isLargeScreen: true,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentPageTitle = pageTitles
        .where((element) => element.keys.first == pageType)
        .first
        .values
        .first;
    bool isHome = pageType == PageType.instructors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isLargeScreen = constraints.maxWidth >= 800;

          Widget scaffold = Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0),
              title: Text(
                isHome ? "" : currentPageTitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: "Zarids",
                  fontSize: 35,
                  fontWeight: FontWeight.w400,
                ),
              ),
              leading: isLargeScreen
                  ? null
                  : Builder(
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
            extendBodyBehindAppBar: isHome,
            drawer: isLargeScreen
                ? null
                : Drawer(
                    child: _buildDrawerContent(context, isModal: true),
                  ),
            body: currentSelectedPage(pageType),
          );

          if (isLargeScreen) {
            return Scaffold(
              body: Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: Drawer(
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      child: _buildDrawerContent(context, isModal: false),
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(child: scaffold),
                ],
              ),
            );
          }

          return scaffold;
        },
      ),
    );
  }
}

Widget currentSelectedPage(PageType page) {
  switch (page) {
    case PageType.instructors:
      return const InstructorsPage();
    case PageType.ads:
      return const AdvertismentsPage();
    case PageType.settings:
      return const SettingsPage();
    case PageType.bookmarks:
      return const BookmarksPage();
  }
}

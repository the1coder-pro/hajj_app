import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/ad_detail.dart';
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
  double _drawerWidth = 300.0;

  List<Map<PageType, String>> pageTitles = [
    {PageType.instructors: "الرئيسية"},
    {PageType.ads: "الإعلانات"},
    {PageType.bookmarks: "المفضلة"},
    {PageType.settings: "الإعدادات"},
  ];

  List<Map> latest3Ads = [];
  List<Map> _adsList = [];

  @override
  void initState() {
    super.initState();
    _fetchLatestAds();
  }

  Future<void> _fetchLatestAds() async {
    try {
      final response = await http.get(Uri.parse(
          'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/3'));
      if (response.statusCode == 200) {
        var decodedData = utf8.decode(response.bodyBytes);
        var data = jsonDecode(decodedData);
        List<Map> validAds = [];
        for (var i = 0; i < data.length; i++) {
          var item = data[i];
          if (DateTime.now().isAfter(DateTime.parse(item['StartDate'])) &&
              DateTime.now().isBefore(DateTime.parse(item['EndDate']))) {
            validAds.add(item);
          }
        }
        if (mounted) {
          setState(() {
            _adsList = validAds;
            latest3Ads = validAds.length > 3
                ? validAds.sublist(validAds.length - 3)
                : validAds;
          });
        }
      }
    } catch (e) {
      // Silently ignore or handle error
    }
  }

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
                leading: const Icon(Icons.people_outline),
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
                leading: const Icon(Icons.new_releases_outlined),
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
                leading: const Icon(Icons.bookmark_outline),
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
                leading: const Icon(Icons.settings_outlined),
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
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              if (latest3Ads.isNotEmpty)
                Material(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: InkWell(
                    onTap: () {
                      if (latest3Ads.length == 1) {
                        int initialIndex = _adsList.indexOf(latest3Ads.first);
                        if (initialIndex == -1) initialIndex = 0;
                        Get.to(
                          () => AdDetailsPage(
                              ads: _adsList, initialIndex: initialIndex),
                          transition: Transition.downToUp,
                        );
                      } else {
                        setState(() {
                          pageType = PageType.ads;
                        });
                      }
                    },
                    child: Container(
                      height: 25,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: MarqueeWidget(
                        child: Row(
                          children: [
                            SizedBox(width: MediaQuery.of(context).size.width),
                            for (int i = 0; i < latest3Ads.length; i++) ...[
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(
                                  "${latest3Ads[i]['Title']}",
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontFamily: "Zarids",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (i < latest3Ads.length - 1)
                                Text(
                                  " | ",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                            SizedBox(width: MediaQuery.of(context).size.width),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isLargeScreen = constraints.maxWidth >= 800;

                    Widget scaffold = Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        elevation: 0,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0),
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
                              child:
                                  _buildDrawerContent(context, isModal: true),
                            ),
                      body: IndexedStack(
                        index: pageTitles.indexWhere(
                            (element) => element.keys.first == pageType),
                        children: const [
                          InstructorsPage(),
                          AdvertismentsPage(),
                          BookmarksPage(),
                          SettingsPage(),
                        ],
                      ),
                    );

                    if (isLargeScreen) {
                      return Scaffold(
                        body: Row(
                          children: [
                            SizedBox(
                              width: _drawerWidth,
                              child: Drawer(
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                child: _buildDrawerContent(context,
                                    isModal: false),
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.resizeColumn,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onPanUpdate: (details) {
                                  setState(() {
                                    _drawerWidth -= details.delta.dx;
                                    _drawerWidth = _drawerWidth.clamp(
                                        200.0, constraints.maxWidth * 0.5);
                                  });
                                },
                                child: const SizedBox(
                                  width: 10,
                                  child:
                                      VerticalDivider(width: 1, thickness: 1),
                                ),
                              ),
                            ),
                            Expanded(child: scaffold),
                          ],
                        ),
                      );
                    }

                    return scaffold;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarqueeWidget extends StatefulWidget {
  final Widget child;
  const MarqueeWidget({super.key, required this.child});

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  late ScrollController _scrollController;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(MediaQuery.of(context).size.width / 2);
      }
      _scroll();
    });
  }

  void _scroll() async {
    if (_isScrolling) return;
    _isScrolling = true;
    await Future.delayed(const Duration(seconds: 1));
    while (mounted) {
      if (!_scrollController.hasClients) {
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }
      double maxScrollExtent = _scrollController.position.maxScrollExtent;
      if (maxScrollExtent > 0) {
        double distance = maxScrollExtent - _scrollController.offset;
        int duration = (distance * 40).toInt(); // smooth reading speed
        await _scrollController.animateTo(
          maxScrollExtent,
          duration: Duration(milliseconds: duration > 0 ? duration : 100),
          curve: Curves.linear,
        );
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(0.0);
        }
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: widget.child,
      ),
    );
  }
}

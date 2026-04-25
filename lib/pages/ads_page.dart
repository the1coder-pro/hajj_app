import 'dart:convert';

// import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajj_app/components/ad_detail.dart';
import 'package:http/http.dart' as http;

class AdvertismentsPage extends StatefulWidget {
  const AdvertismentsPage({super.key});
  static const route = "/ads";

  @override
  State<AdvertismentsPage> createState() => _AdvertismentsPageState();
}

class _AdvertismentsPageState extends State<AdvertismentsPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  static List<Map>? _cachedAdsList;
  static List<Map>? _cachedLatest3Ads;
  List<Map> _adsList = [];
  late Future<void> _initAdsData;

  @override
  void initState() {
    super.initState();
    _initAdsData = _initAds();
  }

  List<Map> latest3Ads = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initAdsData,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
              {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("جاري التحميل...."),
                    ],
                  ),
                );
              }
            case ConnectionState.done:
              {
                return RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _refreshAds,
                    child: _adsList.isEmpty
                        ? const Center(child: Text("لا توجد إعلانات حاليا."))
                        : Column(children: [
                            const Text("اخر الأخبار",
                                style: TextStyle(fontSize: 25)),
                            CarouselSlider(
                              options: CarouselOptions(
                                  height: 250.0,
                                  autoPlay: latest3Ads.length > 1,
                                  enableInfiniteScroll: latest3Ads.length > 1,
                                  autoPlayInterval: const Duration(seconds: 5)),
                              // items are the three latest ads
                              items: latest3Ads.map<Widget>((item) {
                                String imageStr =
                                    item['Image']?.toString() ?? '';
                                String imageURL = '';
                                if (imageStr.contains('id=')) {
                                  String id = imageStr.split('id=')[1];
                                  imageURL =
                                      "https://lh3.googleusercontent.com/d/$id=s1000?authuser=0";
                                }

                                Widget fallbackWidget = Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      item['Title'] ?? 'بدون عنوان',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontFamily: "Zarids",
                                      ),
                                    ),
                                  ),
                                );

                                return Card(
                                  child: InkWell(
                                    onTap: () {
                                      int initialIndex = _adsList.indexOf(item);
                                      if (initialIndex == -1) initialIndex = 0;
                                      Get.to(
                                          () => AdDetailsPage(
                                              ads: _adsList,
                                              initialIndex: initialIndex),
                                          transition: Transition.downToUp);
                                    },
                                    child: imageURL.isNotEmpty
                                        ? Image.network(
                                            imageURL,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return fallbackWidget;
                                            },
                                          )
                                        : fallbackWidget,
                                  ),
                                );
                              }).toList(),
                            ),
                            if (_adsList.length > 1) ...[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text("جميع الإعلانات الحالية:",
                                        style: TextStyle(fontSize: 25))),
                              ),
                              Expanded(
                                  flex: 4,
                                  child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                      ),
                                      reverse: true,
                                      shrinkWrap: true,
                                      itemCount: _adsList.length,
                                      itemBuilder: (context, index) {
                                        String imageStr = _adsList[index]
                                                    ['Image']
                                                ?.toString() ??
                                            '';
                                        String imageURL = '';
                                        if (imageStr.contains('id=')) {
                                          String id = imageStr.split('id=')[1];
                                          imageURL =
                                              "https://lh3.googleusercontent.com/d/$id=s1000?authuser=0";
                                        }

                                        return Card(
                                          child: InkWell(
                                              onTap: () {
                                                Get.to(
                                                    () => AdDetailsPage(
                                                        ads: _adsList,
                                                        initialIndex: index),
                                                    transition:
                                                        Transition.downToUp);
                                              },
                                              child: Center(
                                                  child: Text(_adsList[index]
                                                      ['Title']))),
                                        );
                                      })),
                            ]
                          ]));
              }
          }
        });
  }

  Future<void> _initAds() async {
    if (_cachedAdsList != null && _cachedLatest3Ads != null) {
      setState(() {
        _adsList = _cachedAdsList!;
        latest3Ads = _cachedLatest3Ads!;
      });
      return;
    }
    final response = await http.get(Uri.parse(
        'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/1'));
    if (response.statusCode == 200) {
      // get data utf8

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

      setState(() {
        _adsList = validAds;
        if (validAds.length > 3) {
          // latest3Ads = validAds.sublist(0, 3);
          latest3Ads = validAds.sublist(validAds.length - 3);
        } else {
          latest3Ads = validAds;
        }
        _cachedAdsList = _adsList;
        _cachedLatest3Ads = latest3Ads;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> _refreshAds() async {
    final response = await http.get(Uri.parse(
        'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/1'));
    if (response.statusCode == 200) {
      // get data utf8

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

      setState(() {
        _adsList = validAds;
        if (validAds.length > 3) {
          // get the last 3 items in validAds
          latest3Ads = validAds.sublist(validAds.length - 3);
        } else {
          latest3Ads = validAds;
        }
        _cachedAdsList = _adsList;
        _cachedLatest3Ads = latest3Ads;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

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
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(child: Text("لا توجد إعلانات حاليا."))
                            ],
                          )
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(children: [
                              CarouselSlider(
                                options: CarouselOptions(
                                    height: 120.0,
                                    autoPlay: latest3Ads.length > 1,
                                    enableInfiniteScroll: latest3Ads.length > 1,
                                    autoPlayInterval:
                                        const Duration(seconds: 5)),
                                // items are the three latest ads
                                items: latest3Ads.map<Widget>((item) {
                                  String imageStr =
                                      item['Image']?.toString() ?? '';
                                  String imageURL = '';
                                  if (imageStr.isNotEmpty) {
                                    final regExp =
                                        RegExp(r'(?:id=|\/d\/)([\w-]+)');
                                    final match = regExp.firstMatch(imageStr);
                                    if (match != null &&
                                        match.group(1) != null) {
                                      String id = match.group(1)!;
                                      imageURL =
                                          "https://lh3.googleusercontent.com/d/$id=s1000?authuser=0";
                                    } else {
                                      imageURL = imageStr;
                                    }
                                  }

                                  Widget titleWidget = Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        item['Title'] ?? 'بدون عنوان',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: imageURL.isNotEmpty
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          fontFamily: "Zarids",
                                        ),
                                      ),
                                    ),
                                  );

                                  return Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () {
                                        int initialIndex =
                                            _adsList.indexOf(item);
                                        if (initialIndex == -1)
                                          initialIndex = 0;
                                        Get.to(
                                            () => AdDetailsPage(
                                                ads: _adsList,
                                                initialIndex: initialIndex),
                                            transition: Transition.downToUp);
                                      },
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          if (imageURL.isNotEmpty) ...[
                                            ImageFiltered(
                                              imageFilter: ImageFilter.blur(
                                                  sigmaX: 4.0, sigmaY: 4.0),
                                              child: HttpImageFetcher(
                                                imageUrl: imageURL,
                                                fallbackWidget:
                                                    const SizedBox(),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Container(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                            ),
                                          ],
                                          titleWidget,
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (_adsList.isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text("الإعلانات الحالية:",
                                          style: TextStyle(fontSize: 25))),
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 8.0),
                                    itemCount: _adsList.length,
                                    itemBuilder: (context, index) {
                                      String imageStr = _adsList[index]['Image']
                                              ?.toString() ??
                                          '';
                                      String imageURL = '';
                                      if (imageStr.isNotEmpty) {
                                        final regExp =
                                            RegExp(r'(?:id=|\/d\/)([\w-]+)');
                                        final match =
                                            regExp.firstMatch(imageStr);
                                        if (match != null &&
                                            match.group(1) != null) {
                                          String id = match.group(1)!;
                                          imageURL =
                                              "https://lh3.googleusercontent.com/d/$id=s1000?authuser=0";
                                        } else {
                                          imageURL = imageStr;
                                        }
                                      }

                                      String description = _adsList[index]
                                                  ['Description']
                                              ?.toString()
                                              .replaceAll('\n', ' ') ??
                                          '';

                                      return Card.outlined(
                                        clipBehavior: Clip.antiAlias,
                                        margin:
                                            const EdgeInsets.only(bottom: 16.0),
                                        child: InkWell(
                                            onTap: () {
                                              Get.to(
                                                  () => AdDetailsPage(
                                                      ads: _adsList,
                                                      initialIndex: index),
                                                  transition:
                                                      Transition.downToUp);
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                if (imageURL.isNotEmpty)
                                                  SizedBox(
                                                    height: 180,
                                                    child: HttpImageFetcher(
                                                      imageUrl: imageURL,
                                                      fallbackWidget:
                                                          const SizedBox(),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        _adsList[index]
                                                                ['Title'] ??
                                                            'بدون عنوان',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily: "Zarids",
                                                          fontSize: 20,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      if (description
                                                          .isNotEmpty) ...[
                                                        Divider(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .secondary,
                                                            height: 15),
                                                        _buildFormattedText(
                                                          description,
                                                          TextStyle(
                                                            fontFamily:
                                                                "Zarids",
                                                            fontSize: 16,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurface,
                                                          ),
                                                          maxLines: 2,
                                                        ),
                                                      ]
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                      );
                                    }),
                              ]
                            ]),
                          ));
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
        'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/3'));
    if (response.statusCode == 200) {
      // get data utf8

      var decodedData = utf8.decode(response.bodyBytes);
      var data = jsonDecode(decodedData);

      List<Map> validAds = [];

      for (var i = 0; i < data.length; i++) {
        var item = data[i];
        DateTime? startDate = _parseDate(item['StartDate']?.toString());
        DateTime? endDate = _parseDate(item['EndDate']?.toString());

        if (startDate != null && endDate != null) {
          if (DateTime.now().isAfter(startDate) &&
              DateTime.now().isBefore(endDate)) {
            validAds.add(item);
          }
        }
      }

      validAds.sort((a, b) {
        DateTime? timeA = _parseDate(
            a['Timestamp']?.toString() ?? a['StartDate']?.toString());
        DateTime? timeB = _parseDate(
            b['Timestamp']?.toString() ?? b['StartDate']?.toString());

        if (timeA != null && timeB != null) {
          return timeA.compareTo(timeB);
        }
        return 0;
      });

      setState(() {
        _adsList = validAds.reversed.toList();
        if (_adsList.length > 3) {
          latest3Ads = _adsList.sublist(0, 3);
        } else {
          latest3Ads = _adsList;
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
        'https://opensheet.elk.sh/1IR-c-DM1_G0Qr6sr-iy7gZKwWN5zuQfo_Vr8Ky29BgE/3'));
    if (response.statusCode == 200) {
      // get data utf8

      var decodedData = utf8.decode(response.bodyBytes);
      var data = jsonDecode(decodedData);

      List<Map> validAds = [];

      for (var i = 0; i < data.length; i++) {
        var item = data[i];
        DateTime? startDate = _parseDate(item['StartDate']?.toString());
        DateTime? endDate = _parseDate(item['EndDate']?.toString());

        if (startDate != null && endDate != null) {
          if (DateTime.now().isAfter(startDate) &&
              DateTime.now().isBefore(endDate)) {
            validAds.add(item);
          }
        }
      }

      validAds.sort((a, b) {
        DateTime? timeA = _parseDate(
            a['Timestamp']?.toString() ?? a['StartDate']?.toString());
        DateTime? timeB = _parseDate(
            b['Timestamp']?.toString() ?? b['StartDate']?.toString());

        if (timeA != null && timeB != null) {
          return timeA.compareTo(timeB);
        }
        return 0;
      });

      setState(() {
        _adsList = validAds.reversed.toList();
        if (_adsList.length > 3) {
          latest3Ads = _adsList.sublist(0, 3);
        } else {
          latest3Ads = _adsList;
        }
        _cachedAdsList = _adsList;
        _cachedLatest3Ads = latest3Ads;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      // Handle both yyyy/mm/dd and yyyy-mm-dd formats
      String formatted = dateStr.trim().replaceAll('/', '-');

      // Ensure month and day are zero-padded (DateTime.parse expects 2 digits)
      List<String> parts = formatted.split('-');
      if (parts.length >= 3) {
        String year = parts[0];
        String month = parts[1].padLeft(2, '0');

        // Support datetime strings that contain a time component
        List<String> dayParts = parts[2].split(RegExp(r'\s+'));
        String day = dayParts[0].padLeft(2, '0');

        if (dayParts.length > 1) {
          String time = dayParts.sublist(1).join(' ');
          formatted = '$year-$month-$day $time';
        } else {
          formatted = '$year-$month-$day';
        }
      }

      return DateTime.parse(formatted);
    } catch (e) {
      return null;
    }
  }

  Widget _buildFormattedText(String text, TextStyle baseStyle,
      {int? maxLines}) {
    final spans = <TextSpan>[];
    text.splitMapJoin(
      RegExp(r'\*(.*?)\*', dotAll: true),
      onMatch: (Match m) {
        spans.add(TextSpan(
          text: m.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
        return '';
      },
      onNonMatch: (String n) {
        spans.add(TextSpan(text: n));
        return '';
      },
    );

    return RichText(
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
      text: TextSpan(
        style: baseStyle,
        children: spans,
      ),
    );
  }
}

class HttpImageFetcher extends StatefulWidget {
  final String imageUrl;
  final Widget fallbackWidget;
  final BoxFit fit;
  final FilterQuality filterQuality;

  const HttpImageFetcher({
    super.key,
    required this.imageUrl,
    required this.fallbackWidget,
    this.fit = BoxFit.cover,
    this.filterQuality = FilterQuality.low,
  });

  @override
  State<HttpImageFetcher> createState() => _HttpImageFetcherState();
}

class _HttpImageFetcherState extends State<HttpImageFetcher> {
  static final Map<String, Uint8List> _imageCache = {};
  Uint8List? _imageBytes;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  Future<void> _fetchImage() async {
    if (_imageCache.containsKey(widget.imageUrl)) {
      if (mounted) setState(() => _imageBytes = _imageCache[widget.imageUrl]);
      return;
    }

    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode == 200) {
        _imageCache[widget.imageUrl] = response.bodyBytes;
        if (mounted) setState(() => _imageBytes = response.bodyBytes);
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'HTTP Error: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'فشل تحميل الصورة:\n$_errorMessage',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      );
    }
    if (_imageBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Image.memory(
      _imageBytes!,
      fit: widget.fit,
      width: double.infinity,
      filterQuality: widget.filterQuality,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'خطأ في عرض الصورة:\n${error.toString()}',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

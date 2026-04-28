import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdDetailsPage extends StatefulWidget {
  const AdDetailsPage({
    super.key,
    required this.ads,
    required this.initialIndex,
  });

  final List<Map> ads;
  final int initialIndex;

  @override
  State<AdDetailsPage> createState() => _AdDetailsPageState();
}

class _AdDetailsPageState extends State<AdDetailsPage> {
  late int _currentIndex;
  final ValueNotifier<double> _drawerWidth = ValueNotifier(300.0);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _drawerWidth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty || _currentIndex >= widget.ads.length) {
      return const Scaffold(body: Center(child: Text("الإعلان غير متوفر")));
    }

    Map currentAd = widget.ads[_currentIndex];

    String imageStr = currentAd['Image']?.toString() ?? '';
    String imageURL = '';
    if (imageStr.isNotEmpty) {
      final regExp = RegExp(r'(?:id=|\/d\/)([\w-]+)');
      final match = regExp.firstMatch(imageStr);
      if (match != null && match.group(1) != null) {
        String id = match.group(1)!;
        imageURL = "https://lh3.googleusercontent.com/d/$id=s1000?authuser=0";
      } else {
        imageURL = imageStr; // Fallback in case it's already a direct link
      }
    }

    String title = currentAd['Title'] ?? 'بدون عنوان';
    String description = currentAd['Description'] ?? '';
    String link = currentAd['Link'] ?? '';
    // String? timestamp =
    //     (currentAd['StartDate'] != null && currentAd['EndDate'] != null)
    //         ? "${currentAd['StartDate']} إلى ${currentAd['EndDate']}"
    //         : null;

    Widget fallbackWidget = const Padding(
      padding: EdgeInsets.all(30.0),
      child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
    );

    Widget imageWidget = imageURL.isNotEmpty
        ? Image.network(
            imageURL,
            key: ValueKey(imageURL),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return fallbackWidget;
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          )
        : fallbackWidget;

    Widget detailsWidget = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          Card.outlined(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (timestamp != null && timestamp.isNotEmpty) ...[
                  // Row(
                  //   children: [
                  //     Icon(Icons.access_time,
                  //         color: Theme.of(context).colorScheme.primary,
                  //         size: 20),
                  //     const SizedBox(width: 8),
                  //     Expanded(
                  //       child: Text(
                  //         timestamp,
                  //         style: TextStyle(
                  //           color: Theme.of(context).colorScheme.primary,
                  //           fontWeight: FontWeight.bold,
                  //           fontFamily: "Zarids",
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const Divider(height: 16),
                  // ],
                  Text(
                    description,
                    style: const TextStyle(fontSize: 18, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (link.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: SizedBox(
                width: 150,
                child: FilledButton.icon(
                  // radius
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    Uri url = Uri.parse(link);
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },

                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.launch_outlined),
                  label: const Text("الرابط",
                      style: TextStyle(fontSize: 18, fontFamily: "Zarids")),
                ),
              ),
            ),
          const SizedBox(height: 10)
        ],
      ),
    );

    Widget mainContent = ListView(
      children: [
        InteractiveViewer(
          child: Container(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.3),
            constraints: const BoxConstraints(
              maxHeight: 400, // Bound image height so scrolling is pleasant
            ),
            child: Center(child: imageWidget),
          ),
        ),
        detailsWidget,
      ],
    );

    Widget drawerContent = Drawer(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, right: 8.0, left: 16.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Text(
                          "الإعلانات",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontFamily: "Zarids",
                          ),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: widget.ads.length,
              itemBuilder: (context, index) {
                return ListTile(
                  selected: _currentIndex == index,
                  selectedTileColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  title: Text(
                    widget.ads[index]['Title'] ?? 'بدون عنوان',
                    style: TextStyle(
                      fontFamily: "Zarids",
                      fontSize: 20,
                      fontWeight: _currentIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: _currentIndex == index
                          ? Theme.of(context).colorScheme.onSecondaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: MediaQuery.of(context).size.width < 800 ? AppBar() : null,
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isLargeScreen = constraints.maxWidth >= 800;
            if (isLargeScreen) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ValueListenableBuilder<double>(
                    valueListenable: _drawerWidth,
                    builder: (context, width, child) {
                      return SizedBox(
                        width: width,
                        child: drawerContent,
                      );
                    },
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeColumn,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        _drawerWidth.value -= details.delta.dx;
                        _drawerWidth.value = _drawerWidth.value
                            .clamp(200.0, constraints.maxWidth * 0.5);
                      },
                      child: const SizedBox(
                        width: 10,
                        child: VerticalDivider(width: 1, thickness: 1),
                      ),
                    ),
                  ),
                  Expanded(
                    child: mainContent,
                  ),
                ],
              );
            } else {
              return mainContent;
            }
          },
        ),
      ),
    );
  }
}

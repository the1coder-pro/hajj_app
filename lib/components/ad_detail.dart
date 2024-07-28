
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdDetailsPage extends StatelessWidget {
  const AdDetailsPage({
    super.key,
    required this.imageURL,
    required this.title,
    required this.description,
    required this.link,
  });

  final String imageURL;
  final String title;
  final String description;
  final String link;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: [
            InteractiveViewer(
                child: Image.network(
              imageURL,
              // fit: BoxFit.cover,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(description),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilledButton.icon(
                  onPressed: () async {
                    Uri url = Uri.parse(link);
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.launch_outlined),
                  label: const Text("رابط")),
            )
          ],
        ),
      ),
    );
  }
}
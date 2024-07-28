
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactFooter extends StatelessWidget {
  const ContactFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondaryContainer,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(
            'للتواصل معنا',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // icons for social media
              IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.blue),
                ),
                color: Colors.white,
                onPressed: () async {
                  Uri url = Uri.parse(
                      'https://www.facebook.com/hamlah.alkhalaf/?locale=ar_AR');
                  // open link
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                icon: const Icon(CommunityMaterialIcons.facebook),
              ),
              const SizedBox(width: 10),
              IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.yellow),
                ),
                color: Colors.black,
                onPressed: () async {
                  Uri url = Uri.parse(
                      'https://www.snapchat.com/add/h_alkalaf?sender_web_id=6152c6b7-009d-4f62-b453-490df90fe35e&device_type=desktop&is_copy_url=true');
                  // open link
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                icon: const Icon(CommunityMaterialIcons.snapchat),
              ),
              const SizedBox(width: 10),

              IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.pink),
                ),
                color: Colors.white,
                onPressed: () async {
                  Uri url =
                      Uri.parse('https://www.instagram.com/h_alkalaf/?hl=en');
                  // open link
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                icon: const Icon(CommunityMaterialIcons.instagram),
              ),
              const SizedBox(width: 10),

              IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                ),
                color: Colors.red,
                onPressed: () async {
                  Uri url = Uri.parse('https://www.youtube.com/@halkalaf');
                  // open link
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                icon: const Icon(CommunityMaterialIcons.youtube),
              ),
              const SizedBox(width: 10),

              IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  backgroundColor:
                      WidgetStateProperty.all(const Color(0xFF2b7b7a)),
                ),
                color: Colors.white,
                onPressed: () async {
                  Uri url = Uri.parse('https://wa.me/+966500155187');
                  // open link
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                icon: const Icon(CommunityMaterialIcons.face_agent),
              ),
              const SizedBox(width: 5),
              Text(
                "@h_alkhalaf",
                textDirection: TextDirection.ltr,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 15),
              )
            ],
          ),
          const SizedBox(width: 90),
        ],
      ),
    );
  }
}


class ContactFooterImageTemplate extends StatelessWidget {
  const ContactFooterImageTemplate({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // icons for social media
                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  color: Colors.black,
                  onPressed: () async {
                    Uri url = Uri.parse(
                        'https://www.facebook.com/hamlah.alkhalaf/?locale=ar_AR');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.facebook),
                ),
                const SizedBox(width: 5),
                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  color: Colors.black,
                  onPressed: () async {
                    Uri url = Uri.parse(
                        'https://www.snapchat.com/add/h_alkalaf?sender_web_id=6152c6b7-009d-4f62-b453-490df90fe35e&device_type=desktop&is_copy_url=true');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.snapchat),
                ),
                const SizedBox(width: 5),

                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  color: Colors.black,
                  onPressed: () async {
                    Uri url =
                        Uri.parse('https://www.instagram.com/h_alkalaf/?hl=en');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.instagram),
                ),
                const SizedBox(width: 5),

                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  color: Colors.black,
                  onPressed: () async {
                    Uri url = Uri.parse('https://www.youtube.com/@halkalaf');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.youtube),
                ),
                const SizedBox(width: 10),
                Text("@h_alkhalaf",
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 15))
              ],
            ),
            // for maintance
          ],
        ),
      ),
    );
  }
}

class ContactFooterImage extends StatelessWidget {
  const ContactFooterImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // icons for social media
                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(Colors.blue),
                  ),
                  color: Colors.white,
                  onPressed: () async {
                    Uri url = Uri.parse(
                        'https://www.facebook.com/hamlah.alkhalaf/?locale=ar_AR');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.facebook),
                ),
                const SizedBox(width: 5),
                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(Colors.yellow),
                  ),
                  color: Colors.black,
                  onPressed: () async {
                    Uri url = Uri.parse(
                        'https://www.snapchat.com/add/h_alkalaf?sender_web_id=6152c6b7-009d-4f62-b453-490df90fe35e&device_type=desktop&is_copy_url=true');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.snapchat),
                ),
                const SizedBox(width: 5),

                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(Colors.pink),
                  ),
                  color: Colors.white,
                  onPressed: () async {
                    Uri url =
                        Uri.parse('https://www.instagram.com/h_alkalaf/?hl=en');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.instagram),
                ),
                const SizedBox(width: 5),

                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  color: Colors.red,
                  onPressed: () async {
                    Uri url = Uri.parse('https://www.youtube.com/@halkalaf');
                    // open link
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                  icon: const Icon(CommunityMaterialIcons.youtube),
                ),
                const SizedBox(width: 10),
                Text("@h_alkhalaf",
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontSize: 10))
              ],
            ),
            // for maintance
          ],
        ),
      ),
    );
  }
}
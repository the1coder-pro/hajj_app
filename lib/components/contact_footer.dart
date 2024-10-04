import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactFooter extends StatelessWidget {
  const ContactFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(
            'للتواصل معنا',
            style: TextStyle(
                fontFamily: "Zarids",
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // TODO: Work on Theme
              // switch to theme switch
              // Switch(
              //   value: themeProvider.themeMode == ThemeMode.dark,
              //   onChanged: (isOn) {
              //     themeProvider.toggleTheme(isOn);
              //   },
              // ),

              const SizedBox(width: 5),
              const ContactButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF2b7b7a),
                  icon: CommunityMaterialIcons.face_agent,
                  link: 'https://wa.me/+966500155187'),
              const SizedBox(width: 5),
              const ContactButton(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: CommunityMaterialIcons.facebook,
                link: 'https://www.facebook.com/hamlah.alkhalaf/?locale=ar_AR',
              ),
              const SizedBox(width: 5),
              IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.yellow),
                ),
                color: Colors.white,
                onPressed: () async {
                  Uri url = Uri.parse(
                      'https://www.snapchat.com/add/h_alkalaf?sender_web_id=6152c6b7-009d-4f62-b453-490df90fe35e&device_type=desktop&is_copy_url=true');
                  // open link
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
                icon: const Stack(children: [
                  Icon(FontAwesome.snapchat_ghost, color: Colors.white),
                  Icon(
                    CommunityMaterialIcons.snapchat,
                    color: Colors.black,
                  ),
                ]),
              ),
              const SizedBox(width: 5),
              const ContactButton(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  icon: CommunityMaterialIcons.instagram,
                  link: 'https://www.instagram.com/h_alkalaf/?hl=en'),
              const SizedBox(width: 5),
              const ContactButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  icon: CommunityMaterialIcons.youtube,
                  link: 'https://www.youtube.com/@halkalaf'),
              const SizedBox(width: 10),
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

class ContactButton extends StatelessWidget {
  const ContactButton({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.link,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String link;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        backgroundColor: WidgetStateProperty.all(backgroundColor),
      ),
      color: foregroundColor,
      onPressed: () async {
        Uri url = Uri.parse(link);
        // open link
        if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }
      },
      icon: Icon(icon),
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
                const ContactButton(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: CommunityMaterialIcons.facebook,
                  link:
                      'https://www.facebook.com/hamlah.alkhalaf/?locale=ar_AR',
                ),
                const SizedBox(width: 5),
                const ContactButton(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  icon: CommunityMaterialIcons.snapchat,
                  link:
                      'https://www.snapchat.com/add/h_alkalaf?sender_web_id=6152c6b7-009d-4f62-b453-490df90fe35e&device_type=desktop&is_copy_url=true',
                ),
                const SizedBox(width: 5),

                const ContactButton(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  icon: CommunityMaterialIcons.instagram,
                  link: 'https://www.instagram.com/h_alkalaf/?hl=en',
                ),
                const SizedBox(width: 5),

                const ContactButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  icon: CommunityMaterialIcons.youtube,
                  link: 'https://www.youtube.com/@halkalaf',
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

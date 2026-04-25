import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactFooter extends StatelessWidget {
  ContactFooter({
    super.key,
    this.isLargeScreen = false,
  });
  bool isLargeScreen = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Theme.of(context);
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Align(
            alignment: isLargeScreen
                ? AlignmentGeometry.centerRight
                : Alignment.center,
            child: Text(
              'للتواصل معنا',
              style: TextStyle(
                  fontFamily: "Zarids",
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
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
                ContactButton(
                  backgroundColor: themeProvider.brightness == Brightness.dark
                      ? Colors.black26
                      : Colors.blue,
                  foregroundColor: Colors.white,
                  icon: CommunityMaterialIcons.facebook,
                  link:
                      'https://www.facebook.com/hamlah.alkhalaf/?locale=ar_AR',
                ),
                const SizedBox(width: 5),
                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    backgroundColor: WidgetStateProperty.all(
                        themeProvider.brightness == Brightness.dark
                            ? Colors.black26
                            : Colors.yellow),
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
                  icon: Stack(children: [
                    Icon(FontAwesome.snapchat_ghost, color: Colors.white),
                    Icon(
                      CommunityMaterialIcons.snapchat,
                      color: themeProvider.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ]),
                ),
                const SizedBox(width: 5),
                ContactButton(
                    backgroundColor: themeProvider.brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.pink,
                    foregroundColor: Colors.white,
                    icon: CommunityMaterialIcons.instagram,
                    link: 'https://www.instagram.com/h_alkalaf/?hl=en'),
                const SizedBox(width: 5),
                ContactButton(
                    backgroundColor: themeProvider.brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.white,
                    foregroundColor: themeProvider.brightness == Brightness.dark
                        ? Colors.white
                        : Colors.red,
                    icon: CommunityMaterialIcons.youtube,
                    link: 'https://www.youtube.com/@halkalaf'),
                const SizedBox(width: 10),
                Text(
                  "@h_alkhalaf",
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15),
                )
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 250,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.brightness == Brightness.dark
                    ? Colors.black26
                    : Colors.white,
                foregroundColor: themeProvider.brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF2b7b7a),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                Uri url = Uri.parse('https://wa.me/+966500155187');
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
              icon: const Icon(CommunityMaterialIcons.face_agent),
              label: const Text(
                "خدمة العملاء",
                style: TextStyle(
                    fontFamily: "Zarids",
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (!isLargeScreen) const SizedBox(height: 50),
          // const SizedBox(width: 90),
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

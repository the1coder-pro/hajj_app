
import 'package:flutter/material.dart';
import 'package:hajj_app/settings.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomizedIconButton extends StatelessWidget {
  const CustomizedIconButton({
    super.key,
    required this.icon,
    required this.link,
    required this.themeProvider,
  });

  final ThemeProvider themeProvider;
  final IconData icon;
  final String link;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, top: 2),
      child: IconButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          backgroundColor: themeProvider.themeMode == ThemeMode.dark
              ? WidgetStateProperty.all(Colors.green[400])
              : WidgetStateProperty.all(Colors.green),
        ),
        color: themeProvider.themeMode == ThemeMode.dark
            ? Colors.black
            : Colors.white,
        onPressed: () async {
          Uri url = Uri.parse(link);
          // open link
          if (!await launchUrl(url)) {
            throw Exception('Could not launch $url');
          }
        },
        icon: Icon(icon),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hajj_app/settings.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("الإعدادات"), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // font size slider
            const Text("حجم الخط", style: TextStyle(fontSize: 20)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Slider(
                  label: fontSizeProvider.fontSize.toString(),
                  value: fontSizeProvider.fontSize,
                  min: 20,
                  max: 40,
                  divisions: 5,
                  onChanged: (value) {
                    fontSizeProvider.fontSize = value;
                  },
                ),
                // font size
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  child: Text(fontSizeProvider.fontSize.toString(),
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

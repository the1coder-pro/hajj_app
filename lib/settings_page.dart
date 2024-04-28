import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("الإعدادات")),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // font size slider
            Text("حجم الخط"),
            Row(
              children: [
                Icon(Icons.format_size),
                Slider(
                  value: 20,
                  min: 10,
                  max: 30,
                  onChanged: (value) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
    final prefsProvider = Provider.of<QuestionPrefsProvider>(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // font size slider
            const Text("حجم الخط",
                style: TextStyle(fontFamily: "Zarids", fontSize: 25)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Slider(
                  label: prefsProvider.fontSize.toString(),
                  value: prefsProvider.fontSize,
                  min: 20,
                  max: 40,
                  divisions: 5,
                  onChanged: (value) {
                    prefsProvider.fontSize = value;
                  },
                ),
                // font size
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  child: Text(prefsProvider.fontSize.toString(),
                      style: const TextStyle(fontSize: 25),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
            const Text("سرعة الصوت",
                style: TextStyle(fontFamily: "Zarids", fontSize: 25)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Slider(
                  label: prefsProvider.audioSpeed.toString(),
                  value: prefsProvider.audioSpeed,
                  min: 0.5,
                  max: 5,
                  // divisions are 5 4.5 4 3.5 3 2.5 2 1.5 1 0.5
                  divisions: 9,
                  onChanged: (value) {
                    prefsProvider.audioSpeed = value;
                  },
                ),
                // font size
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  child: Text(prefsProvider.audioSpeed.toString(),
                      style: const TextStyle(fontSize: 25),
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

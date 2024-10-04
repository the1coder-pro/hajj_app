import 'package:flutter/material.dart';
import 'package:hajj_app/settings.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  static const route = "/settings";

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
            // dark mode switch
            SwitchListTile(
              title: Text("الوضع الليلي",
                  style: Theme.of(context).textTheme.displaySmall),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (isOn) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme(isOn);
              },
            ),

            ListTile(
              title: Text("حجم الخط",
                  style: Theme.of(context).textTheme.displaySmall),
              subtitle: Slider(
                label: prefsProvider.fontSize.toString(),
                value: prefsProvider.fontSize,
                min: 20,
                max: 40,
                divisions: 5,
                onChanged: (value) {
                  prefsProvider.fontSize = value;
                },
              ),
              trailing: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                child: Text(prefsProvider.fontSize.toString(),
                    style: TextStyle(
                        fontSize: 22,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                    textAlign: TextAlign.center),
              ),
            ),

            ListTile(
              title: Text("سرعة الصوت",
                  style: Theme.of(context).textTheme.displaySmall),
              subtitle: Slider(
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
              trailing: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                child: Text(prefsProvider.audioSpeed.toString(),
                    style: TextStyle(
                        fontSize: 22,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                    textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

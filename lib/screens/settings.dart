import 'package:flutter/material.dart';
import 'package:messless/router.dart';
import 'package:messless/widgets/msls_appbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool switchValue = false;
  double sliderValue = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MslsAppbar(),
      body: SafeArea(
        top: true,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton(onPressed: () {
              goRouter.push("/settings/wsTesting");
            }, child: const Text("WS Testing")),

            const Text(
              "UI Components",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const TextField(
              decoration: InputDecoration(
                labelText: "Textfeld",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            FilledButton(onPressed: () {}, child: const Text("Filled Button")),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: () {},
              child: const Text("Outlined Button"),
            ),

            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text("Toggle"),
              value: switchValue,
              onChanged: (v) {
                setState(() {
                  switchValue = v;
                });
              },
            ),

            const SizedBox(height: 16),

            Slider(
              value: sliderValue,
              min: 0,
              max: 100,
              onChanged: (v) {
                setState(() {
                  sliderValue = v;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

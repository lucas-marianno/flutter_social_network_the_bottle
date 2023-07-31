import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import 'package:the_wall/components/elevated_button.dart';
import 'package:the_wall/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.grey[200],
        centerTitle: true,
        title: const Text('S E T T I N G S'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SettingsTile(
                    value: replaceEmailWithUsernameOnWallPost,
                    title: 'replaceEmailWithUsernameOnWallPost',
                    onChanged: (value) {
                      replaceEmailWithUsernameOnWallPost = value;
                      setState(() {});
                    },
                  ),
                  SettingsTile(
                    value: enterSendsPost,
                    title: 'enterSendsPost',
                    onChanged: (value) {
                      enterSendsPost = value;
                      setState(() {});
                    },
                  ),
                  SettingsTile(
                    value: enablePostComments,
                    title: 'enablePostComments',
                    onChanged: (value) {
                      enablePostComments = value;
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const Text('Some configurations might not take effect until app restarts'),
            const SizedBox(height: 15),
            MyButton(
              text: 'Restart App',
              onTap: () {
                // TODO: replace with state management solution
                Restart.restartApp();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.value,
    required this.title,
    required this.onChanged,
  });
  final bool value;
  final String title;
  final void Function(bool value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Switch(
          trackColor: const MaterialStatePropertyAll(Colors.white),
          trackOutlineColor: MaterialStatePropertyAll(Colors.grey[300]),
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

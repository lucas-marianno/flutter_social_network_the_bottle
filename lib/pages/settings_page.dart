import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/settings_tile.dart';
import '../settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final String userEmail = FirebaseAuth.instance.currentUser!.email!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S E T T I N G S'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('User Settings').doc(userEmail).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(25),
              child: ListView(
                children: [
                  SettingsTile(
                    value: UserConfig().replaceEmailWithUsernameOnWallPost,
                    title: 'replaceEmailWithUsernameOnWallPost',
                    onChanged: (value) {
                      UserConfig().saveSettings(replaceEmailWithUsernameOnWallPost: value);
                    },
                  ),
                  SettingsTile(
                    value: UserConfig().enterSendsPost,
                    title: 'enterSendsPost',
                    onChanged: (value) {
                      UserConfig().saveSettings(enterSendsPost: value);
                    },
                  ),
                  SettingsTile(
                    value: UserConfig().enablePostComments,
                    title: 'enablePostComments',
                    onChanged: (value) {
                      UserConfig().saveSettings(enablePostComments: value);
                    },
                  ),
                  SettingsTile(
                    value: UserConfig().darkMode,
                    title: 'darkMode',
                    onChanged: (value) {
                      UserConfig().saveSettings(darkMode: value);
                    },
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

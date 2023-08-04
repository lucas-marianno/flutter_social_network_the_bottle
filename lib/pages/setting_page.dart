import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/settings.dart';

import '../components/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final String userEmail = FirebaseAuth.instance.currentUser!.email!;

  saveSettings() {
    FirebaseFirestore.instance.collection('User Settings').doc(userEmail).set({
      'replaceEmailWithUsernameOnWallPost': configReplaceEmailWithUsernameOnWallPost,
      'enterSendsPost': configEnterSendsPost,
      'enablePostComments': configEnablePostComments,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        title: const Text('S E T T I N G S'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('User Settings').doc(userEmail).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        SettingsTile(
                          value: configReplaceEmailWithUsernameOnWallPost,
                          title: 'replaceEmailWithUsernameOnWallPost',
                          onChanged: (value) {
                            configReplaceEmailWithUsernameOnWallPost = value;
                            saveSettings();
                          },
                        ),
                        SettingsTile(
                          value: configEnterSendsPost,
                          title: 'enterSendsPost',
                          onChanged: (value) {
                            configEnterSendsPost = value;
                            saveSettings();
                          },
                        ),
                        SettingsTile(
                          value: configEnablePostComments,
                          title: 'enablePostComments',
                          onChanged: (value) {
                            configEnablePostComments = value;
                            saveSettings();
                          },
                        ),
                      ],
                    ),
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

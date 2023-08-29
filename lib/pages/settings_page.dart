import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../components/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final String userEmail = FirebaseAuth.instance.currentUser!.email!;

  @override
  Widget build(BuildContext context) {
    final settingsRef = FirebaseFirestore.instance.collection('User Settings').doc(userEmail);
    return Scaffold(
      appBar: AppBar(
        title: const Text('S E T T I N G S'),
      ),
      body: StreamBuilder(
        stream: settingsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.data() != null) {
              return Padding(
                padding: const EdgeInsets.all(25),
                child: ListView(
                  children: [
                    SettingsTile(
                      value: snapshot.data!['enterSendsPost'] ?? false,
                      title: 'enterSendsPost',
                      onChanged: (value) {
                        settingsRef.set({'enterSendsPost': value}, SetOptions(merge: true));
                      },
                    ),
                    SettingsTile(
                      value: snapshot.data!['darkMode'] ?? false,
                      title: 'darkMode',
                      onChanged: (value) {
                        settingsRef.set({'darkMode': value}, SetOptions(merge: true));
                      },
                    ),
                  ],
                ),
              );
            } else {
              settingsRef.set({
                'enterSendsPost': false,
                'darkMode': ThemeMode.system == ThemeMode.dark,
              }, SetOptions(merge: true));
              return const Center(child: CircularProgressIndicator());
            }
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

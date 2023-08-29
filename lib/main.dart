import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/pages/auth_page.dart';
import 'package:the_bottle/firebase_options.dart';
import 'package:the_bottle/pages/home_page.dart';
import 'package:the_bottle/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const Main());
}

class Main extends StatefulWidget {
  static const String name = 'Main';

  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.hasData) {
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('User Settings')
                .doc(authSnapshot.data!.email)
                .snapshots(),
            builder: (context, settingsSnapshot) {
              if (settingsSnapshot.hasData) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: settingsSnapshot.data?.data()?['darkMode'] ?? false
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  home: const HomePage(),
                );
              } else {
                return Center(child: CircularProgressIndicator(color: Colors.grey[300]));
              }
            },
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            home: const AuthPage(),
          );
        }
      },
    );
  }
}

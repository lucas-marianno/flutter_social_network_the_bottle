import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/firebase_options.dart';
import 'package:the_wall/settings.dart';
import 'package:the_wall/theme.dart';
import 'auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('User Settings')
          .doc(FirebaseAuth.instance.currentUser?.email)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          print(snapshot.data!.data()!['darkMode']);
          ThemeMode themeMode() {
            if (snapshot.data!.data()!['darkMode'] == null) return ThemeMode.system;
            return snapshot.data!.data()!['darkMode'] ? ThemeMode.dark : ThemeMode.light;
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode(),
            home: const AuthPage(),
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: UserConfig().darkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthPage(),
          );
        }
      },
    );
  }
}

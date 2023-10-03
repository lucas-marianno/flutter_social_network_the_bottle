import 'package:flutter/material.dart';
import 'package:the_bottle/pages/about_page.dart';
import 'package:the_bottle/theme.dart';

const sandboxEnabled = false;

class Sandbox extends StatelessWidget {
  const Sandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: const AboutPage(),
    );
  }
}

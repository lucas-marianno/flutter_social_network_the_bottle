import 'package:flutter/material.dart';
import 'package:the_bottle/pages/conversation_page.dart';
import 'package:the_bottle/theme.dart';

class Sandbox extends StatelessWidget {
  const Sandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: const ConversationPage(
        conversationId: 'yMYCeAAqQY2ALm10WIr2',
        talkingTo: Text('Vania'),
      ),
    );
  }
}

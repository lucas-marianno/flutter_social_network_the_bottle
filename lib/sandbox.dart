// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:the_bottle/pages/conversation_page.dart';
import 'package:the_bottle/theme.dart';

const sandboxEnabled = false;

class Sandbox extends StatelessWidget {
  const Sandbox({super.key});

  @override
  Widget build(BuildContext context) {
    test();
    // return Center(
    //   child: CircularProgressIndicator(),
    // );
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: const ConversationPage(conversationId: '0eqORoG2AWP61nUKh0Hp'),
    );
  }
}

test() async {
  print('aaaaaaaaaaaaaaaaaaa');

  final a = MyAsyncInitializer();
  await a.initialize();
  print(a.data);
}

class MyAsyncInitializer {
  late String data;

  // MyAsyncInitializer._(); // Private constructor

  // Named constructor for creating an instance
  MyAsyncInitializer();

  // Asynchronously initialize the instance
  Future<void> initialize() async {
    // Perform your asynchronous initialization here
    await Future.delayed(const Duration(seconds: 2));
    data = 'Initialized data';
  }
}

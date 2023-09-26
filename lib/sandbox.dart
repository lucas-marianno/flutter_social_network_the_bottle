// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/theme.dart';
import 'package:the_bottle/util/timestamp_to_string.dart';

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
      home: Scaffold(
        appBar: AppBar(title: const Text('S A N D B O X')),
        body: const Center(
          child: ElevatedButton(onPressed: test, child: Text('print')),
        ),
      ),
    );
  }
}

void test() async {
  final data =
      await FirebaseFirestore.instance.collection('User Posts').doc('ZvGElJdLEgIeD6FyvVCa').get();
  final timestamp = data.data()?['TimeStamp'] as Timestamp;
  print(timestamp);
  print(timestampToString(timestamp));
  print(timestampToString(timestamp, absolute: true));
}

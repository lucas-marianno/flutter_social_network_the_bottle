import 'package:flutter/material.dart';
import 'package:the_wall/components/message_baloon.dart';

class Sandbox extends StatelessWidget {
  const Sandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/assets/darkdoodle.jpg',
            fit: BoxFit.cover,
          ),
          ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return MessageBaloon(text: 'bla' * index, timestamp: 'now', sender: 'sender');
            },
          ),
        ],
      ),
    );
  }
}

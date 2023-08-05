import 'package:flutter/material.dart';
import 'package:the_wall/components/comment.dart';

class Sandbox extends StatelessWidget {
  const Sandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('S A N D B O X'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.grey[200],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: ListView(
          children: [
            Comment(
              text:
                  'This is a loren ipsum da vida ashudhaus huda as u sudh ufh usu  sidf hisjd ijfsid jifsd ihsidh fishd ih',
              user: 'user',
              timestamp: 'timestamp',
            ),
          ],
        ),
      ),
    );
  }
}

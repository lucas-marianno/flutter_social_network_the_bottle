import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/comment.dart';

class Sandbox extends StatefulWidget {
  const Sandbox({super.key});

  @override
  State<Sandbox> createState() => _SandboxState();
}

class _SandboxState extends State<Sandbox> {
  bool loginComplete = false;
  void login() async {
    if (FirebaseAuth.instance.currentUser.isNull) {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: 'test@user.com', password: 'password');
    }

    setState(() => loginComplete = true);
  }

  @override
  void initState() {
    login();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!loginComplete) {
      return const Center(child: CircularProgressIndicator());
    }
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
          children: const [
            Comment(
              postId: 'Ad9RpA9qpwvdZsrpMUbs',
              commentId: '0zpqCkJzkq7mUyTqmccq',
            ),
          ],
        ),
      ),
    );
  }
}

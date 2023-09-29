// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/dialog/show_dialog.dart';

void loginToAccount(String email, String password, BuildContext context) async {
  if (email.isEmpty || password.isEmpty) return;

  showDialog(
    context: context,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
    showMyDialog(
      context,
      title: 'Log in failed!',
      content: e.code.replaceAll('-', ' '),
    );
  }
}

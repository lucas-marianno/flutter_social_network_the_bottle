// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../components/dialog/show_dialog.dart';

void createAccount(
  String email,
  String password,
  String confirmPassword,
  BuildContext context,
) async {
  // TODO: Feature: Security: Only allow verified emails
  // https://firebase.google.com/docs/auth/flutter/email-link-auth

  if (email.isEmpty || password.isEmpty) return;
  if (password != confirmPassword) {
    showMyDialog(context, title: 'Nope!', content: 'Passwords don\'t match.');
    return;
  }
  if (password.length < 6) {
    showMyDialog(
      context,
      title: 'Weak Passord!',
      content: 'Password must be at least 6 characters long',
    );
    return;
  }

  showDialog(
    context: context,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );
  try {
    // creates new user
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // creates user profile
    await FirebaseFirestore.instance.collection('User Profile').doc(email).set({
      'username': email.split('@')[0],
      'bio': 'Write about yourself here...',
    });
  } on FirebaseAuthException catch (e) {
    if (context.mounted) Navigator.pop(context);
    showMyDialog(context, content: e.code);
  }
}

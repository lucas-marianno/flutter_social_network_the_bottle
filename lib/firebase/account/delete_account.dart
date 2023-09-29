import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../components/dialog/input_from_dialog.dart';
import '../../components/dialog/show_dialog.dart';
import '../is_current_user.dart';

void deleteAccount(String accountEmail, BuildContext context) async {
  if (!isCurrentUser(accountEmail)) return;

  User currentUser = FirebaseAuth.instance.currentUser!;
  String currentUserEmail = currentUser.email!;

  final confirmDeletion = await showMyDialog(
    context,
    title: 'This action is irreversible!!!',
    content: 'Are you sure you want to delete your account?',
    showActions: true,
  );

  if (confirmDeletion != true) return;

  // ignore: use_build_context_synchronously
  final password = await inputFromDialog(context, title: 'Confirm Password');

  if (password == null || password == '') return;

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: currentUserEmail,
      password: password,
    );
  } on FirebaseException catch (e) {
    // ignore: use_build_context_synchronously
    await showMyDialog(
      context,
      title: 'Authentication Failed',
      content: e.code.replaceAll('-', ' '),
    );
    return;
  }

  try {
    // delete data from auth
    await currentUser.delete();
    // logout
    await FirebaseAuth.instance.signOut();
  } on FirebaseException catch (error) {
    // ignore: use_build_context_synchronously
    await showMyDialog(
      context,
      title: 'Error',
      content: error.code.replaceAll('-', ' '),
    );
    return;
  }

  try {
    // delete data from storage
    final storage = FirebaseStorage.instance.ref();
    await storage.child('Profile Pictures/$currentUserEmail').delete();
    await storage.child('Profile Thumbnails/$currentUserEmail').delete();
  } on FirebaseException catch (error) {
    if (error.code != 'object-not-found') {
      // ignore: use_build_context_synchronously
      await showMyDialog(
        context,
        title: 'Error',
        content: error.code.replaceAll('-', ' '),
      );
    }
  }

  try {
    // delete data from database
    final database = FirebaseFirestore.instance;
    await database.collection('User Profile').doc(currentUserEmail).delete();
    await database.collection('User Settings').doc(currentUserEmail).delete();
  } on FirebaseException catch (error) {
    if (error.code != 'object-not-found') {
      // ignore: use_build_context_synchronously
      await showMyDialog(
        context,
        title: 'Error',
        content: error.code.replaceAll('-', ' '),
      );
    }
  }
  // ignore: use_build_context_synchronously
  Navigator.of(context).pop();
}

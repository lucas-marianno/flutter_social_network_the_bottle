import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/firebase/is_current_user.dart';
import '../../components/dialog/input_from_modal_bottom_sheet.dart';

void editUsername(String currentUsername, String userEmail, BuildContext context) async {
  if (!isCurrentUser(userEmail)) return;

  final newUsername = await getInputFromModalBottomSheet(
    context,
    title: 'New Username',
    startingString: currentUsername,
    hintText: 'Username',
    maxLength: 35,
  );
  if (newUsername == null || newUsername == currentUsername) return;

  await FirebaseFirestore.instance.collection('User Profile').doc(userEmail).set({
    'username': newUsername,
  }, SetOptions(merge: true));
}

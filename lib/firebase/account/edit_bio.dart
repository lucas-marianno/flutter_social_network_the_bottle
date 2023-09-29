import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../components/dialog/input_from_modal_bottom_sheet.dart';
import '../is_current_user.dart';

void editBio(String currentBio, String userEmail, BuildContext context) async {
  if (!isCurrentUser(userEmail)) return;

  final newBio = await getInputFromModalBottomSheet(
    context,
    title: 'New bio',
    startingString: currentBio,
    hintText: 'Your new bio...',
    enterKeyPressSubmits: false,
    maxLength: 500,
  );

  if (newBio == null || newBio == currentBio) return;
  await FirebaseFirestore.instance.collection('User Profile').doc(userEmail).set({
    'bio': newBio,
  }, SetOptions(merge: true));
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/firebase/is_current_user.dart';
import '../../components/dialog/input_from_modal_bottom_sheet.dart';
import '../../components/dialog/show_dialog.dart';

void editPost(String postId, String opEmail, String currentText, BuildContext context) async {
  // dismiss any keyboard
  FocusManager.instance.primaryFocus?.unfocus();
  if (context.mounted) Navigator.pop(context);

  if (!isCurrentUser(opEmail)) {
    showMyDialog(
      context,
      title: 'Nope!',
      content: 'You cannot edit posts made by someone else',
    );
    return;
  }

  // get new text from user
  String? newPostText = await getInputFromModalBottomSheet(
    context,
    startingString: currentText,
    enterKeyPressSubmits: false,
  );

  if (newPostText == null || newPostText.isEmpty || newPostText == currentText) return;

  // edit post in firebase firestore
  FirebaseFirestore.instance.collection('User Posts').doc(postId).set({
    'Message': newPostText,
    'Edited': true,
  }, SetOptions(merge: true));
}

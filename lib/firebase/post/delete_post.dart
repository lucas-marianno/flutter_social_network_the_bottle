import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/firebase/is_current_user.dart';
import 'package:the_bottle/firebase/post/delete_post_image.dart';
import '../../components/dialog/show_dialog.dart';

Future<void> deletePost(String postId, String opEmail, BuildContext context) async {
  // dismiss any keyboard
  FocusManager.instance.primaryFocus?.unfocus();
  if (context.mounted) Navigator.pop(context);

  if (!isCurrentUser(opEmail)) {
    showMyDialog(context, title: 'Nope!', content: 'You cannot delete posts made by someone else');
    return;
  }

  await deletePostImage(postId);

  // delete comments collection (if they exist)
  try {
    final commentsRef =
        FirebaseFirestore.instance.collection('User Posts').doc(postId).collection('Comments');
    final comments = await commentsRef.get();
    if (comments.docs.isNotEmpty) {
      // delete comments
      for (var comment in comments.docs) {
        comment.reference.delete();
      }
      commentsRef.doc().delete();
    }
  } on Exception {
    // skip
  }

  // delete post from firebase firestore
  await FirebaseFirestore.instance.collection('User Posts').doc(postId).delete();
}

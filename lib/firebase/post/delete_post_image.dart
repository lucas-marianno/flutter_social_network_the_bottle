import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> deletePostImage(String postId) async {
  // deletes imageUrl from post
  await FirebaseFirestore.instance.collection('User Posts').doc(postId).set({
    'Post Picture': null,
  }, SetOptions(merge: true));

  // delete post picture from firebase storage (if it exists)
  try {
    await FirebaseStorage.instance.ref('Post Pictures/$postId').delete();
  } on Exception {
    // skip
  }
}

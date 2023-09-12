import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void likePost(String postId, bool isLiked) {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final postReference = FirebaseFirestore.instance.collection('User Posts').doc(postId);

  if (isLiked) {
    postReference.update({
      'Likes': FieldValue.arrayUnion([currentUser.email]),
    });
  } else {
    postReference.update({
      'Likes': FieldValue.arrayRemove([currentUser.email]),
    });
  }
}

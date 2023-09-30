import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_bottle/firebase/post/add_image_to_post.dart';

void createPost(String text, Uint8List? loadedImage) async {
  if (text.isEmpty && loadedImage == null) return;

  // send post
  final post = await FirebaseFirestore.instance.collection('User Posts').add({
    'UserEmail': FirebaseAuth.instance.currentUser!.email,
    'Message': text,
    'TimeStamp': Timestamp.now(),
    'Likes': [],
  });

  if (loadedImage != null) addImageToPost(post.id, loadedImage);
}

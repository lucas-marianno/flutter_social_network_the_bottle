import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

void createPost(String text, Uint8List? loadedImage) async {
  if (text.isEmpty && loadedImage == null) return;

  // send post
  final post = await FirebaseFirestore.instance.collection('User Posts').add({
    'UserEmail': FirebaseAuth.instance.currentUser!.email,
    'Message': text,
    'TimeStamp': Timestamp.now(),
    'Likes': [],
  });

  if (loadedImage == null) return;

  // upload picture to firebase storage and retrieve download URL
  final String storageUrl =
      await (await FirebaseStorage.instance.ref('Post Pictures/${post.id}').putData(loadedImage))
          .ref
          .getDownloadURL();

  // upload pictureUrl to firebase database
  await FirebaseFirestore.instance.collection('User Posts').doc(post.id).set(
    {'Post Picture': storageUrl},
    SetOptions(merge: true),
  );
}

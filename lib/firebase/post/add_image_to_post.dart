import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> addImageToPost(String postId, Uint8List? image) async {
  if (image == null) return;
  // upload picture to firebase storage and retrieve download URL
  final String storageUrl =
      await (await FirebaseStorage.instance.ref('Post Pictures/$postId').putData(image))
          .ref
          .getDownloadURL();

  // upload pictureUrl to firebase database
  await FirebaseFirestore.instance.collection('User Posts').doc(postId).set(
    {'Post Picture': storageUrl},
    SetOptions(merge: true),
  );
}

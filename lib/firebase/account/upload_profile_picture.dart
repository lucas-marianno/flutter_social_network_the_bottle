import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_bottle/firebase/is_current_user.dart';
import '../../components/list_tile.dart';
import '../../components/dialog/options_modal_bottom_sheet.dart';

void pickAndUploadProfilePicture(String userEmail, BuildContext context) async {
  if (!isCurrentUser(userEmail)) return;

  // prompt user to select camera or gallery
  final ImageSource? imgSource = await optionsFromModalBottomSheet(context, children: [
    MyListTile(
      iconData: Icons.camera,
      text: 'Open camera',
      onTap: () => Navigator.pop(context, ImageSource.camera),
    ),
    MyListTile(
      iconData: Icons.image_search,
      text: 'From gallery',
      onTap: () => Navigator.pop(context, ImageSource.gallery),
    ),
  ]);

  if (imgSource == null) return;

  // retrieve image from user
  final XFile? imgFile = await ImagePicker().pickImage(
    source: imgSource,
    imageQuality: 75,
    maxHeight: 1080,
    maxWidth: 1080,
  );

  if (imgFile == null) return;

  // creates thumbnail
  final image = await imgFile.readAsBytes();
  final thumbnail = await FlutterImageCompress.compressWithList(
    image,
    quality: 50,
    minHeight: 50,
    minWidth: 50,
  );

  // set filename as user email
  final String picturesFilename = 'Profile Pictures/$userEmail';
  final String thumbnailsFilename = 'Profile Thumbnails/$userEmail';

  // upload to storage (handle web)
  final TaskSnapshot imgUploadTask =
      await FirebaseStorage.instance.ref(picturesFilename).putData(image);
  final TaskSnapshot thumbnailUploadTask =
      await FirebaseStorage.instance.ref(thumbnailsFilename).putData(thumbnail);

  // img and thumbnail urls
  final String imgStorageUrl = await imgUploadTask.ref.getDownloadURL();
  final String thumbnailStorageUrl = await thumbnailUploadTask.ref.getDownloadURL();

  // save image download URL to database in UserProfile/picture
  await FirebaseFirestore.instance.collection('User Profile').doc(userEmail).set(
      {'pictureUrl': imgStorageUrl, 'thumbnailUrl': thumbnailStorageUrl}, SetOptions(merge: true));
}

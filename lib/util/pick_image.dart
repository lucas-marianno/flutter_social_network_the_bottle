import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_bottle/components/dialog/options_modal_bottom_sheet.dart';
import 'package:the_bottle/components/list_tile.dart';

Future<Uint8List?> pickImage(BuildContext context) async {
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

  if (imgSource == null) return null;

  // retrieve image from user
  final img = await ImagePicker().pickImage(
    source: imgSource,
    imageQuality: 75,
    maxHeight: 1080,
    maxWidth: 1080,
  );

  if (img == null) return null;

  return await img.readAsBytes();
}

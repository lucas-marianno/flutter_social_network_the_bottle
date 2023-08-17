import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_wall/components/textfield.dart';

import '../pages/image_visualizer_page.dart';
import 'list_tile.dart';
import 'options_modal_bottom_sheet.dart';

class InputField extends StatefulWidget {
  const InputField({super.key, required this.postMessageFunction});
  final void Function(String text, Uint8List? loadedImage)? postMessageFunction;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  final TextEditingController textEditingController = TextEditingController();
  Uint8List? loadedImage;

  void selectImage() async {
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
    final img = await ImagePicker().pickImage(
      source: imgSource,
      imageQuality: 75,
      maxHeight: 1080,
      maxWidth: 1080,
    );

    if (img == null) return;

    loadedImage = await img.readAsBytes();

    setState(() {});
  }

  void unSelectImage() {
    setState(() => loadedImage = null);
  }

  void viewSelectedImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageVisualizerPage(image: loadedImage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // post message
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          color: Theme.of(context).colorScheme.surface,
          height: 32,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 10),
          child: Row(
            children: [
              // preview of loaded image
              if (loadedImage == null)
                Container()
              else
                GestureDetector(
                  onTap: viewSelectedImage,
                  onLongPress: unSelectImage,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.memory(loadedImage!, fit: BoxFit.cover),
                  ),
                ),
              loadedImage == null ? Container() : const SizedBox(width: 10),
              // input textfield
              // TODO: Bugfix: either put a character limit or find a way to scroll through
              // the written text. (Check Kazu's video message for details)
              Expanded(
                child: MyTextField(
                  controller: textEditingController,
                  hintText: loadedImage == null ? 'Write your post' : 'Write your description',
                  onSubmited: () =>
                      widget.postMessageFunction?.call(textEditingController.text, loadedImage),
                  autofocus: false,
                ),
              ),
              // post image button
              IconButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  selectImage();
                },
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 38),
              ),
              // post text button
              IconButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.postMessageFunction?.call(textEditingController.text, loadedImage);
                },
                icon: Icon(loadedImage == null ? Icons.post_add : Icons.send, size: 40),
              ),
            ],
          ),
        ),
        // logged in as
        Text(
          'Logged in as ${FirebaseAuth.instance.currentUser!.email}',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_bottle/components/textfield.dart';
import '../pages/image_visualizer_page.dart';
import 'list_tile.dart';
import 'options_modal_bottom_sheet.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    required this.onSendTap,
    this.dismissKeyboardOnSend = true,
  });
  final void Function(String text, Uint8List? loadedImage)? onSendTap;
  final bool dismissKeyboardOnSend;

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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // preview of loaded image
                loadedImage == null
                    ? Container()
                    : GestureDetector(
                        onTap: viewSelectedImage,
                        onLongPress: unSelectImage,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.memory(loadedImage!, fit: BoxFit.cover),
                        ),
                      ),
                loadedImage == null ? Container() : const SizedBox(width: 10),
                // add image button
                loadedImage != null
                    ? Container()
                    : IconButton(
                        icon: const Icon(Icons.add_photo_alternate, size: 38),
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          selectImage();
                        },
                      ),
                // input textfield
                Expanded(
                  child: MyTextField(
                    controller: textEditingController,
                    maxLength: 500,
                    hintText: loadedImage == null ? 'Write your post' : 'Write your description',
                    onChanged: () => setState(() {}),
                    onSubmited: () {
                      widget.onSendTap?.call(textEditingController.text, loadedImage);
                      unSelectImage();
                    },
                    autofocus: false,
                  ),
                ),

                // post text button
                textEditingController.text.isEmpty && loadedImage == null
                    ? Container()
                    : IconButton(
                        icon: const Icon(Icons.send, size: 40),
                        onPressed: () {
                          if (widget.dismissKeyboardOnSend) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                          widget.onSendTap?.call(textEditingController.text, loadedImage);
                          textEditingController.clear();
                          unSelectImage();
                        },
                      ),
              ],
            ),
          ),
          // logged in as
        ],
      ),
    );
  }
}

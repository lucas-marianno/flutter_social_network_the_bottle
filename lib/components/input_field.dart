import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/textfield.dart';
import 'package:the_bottle/util/pick_image.dart';
import '../pages/image_visualizer_page.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    required this.onSendTap,
    this.dismissKeyboardOnSend = true,
    this.enterKeyPressSubmits = false,
    this.hintText,
    this.textEditingController,
  });
  final void Function(String text, Uint8List? loadedImage)? onSendTap;
  final bool dismissKeyboardOnSend;
  final bool enterKeyPressSubmits;
  final String? hintText;
  final TextEditingController? textEditingController;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late final TextEditingController textEditingController;
  Uint8List? loadedImage;

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
  void initState() {
    textEditingController = widget.textEditingController ?? TextEditingController();
    super.initState();
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
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          loadedImage = await pickImage(context);
                          setState(() {});
                        },
                      ),
                // input textfield
                Expanded(
                  child: MyTextField(
                    controller: textEditingController,
                    maxLength: 500,
                    hintText: widget.hintText ??
                        (loadedImage == null ? 'Write your post' : 'Write your description'),
                    onChanged: () => setState(() {}),
                    onSubmited: () {
                      widget.onSendTap?.call(textEditingController.text, loadedImage);
                      unSelectImage();
                      textEditingController.clear();
                    },
                    autofocus: false,
                    enterKeyPressSubmits: widget.enterKeyPressSubmits,
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

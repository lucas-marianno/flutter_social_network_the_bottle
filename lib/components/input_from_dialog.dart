import 'package:flutter/material.dart';
import 'package:the_bottle/components/textfield.dart';

Future<dynamic> inputFromDialog(
  BuildContext context, {
  String? title,
}) async {
  final controller = TextEditingController();
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title != null ? Center(child: Text(title)) : null,
      content: MyTextField(
        controller: controller,
        hintText: 'password',
        obscureText: true,
        autofocus: true,
        enterKeyPressSubmits: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text(
            'OK',
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:the_wall/components/textfield.dart';

Future<String?> getInputFromDialog(
  BuildContext context, {
  required String startingString,
  required String title,
  String? hintText,
}) async {
  TextEditingController controller = TextEditingController();
  controller.text = startingString;

  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[200],
      title: Center(child: Text(title)),
      content: MyTextField(
        controller: controller,
        hintText: hintText ?? '',
        onSubmited: () {
          Navigator.pop(context, controller.text);
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
          child: const Text('Ok'),
        )
      ],
    ),
  );
}

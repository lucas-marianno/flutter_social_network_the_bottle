import 'package:flutter/material.dart';
import 'package:the_wall/components/textfield.dart';

Future<String?> getInputFromDialog(
  BuildContext context, {
  String? title,
  String hintText = '',
  String startingString = '',
  String submitButtonLabel = 'Ok',
}) async {
  TextEditingController controller = TextEditingController();
  controller.text = startingString;

  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[200],
      title: title == null ? null : Center(child: Text(title)),
      content: MyTextField(
        controller: controller,
        hintText: hintText,
        onSubmited: () {
          Navigator.pop(context, controller.text);
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
          child: Text(submitButtonLabel),
        )
      ],
    ),
  );
}

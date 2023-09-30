import 'dart:math';

import 'package:flutter/material.dart';
import 'package:the_bottle/components/textfield.dart';

Future<String?> getInputFromModalBottomSheet(
  BuildContext context, {
  String? title,
  String? hintText,
  String startingString = '',
  bool enterKeyPressSubmits = true,
  int? maxLength,
}) async {
  TextEditingController controller = TextEditingController();
  controller.text = startingString;

  return await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 15,
          left: 15,
          right: 15,
          top: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            const Flexible(
              child: Divider(
                height: 30,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: max(100, MediaQuery.of(context).viewInsets.bottom - 50),
                    child: MyTextField(
                      controller: controller,
                      hintText: hintText,
                      enterKeyPressSubmits: enterKeyPressSubmits,
                      maxLength: maxLength,
                      onSubmited: () => Navigator.of(context).pop(controller.text),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(controller.text),
                  icon: const Icon(
                    Icons.send,
                    size: 40,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      );
    },
  );
}

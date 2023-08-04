import 'package:flutter/material.dart';
import 'package:the_wall/components/textfield.dart';

Future<String?> getInputFromModalBottomSheet(
  BuildContext context, {
  String? title,
  String? hintText,
  String startingString = '',
  bool enterKeyPressSubmits = true,
}) async {
  TextEditingController controller = TextEditingController();
  controller.text = startingString;

  return await showModalBottomSheet(
    backgroundColor: Colors.grey[900],
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
              child: Text(title ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[300], fontSize: 20)),
            ),
            Flexible(child: Divider(color: Colors.grey[700], height: 30)),
            Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: controller,
                    hintText: hintText,
                    enterKeyPressSubmits: enterKeyPressSubmits,
                    onSubmited: () => Navigator.of(context).pop(controller.text),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(controller.text),
                  icon: Icon(Icons.send, color: Colors.grey[300], size: 40),
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

import 'package:flutter/material.dart';

Future<dynamic> showMyDialog(
  BuildContext context, {
  String? title,
  String? content,
  bool showActions = false,
}) async {
  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: title != null ? Text(title) : null,
      content: content != null
          ? Text(content, textAlign: TextAlign.justify, style: const TextStyle(fontSize: 16))
          : null,
      actions: !showActions
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'OK',
                ),
              ),
            ],
    ),
  );
}

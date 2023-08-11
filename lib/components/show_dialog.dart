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
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: title != null ? Center(child: Text(title)) : null,
      content: content != null ? Text(content, style: const TextStyle(fontSize: 16)) : null,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
      ],
    ),
  );
}

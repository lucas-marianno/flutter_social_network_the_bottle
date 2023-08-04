import 'package:flutter/material.dart';

Future<void> showMyDialog(BuildContext context, {String? title, String? content}) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: title != null ? Center(child: Text(title)) : null,
      content: content != null ? Text(content, style: const TextStyle(fontSize: 16)) : null,
    ),
  );
}

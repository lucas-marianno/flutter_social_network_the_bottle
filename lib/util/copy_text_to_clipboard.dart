import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> copyTextToClipboard(String text, BuildContext context) async {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text(
        'Text copied to clipboard',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 10,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_bottle/components/dialog/show_snackbar.dart';

Future<void> copyTextToClipboard(String text, BuildContext context) async {
  if (text.isEmpty) return;
  Clipboard.setData(ClipboardData(text: text));
  showMySnackBar(context, 'Text copied to clipboard');
}

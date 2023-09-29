import 'package:flutter/material.dart';

void showMySnackBar(context, String text) {
  if (text.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 10,
    ),
  );
}

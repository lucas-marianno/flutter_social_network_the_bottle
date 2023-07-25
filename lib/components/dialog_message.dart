import 'package:flutter/material.dart';

class MessageDialog extends StatelessWidget {
  const MessageDialog(this.context, this.message, {super.key});

  final String message;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.white, width: 5)),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

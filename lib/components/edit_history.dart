import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../util/timestamp_to_string.dart';

class EditHistory extends StatelessWidget {
  const EditHistory({
    super.key,
    required this.previousText,
    required this.newText,
    required this.timestamp,
  });

  final String previousText;
  final String newText;
  final Timestamp timestamp;

  @override
  Widget build(BuildContext context) {
    //TODO: finish implemeting EditHistory
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('before'),
        Text(previousText),
        const Text('after'),
        Text(newText),
        const Text('Modified at'),
        Text(timestampToString(timestamp)),
        const Text(''),
      ],
    );
  }
}

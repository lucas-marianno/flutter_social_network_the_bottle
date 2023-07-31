import 'package:flutter/material.dart';

Future<dynamic> optionsFromModalBottomSheet(
  BuildContext context, {
  required List<Widget> children,
}) async {
  return await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.grey[900],
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Column(children: children),
      );
    },
  );
}

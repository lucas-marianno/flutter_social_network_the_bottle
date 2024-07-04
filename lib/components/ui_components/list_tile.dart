import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  const MyListTile({
    super.key,
    required this.iconData,
    required this.text,
    required this.onTap,
    this.reverseColors = false,
  });
  final IconData iconData;
  final String text;
  final Function()? onTap;
  final bool reverseColors;

  @override
  Widget build(BuildContext context) {
    if (reverseColors) {
      return ListTile(
        leading: Icon(iconData),
        title: Text(text),
        onTap: onTap,
      );
    }

    return ListTile(
      leading: Icon(iconData),
      title: Text(text),
      onTap: onTap,
    );
  }
}

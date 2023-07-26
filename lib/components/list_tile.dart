import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  const MyListTile({
    super.key,
    required this.iconData,
    required this.text,
    required this.onTap,
  });
  final IconData iconData;
  final String text;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      iconColor: Colors.grey[200],
      textColor: Colors.grey[200],
      leading: Icon(iconData),
      title: Text(text),
      onTap: onTap,
    );
  }
}

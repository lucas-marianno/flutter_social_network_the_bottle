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
      iconColor: Theme.of(context).colorScheme.onPrimary,
      textColor: Theme.of(context).colorScheme.onPrimary,
      leading: Icon(iconData),
      title: Text(text),
      onTap: onTap,
    );
  }
}

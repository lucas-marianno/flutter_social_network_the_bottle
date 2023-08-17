import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/profile_picture.dart';
import 'package:the_wall/components/username.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.userEmail,
    required this.onTap,
    required this.seen,
    required this.lastUpdated,
    this.reverseColors = false,
  });

  final String userEmail;
  final Function()? onTap;
  final bool reverseColors;
  final bool seen;
  final Timestamp lastUpdated;

  @override
  Widget build(BuildContext context) {
    final Color color = reverseColors
        ? Theme.of(context).colorScheme.onBackground
        : Theme.of(context).colorScheme.onPrimary;

    return ListTile(
      iconColor: color,
      textColor: color,
      leading: ProfilePicture(profileEmailId: userEmail),
      title: Username(userEmail: userEmail),
      trailing: seen ? null : Icon(Icons.info, color: color),
      onTap: onTap,
    );
  }
}

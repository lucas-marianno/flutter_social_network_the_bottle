import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/profile_picture.dart';
import 'package:the_bottle/components/username.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.userEmail,
    required this.onTap,
    required this.seen,
    required this.lastUpdated,
    this.reverseColors = false,
    this.onLongPress,
  });

  final String userEmail;
  final Function()? onTap;
  final bool reverseColors;
  final bool seen;
  final Timestamp lastUpdated;
  final Function()? onLongPress;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ProfilePicture(profileEmailId: userEmail),
      title: Username(userEmail: userEmail),
      trailing: seen ? null : const Icon(Icons.info),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

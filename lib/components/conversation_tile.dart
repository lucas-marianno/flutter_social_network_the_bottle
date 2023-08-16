import 'package:flutter/material.dart';
import 'package:the_wall/components/profile_picture.dart';
import 'package:the_wall/components/username.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.userEmail,
    required this.onTap,
    this.reverseColors = false,
  });

  final String userEmail;
  final Function()? onTap;
  final bool reverseColors;

  @override
  Widget build(BuildContext context) {
    if (reverseColors) {
      return ListTile(
        iconColor: Theme.of(context).colorScheme.onBackground,
        textColor: Theme.of(context).colorScheme.onBackground,
        leading: ProfilePicture(profileEmailId: userEmail),
        title: Username(userEmail: userEmail),
        onTap: onTap,
      );
    }

    return ListTile(
      iconColor: Theme.of(context).colorScheme.onPrimary,
      textColor: Theme.of(context).colorScheme.onPrimary,
      leading: ProfilePicture(profileEmailId: userEmail),
      title: Username(userEmail: userEmail),
      onTap: onTap,
    );
  }
}

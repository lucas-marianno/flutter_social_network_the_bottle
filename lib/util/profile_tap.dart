import 'package:flutter/material.dart';
import 'package:the_bottle/components/username.dart';
import 'package:the_bottle/firebase/is_current_user.dart';
import 'package:the_bottle/firebase/post/message_op.dart';
import '../pages/profile_page.dart';
import 'package:the_bottle/components/dialog/options_modal_bottom_sheet.dart';

void profileTap(BuildContext context, String profileEmail, {String? heroTag}) {
  optionsFromModalBottomSheet(
    context,
    children: [
      isCurrentUser(profileEmail)
          ? const SizedBox()
          : ListTile(
              onTap: () => messageOriginalPoster(profileEmail, context),
              leading: const Icon(Icons.message),
              title: Row(
                children: [
                  const Text(
                    'Message ',
                  ),
                  Username(
                    userEmail: profileEmail,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
      ListTile(
        onTap: () {
          // Go to profile
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                userEmail: profileEmail,
                heroTag: heroTag,
              ),
            ),
          );
        },
        leading: const Icon(Icons.person),
        title: const Text(
          'View Profile',
        ),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:the_bottle/components/profile_picture.dart';
import 'package:the_bottle/components/dialog/show_dialog.dart';
import 'package:the_bottle/components/username.dart';
import '../pages/profile_page.dart';

void showLikesList(context, List? likesList) {
  if (likesList == null || likesList.isEmpty) {
    showMyDialog(context, title: 'Likes', content: 'No one liked this yet');
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Likes'),
        content: SizedBox(
          width: double.maxFinite,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height / 2,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: likesList.length,
              itemBuilder: (context, index) {
                final userEmail = likesList[index].toString();
                return ListTile(
                  leading: ProfilePicture(profileEmailId: userEmail),
                  title: Username(userEmail: userEmail),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(userEmail: userEmail),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

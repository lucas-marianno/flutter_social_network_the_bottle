import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/profile_picture.dart';
import 'package:the_bottle/components/username.dart';
import 'package:the_bottle/firebase/is_current_user.dart';
import 'package:the_bottle/firebase/post/message_op.dart';
import 'package:the_bottle/util/copy_text_to_clipboard.dart';
import '../firebase/post/delete_post.dart';
import '../firebase/post/edit_post.dart';
import '../pages/profile_page.dart';
import '../util/timestamp_to_string.dart';
import 'options_modal_bottom_sheet.dart';

class WallPostHeader extends StatefulWidget {
  const WallPostHeader({
    super.key,
    required this.postText,
    required this.postId,
    required this.opEmail,
    required this.postTimeStamp,
    this.isEdited = false,
    this.isFullScreen = false,
  });
  final String postText;
  final String postId;
  final String opEmail;
  final Timestamp postTimeStamp;
  final bool isEdited;
  final bool isFullScreen;

  @override
  State<WallPostHeader> createState() => _WallPostHeaderState();
}

class _WallPostHeaderState extends State<WallPostHeader> {
  void profileTap() {
    optionsFromModalBottomSheet(
      context,
      children: [
        isCurrentUser(widget.opEmail)
            ? Container()
            : ListTile(
                onTap: () => messageOriginalPoster(widget.opEmail, context),
                leading: const Icon(Icons.message),
                title: Row(
                  children: [
                    const Text(
                      'Message ',
                    ),
                    Username(
                      userEmail: widget.opEmail,
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
                  userEmail: widget.opEmail,
                  heroTag: widget.postId,
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

  void postOptions() {
    if (widget.isFullScreen) return;
    optionsFromModalBottomSheet(
      context,
      children: [
        ListTile(
          onTap: () => editPost(widget.postId, widget.opEmail, widget.postText, context),
          leading: const Icon(Icons.edit),
          title: const Text(
            'Edit post',
          ),
        ),
        ListTile(
          onTap: () => deletePost(widget.postId, widget.opEmail, context),
          leading: const Icon(Icons.delete),
          title: const Text(
            'Delete post',
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pop();
            copyTextToClipboard(widget.postText, context);
          },
          leading: const Icon(Icons.copy),
          title: const Text(
            'Copy post text',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // profile thumbnail
        ProfilePicture(
          profileEmailId: widget.opEmail,
          size: ProfilePictureSize.small,
          onTap: profileTap,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // username
            Username(
              userEmail: widget.opEmail,
              onTap: profileTap,
            ),
            // timestamp
            Text(
              timestampToString(widget.postTimeStamp),
            )
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // more
            isCurrentUser(widget.opEmail)
                ? Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: postOptions, child: const Icon(Icons.more_horiz)))
                : Container(),
            // edited flag
            Text(
              widget.isEdited ? 'edited' : '',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

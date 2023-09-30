import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/profile_picture.dart';
import 'package:the_bottle/components/username.dart';
import 'package:the_bottle/firebase/is_current_user.dart';
import 'package:the_bottle/firebase/post/add_image_to_post.dart';
import 'package:the_bottle/firebase/post/delete_post_image.dart';
import 'package:the_bottle/util/copy_text_to_clipboard.dart';
import 'package:the_bottle/util/pick_image.dart';
import 'package:the_bottle/util/profile_tap.dart';
import '../firebase/post/delete_post.dart';
import '../firebase/post/edit_post.dart';
import '../util/timestamp_to_string.dart';
import 'package:the_bottle/components/dialog/options_modal_bottom_sheet.dart';

class WallPostHeader extends StatefulWidget {
  const WallPostHeader({
    super.key,
    required this.postText,
    required this.postId,
    required this.opEmail,
    required this.postTimeStamp,
    this.isEdited = false,
    this.isFullScreen = false,
    this.hasImage = false,
  });
  final String postText;
  final String postId;
  final String opEmail;
  final Timestamp postTimeStamp;
  final bool isEdited;
  final bool isFullScreen;
  final bool hasImage;

  @override
  State<WallPostHeader> createState() => _WallPostHeaderState();
}

class _WallPostHeaderState extends State<WallPostHeader> {
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
          onTap: () async {
            Navigator.of(context).pop();
            if (!widget.hasImage) {
              addImageToPost(widget.postId, await pickImage(context));
            } else {
              deletePostImage(widget.postId);
            }
          },
          leading: Icon(widget.hasImage ? Icons.image_not_supported : Icons.image_search),
          title: Text(
            widget.hasImage ? 'Delete image' : 'Add an image to post',
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
          onTap: () => profileTap(context, widget.opEmail),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // username
            Username(
              userEmail: widget.opEmail,
              onTap: () => profileTap(context, widget.opEmail),
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
